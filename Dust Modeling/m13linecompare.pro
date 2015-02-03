;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13LineCompare
;
; PURPOSE:
; Genrates plots so that the spectra and emission lines of the various collection runs for a target star can be compared easily.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13linecompare, filesArray, colorsArray, outputFolder, STANDARDSTAR = standardStar, STANDARDNAME = standardName
;
; INPUTS:
; filesArray: The array of spectra files to compare. These should be sav files output by M13ModelCreator. Use the same file used in M13AutoLines.
; colorsArray: The colors to use to plot each dataset. There should be one color per dataset. These should be the named color string constants provided by IDL.
; outputFolder: The folder to place all the comparison plots. Input is the full file path.
;
; KEYWORD PARAMETERS:
; STANDARDSTAR: Set this keyword to include the standard star in the plot. The value should be set to the full file path of the fits file for the standard star.
; STANDARDNAME: The name of the standard star.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-

pro m13linecompare, filesArray, colorsArray, outputFolder, STANDARDSTAR = standardStar, STANDARDNAME = standardName

;--------------Setup---------------

;Load the first file for setup
restore, filesArray[0], /verbose

print, 'Comparing lines for star: ' + targetName
print, '  Loaded target data....'

n_lines = size(line_Label, /n_elements)
n_files = size(filesArray, /n_elements)

;Generate min and max plot ranges
xmin = fltarr(n_lines)
xmax = fltarr(n_lines)
for i = 0, n_lines - 1 do begin
  xmin(i) = wavelengths(i) - 0.01
  xmax(i) = wavelengths(i) + 0.01
endfor

print, '  Finished setup.'

print, '  Creating unscaled plots...'

