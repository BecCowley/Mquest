function createkeys(filenam)
%createkeys - this creates an empty keys file for new databases
% if the file already exists, returns the schema for the file.
%Updated to become a function and to use the Matlab netcdf tools.
%Bec Cowley, June, 2016

if ~exist(filenam,'file')
    nc = getMQschema_keysfile;
    
    ncwriteschema(filenam,nc);
end
return
end
