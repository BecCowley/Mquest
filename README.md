# Mquest
Mquest source code for XBT profile QC

Documents folder contains the user manual (a little out of date, but still ok).

SHORTCUT KEYS: see 'MQuESTmanual.doc' in Documents folder.

1) Clone git repository with Mquest files: https://github.com/BecCowley/Mquest.git
2) Set up the CONFIG.m file with correct paths for your system before loading Mquest.
3) Install additional files. Here is a link to get all the files you need to get Mquest working: https://drive.google.com/drive/folders/1tmLg7BL_dsIYALVQIHmhJ53DOWjcD8tZ?usp=sharing

Unzip the files from the link and put them in the following directories :
* UserSettings/calls.txt
* UserSettings/CONFIG.m
* UserSettings/ships.txt
* UserSettings/uniqueid.mat
* CARSatlas/temperature_Argo_2006_Jan2019.nc
* Bathymetry/terrainbase.nc

4) Set the Matlab paths to include the folder that contains your Mquest code.

5) To import data:
 
Open MATLAB and set the current directory to be above where your data is located, eg: if the XBT data is in /source/Data/XBT, change directory to /source/Data before running Mquest.

Run Mquest: Mquest(‘name’). 'name' is any string that gives a profile to the startup. Startup settings are then saved to that name.

Make up a data prefix name, this will be the directory in which your QC’d data is stored. For example: 'CSIROXBT2019'  Output will be in /source/Data/CSIROXBT2019.

Ignore everything else for now, click button to start Mquest.
To import data: Click on data type FIRST (i.e. Devil), then single click on directory where data is stored.  
Click Import button.
The MATLAB command line will ask for confirmation of SOOP line identifier (recommend using 'NOLINE' if this is not applicable), ship callsign, voyage name, then shipname (if it is not already in the ships.txt file).

## More information:

You can run Mquest without a buddy database. When you start it up, enter a database name for your data and that will appear in the 'buddy' window below. If you wanted to add buddy databases, you could by clicking in that window. But if you don't have any, don't add any.

The CSIRO Cookbook will help with describing which flags to use. The main ones to use are:
* WBR = wire break reject (w key or q w keys)
* WSR = wire stretch reject (I use the drop down menu, but I think there are some shortcut keys for this).
* LER = leakage reject (q k keys)
* IPR = insulation penetration reject (q v keys)
* CSA = chop surface spikes accept (c key)
* HBR/NGR = hit bottom reject/no good reject (z key)
* IVA = inversion accept (q i keys)

## Reference:
Cowley, Rebecca; Krummel, Lisa. Australian XBT Quality Control Cookbook Version 2.1. Hobart, Tasmania, Australia: CSIRO; 2022. csiro:EP2022-1825. https://doi.org/10.25919/3tm5-zn80)
