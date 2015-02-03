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
  elementsJBand = 0
  fluxHBand = 0
  elementsHBand = 0
  fluxKBand = 0
  elementsKBand = 0
  fluxLBand = 0
  elementsLBand = 0
  
  for i = 0, n - 1 do begin
    ;J Band
    if wTarget(i) ge 1.20 and wTarget(i) le 1.30 then begin
      fluxJBand = fluxJBand + lflTarget(i)
      elementsJBand = elementsJBand + 1
    endif
    
    ;HBand
    if wTarget(i) ge 1.60 and wTarget(i) le 1.70 then begin
      fluxHBand = fluxHBand + lflTarget(i)
      elementsHBand = elementsHBand + 1
    endif
    
    ;KBand
    if wTarget(i) ge 2.109 and wTarget(i) le 2.30 then begin
      fluxKBand = fluxKBand + lflTarget(i)
      elementsKBand = elementsKBand + 1
    endif
    
    ;LBand
    if wTarget(i) ge 3.42 and wTarget(i) le 4.12 then begin
      fluxLBand = fluxLBand + lflTarget(i)
      elementsLBand = elementsLBand + 1
    endif
    
  endfor
  
  ;Get the average flux
  fluxJBand = fluxJBand / elementsJBand
  fluxHBand = fluxHBand / elementsHBand
  fluxKBand = fluxKBand / elementsKBand
  fluxLBand = fluxLBand / elementsLBand
  
  ;Save
  save, filename = (outputFolder + '/bandflux.sav'), fluxJband, fluxHband, fluxKBand, fluxLband, wtarget, ftarget, targetName, targetObservationDate
  print,'  Process Completed!'
  
end