;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13LineCompareChart
;
; PURPOSE:
; Genrates plots to compare the flux of an emission line over time.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13linecomparechart, filesArray, julianDatesArray, outputFolder
;
; INPUTS:
; filesArray: The array of spectra files to compare. These should be sav files output by M13ModelCreator. Use the same file used in M13LineCompare.
; julianDatesArray: The julian date of the observation the data is for. Use Julday(month, day, year) to create the dates.
; outputFolder: The folder to place all the comparison plots. Input is the full file path.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-

pro m13linecomparechart, filesArray, julianDatesArray, outputFolder

  ;Load the first file for setup
  restore, filesArray[0], /verbose
  
  print, 'Comparing lines for star: ' + targetName
  print, '  Loaded target data....'

  n_lines = size(line_Label, /n_elements)
  n_files = size(filesArray, /n_elements)
  
  print, '  Finished setup.'
  print, '  Creating plots...'
  
  ;For each line
  for  lineIndex = 0, n_lines - 1 do begin
    
        print, '    Generating arrays for line: ' + line_label(lineIndex)
        ;The array to hold all the flux information
        fluxArray = fltarr(n_files)
        datesArray = strarr(n_files)
        for fileIndex = 0, n_files - 1 do begin
          
          restore, filesArray[fileIndex]
          
          ;Retreive the lineflux for the line, and add it to the array.
          lf1 = lineflux1[lineIndex]
          lf2 = lineflux2[lineIndex]
          fluxArray[fileIndex] = (lf1 + lf2) / 2.0
          ;Kill Nans
          if Finite(fluxArray[fileIndex]) eq 0 then fluxArray[fileIndex] = 0
          ;Mark Prisms
          if strpos(targetName, "Prism") ne -1 then begin 
            datesArray[fileIndex] = targetObservationDate + "P"
          endif else begin
            datesArray[fileIndex] = targetObservationDate
          endelse          
          
          
        endfor
    print, '      Creating Unscaled plot...'

    groupPlot = BarPlot(indgen(n_files), fluxArray, fill_color = 'blue', font_size = 20, thick = 2.0, title = targetName + ' - ' + line_label(lineIndex), xrange = [-1 ,n_files + 1], yrange = [0, 1], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    groupPlot.font_size = 30
    ;Axes formatting
    theaxes = groupPlot.axes
    theaxes[0].title = ''
    theaxes[1].title = '$F!D\lambda !N (W m!E-2!N \mu !5m!E-1!N)$'
    theaxes[0].thick = 2.0
    theaxes[1].thick = 2.0
    theaxes[2].thick = 2.0
    theaxes[3].thick = 2.0
    theaxes[0].ticklen = .015
    theaxes[1].ticklen = .015
    theaxes[2].ticklen = .015
    theaxes[3].ticklen = .015
    theaxes[0].tickvalues = indgen(n_files)
    theaxes[0].text_orientation = 90
    theaxes[0].tickname =  datesArray
    
    scaledPlot = barplot(julianDatesArray, fluxArray, fill_color = 'blue', font_size = 20, thick = 3.0, title = targetName + ' - ' + line_label(lineIndex), xrange = [0 ,1], yrange = [0, 1], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'blue', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    scaledPlot.font_size = 30
    ;Axes formatting
    theaxes = scaledPlot.axes
    theaxes[0].title = 'Day'
    theaxes[1].title = '$F!D\lambda !N (W m!E-2!N \mu !5m!E-1!N)$'
    theaxes[0].thick = 2.0
    theaxes[1].thick = 2.0
    theaxes[2].thick = 2.0
    theaxes[3].thick = 2.0
    theaxes[0].ticklen = .015
    theaxes[1].ticklen = .015
    theaxes[2].ticklen = .015
    theaxes[3].ticklen = .015
    theaxes[0].tickunits = ["Days"]
    theaxes[0].TICKFONT_SIZE = 10
    
    theaxes[0].major = 20
    theaxes[0].minor = 1 
    
    ;Calculate the plot range
    ;Find the minimum and maximum values of the flux array
    ymax = max(fluxArray) + 1e-17
    ymin = min(fluxArray) - 1e-17
    ymin = min([ymin, 0]) 
    groupPlot.YRANGE = [ymin, ymax]
    scaledPlot.YRANGE = [ymin, ymax]
    
    xmin = min(julianDatesArray)
    xmax = max(julianDatesArray)
    scaledPlot.XRange = [xmin - 30, xmax + 30]
    
    date_label = label_date(DATE_FORMAT = '%M')
    months = axis('X', location = ymin - ((ymax - ymin) / 10), title = "Month", tickformat = "LABEL_DATE", tickinterval = 10, target = scaledPlot, tickunit = "Months", thick = 2)
    years = axis('X', location = ymin - ((ymax - ymin) / 4), title = "Year", target = scaledPlot, tickunit = "Years", thick = 2)
    
    outputFile = outputFolder + '/' + targetName + "_" + file_label[lineIndex] + "_ComparisonChartUnscaled.pdf"
    groupPlot.save, outputFile, /close, width = 11, height = 8.5, /Landscape
    outputFileB = outputFolder + '/' + targetName + "_" + file_label[lineIndex] + "_ComparisonChartScaled.pdf"
    scaledPlot.save, outputFileB, /close, width = 11, height = 8.5, /Landscape
    
    groupPlot.close
    scaledPlot.close
    
  endfor
  
  print, 'Finished!'
  
end