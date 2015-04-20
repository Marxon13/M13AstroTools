;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13AutoLines
;
; PURPOSE:
; Generates plots for, and analyzes specific spectral lines in spectra.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13autolines, inputFile, outputFolder
;
; INPUTS:
; inputFile: The sav file output by M13ModelCreator with the best smoothing value.
; outputFolder: The folder to output all the plots and data files to.
; 
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-

;Finds the values in the given range
function binForRange, xArr, xrange

  ;Find Y Minimum
  xminbin = value_locate(xArr, xrange[0])
  xmaxbin = value_locate(xArr, xrange[1])
  ;Catch if a value is not found
  if xminbin eq -1 then begin
    print, "Minimum value not found, setting to 0."
    xminbin = 0
  endif
  if xmaxbin eq -1 then begin
    print, "Minimum value not found, setting to array length - 1. (" + size(xarr, /n_elements) - 1 + ")"
    xmaxbin = size(xarr, /n_elements) - 1
  endif
  
  return, [xminbin, xmaxbin]

end


pro m13autolines, inputFile, outputFolder

;Restore the file
restore, inputFile

;---------------
;Start with Chi-Squared differences to calculate the line flux
;---------------

print, 'Creating lines for star: ' + targetName + ' - ' + targetObservationDate
print, '  Loaded target data....'

;setup variables
w = wTarget
fmodel = lflModel / w
ftarget = lflTarget / w

;Wavelengths of the line locations
wl = [0.8449,0.849802,0.854209,0.8600754,0.866214,0.8752876,0.8865217,0.9017385,0.9231547,0.9548590,1.0052128,1.0941091,1.282159,2.166120,4.052262]
n_lines = size(wl, /n_elements)

;Create the x array for the chi-squared calculation
;bump = findgen(1000) / 10000 + 0.95
bump = findgen(10000) / 10000 + 0.5
print,'  start bump= ',strcompress(min(bump)),' | end bump= ',strcompress(max(bump))

;Stores the fluxes of the lines
lineflux1 = fltarr(n_lines)
lineflux2 = fltarr(n_lines)

;Auto create the width of the lines
wl1 = fltarr(n_lines)
wl2 = fltarr(n_lines)
;1000 km/s width
for i=3, n_lines-1 do begin
  wl1(i) = wl(i) * (1.00 - 3.00e-3 * 0.8)
  wl2(i) = wl(i) * (1.00 + 3.00e-3 * 0.8)
endfor

;need smaller for [O I]
wl1(0) = wl(0) * (1.00 - 1.67e-3 * 0.8)
wl2(0) = wl(0) * (1.00 + 1.67e-3 * 0.8)
wl1(1) = wl(1) * (1.00 - 2.33e-3 * 0.8)
wl2(1) = wl(1) * (1.00 + 2.33e-3 * 0.8)
wl1(2) = wl(2) * (1.00 - 2.33e-3 * 0.8)
wl2(2) = wl(2) * (1.00 + 2.33e-3 * 0.8)

;The ranges used to calculate the chi squared fit. 1-2, and 3-4
wc1 = [0.8410,0.8482,0.8516,0.8570,0.8618,0.8720,0.8830,0.8930,0.9150,0.9520,0.970,1.087,1.270,2.151,4.010]
wc2 = [0.8429,0.8486,0.8524,0.8577,0.8630,0.8723,0.8845,0.8980,0.9190,0.9450,0.990,1.091,1.275,2.158,4.030]
wc3 = [0.8461,0.8516,0.857,0.8618,0.8689,0.8777,0.8885,0.894,0.926,0.9575,1.020,1.098,1.288,2.175,4.07]
wc4 = [0.8463,0.8524,0.8577,0.863,0.872,0.8995,0.894,0.908,0.929,0.965,1.030,1.103,1.295,2.185,4.09]

bump_line = fltarr(n_lines)
;Create the minimum and maximum plot widths for each line plot
xmin = fltarr(n_lines)
xmax = fltarr(n_lines)
for i = 0, n_lines - 1 do begin
  xmin(i) = wl(i) - 0.01
  xmax(i) = wl(i) + 0.01
  print, '  xmin(', strcompress(i), ') = ', strcompress(xmin(i)), ' | xmax(', strcompress(i), ') = ', strcompress(xmax(i))
endfor

;Calculate the positions of the legend text, as a legend background gets in the way
starx = fltarr(n_lines)
modelx = fltarr(n_lines)
differx = fltarr(n_lines)
for i=0,n_lines-1 do begin
  starx(i) = (xmax(i) - xmin(i)) * 0.05 + xmin(i)
  modelx(i) = (xmax(i) - xmin(i)) * 0.05 + xmin(i)
  differx(i) = (xmax(i) - xmin(i)) * 0.05 + xmin(i)