;For each line
for  lineIndex = 0, n_lines - 1 do begin
  
  print, '    Creating plot for line: ' + line_label(lineIndex)
  
  unscaledPlot = plot([0,0], [0,0], /nodata, font_size = 20, thick = 2.0, title = targetName + ' - ' + line_label(lineIndex), xrange = [xmin(lineIndex),xmax(lineIndex)], yrange = [0, 1], margin = [.25, .14, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
  ;Set the title formatting
  unscaledPlot.font_size = 30
  ;Axes formatting
  theaxes = unscaledPlot.axes
  theaxes[0].title = '$\lambda (\mu m)$'
  theaxes[1].title = '$F!D\lambda !N (W m!E-2!N \mu !5m!E-1!N)$'
  theaxes[0].thick = 2.0
  theaxes[1].thick = 2.0
  theaxes[2].thick = 2.0
  theaxes[3].thick = 2.0
  theaxes[0].ticklen = .015
  theaxes[1].ticklen = .015
  theaxes[2].ticklen = .015
  theaxes[3].ticklen = .015
  
  ;Setup to calculate the plot ranges.
  unscaledYMin = 9999999
  unscaledYMax = 0
  
  if keyword_set(standardStar) then unscaledPlotsArray = objarr(n_files + 1) else unscaledPlotsArray = objarr(n_files)
  
  for fileIndex = 0, n_files - 1 do begin
    
    print, '      Adding plot for date: ' + targetObservationDate
    
    restore, filesArray[fileIndex]
    
    ;-------------Unscaled---------------
    
    ;Auto calculate the y range
    ;get the indicies to trim to
    xminbin = value_locate(wTarget, xmin(lineIndex))
    xmaxbin = value_locate(wTarget, xmax(lineIndex))
    ;Trim ftarget to this sub array
    yarray = ftarget[xminbin : xmaxbin]
    ;Find the minimum and maximum values of the sub array
    ymin = min(yarray) - 1e-13
    ymax = max(yarray) + 1e-13
    
    unscaledYMin = min([ymin, unscaledYMin])
    unscaledYMax = max([ymax, unscaledYMax])
    
    ;Plot
    linePlot = plot(wTarget, ftarget, color = colorsArray[fileIndex], overplot = unscaledPlot, name = targetName + ' - ' + targetObservationDate)
    unscaledPlotsArray[fileIndex] = linePlot

  endfor
  
  if keyword_set(standardStar) then begin
    
    print, '      Adding plot for standard star.'
    
    a = readfits(standardStar)
    w = a(*, 0)
    f = a(*, 1)
    wStandard = w
    fStandard = f

    ;-------------Unscaled---------------

    ;Auto calculate the y range
    ;get the indicies to trim to
    xminbin = value_locate(wStandard, xmin(lineIndex))
    xmaxbin = value_locate(wStandard, xmax(lineIndex))
    ;Trim ftarget to this sub array
    yarray = fStandard[xminbin : xmaxbin]
    ;Find the minimum and maximum values of the sub array
    ymin = min(yarray) - 1e-13
    ymax = max(yarray) + 1e-13

    unscaledYMin = min([ymin, unscaledYMin])
    unscaledYMax = max([ymax, unscaledYMax])

    ;Plot
    linePlot = PLOT(wStandard, fStandard, color = 'black', overplot = unscaledPlot, name = standardName)
    unscaledPlotsArray[fileIndex] = linePlot
    
  endif
  
  outputFile = outputFolder + '/' + targetName + "_" + file_label[lineIndex] + "_Comparison"
  
  if keyword_set(standardStar) then begin
    outputFile = outputFile + '_WithStandard'
  endif
  
  y = [unscaledYMin, unscaledYMax]
  x = [wavelengths(lineIndex), wavelengths(lineIndex)]
  line = polyline(x,y, /data, linestyle = '--', /overplot)
  
  unscaledPlot.yrange = [unscaledYMin, unscaledYMax]
  
  unscaledLegend = LEGEND(target = unscaledPlotsArray, /DATA, /AUTO_TEXT_COLOR, position = [xmin(lineIndex) + .0005, unscaledYMax - 5e-14], font_name = 'Helvetica', FONT_SIZE=8, horizontal_spacing = .05, shadow = 0, linestyle = 0, sample_width = 0.0, horizontal_alignment = 'left')

  unscaledPlot.save, (outputFile + '_Unscaled.pdf'), /close, width = 11, height = 8.5, /Landscape
  unscaledPlot.close
  
  print, '  Finished unscaled plots...'

endfor

print, '  Creating scaled plots...'

for lineIndex = 0, n_lines - 1  do begin
  
  print, '    Creating plot for line: ' + line_label(lineIndex)
  
  scaledPlot = plot([0,0], [0,0], /nodata, font_size = 20, thick = 2.0, title = targetName + ' - ' + line_label(lineIndex), xrange = [xmin(lineIndex),xmax(lineIndex)], yrange = [0, 1], margin = [.25, .14, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
  ;Set the title formatting
  scaledPlot.font_size = 30
  ;Axes formatting
  theaxes = scaledPlot.axes
  theaxes[0].title = '$\lambda (\mu m)$'
  theaxes[1].title = '$F!D\lambda !N (W m!E-2!N \mu !5m!E-1!N)$'
  theaxes[0].thick = 2.0
  theaxes[1].thick = 2.0
  theaxes[2].thick = 2.0
  theaxes[3].thick = 2.0
  theaxes[0].ticklen = .015
  theaxes[1].ticklen = .015
  theaxes[2].ticklen = .015
  theaxes[3].ticklen = .015

  scaledYMin = 9999999
  scaledYMax = 0

  if keyword_set(standardStar) then scaledPlotsArray = objarr(n_files + 1) else scaledPlotsArray = objarr(n_files)
  
  for fileIndex = 0, n_files - 1 do begin
    
    restore, filesArray[fileIndex]
    
    print, '      Adding plot for date: ' + targetObservationDate
    
    ;Find the average flux of the data around the line
    ;get the indicies to trim to
    xlowminbin = value_locate(wTarget, xmin(lineIndex) - .008)
    xlowmaxbin = value_locate(wTarget, xmin(lineIndex))
    xhighminbin = value_locate(wTarget, xmax(lineIndex))
    xhighmaxbin = value_locate(wTarget, xmax(lineIndex) + .008)
    ;Get the sub arrays
    fLowArray = fTarget[xlowminbin : xlowmaxbin]
    fHighArray = fTarget[xhighminbin : xhighmaxBin]

    average = avg([avg(fLowArray), avg(fHighArray)])
    
    ;Scale the target's flux by the given amount to have all the line's bases sit at 0
    flux = fTarget - average
    
    ;Auto calculate the y range
    ;get the indicies to trim to
    xminbin = value_locate(wTarget, xmin(lineIndex))
    xmaxbin = value_locate(wTarget, xmax(lineIndex))
    ;Trim ftarget to this sub array
    yarray = flux[xminbin : xmaxbin]
    ;Find the minimum and maximum values of the sub array
    ymin = min(yarray) - 1e-13
    ymax = max(yarray) + 1e-13

    scaledYMin = min([ymin, scaledYMin])
    scaledYMax = max([ymax, scaledYMax])
    
    ;Plot
    linePlot = plot(wTarget, flux, color = colorsArray[fileIndex], overplot = scaledPlot, name =  targetName + ' - ' + targetObservationDate)
    scaledPlotsArray[fileIndex] = linePlot
    
  endfor
  
  if keyword_set(standardStar) then begin

    print, '      Adding plot for standard star.'

    a = readfits(standardStar)
    w = a(*, 0)
    f = a(*, 1)
    wStandard = w
    fStandard = f

    ;Find the average flux of the data around the line
    ;get the indicies to trim to
    xlowminbin = value_locate(wStandard, xmin(lineIndex) - .008)
    xlowmaxbin = value_locate(wStandard, xmin(lineIndex))
    xhighminbin = value_locate(wStandard, xmax(lineIndex))
    xhighmaxbin = value_locate(wStandard, xmax(lineIndex) + .008)
    ;Get the sub arrays
    fLowArray = fStandard[xlowminbin : xlowmaxbin]
    fHighArray = fStandard[xhighminbin : xhighmaxBin]

    average = avg([avg(fLowArray), avg(fHighArray)])
    
    ;Scale the target's flux by the given amount to have all the line's bases sit at 0
    flux = fStandard - average

    ;Auto calculate the y range
    ;get the indicies to trim to
    xminbin = value_locate(wStandard, xmin(lineIndex))
    xmaxbin = value_locate(wStandard, xmax(lineIndex))
    ;Trim ftarget to this sub array
    yarray = flux[xminbin : xmaxbin]
    ;Find the minimum and maximum values of the sub array
    ymin = min(yarray) - 1e-13
    ymax = max(yarray) + 1e-13

    scaledYMin = min([ymin, scaledYMin])
    scaledYMax = max([ymax, scaledYMax])

    ;Plot
    linePlot = PLOT(wStandard, flux, color = 'black', overplot = scaledPlot, name = standardName)
    scaledPlotsArray[fileIndex] = linePlot

  endif
  
  outputFile = outputFolder + '/' + targetName + "_" + file_label[lineIndex] + "_Comparison"
  
  if keyword_set(standardStar) then begin
    outputFile = outputFile + '_WithStandard'
  endif
  
  y = [scaledYMin, scaledYMax]
  x = [wavelengths(lineIndex), wavelengths(lineIndex)]
  line = polyline(x,y, /data, linestyle = '--', /overplot)
  
  scaledPlot.yrange = [scaledYMin, scaledYMax]
  
  scaledLegend = legend(target = scaledPlotsArray, /DATA, /AUTO_TEXT_COLOR, position = [xmin(lineIndex) + .0005, scaledYMax - 5e-14], font_name = 'Helvetica', font_size=8, horizontal_spacing = .05, shadow = 0, linestyle = 0, sample_width = 0.0,horizontal_alignment = 'left')

  scaledPlot.save, (outputFile + '_Scaled.pdf'), /close, width = 11, height = 8.5, /Landscape
  scaledPlot.close
  
  print, '  Finished scaled plots...'
  
endfor

end