<img src="https://raw.github.com/Marxon13/M13AstroTools/master/ImageResources/M13AstroToolsBanner.png">

M13AstroTools
=============

A set of tools for processing astronomical data, mainly processing and plotting fits files from Spextool to model dust disks.

Tools
---------

**Utilities**

- _M13FitsToCSV_: Converts fits files to CSV files using λfλ.
- _M13PlotLogBox_: Creates the base for a log plot used in other functions.

**Dust Modeling**

Check out the manual to see how to run the code step by step!

- _M13StarFitter_: Helps calculate the various parameters necessary to create a model of a dust disk. This is a Mathematica notebook, but a PDF form has been included so that it can be read by people without a Mathematica License.
- _M13ModelCreator_: Using specified parameters and a standard star, plots a model of the dust disk emission against the target star.
- _M13BandFlux_: Calculates the average flux in the JHKL bands.
- _M13AutoLines_: Auto plots and calculates the flux for various emission lines.
- _M13AccretionRate_: Calculates the accretion rate of the dust using two formulae. 
- _M13LineCompare_: Plots the spectra around various emission lines for different sets of collected data together.
- _M13LineCompareChart_: Plots the changes in various emission lines over time.
- _M13AccretionCompareChart_: Plots the changes in the accretion rate over time.

Necessary Libraries
-------------------
- [NASA's IDL Astro Library](https://github.com/wlandsman/IDLAstro)
- [Spextool Library](http://irtfweb.ifa.hawaii.edu/~spex/)

TODO:
--------

- Replace gridterp with an actively maintained substitute.
- Replace parcheck with an actively maintained substitute. 
- Fix the annotation placement so that it is determined by its size in data points, not arbitrary percentage offsets.