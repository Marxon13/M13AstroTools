;
; Copyright (c) 2014, Brandon McQuilkin
;+
; NAME:
; M13FitsToCSV
;
; PURPOSE:
; Converts spectra data into a csv file
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m1fitstocsv, inputFile, exportPath, scale
; 
; INPUTS:
; inputFile: The path to the fits file that needs to be converted. If WOVERRIDE and LFLOVERRIDE are set, then this variable will not be used.
; exportPath: The path to export the file converted file to. (Including the file name.)
; scale: For prism data 1.0, for SXD and LXD data, the scale factor to get the data to match the prism data in intensity.
; 
; KEYWORD PARAMETERS:
; WOVERRIDE: Set this keyword override the wavelength data that is converted.
; LFLOVERRIDE: Set this keyword to override the intensity data that is converted.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-
pro m13fitstocsv, inputFile, exportPath, scale, WOVERRIDE = woverride, LFLOVERRIDE = lfloverride

  if n_elements(woverride) ne 0 and n_elements(lfloverride) ne 0 then begin
    w = woverride
    lfl = lfloverride
  endif else begin
    ;read the file and convert to w, lfl
    a=readfits(inputFile)
    w=a(*,0)
    f=a(*,1)
    lfl=w*f
  endelse
  
  
  ;Remove all nans and infinities
  w2 = []
  lfl2 = []
  
  cgProgressBar = Obj_New("CGPROGRESSBAR", title = "Converting for Mathematica...")
  cgProgressBar -> Start
  count = size(w, /N_ELEMENTS)
  print, "Converting ", count, " points..."
  
  for i = 0, count - 1 do begin
    a = w[i]
    b = lfl[i]
    if finite(a) && finite(b) then begin
      w2 = [w2, a]
      lfl2 = [lfl2, b * scale]
    endif else begin 
      ;print, "NaN Value: ", i
    endelse    
    cgProgressBar -> Update, (i / count) * 100 
  endfor
  
  
  ;Write
  newPath = exportPath
  
  write_csv, newPath, w2, lfl2
  print, "Finished"
end