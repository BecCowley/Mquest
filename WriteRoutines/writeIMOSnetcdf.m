function writeIMOSnetcdf(profiledata,pd,writekeys)
%function writeIMOSnetcdf(profiledata,pd,writekeys)
% Function to write out the data to IMOS format netcdf files.
% Uses the generate_netcdf_att file set up by IMOS data-services.
% Bec Cowley, March, 2020

% Let's output to one directory only (Will need to step through this to
% debug)
if(pd.ndep==0)
    return
end
filenamnew=[pd.outputfile{1} '/' pd.nss '.nc'];

%load up the netcdf template required and write out a blank file to start:
if ~exist(filenamnew,'file')
    nc = getIMOSnc_schema;
    %create directory if required
    if exist(pd.outputfile{1},'dir') ~= 7
        mkdir(pd.outputfile{1})
    end
    ncwriteschema(filenamnew,nc);
end

%now fill the netcdf file with the data:



end