endfor

;Setup file and plot names
line_label = ['O I 8446','Ca II 8498','Ca II 8542','Pa 14','Ca II 8662','Pa 12','Pa 11','Pa 10','Pa 09','$Pa \epsilon$','$Pa \delta$','$Pa \gamma$','$Pa \beta$','$Br \gamma$','$Br \alpha$']
file_label = ['O I 8446','Ca II 8498','Ca II 8542','Pa 14','Ca II 8662','Pa 12','Pa 11','Pa 10','Pa 09','Pa eps','Pa delta','Pa gamma','Pa beta','Br gamma','Br alpha']

print, '  Finished setup.'

;
for m=0, n_lines-1 do begin
  
  print, '  Begining line: ' + line_label[m]
  print, '    Calculating Chi Squared...'
  bumpLength = size(bump, /n_elements)
  chisqr = fltarr(bumpLength)
  
  ;Get the values in the specified ranges for the chi squared. This gets the indicies that meet the requirement
  binRangeOne = binForRange(w, [wc1(m), wc2(m)])
  binRangeTwo = binForRange(w, [wc3(m), wc4(m)])
  print, "  Chi Squared Range: ", strcompress(binRangeOne), " + ", strcompress(binRangeTwo)
  indiciesRangeOne = indgen(abs(binRangeOne(1) - binRangeOne(0)), START=min([binRangeOne(0), binRangeOne(1)]), INCREMENT=1)
  indiciesRangeTwo = indgen(abs(binRangeTwo(1) - binRangeTwo(0)), START=min([binRangeTwo(0), binRangeTwo(1)]), INCREMENT=1)
  
  
  for j=0, bumpLength - 1 do begin
    chi = 0.0
    ;get chi_squared differences between data & bumped model in continuum
    for i=0, size(indiciesRangeOne, /n_elements) - 1 do begin
      index = indiciesRangeOne(i)
      chi = chi + ((ftarget(index) - fmodel(index) * bump(j)))^2
    endfor
    for i=0, size(indiciesRangeTwo, /n_elements) - 1 do begin
      index = indiciesRangeTwo(i)
      chi = chi + ((ftarget(index) - fmodel(index) * bump(j)))^2
    endfor
    chisqr(j) = chi
  endfor
  
  k = 0
  for j = 0, bumpLength - 1 do begin
    if (chisqr(j) eq min(chisqr)) then k = j
  endfor

  ;Plot Chi Squared
  print,'    Min Bump= ', strcompress(bump(k)), ' occurs at k = ', strcompress(k)
  bump_Line(m) = bump(k)
  
  ; Create the plot object, Check to see we don't have nan plot ranges associated with no data.
  if finite(max(chisqr)) eq 1 then begin 
  theplot = plot(bump, chisqr, font_size = 20, thick = 2.0, title = (targetName + ' - ' + line_label(m)), xrange = [bump(0), bump(bumpLength - 1)], yrange = [0,max(chisqr)*1.1], margin = [.25, .14, .12, .12], dimensions = [1280, 800])
  endif else begin
  theplot = plot(bump, chisqr, font_size = 20, thick = 2.0, title = (targetName + ' - ' + line_label(m)), xrange = [bump(0), bump(bumpLength - 1)], yrange = [0,1], margin = [.25, .14, .12, .12], dimensions = [1280, 800])
  failtext = text(1.0, 0.5, 'No Data', /data, font_name = 'Helvetica', font_size=30, alignment = 0.5)
  endelse
  ;Set the title formatting
  theplot.font_size = 30
  ;Axes formatting
  theaxes = theplot.axes
  theaxes[0].title = 'Bump'
  theaxes[1].title = 'Chi-Squared'
  theaxes[0].thick = 2.0
  theaxes[1].thick = 2.0
  theaxes[2].thick = 2.0
  theaxes[3].thick = 2.0
  theaxes[0].ticklen = .015
  theaxes[1].ticklen = .015
  theaxes[2].ticklen = .015
  theaxes[3].ticklen = .015 
  
  ;Save the plot
  theplot.save, (outputFolder + "/" + 'ChiSquared - ' + file_label(m) + ' - ' + smoothDescription + '.pdf'), /close, width = 11, height = 8.5, /landscape
  theplot.close
  
  ;Auto calculate the y range
  ;get the indicies to trim to
  xminbin = value_locate(w, xmin(m))
  xmaxbin = value_locate(w, xmax(m))
  ;Trim ftarget to this sub array
  yarray = ftarget[xminbin : xmaxbin]
  ;Find the minimum and maximum values of the sub array
  ymin = min(yarray) - 5e-13
  ymax = max(yarray) + 5e-13
  
  ;Plot
  if finite(ymin) eq 1 and finite(ymax) eq 1 then begin
  theplot = plot(w, ftarget, font_size = 20, thick = 2.0, title = targetName + ' - ' + line_label(m), xrange = [xmin(m),xmax(m)], yrange = [ymin,ymax], margin = [.25, .14, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
  endif else begin
  theplot = plot(w, ftarget, font_size = 20, thick = 2.0, title = targetName + ' - ' + line_label(m), xrange = [xmin(m),xmax(m)], yrange = [0,1], margin = [.25, .14, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1) 
  failtext = text((xmin(m) + xmax(m)) / 2.0, 0.5, 'No Data', /data, font_name = 'Helvetica', font_size=30, alignment = 0.5)
  endelse
  ;Set the title formatting
  theplot.font_size = 30
  ;Axes formatting
  theaxes = theplot.axes
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
  
  ;Place target name
  stary = (ymax - ymin) * 0.90 + ymin
  atext = text(starx(m), stary, targetName, /Data, font_name = 'Helvetica', font_size=13, color = 'black')
  
  print, '    Calculating comparison...'
  
  ;Plot the model, times the offset scaling
  ;aplot = plot(w, fmodel * bump(bump_Line(m)), /overplot, color = 'red')
  aplot = plot(w, fmodel * bump_Line(m), /overplot, color = 'red')
  modely = (ymax - ymin) * 0.85 + ymin
  atext = text(modelx(m), modely, 'Model', /data, font_name = 'Helvetica', font_size=13, color = 'red')

  ;Calculate the difference
  diff = ftarget - fmodel * bump_Line(m)
  ;Get the proper offset
  offset = fTarget(binRangeOne(1)) - diff(binRangeOne(1))
  ;Plot
  aplot = plot(w, (diff + offset), /overplot, color = 'blue')
  differy = (ymax - ymin) * 0.80 + ymin
  atext = text(differx(m), differy, 'Difference + Offset', /data, font_name = 'Helvetica', font_size=13, color = 'blue')

  f1=0
  ; method 1 - rectangle approximation
  for i=1,n_elements(w)-2 do begin
    if w(i) ge wl1(m) and w(i) le wl2(m) then deltaw = (w(i+1) - w(i-1)) / 2.0
    if w(i) ge wl1(m) and w(i) le wl2(m) then f1 = f1 + diff(i) * deltaw
    if w(i) ge wl1(m) and w(i) le wl2(m) then aplot = plot([w(i) , w(i)], [diff(i) + offset, diff(i) + offset], /overplot, color = 'black', symbol = '+')
  endfor

  lineflux1(m) = f1
  print,'    line flux 1 = ', f1

  ;Print vertical lines
  x=[wl1(m),wl1(m)]
  y=[ymin,ymax]
  aline = polyline(x, y, /data, /overplot)
  x=[wl2(m),wl2(m)]
  aline = polyline(x, y, /data, /overplot)

  x=[wl1(m)-deltaw/2.0,wl1(m)-deltaw/2.0]
  aline = polyline(x, y, /data, linestyle = '--', /overplot)
  x=[wl2(m)+deltaw/2.0,wl2(m)+deltaw/2.0]
  aline = polyline(x, y, /data, linestyle = '--', /overplot)

  theplot.save, (outputFolder + '/' + file_label(m) + ' - ' + smoothDescription + '.pdf'), /close, width = 11, height = 8.5, /landscape
  theplot.close

  ; method 2 - trapazoidal?
  f2 = 0
  for i=1, n_elements(w)-2 do begin
    if w(i) ge wl1(m) and w(i) le wl2(m) then deltaw = (w(i+1) - w(i-1)) / 2.0
    if w(i) ge wl1(m) and w(i) le wl2(m) then f2 = f2 + ((diff(i) + diff(i-1)) / 2.0) * deltaw
  endfor

  lineflux2(m) = f2

  print, '    line flux 2 = ', strcompress(f2)
  print, '    line flux = ', strcompress(((f1+f2)/2.0)), ' | METHOD DIFFERENCE = ', strcompress(abs((f1-f2))/2.0), ' | bump=', strcompress(bump_Line(m))

endfor

;Save
wavelengths = wl
wavelengthsMinX = wl1
wavelengthsMaxX = wl2
diff = fltarr(n_elements(f1))
diff = (abs(f1 - f2) / 2.0)
save, filename = (outputFolder + '/' + smoothDescription + ' - lineflux.sav'), lineflux1, lineflux2, wtarget, ftarget, fmodel, targetName, bump_Line, line_label, file_label, smoothDescription, wavelengths, wavelengthsMinX, wavelengthsMaxX, targetObservationDate
print,'  Process Completed!'


end