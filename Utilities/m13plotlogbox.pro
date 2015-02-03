;
; Copyright (c) 2014, Dr. Michael Sitko, Brandon McQuilkin
;+
; NAME:
; M13PlotLogBox
;
; PURPOSE:
; Generates a log plot for plotting spectral data.
;
; CATEGORY:
; Astronomy
;
; CALLING SEQUENCE:
; m13plotlogbox, xmin, xmax, ymin, ymax, atitle, xtitle, ytitle, size
; 
; INPUTS:
; xmin The minimum x value that the plot will show.
; xmax The maximum x value that the plot will show.
; ymin The minimum y value that the plot will show.
; ymax The maximum y value that the plot will show.
; atitle The title of the plot.
; xtitle The title of the X axis.
; ytitle The title of the Y axis.
; size The dimensions of the plot.
;
; MODIFICATION HISTORY:
;   Written by: Brandon McQuilkin, July 8th, 2014.
;-
function m13plotlogbox, xmin, xmax, ymin, ymax, atitle, xtitle, ytitle, size

  ; Create the plot object
  theplot = PLOT(findgen(2), /nodata, /xlog, /ylog, font_size = 20, thick = 2.0, title = atitle, xrange = [xmin, xmax], yrange = [ymin, ymax], margin = [.2, .14, .12, .12], dimensions = size) 
  
  ;Set the title formatting
  theplot.font_size = 30
  
  ;Axes formatting
  theaxes = theplot.axes
  theaxes[0].title = xtitle
  theaxes[1].title = ytitle
  
  theaxes[0].thick = 2.0
  theaxes[1].thick = 2.0
  theaxes[2].thick = 2.0
  theaxes[3].thick = 2.0
  
  theaxes[0].ticklen = .015
  theaxes[1].ticklen = .015
  theaxes[2].ticklen = .015
  theaxes[3].ticklen = .015

  return, theplot
end