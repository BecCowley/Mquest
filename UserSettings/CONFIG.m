% CONFIG - sets up the environmental and path variables for Mquest - this
% must be edited when the program is installed on a new system.
 
global DATA_SOURCE
global DATA_PRIORITY
global MQUEST_DIRECTORY_PC
global DATA_QC_SOURCE

   DATA_SOURCE='CSIRO';
%      DATA_SOURCE='AODC';
   DATA_QC_SOURCE='CS';
%     DATA_QC_SOURCE='AD';
    DATA_PRIORITY=1;
    
if(~ispc)
    % configuration bits for UNIX/LINUX:
global UNIQUE_ID_PATH_UNIX LAND_MASK_FILE_UNIX MAP_FILE_UNIX  TOPO_FILE_UNIX 
global CLIMATOLOGY_PATH_UNIX LEVITUSDATA_PATH_UNIX MQUEST_DIRECTORY_UNIX
    
UNIQUE_ID_PATH_UNIX='/Users/cow074/Documents/work_mac/Mquest/Mquest/UserSettings/';

    MAP_FILE_UNIX='/Users/cow074/Documents/work_mac/Mquest/Mquest/Bathymetry/terrainbase';

    CLIMATOLOGY_PATH_UNIX='/Users/cow074/Documents/work_mac/Mquest/Mquest/CARSatlas/';
%     LEVITUSDATA_PATH_UNIX='/media/sf_Mquest/CARSatlas/levitusdata/';

    MQUEST_DIRECTORY_UNIX='/Users/cow074/Documents/work_mac/Mquest/Mquest/UserSettings/';
    addpath(MQUEST_DIRECTORY_UNIX);
   
else
% configuration bits for PC:
global UNIQUE_ID_PATH_PC LAND_MASK_FILE_PC MAP_FILE_PC  TOPO_FILE_PC 
global CLIMATOLOGY_PATH_PC LEVITUSDATA_PATH_PC MQUEST_DIRECTORY_PC

    UNIQUE_ID_PATH_PC='/home/gronell/';
    
% Note: this second path points to the unique id file on unix and the drive
% must be mapped on the pc for this to work. It's more efficient if you're
% running both on unix AND a pc to keep one unique id file - this prevents
% using the same id for more than one file

    UNIQUE_ID_PATH_UNIX_FROM_PC='k:/gronell/';

    MAP_FILE_PC='C:\Documents and Settings\thr020\My Documents\work stuff collected\questdevelopment\netcdf-data\terrainbase';

    CLIMATOLOGY_PATH_PC='C:\Documents and Settings\thr020\My Documents\work stuff collected\questdevelopment\CARSatlas\carsdata\';
    LEVITUSDATA_PATH_PC='C:\Documents and Settings\thr020\My Documents\work stuff collected\questdevelopment\CARSatlas\levitusdata\';

    MQUEST_DIRECTORY_PC='C:\Documents and Settings\thr020\My Documents\work stuff collected\questdevelopment\';

    addpath(MQUEST_DIRECTORY_PC);

end
