;
; Copyright (c) 2015, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13BandFlux
;
; PURPOSE:
; Calculates the flux of the target in the JHKL photometric bands.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13bandflux, inputFile, outputFolder
;
; INPUTS:
; inputFile: The sav file output by M13ModelCreator with the best smoothing value.
; outputFolder: The folder to output all the plots and data files to.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-
pro m13bandflux, inputFile, outputFolder

  print, 'Calculating band fluxes'
  ;Restore the file
  restore, inputFile
  
  ;Get the number of elements that we have to process
  n = n_elements(wTarget)
  
  fluxJBand = 0
  errorJBand = 0
  elementsJBand = 0
  fluxHBand = 0
  errorHBand = 0
  elementsHBand = 0
  fluxKBand = 0
  errorKBand = 0
  elementsKBand = 0
  fluxLBand = 0
  errorLBand = 0
  elementsLBand = 0
  
  for i = 0, n - 1 do begin
    ;J Band
    if wTarget(i) ge 1.20 and wTarget(i) le 1.30 then begin
      fluxJBand = fluxJBand + lflTarget(i)
      errorJBand = sqrt(errorJBand^2 + elflTarget(i)^2)
      elementsJBand = elementsJBand + 1
    endif
    
    ;HBand
    if wTarget(i) ge 1.60 and wTarget(i) le 1.70 then begin
      fluxHBand = fluxHBand + lflTarget(i)
      errorHBand = sqrt(errorHBand^2 + elflTarget(i)^2)
      elementsHBand = elementsHBand + 1
    endif
    
    ;KBand
    if wTarget(i) ge 2.109 and wTarget(i) le 2.30 then begin
      fluxKBand = fluxKBand + lflTarget(i)
      errorKBand = sqrt(errorKBand^2 + elflTarget(i)^2)
      elementsKBand = elementsKBand + 1
    endif
    
    ;LBand
    if wTarget(i) ge 3.42 and wTarget(i) le 4.12 then begin
      fluxLBand = fluxLBand + lflTarget(i)
      errorLBand = sqrt(errorLBand^2 + elflTarget(i)^2)
      elementsLBand = elementsLBand + 1
    endif
    
  endfor
  
  ;Get the average flux
  tempJ = fluxJBand
  fluxJBand = fluxJBand / elementsJBand
  errorJBand = abs(fluxJBand) * sqrt((errorJBand / tempJ)^2 + (0 / elementsJBand)^2)
  tempH = fluxHBand
  fluxHBand = fluxHBand / elementsHBand
  errorHBand = abs(fluxHBand) * sqrt((errorHBand / tempH)^2 + (0 / elementsHBand)^2)
  tempK = fluxKBand
  fluxKBand = fluxKBand / elementsKBand
  errorKBand = abs(fluxKBand) * sqrt((errorKBand / tempK)^2 + (0 / elementsKBand)^2)
  tempL = fluxLBand
  fluxLBand = fluxLBand / elementsLBand
  errorLBand = abs(fluxLBand) * sqrt((errorLBand / tempL)^2 + (0 / elementsLBand)^2)
  
  ;Save
  save, filename = (outputFolder + '/bandflux.sav'), fluxJband, errorJBand, fluxHband, errorHBand, fluxKBand, errorKBand, fluxLband, errorLBand, wtarget, lfltarget, elfltarget, targetName, targetObservationDate
  print,'  Process Completed!'
  
end