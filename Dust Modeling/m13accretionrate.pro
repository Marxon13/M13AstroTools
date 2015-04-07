;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13AccretionRate
;
; PURPOSE:
; Calculates the accretion rate of a star, based off of its specra, and other parameters.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13acreationrate, lineFluxFile, saveFolder, distance, starMass, starRadius
;
; INPUTS:
; lineFluxFile: The lineflux sav file output by M13AutoLines
; saveFolder: The folder to output the file with the accretion rates to.
; distance: The distance from Earth to the star in parsecs. 
; starMass: The mass of the star in solar masses.
; starRadius: The radius of the star in solar radai.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-
pro m13accretionrate, lineFluxFile, saveFolder, distance, starMass, starRadius

;restore the file
restore, lineFluxFile
print, 'Calculating accretion rates for star: ' + targetName + ' - ' + targetObservationDate
print, '  Loaded target data....'

pi = 3.141593
pc = 3.086e16
Lsun = 3.85e26
G = 6.67e-11

;The array of the flux used to calculate the line
fluxArray = fltarr(3)
;The mass accreation calculated in solar masses per year
accretionArray = fltarr(3)
;The source line
sourceArray = strarr(3)
;The method used
methodArray = strarr(3)
;The file compatable name for saving generated plots
fileArray = strArr(3)

print, '  Calculating Pa Beta: Muzerolle 1998  AJ, 116, 2965'
f_PaBeta = lineflux1(12)
L_PaBeta = f_PaBeta * pi * (distance * pc)^2
print,'    Flux Pa Beta = ', strcompress(f_PaBeta), ' | Lum Pa beta = ', strcompress(L_PaBeta)

Log_Lacc_PaBeta = 1.14 * (alog10(L_PaBeta / Lsun)) + 3.15          ; Muzerolle 1998  AJ, 116, 2965
Lacc_PaBeta = 10^(Log_Lacc_PaBeta)
print,'    Lacc Pa beta = ', strcompress(Lacc_PaBeta)

Mdot_PaBeta = (3.155e7 / 1.99e30) * (Lacc_PaBeta * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)

print, '    Mdot_PaBeta = ', strcompress( Mdot_PaBeta)

fluxArray[0] = f_PaBeta
accretionArray[0] = Mdot_PaBeta
sourceArray[0] = '$Pa \beta$'
methodArray[0] = 'Muzerolle 1998  AJ, 116, 2965'
fileArray[0] = 'Pa Beta - Muzerolle 1998'

;-----------------------------

print, '  Calculating Br Gamma: Muzerolle 1998  AJ, 116, 2965'
f_BrGamma = lineflux1(13)
L_BrGamma = f_BrGamma * pi * (distance * pc)^2
print,'    Flux Br Gamma = ',strcompress(f_BrGamma), ' | Lum Br Gamma = ', strcompress(L_BrGamma)

Log_Lacc_BrGamma = 1.26 * (alog10(L_BrGamma / Lsun)) + 4.43        ; Muzerolle 1998  AJ, 116, 2965
Lacc_BrGamma = 10^(Log_Lacc_BrGamma)
print,'    Lacc_BrGamma = ', strcompress(Lacc_BrGamma)

Mdot_BrGamma = (3.155e7 / 1.99e30) * (Lacc_BrGamma * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)

print, '    Mdot_BrGamma = ', strcompress(Mdot_BrGamma)

fluxArray[1] = f_BrGamma
accretionArray[1] = Mdot_BrGamma
sourceArray[1] = '$Br \gamma$'
methodArray[1] = 'Muzerolle 1998  AJ, 116, 2965'
fileArray[1] = 'Br Gamma - Muzerolle 1998'

;-----------------------------

print, '  Calculating Br Gamma: Calvet 2004 AJ, 128, 1294'
f_PaBeta = lineflux1(12)
L_PaBeta = f_PaBeta * pi * (distance * pc)^2
print,'    Flux Pa Beta = ', strcompress(f_PaBeta), ' | Lum Pa beta = ', strcompress(L_PaBeta)

Log_Lacc_BrGamma2 = 0.9 * (alog10(L_BrGamma / Lsun) + 4.0) - 0.7   ; Calvet 2004 AJ, 128, 1294
Lacc_BrGamma2 = 10^(Log_Lacc_BrGamma2)
print,'    Lacc Pa beta = ', strcompress(Lacc_PaBeta),' | Lacc_BrGamma = ', strcompress(Lacc_BrGamma),' | Lacc_BrGamma2 = ', strcompress(Lacc_BrGamma2)

Mdot_BrGamma2 = (3.155e7 / 1.99e30) * (Lacc_BrGamma2 * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)

print, '    Mdot_BrGamma2 = ', strcompress(Mdot_BrGamma2)

fluxArray[2] = f_PaBeta
accretionArray[2] = Mdot_BrGamma2
sourceArray[2] = '$Br \gamma$'
methodArray[2] = 'Calvet 2004 AJ, 128, 1294'
fileArray[2] = 'Br Gamma -  Calvet 2004'


save, filename = saveFolder + '/' + targetname + '_' + targetObservationDate + '_' + smoothDescription + '_accretion_rates.sav', distance, starMass, starRadius, targetName, targetObservationDate, fluxArray, accretionArray, sourceArray, methodArray, fileArray

print,'  Process Completed!'
end