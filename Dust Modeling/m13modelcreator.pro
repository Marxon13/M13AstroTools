;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13ModelCreator
;
; PURPOSE:
; Generates a model of the target star using the standard star plus other parameters.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13modelcreator, targetData, standardData, saveFolder, targetName, standardName, targetObservationDate, t, dustnorm, beta, starnorm, TargetScale = targetScale, OMITDATE = omitDate, BOXCARONLY = boxcarOnly, GAUSSIANONLY = gausianOnly, DETAILPLOTONLY = detailPlotOnly, FULLPLOTONLY = fullPlotOnly
;
; INPUTS:
; targetData: The fits file that contains the spectral data for the target star. Input is the full file path.
; standardData: The fits file that contains the spectral data for the standard star. Input is the full file path.
; saveFolder: The folder to place all the model save files and plots. Input is the full file path.
; targetName: The name of the target star as a string.
; standardName: The name of the standard star as a string.
; targetObservationDate: The date the target star was observed as a string.
; t: The temprature of the dust needed to get the model to match the target star spectrum.
; dustNorm: The dust norm needed to get the model to match the target star spectrum.
; beta: The beta needed to get the model to match the target star spectrum.
; starNorm: The star norm needed to get the model to match the target star spectrum.
; targetScale: The amount to scale the target data by. This scaling is usually the scaling required to get the input target data to match the flux of its prism data companion.
;
; KEYWORD PARAMETERS:
; OMITDATE: Set this keyword to not include the targetObservationDate in the plot.
; BOXCARONLY: Set this keyword to only use boxcar smoothing.
; GAUSSIANONLY: Set this keyword to only use gaussian smoothing.
; DETAILPLOTONLY: Set this keyword to only create the detail plots.
; FULLPLOTONLY: Set this keyword to only create the full plots.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-

;Finds the minimum y value in the given domain
function minimumInRange, xArr, yArr, xrange

  ;Find Y Minimum
  xminbin = value_locate(xArr, xrange[0])
  xmaxbin = value_locate(xArr, xrange[1])
  ;Catch if a value is not found
  if xminbin eq -1 then begin
    xminbin = 0
  endif
  if xmaxbin eq -1 then begin
    xmaxbin = size(xarr, /n_dimensions)
  endif
  ;Trim fstar to this sub array
  yarray = yArr[xminbin : xmaxbin]
  ;Find the minimum value
  ymin = min(yarray)

  return, ymin

end

;Find the minimum of three value sets in the given domain
function minimumInArraysInRange, x1, y1, x2, y2, x3, y3, xrange

  ;Find Y Minimums
  ymin1 = minimumInRange(x1, y1, xrange)
  ymin2 = minimumInRange(x2, y2, xrange)
  ymin3 = minimumInRange(x3, y3, xrange)

  return, min([ymin1, ymin2, ymin3])

end

;Find the maximum y value in the given domain
function maximumInRange, xArr, yArr, xrange

;Find Y Maximum
xminbin = value_locate(xArr, xrange[0])
xmaxbin = value_locate(xArr, xrange[1])
;Catch if a value is not found
if xminbin eq -1 then begin
  xminbin = 0;
endif
if xmaxbin eq -1 then begin
  xmaxbin = size(xmaxbin, /n_dimensions)
endif
;Trim fstar to this sub array
yarray = yArr[xminbin : xmaxbin]
;Find the minimum value
ymax = max(yarray)

return, ymax
end

;find the maximum of three value sets in the given domain
function maximumInArraysInRange, x1, y1, x2, y2, x3, y3, xrange

  ;Find Y Minimums
  ymin1 = maximumInRange(x1, y1, xrange)
  ymin2 = maximumInRange(x2, y2, xrange)
  ymin3 = maximumInRange(x3, y3, xrange)

  return, max([ymin1, ymin2, ymin3])

end

pro m13modelcreator, targetData, standardData, saveFolder, targetName, standardName, targetObservationDate, t, dustnorm, beta, starnorm, targetScale, OMITDATE = omitDate, BOXCARONLY = boxcarOnly, GAUSSIANONLY = gausianOnly, DETAILPLOTONLY = detailPlotOnly, FULLPLOTONLY = fullPlotOnly, KEEPPLOTSOPEN = keepPlotOpen

print, 'Creating model for star: ' + targetName + ' - ' + targetObservationDate
;---------------Constants---------------
;Axis titles
xtitle = '$\lambda (\mu m)$'
ytitle = '$\lambda F!D\lambda !N (\lambda W m!E-2!N \mu !5m!E-1!N)$'

;The minimum and maximum amount of smoothing
amountMin = 0
amountMax = 10

;---------------Read Data---------------

