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

f_PaBeta = lineflux1(12)
f_BrGamma = lineflux1(13)

pi = 3.141593
pc = 3.086e16
Lsun = 3.85e26
G = 6.67e-11

L_PaBeta = f_PaBeta * pi * (distance * pc)^2
L_BrGamma = f_BrGamma * pi * (distance * pc)^2

print,'  Flux Pa Beta = ', strcompress(f_PaBeta), ' | Lum Pa beta = ', strcompress(L_PaBeta)
print,'  Flux Br Gamma = ',strcompress(f_BrGamma), ' | Lum Br Gamma = ', strcompress(L_BrGamma)

Log_Lacc_PaBeta = 1.14 * (alog10(L_PaBeta / Lsun)) + 3.15          ; Muzerolle 1998  AJ, 116, 2965
Log_Lacc_BrGamma = 1.26 * (alog10(L_BrGamma / Lsun)) + 4.43        ; Muzerolle 1998  AJ, 116, 2965
Log_Lacc_BrGamma2 = 0.9 * (alog10(L_BrGamma / Lsun) + 4.0) - 0.7   ; Calvet 2004 AJ, 128, 1294

Lacc_PaBeta = 10^(Log_Lacc_PaBeta)
Lacc_BrGamma = 10^(Log_Lacc_BrGamma)
Lacc_BrGamma2 = 10^(Log_Lacc_BrGamma2)
print,'  Lacc Pa beta = ', strcompress(Lacc_PaBeta),' | Lacc_BrGamma = ', strcompress(Lacc_BrGamma),' | Lacc_BrGamma2 = ', strcompress(Lacc_BrGamma2)

Mdot_PaBeta = (3.155e7 / 1.99e30) * (Lacc_PaBeta * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)
Mdot_BrGamma = (3.155e7 / 1.99e30) * (Lacc_BrGamma * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)

print, '  Mdot_PaBeta = ', strcompress( Mdot_PaBeta), ' | Mdot_BrGamma = ', strcompress(Mdot_BrGamma)

save, filename = saveFolder + '/' + targetname + '_accretion_rates.sav', f_PaBeta, f_BrGamma, distance, starMass, starRadius, Mdot_PaBeta, Mdot_BrGamma, targetName, targetObservationDate

print,'  Process Completed!'
end