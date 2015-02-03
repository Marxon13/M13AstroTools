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
  restore, filesArray[0], /verbose

  print, 'Comparing acretion rates for star: ' + targetName
  print, '  Loaded target data....'

  n_files = size(filesArray, /N_ELEMENTS)

  print, '  Finished setup.'
  print, '  Generating data arrays...'
  
  ;Create the holding arrays for the data
  datesArray = strarr(n_files)
  brGammaArray = fltarr(n_files)
  paBetaArray = fltarr(n_files)
  
  for fileIndex = 0, n_files - 1 do begin
    
    restore, filesArray[fileIndex]
    
    ;Add the mdots to the arrays
    brGammaArray[fileIndex] = mdot_brgamma
    paBetaArray[fileIndex] = mdot_pabeta
    
    ;Kill Nans
    if finite(brGammaArray[fileIndex]) eq 0 then brGammaArray[fileIndex] = 0
    if finite(paBetaArray[fileIndex]) eq 0 then paBetaArray[fileIndex] = 0
    
    ;Mark Prisms
    if strpos(targetName, "Prism") ne -1 then begin
      datesArray[fileIndex] = targetObservationDate + "P"
    endif else begin
      datesArray[fileIndex] = targetObservationDate
    endelse
    
    endfor
    
    print, '  Generating plots...'

    groupPlotBrGamma = barplot(indgen(n_files), brGammaArray, fill_color = 'blue', font_size = 20, thick = 2.0, title = targetName + ' Accretion Rates (Br Gamma)', xrange = [-1 ,n_files + 1], yrange = [0, max(brGammaArray)], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    groupPlotBrGamma.font_size = 30
    ;Axes formatting
    theaxes = groupPlotBrGamma.axes
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
    
    groupPlotPaBeta = barplot(indgen(n_files), paBetaArray, fill_color = 'blue', font_size = 20, thick = 2.0, title = targetName + ' Accretion Rates (Pa Beta)', xrange = [-1 ,n_files + 1], yrange = [0, max(paBetaArray)], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'black', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    groupPlotPaBeta.font_size = 30
    ;Axes formatting
    theaxes = groupPlotPaBeta.axes
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
    
    scaledPlotBrGamma = barplot(julianDatesArray, brGammaArray, fill_color = 'blue', font_size = 20, thick = 3.0, title = targetName + ' Accretion Rates (Br Gamma)', xrange = [0 ,1], yrange = [0, max(brGammaArray)], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'blue', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    scaledPlotBrGamma.font_size = 30
    ;Axes formatting
    theaxes = scaledPlotBrGamma.axes
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
    
    scaledPlotPaBeta = barplot(julianDatesArray, paBetaArray, fill_color = 'blue', font_size = 20, thick = 3.0, title = targetName + ' Accretion Rates (Pa Beta)', xrange = [0 ,1], yrange = [0, max(paBetaArray)], margin = [.25, .25, .12, .12], dimensions = [1280, 800], color = 'blue', xstyle = 1, ystyle = 1)
    ;Set the title formatting
    scaledPlotPaBeta.font_size = 30
    ;Axes formatting
    theaxes = scaledPlotPaBeta.axes
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
    ymax = max(paBetaArray) + 1e-8
    ymin = min(paBetaArray) - 1e-8
    ymin = min([ymin, 0])
    groupPlotPaBeta.YRANGE = [ymin, ymax]
    scaledPlotPaBeta.YRANGE = [ymin, ymax]

    xmin = min(julianDatesArray)
    xmax = max(julianDatesArray)
    scaledPlotPaBeta.XRange = [xmin - 30, xmax + 30]

    date_label = label_date(DATE_FORMAT = '%M')
    months = axis('X', location = ymin - ((ymax - ymin) / 10), title = "Month", tickformat = "LABEL_DATE", tickinterval = 10, target = scaledPlotPaBeta, tickunit = "Months", thick = 2)
    years = axis('X', location = ymin - ((ymax - ymin) / 4), title = "Year", target = scaledPlotPaBeta, tickunit = "Years", thick = 2)

    ;Calculate the plot ranges
    ;Find the minimum and maximum values of the pa beta
    ymax = max(brGammaArray) + 1e-8
    ymin = min(brGammaArray) - 1e-8
    ymin = min([ymin, 0])
    groupPlotBrGamma.YRANGE = [ymin, ymax]
    scaledPlotBrGamma.YRANGE = [ymin, ymax]

    xmin = min(julianDatesArray)
    xmax = max(julianDatesArray)
    scaledPlotBrGamma.XRange = [xmin - 30, xmax + 30]

    date_label = label_date(DATE_FORMAT = '%M')
    months = axis('X', location = ymin - ((ymax - ymin) / 10), title = "Month", tickformat = "LABEL_DATE", tickinterval = 10, target = scaledPlotBrGamma, tickunit = "Months", thick = 2)
    years = axis('X', location = ymin - ((ymax - ymin) / 4), title = "Year", target = scaledPlotBrGamma, tickunit = "Years", thick = 2)
    
    outputFile = outputFolder + '/' + targetName + "_AccreationRatesComparisonPaBetaUnscaled.pdf"
    groupPlotPaBeta.save, outputFile, /close, width = 11, height = 8.5, /Landscape
    outputFileB = outputFolder + '/' + targetName + "_AccreationRatesComparisonPaBetaScaled.pdf"
    scaledPlotPaBeta.save, outputFileB, /close, width = 11, height = 8.5, /Landscape
    
    outputFileC = outputFolder + '/' + targetName + "_AccreationRatesComparisonBrGammaUnscaled.pdf"
    groupPlotBrGamma.save, outputFileC, /close, width = 11, height = 8.5, /Landscape
    outputFileD = outputFolder + '/' + targetName + "_AccreationRatesComparisonBrGammaScaled.pdf"
    scaledPlotBrGamma.save, outputFileD, /close, width = 11, height = 8.5, /Landscape
    
    groupPlotPaBeta.close
    scaledPlotPaBeta.close
    groupPlotBrGamma.close
    scaledPlotBrGamma.close
end