; Read in the data for the Target
print, '  Loading target data....'
a = readfits(targetData)
w = a(*, 0)
f = a(*, 1)
e = a(*, 2)
wTarget = w
lflTarget = w * f * targetScale
elflTarget = w * e * targetScale
print, '  Loaded'

; Now read in the spectrum of the spectral standard star
print, '  Loading sandard data...'
a = readfits(standardData)
w = a(*, 0)
f = a(*, 1)
e = a(*, 2)
wStandard = w
lflStandard = w * f
elflStandard = w * e

;---------------Process Data---------------

; Regrid the wavelengths so the two have the same wavelengths
b = elflStandard
d = elflStandard
gridterp, wTarget, wStandard, lflStandard, elflStandard, b, d

; Scale the standard to match the science target at the shortest wavelengths,
; that's where the dust emission will be smallest, since the dust is cooler than the stars
lflStandard = lflStandard * starnorm
elflStandard = elflStandard * starnorm
print, '  Loaded'


;---------------Looping-----------------

; Iterate over the smooth types: boxcar (0), gaussian (1)
for smoothType = 0, 1 do begin
  
  ; Skip unnecessary steps
  if keyword_set(boxcarOnly) and smoothType eq 1 then begin
    continue
  endif
  if keyword_set(gaussianOnly) and smoothType eq 0 then begin
    continue
  endif
  
  ; Iterate over the smooth amounts
  for smoothAmount = amountMin, amountMax do begin
    
    ; Iterate over the plot types: detail (0), full (1)
    for plotType = 0, 1 do begin
      
      ; Skip unnessary steps
      if keyword_set(detailPlotOnly) and smoothType eq 1 then begin
        continue
      endif
      if keyword_set(fullPlotOnly) and smoothType eq 0 then begin
        continue
      endif
      
      print, '  Begin plotting...'
      
      ; Create the plot
      
      ; Plot title
      plotTitle = targetName
      if  keyword_set(omitDate) eq 0 then plotTitle = plotTitle + ' - ' + targetObservationDate
      
      ;Create the plot base
      if plotType eq 0 then begin
        thePlot = m13plotlogbox(0.8, 1.1, 7.0e-13, 3.0e-12, plotTitle, xtitle, ytitle, [1280, 800])
        print, '    Creating detail plot...'
      endif
      if plotType eq 1 then begin
        thePlot = m13plotlogbox(0.7, 7.0, 1.0e-13, 5.0e-12, plotTitle, xtitle, ytitle, [1280, 800])
        print, '    Creating full plot...'
      endif
      
      ; Smooth the standard star spectrum to match that of the science target
      ; standard usually observed with 0.3 acrsec slit, while I usually have 0.8 arcsec.
      smoothDescription = ''
      if smoothAmount ne 0 then begin
        
        if smoothType eq 0 then begin
          lflTemp = smooth(lflStandard, smoothAmount, /NAN)
          smoothDescription = 'Boxcar ' + strcompress(smoothAmount)
        endif
        
        if smoothType eq 1 then begin
          convolvespec, wStandard, lflStandard, (smoothAmount) * 0.000232995, lflTemp
          smoothDescription = 'Gaussian ' + strcompress(smoothAmount)
        endif
        
      endif else begin
        lflTemp = lflStandard
        smoothDescription = 'No Smoothing'
      endelse
      
      print, '    ' + smoothDescription
      
      ; Plot the science target data
      print, '    Plotting target...'
      targetwlfl = plot(wTarget, lflTarget, color = "red", thick = 1.0, name = targetName, /overplot)
      
      ; plot the standard star
      print, '    Plotting standard...'
      standardwlfl = plot(wStandard, lflStandard, /overplot, color = 'black', thick = 1.0, name = standardName)
      
      ; Calculate the planckian spectrum
      ; t is the temperature
      ; norm is a normalizing scale factor
      ; beta can act as a dust emissivity, but here I am using it as a way to simulate
      ; a range of temperatures
      ; this will be added to the standard star spectrum
      ; adjust t, norm, and beta to match the SED plot of the science target
      print, '    Creating model...'
      n = n_elements(wStandard)
      fbb = fltarr(n)
      FBB(*) = (dustnorm) / (wStandard(*)^4) * (1. / (exp(1.4388e4 / (t * wStandard(*))) - 1.))
      fbb = fbb * wStandard^beta
      net = lflTemp + fbb
      print, '    Created'
      print, '    Plotting model...'
      plot1 = plot(wStandard, fbb, /overplot, color = 'blue', thick = 1.0, name = "Dust Emission")
      plot2 = plot(wStandard, net, /overplot, color = 'green', thick = 1.0, name = "Photosphere + Dust")
      
      ;Change names fot the save file
      wModel = wStandard
      lflModel = net
      elflModel = elflStandard
      
      ;Update the plot ranges
      ymaximum = maximumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, thePlot.xrange)
      yminimum = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, thePlot.xrange)
      ;Check for nan
      if finite(yminimum) eq 0 then begin
        yrange = thePlot.yrange
        yminimum = yrange[0]
      endif
      thePlot.yrange = [yminimum - (yminimum / 10.0), ymaximum + (ymaximum / 10.0)]
      
      ;Add plot labels if necessary
      if plotType eq 0 then begin
        print, '    Adding plot labels...'
        
        ; Ca II
        print, '    Ca II...'
        
        ymin1 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.8476, .8520])
        ymin2 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.8520, .8564])
        ymin3 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.8640, .8684])
        ymin = min([ymin1, ymin2, ymin3])
        
        x = [0.8498, 0.8498]
        y = [ymin1 - (ymin1 / 20.0), ymin - (ymin / 20.0)]
        line1 = Polyline(x, y, /data, target = plot, color = "magenta", thick = 1.0)
        
        x = [0.8542,0.8542]
        y = [ymin2 - (ymin2 / 20.0), ymin - (ymin / 20.0)]
        line2 = Polyline(x, y, /data, target = plot, color = "magenta", thick = 1.0)
        
        x = [0.8662,0.8662]
        y = [ymin3 - (ymin3 / 20.0), ymin - (ymin / 20.0)]
        line3 = Polyline(x, y, /data, target = plot, color = "magenta", thick = 1.0)
        
        text1 = text(0.852, ymin - (ymin / 20.0) - (ymin / 10.0), 'Ca II', /data, font_name = 'Helvetica', font_size=14, color = "magenta")

        ; [O I]
        print, '    [O I]...'
        
        ymin = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.8424, .8468])
 
        x=[0.8446,0.8446]
        y = [ymin - (ymin / 10.0), ymin - (ymin / 20.0)]
        line4 = Polyline(x, y, /data, target = plot, color = "teal", thick = 1.0)
        text2 = text(0.83, ymin - (ymin / 10.0) - (ymin / 20.0), '[O I]', /data, font_name = 'Helvetica', font_size=14, color = "teal")

        ; H I
        print, '    H I...'
        
        ymin1 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.8843, .8865]) ;11
        ymin2 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.8995, .9039]) ;10
        ymin3 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.9209, .9253]) ;9
        ymin4 = minimumInArraysInRange(wModel, lflModel, wStandard, lflStandard, wTarget, lflTarget, [0.9526, .9570]) ;e
        ymin = min([ymin1, ymin2, ymin3, ymin4])
        
        x=[0.8865, 0.8865]
        y = [ymin1 - (ymin1 / 20.0), ymin - (ymin / 10.0)]
        line4 = Polyline(x, y, /data, target = plot, color = "purple", thick = 1.0)
        text2 = text(0.882, ymin - (ymin / 10.0) - (ymin / 10.0), '11', /data, font_name = 'Helvetica', font_size=14, color = "purple")

        x=[0.9017, 0.9017]
        y = [ymin2 - (ymin2 / 20.0), ymin - (ymin / 10.0)]
        line4 = Polyline(x, y, /data, target = plot, color = "purple", thick = 1.0)
        text2 = text(0.897, ymin - (ymin / 10.0) - (ymin / 10.0), '10', /data, font_name = 'Helvetica', font_size=14, color = "purple")
        
        x=[0.9231, 0.9231]
        y = [ymin3 - (ymin3 / 20.0), ymin - (ymin / 10.0)]
        line4 = Polyline(x, y, /data, target = plot, color = "purple", thick = 1.0)
        text2 = text(0.922, ymin - (ymin / 10.0) - (ymin / 10.0), '9', /data, font_name = 'Helvetica', font_size=14, color = "purple")
        
        x=[0.9548, 0.9548]
        y = [ymin4 - (ymin4 / 20.0), ymin - (ymin / 10.0)]
        line4 = Polyline(x, y, /data, target = plot, color = "purple", thick = 1.0)
        text2 = text(0.953, ymin - (ymin / 10.0) - (ymin / 10.0), cggreek('epsilon', /ps), /data, font_name = 'Helvetica', font_size=14, color = "purple")

        text3 = text(.90, ymin - (ymin / 5.0) - (ymin / 10.0) , 'H I Paschen', /data, font_name = 'Helvetica', font_size=14, color = "purple")
        
        print, '    Completed labeling'
      endif
      
      if plotType eq 1 then begin
        print, '    Creating legend...'
        thelegend = legend(target = [targetwlfl, standardwlfl, plot1, plot2], $
          position = [thePlot.xrange[1] - 0.6, ymaximum - (ymaximum / 10.0)], /data, /auto_text_color, font_name = 'Helvetica', font_size=14, horizontal_spacing = .05, shadow = 0, linestyle = 6, sample_width = 0.0)
      endif
      
      ; Generate the save file path
      print, '    Generating save file path'
      plotTypeString = ""
      if plotType eq 0 then plotTypeString = "DetailPlot"
      if plotType eq 1 then plotTypeString = "FullPlot"

      smoothString = ""
      amountString = ""
      if smoothAmount ne 0 then begin
        if smoothType eq 0 then smoothString = "_Boxcar"
        if smoothType eq 1 then smoothString = "_Gaussian"
        amountString = strcompress(smoothAmount, /remove_all)
      endif

      outputFile = saveFolder + '/' + targetName + smoothString + amountString
      
      print, '    Saving data...'
      
      ; Save the data
      save, filename=(outputFile + '_modelParameters.sav'), t, dustnorm, beta, starnorm, wmodel, lflmodel, elflmodel, wTarget, lflTarget, elflTarget, smoothDescription, targetName, targetObservationDate
      ; Save the plot
      outputFile = outputFile  + "_" + plotTypeString
      thePlot.save, (outputFile + '.pdf'), /close, width = 11, height = 8.5, /Landscape
      if keyword_Set(keepPlotOpen) eq 0 then thePlot.close
      
      print, '    Saving complete...'
      
    endfor
  endfor
