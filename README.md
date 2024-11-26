# Mquest
Mquest source code for XBT profile QC

Documents folder contains the user manual (a little out of date, but still ok).

SHORTCUT KEYS: see 'MQuESTmanual.doc' in Documents folder.

1) Clone git repository with Mquest files: https://github.com/BecCowley/Mquest.git
2) Set up the CONFIG.m file with correct paths for your system before loading Mquest.
3) Install additional files. Here is a link to get all the files you need to get Mquest working https://drive.google.com/drive/folders/1tmLg7BL_dsIYALVQIHmhJ53DOWjcD8tZ?usp=sharing
Unzip the files from the link and put them in the following directories :
UserSettings/calls.txt
UserSettings/CONFIG.m
UserSettings/ships.txt
UserSettings/uniqueid.mat
CARSatlas/temperature_Argo_2006_Jan2019.nc
Bathymetry/terrainbase.nc

4) Set the Matlab paths to include the folder that contains your Mquest code.

5) To import data:
 
Open MATLAB and set the current directory to be above where your data is located, eg: XBT data is in /source/Data/XBT, so cd to /source/Data

Run Mquest: Mquest(‘name’). 'name' is any string that gives a profile to the startup. Startup settings are then saved to that name.

Make up a data prefix name, this will be the directory in which your QC’d data is stored. For example: 'CSIROXBT2019'  Output will be in /source/Data/CSIROXBT2019
Ignore everything else for now, click button to start Mquest.
To import data: Click on data type FIRST (i.e. MLK21 NZ), then single click on directory where data is stored.  Import.
MATLAB command line will ask for ship callsign, then voyage number, then shipname.  The information entered here will be added to the ships.txt file and next time this information will be matched by callsign. Also add an appropriate voyage number.

6) More information:

You can run Mquest without a buddy database. When you start it up, enter a database name for your data and that will appear in the 'buddy' window below. If you wanted to add buddy databases, you could by clicking in that window. But if you don't have any, don't add any.

The CSIRO Cookbook will help with describing which flags to use. The main ones to use are:
•	 WBR = wire break reject (w key or q w keys)
•	WSR = wire stretch reject (I use the drop down menu, but I think there are some shortcut keys for this).
•	LER = leakage reject (q k keys)
•	IPR = insulation penetration reject (q v keys)
•	CSA = chop surface spikes accept (c key)
•	HBR/NGR = hit bottom reject/no good reject (z key)
•	IVA = inversion accept (q i keys)
(CSIRO cookbook: http://www.marine.csiro.au/~gronell/cookbook/csiro.htm)
