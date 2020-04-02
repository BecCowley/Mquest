function nc = getIMOSnc_schema
% Grab the netcdf schema for IMOS netcdf files
% Bec Cowley, March, 2020

% load up the blank netcdf schema from mat file:

if exist('ncblank_imos_original.mat','file')
    load('ncblank_imos_original.mat','ncblank')
    nc = ncblank;
    return
else
    disp('getIMOSnc_schema.m: Unable to make the netcdf file, please check that the ''ncblank_imos.mat'' file is in the matlab path')
    return
end