endfor

print, '  Finished Plotting'
print, '  Begin ploting comparison...'


;---------------Comparison---------------

;Calculate the number of plots I need to compare
numberOfPlots = (amountMax - amountMin + 1)
plotHeight = (.3 * numberOfPlots) + .1

;Create the base plot

theplot = plot(findgen(2), /nodata, font_size = 20, thick = 2.0, title = targetName + ' ' + targetObservationDate + ' - ' + " Comparison", xrange = [.8, 1.0], yrange = [1, plotHeight], margin = [.2, .14, .12, .12], dimensions = [1280, 800])

;Set the title formatting
theplot.title.font_size = 30

;Axes formatting
theaxes = theplot.axes
theaxes[0].title = '$\lambda (\mu m)$'
theaxes[1].title = ""

theaxes[0].thick = 2.0
theaxes[1].thick = 2.0
theaxes[2].thick = 2.0
theaxes[3].thick = 2.0

theaxes[0].ticklen = .015
theaxes[1].ticklen = .015
theaxes[2].ticklen = .015
theaxes[3].ticklen = .015

;Load the target data
a=readfits(targetData)
wTarget = a(*,0)
fluxTarget = a(*,1)
e = a(*,2)
lflTarget = w * f

offset = 0.0

;Iterate over box and gaussian
for smoothType = 0,1 do begin
  
 ; Skip unnecessary steps
  if keyword_set(boxcarOnly) and smoothType eq 1 then begin
    continue
  endif
  if keyword_set(gaussianOnly) and smoothType eq 0 then begin
    continue
  endif

  ;Iterate over smooth amount
  for smoothAmount = amountMin, amountMax do begin

    ;Generate the file path
    smoothString = ""
     amountString = ""
      if smoothAmount ne 0 then begin
        if smoothType eq 0 then smoothString = "_Boxcar"
        if smoothType eq 1 then smoothString = "_Gaussian"
        amountString = strcompress(smoothAmount, /remove_all)
      endif

    inputFile = saveFolder + '/' + targetName + smoothString + amountString + '_modelParameters.sav'

    ;Load the file
    restore, inputFile

    ;update the offset
    offset = offset + .1

    plot1 = plot(wModel, ((lflTarget / lflModel) + offset), /overplot, thick = 1.0)
    text1 = text(.97, .95 + offset, strcompress(smoothAmount, /remove_all) + ' Point ' + smoothString, /data, font_name = 'Helvetica', font_size=14)

  endfor
endfor

;Plot waveguides
y=[1, plotHeight]
x=[0.82,0.82]
line1 = polyline(x,y, /data, linestyle = '--', /overplot)

x=[0.833,0.833]
line2 = polyline(x,y, /data, linestyle = '--', /overplot)

x=[0.88,0.88]
line3 = polyline(x,y, /data, linestyle = '--', /overplot)

x=[0.907,0.907]
line4 = polyline(x,y, /data, linestyle = '--', /overplot)

x=[0.942,0.942]
line5 = polyline(x,y, /data, linestyle = '--', /overplot)

x=[0.966,0.966]
line6 = polyline(x,y, /data, linestyle = '--', /overplot)

x=[0.989,0.989]
line7 = polyline(x,y, /data, linestyle = '--', /overplot)

;Save the ratio comparison
outputFile = saveFolder + '/' + targetName + "_Ratios.pdf"

thePlot.save, outputFile, /close, width = 11, height = 8.5, /landscape

print, "  Process Completed"

end