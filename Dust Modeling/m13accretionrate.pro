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
; KEYWORD PARAMETERS:
; DISTANCEERROR: The error in the distance to the target.
; STARMASSERROR: The error in the target's mass.
; STARRADIUSERROR: The error in the target's radius.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-
pro m13accretionrate, lineFluxFile, saveFolder, distance, starMass, starRadius, DISTANCEERROR = distanceError, STARMASSERROR = starMassError, STARRADIUSERROR = starRadiusError

  ;----------------Errors-----------------
  IF KEYWORD_SET(starMassError) eq 0 THEN starMassError = 0
  IF KEYWORD_SET(distanceError) eq 0 THEN distanceError = 0
  IF KEYWORD_SET(starRadiusError) eq 0 THEN starRadiusError = 0
  
  ;restore the file
  restore, lineFluxFile
  print, 'Calculating accretion rates for star: ' + targetName + ' - ' + targetObservationDate
  print, '  Loaded target data....'
  
  pi = 3.141593D ;pi
  pc = double(3.086e16) ; meters per parsec
  Lsun = double(3.846e26) ;sun lumonisity in watts
  LsunError = double(0.008e26)
  G = double(6.67384e-11) ;gravitational constant
  secondsPerYear = double(3.155e7) ;number of seconds in a year
  mSolarKg = double(1.99e30) ;mass of the sun in kg
  mSolarKgError = double(0.00025e30)
  solarRadiusMeters = double(6.96e8) ; solar radius in meters
  solarRadiusMetersError = 65000D
  
  ;The array of the flux used to calculate the line
  fluxArray = fltarr(3)
  fluxErrorArray = fltarr(3)
  ;The mass accreation calculated in solar masses per year
  accretionArray = fltarr(3)
  accretionErrorArray = fltarr(3)
  ;The source line
  sourceArray = strarr(3)
  ;The method used
  methodArray = strarr(3)
  ;The file compatable name for saving generated plots
  fileArray = strArr(3)
  
  print, '  Calculating Pa Beta: Muzerolle 1998  AJ, 116, 2965'
  f_PaBeta = double(linefluxAverage(12))
  f_PaBetaError = double(linefluxAverageError(12))
  
  ;L_PaBeta = f_PaBeta * pi * (distance * pc)^2
  distanceMeters = distance * pc
  distanceMetersError = distanceError * pc
  
  distanceSquared = distanceMeters^2
  distanceSquaredError = abs((distanceSquared / distanceMeters) * 2D * distanceMetersError)
  
  fPaBetaPi = f_PaBeta * pi
  fPaBetaPiError = f_PaBetaError * pi
  
  L_PaBeta = fPaBetaPi * distanceSquared
  L_PaBetaError = abs(L_PaBeta) * sqrt((fPaBetaPiError / fPaBetaPi)^2 + (distanceSquaredError / distanceSquared)^2)
  
  print,'    Flux Pa Beta = ', strcompress(f_PaBeta), "+=", strcompress(f_PaBetaError), ' | Lum Pa beta = ', strcompress(L_PaBeta), "+-", strcompress(L_PaBetaError)
  
  ; Muzerolle 1998  AJ, 116, 2965
  ;Log_Lacc_PaBeta = 1.14 * (alog10(L_PaBeta / Lsun)) + 3.15          
  
  divide = L_PaBeta / Lsun
  divideError = abs(divide) * sqrt((L_PaBetaError / L_PaBeta)^2 + (LsunError / Lsun)^2)
  
  logbase10 = alog10(divide)
  logbase10error = (1D / alog(10D)) * (divideError / divide)
  
  scaledLog = 1.14D * logbase10
  scaledLogError = abs(scaledLog) * sqrt((0.16D / 1.14D)^2 + (logbase10error / logbase10)^2)
  
  Log_Lacc_PaBeta = scaledLog + 3.15D
  Log_Lacc_PaBetaError = sqrt(scaledLogError^2 + 0.58D^2)
  
  Lacc_PaBeta = 10D^(Log_Lacc_PaBeta)
  Lacc_PaBetaError = sqrt(((Log_Lacc_PaBeta / 10D) * 0D)^2 + (alog(10D) * Log_Lacc_PaBetaError)^2)
  print,'    Lacc Pa beta = ', strcompress(Lacc_PaBeta), "+-", strcompress(Lacc_PaBetaError)
 
  ;Removed the .8, as there is a difference in accretion lumonicity and accretion column lumonicity: (3.155e7 / 1.99e30) * (Lacc_PaBeta * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)
  Mdot_PaBeta = (secondsPerYear / mSolarKg) * (Lacc_PaBeta * Lsun * (starRadius * solarRadiusMeters)) / (G * starMass * mSolarKg)
  Mdot_PaBetaError = abs(Mdot_PaBeta) * sqrt((0D / secondsPerYear)^2 + (mSolarKgError / mSolarKg)^2 + (Lacc_PaBetaError / Lacc_PaBeta)^2 + (LsunError / Lsun)^2 + (starRadiusError / starRadius)^2 + (solarRadiusMetersError / solarRadiusMeters)^2 + (0D / G)^2 + (starMassError / starMass)^2 + (mSolarKgError / mSolarKg)^2)  
  
  print, '    Mdot_PaBeta = ', strcompress( Mdot_PaBeta), "+-", strcompress(Mdot_PaBetaError)
  
  fluxArray[0] = f_PaBeta
  fluxErrorArray[0] = f_PaBetaError
  accretionArray[0] = Mdot_PaBeta
  accretionErrorArray[0] = Mdot_PaBetaError
  sourceArray[0] = '$Pa \beta$'
  methodArray[0] = 'Muzerolle 1998  AJ, 116, 2965'
  fileArray[0] = 'Pa Beta - Muzerolle 1998'
  
  ;-----------------------------
  
  print, '  Calculating Br Gamma: Muzerolle 1998  AJ, 116, 2965'
  f_BrGamma = double(linefluxAverage(13))
  f_BrGammaError = double(lineFluxAverageError(13))
  
  ;L_BrGamma = f_BrGamma * pi * (distance * pc)^2
  distanceMeters = distance * pc
  distanceMetersError = distanceError * pc

  distanceSquared = distanceMeters^2
  distanceSquaredError = abs((distanceSquared / distanceMeters) * 2D * distanceMetersError)
  
  fBrGammaPi = f_BrGamma * pi
  fBrGammaPiError = f_BrGammaError * pi

  L_BrGamma = fBrGammaPi * distanceSquared
  L_BrGammaError = abs(L_BrGamma) * sqrt((fBrGammaPiError / fBrGammaPi)^2 + (distanceSquaredError / distanceSquared)^2)
  
  print,'    Flux Br Gamma = ', strcompress(f_BrGamma), "+=", strcompress(f_BrGammaError), ' | Lum Br Gamma = ', strcompress(L_BrGamma), "+-", strcompress(L_BrGammaError)
  
  ; Muzerolle 1998  AJ, 116, 2965
  ;Log_Lacc_BrGamma = 1.26 * (alog10(L_BrGamma / Lsun)) + 4.43

  divide = L_BrGamma / Lsun
  divideError = abs(divide) * sqrt((L_BrGammaError / L_BrGamma)^2 + (LsunError / Lsun)^2)

  logbase10 = alog10(divide)
  logbase10error = (1D / alog(10D)) * (divideError / divide)

  scaledLog = 1.26D * logbase10
  scaledLogError = abs(scaledLog) * sqrt((0.19D / 1.26D)^2 + (logbase10error / logbase10)^2)

  Log_Lacc_BrGamma = scaledLog + 4.43D
  Log_Lacc_BrGammaError = sqrt(scaledLogError^2 + 0.79D^2)

  Lacc_BrGamma = 10D^(Log_Lacc_BrGamma)
  Lacc_BrGammaError = sqrt(((Log_Lacc_BrGamma / 10D) * 0D)^2 + (alog(10D) * Log_Lacc_BrGammaError)^2)
  
  print,'    Lacc Br Gamma = ', strcompress(Lacc_BrGamma), "+-", strcompress(Lacc_BrGammaError)
  
  ;Removed the .8, as there is a difference in accretion lumonicity and accretion column lumonicity: (3.155e7 / 1.99e30) * (Lacc_BrGamma * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)
  Mdot_BrGamma = (secondsPerYear / mSolarKg) * (Lacc_BrGamma * Lsun * (starRadius * solarRadiusMeters)) / (G * starMass * mSolarKg)
  Mdot_BrGammaError = abs(Mdot_BrGamma) * sqrt((0D / secondsPerYear)^2 + (mSolarKgError / mSolarKg)^2 + (Lacc_BrGammaError / Lacc_BrGamma)^2 + (LsunError / Lsun)^2 + (starRadiusError / starRadius)^2 + (solarRadiusMetersError / solarRadiusMeters)^2 + (0D / G)^2 + (starMassError / starMass)^2 + (mSolarKgError / mSolarKg)^2)  
  
  print, '    Mdot_BrGamma = ', strcompress( Mdot_BrGamma), "+-", strcompress(Mdot_BrGammaError)
  
  fluxArray[1] = f_BrGamma
  fluxErrorArray[1] = f_BrGammaError
  accretionArray[1] = Mdot_BrGamma
  accretionErrorArray[1] = Mdot_BrGammaError
  sourceArray[1] = '$Br \gamma$'
  methodArray[1] = 'Muzerolle 1998  AJ, 116, 2965'
  fileArray[1] = 'Br Gamma - Muzerolle 1998'
  
  ;-----------------------------
  
  print, '  Calculating Br Gamma: Calvet 2004 AJ, 128, 1294'
  f_BrGamma = double(linefluxAverage(13))
  f_BrGammaError = double(lineFluxAverageError(13))
  
  ;L_BrGamma = f_BrGamma * pi * (distance * pc)^2
  distanceMeters = distance * pc
  distanceMetersError = distanceError * pc

  distanceSquared = distanceMeters^2
  distanceSquaredError = abs((distanceSquared / distanceMeters) * 2D * distanceMetersError)
  
  fBrGammaPi = f_BrGamma * pi
  fBrGammaPiError = f_BrGammaError * pi

  L_BrGamma = fBrGammaPi * distanceSquared
  L_BrGammaError = abs(L_BrGamma) * sqrt((fBrGammaPiError / fBrGammaPi)^2 + (distanceSquaredError / distanceSquared)^2)
  
  print,'    Flux Br Gamma = ', strcompress(f_BrGamma), "+=", strcompress(f_BrGammaError), ' | Lum Br Gamma = ', strcompress(L_BrGamma), "+-", strcompress(L_BrGammaError)
  
  ; Calvet 2004 AJ, 128, 1294
  ;Log_Lacc_BrGamma2 = (0.9 * (alog10(L_BrGamma) / Lsun) + 4.0) - 0.7 ----> Error in paper, Lsun should be in the log?
  ;Log_Lacc_BrGamma2 = (0.9 * (alog10(L_BrGamma / Lsun) + 4.0)) - 0.7
  
  divide = L_BrGamma / Lsun
  divideError = abs(divide) * sqrt((L_BrGammaError / L_BrGamma)^2 + (LsunError / Lsun)^2)

  logbase10 = alog10(divide)
  logbase10error = (1D / alog(10D)) * (divideError / divide)
  
  logSum = logbase10 + 4.0D
  logSumError = sqrt(logbase10error^2 + 0.67D^2)
  
  scale = logSum * 0.9D
  scaleError = abs(scale) * sqrt((logSumError / logSum)^2 + ( 0.53D / 0.9D)^2)
  
  Log_Lacc_BrGamma2 = scale - 0.7D
  Log_Lacc_BrGamma2Error = sqrt(scaleError^2 + 0.19D^2)
  
  Lacc_BrGamma2 = 10D^(Log_Lacc_BrGamma2)
  Lacc_BrGamma2Error = sqrt(((Log_Lacc_BrGamma2 / 10D) * 0D)^2 + (alog(10D) * Log_Lacc_BrGamma2Error)^2)
  
  print,'    Lacc Br Gamma = ', strcompress(Lacc_BrGamma2), "+-", strcompress(Lacc_BrGamma2Error)
  
  ;Removed the .8, as there is a difference in accretion lumonicity and accretion column lumonicity: (3.155e7 / 1.99e30) * (Lacc_BrGamma2 * 3.85e26 * (starRadius * 6.96e8)) / (0.8 * G * starMass * 1.99e30)
  Mdot_BrGamma2 = (secondsPerYear / mSolarKg) * (Lacc_BrGamma2 * Lsun * (starRadius * solarRadiusMeters)) / (G * starMass * mSolarKg)
  Mdot_BrGamma2Error = abs(Mdot_BrGamma2) * sqrt((0D / secondsPerYear)^2 + (mSolarKgError / mSolarKg)^2 + (Lacc_BrGamma2Error / Lacc_BrGamma2)^2 + (LsunError / Lsun)^2 + (starRadiusError / starRadius)^2 + (solarRadiusMetersError / solarRadiusMeters)^2 + (0D / G)^2 + (starMassError / starMass)^2 + (mSolarKgError / mSolarKg)^2)  
   
  print, '    Mdot_BrGamma2 = ', strcompress( Mdot_BrGamma2), "+-", strcompress(Mdot_BrGamma2Error)
  
  
  fluxArray[2] = f_BrGamma
  fluxErrorArray[2] = f_BrGammaError
  accretionArray[2] = Mdot_BrGamma2
  accretionErrorArray[2] = Mdot_BrGamma2Error
  sourceArray[2] = '$Br \gamma$'
  methodArray[2] = 'Calvet 2004 AJ, 128, 1294'
  fileArray[2] = 'Br Gamma -  Calvet 2004'
  
  
  save, filename = saveFolder + '/' + targetname + '_' + targetObservationDate + '_' + smoothDescription + '_accretion_rates.sav', distance, distanceerror, starMass, starmasserror, starRadius, starradiuserror, targetName, targetObservationDate, fluxArray, fluxErrorArray, accretionArray, accretionErrorArray, sourceArray, methodArray, fileArray
  
  print,'  Process Completed!'
end