function nc = getMQschema_keysfile
% create the netcdf schema for MQuest files.
% Bec Cowley, May 2016

% load up the blank netcdf schema from mat file:

if exist('blank_nc_keysfile.mat','file')
    load blank_nc_keysfile.mat
    nc = kf;
else
    %make it from scratch. This needs to be developed, but shouldn't be
    %needed if the blank_nc_keysfile.mat file is available.
    disp('Unable to make the keysfile file from scratch, need to do more coding here')
    nc = [];
end

