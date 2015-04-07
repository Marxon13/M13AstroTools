;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13AccretionCompare
;
; PURPOSE:
; Genrates plots to compare accretion rates of a target star over time.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13accretioncompare, filesArray, julianDatesArray, outputFolder
;
; INPUTS:
; filesArray: The array of accretion rate files for the various dates. These should be the sav files output by M13AcretionRates.
; julianDatesArray: The julian date of the observation the data is for. Use Julday(month, day, year) to create the dates.
; outputFolder: The folder to place all the comparison plots. Input is the full file path.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-

pro m13accretioncompare, filesArray, julianDatesArray, outputFolder

  ;Load the first file for setup
  restore, filesArray[0]
  
  print, 'Comparing acretion rates for star: ' + targetName

  n_files = size(filesArray, /N_ELEMENTS)

  print, '  Finished setup.'
  print, '  Determining number of accretion rates to plot'

  n_rates = size(accretionArray, /N_ELEMENTS)

  print, '  Generating plots...'
  for rateIndex = 0, n_rates - 1 do begin
    
    ;Create the holding arrays for the data
    datesArray = strarr(n_files)
    dataArray = fltarr(n_files)
    
    ;Load the data
    for fileIndex = 0, n_files - 1 do begin

      restore, filesArray[fileIndex]

      ;Add the mdots to the arrays
      dataArray[fileIndex] = accretionArray[rateIndex]

      ;Kill Nans
      if finite(dataArray[fileIndex]) eq 0 then dataArray[fileIndex] = 0

    endfor
    
    ;Group Plot
    groupPlot = barplot(indgen(n_files), dataArray, fill_color = 'blue', font_size = 20, thick = 2.0, title = targetName + ' Accretion Rates (' + sourceArray[rateIndex] + ')', xrange = [-1 ,n_files + 1], yrange = [0, max(dataArray)], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    groupPlot.font_size = 30
    ;Axes formatting
    theaxes = groupPlot.axes
    theaxes[0].title = ''
    theaxes[1].title = 'Solar Masses / Year'
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
    
    ;Scaled Plot
    scaledPlot = barplot(julianDatesArray, dataArray, fill_color = 'blue', font_size = 20, thick = 3.0, title = targetName + ' Accretion Rates (' + sourceArray[rateIndex] + ')', xrange = [0 ,1], yrange = [0, max(dataArray)], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'blue', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    scaledPlot.font_size = 30
    ;Axes formatting
    theaxes = scaledPlot.axes
    theaxes[0].title = 'Day'
    theaxes[1].title = 'Solar Masses / Year'
    theaxes[0].thick = 2.0
    theaxes[1].thick = 2.0
    theaxes[2].thick = 2.0
    theaxes[3].thick = 2.0
    theaxes[0].ticklen = .015
    theaxes[1].ticklen = .015
    theaxes[2].ticklen = .015
    theaxes[3].ticklen = .015
    theaxes[0].tickunits = ["Days"]
    theaxes[0].tickfont_size = 10

    theaxes[0].major = 20
    theaxes[0].minor = 1
    
    ;Calculate the plot ranges
    ;Find the minimum and maximum values of the pa beta
    ymax = max(dataArray) + 1e-8
    ymin = min(dataArray) - 1e-8
    ymin = min([ymin, 0])
    groupPlot.YRANGE = [ymin, ymax]
    scaledPlot.YRANGE = [ymin, ymax]

    xmin = min(julianDatesArray)
    xmax = max(julianDatesArray)
    scaledPlot.XRange = [xmin - 30, xmax + 30]

    date_label = label_date(DATE_FORMAT = '%M')
    months = axis('X', location = ymin - ((ymax - ymin) / 10), title = "Month", tickformat = "LABEL_DATE", tickinterval = 10, target = scaledPlot, tickunit = "Months", thick = 2)
    years = axis('X', location = ymin - ((ymax - ymin) / 4), title = "Year", target = scaledPlot, tickunit = "Years", thick = 2)

    ;save
    outputFile = outputFolder + '/' + targetName + "_" + fileArray[rateIndex] + "_AccreationRatesComparisonUnscaled.pdf"
    groupPlot.save, outputFile, /close, width = 11, height = 8.5, /Landscape
    outputFile = outputFolder + '/' + targetName + "_" + fileArray[rateIndex] + "_AccreationRatesComparisonScaled.pdf"
    scaledPlot.save, outputFile, /close, width = 11, height = 8.5, /Landscape

    groupPlot.close
    scaledPlot.close
    
  endfor
end