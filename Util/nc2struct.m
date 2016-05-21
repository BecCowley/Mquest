function ncdat = nc2struct(fn)
% function ncdat = getkeys_bec(prefix)
% get all the data from a netcdf file
% returns data in a structure with same names as the variables in the nc
% % file. eg:
% ncdat = 
% 
%          obslat: [885x1 single]
%          obslng: [885x1 single]
%        c360long: [885x1 single]
%          autoqc: [885x1 double]
%         stn_num: [885x10 char]
%        callsign: [885x10 char]
%           obs_y: [885x4 char]
%           obs_t: [885x4 char]
%           obs_m: [885x2 char]
%           obs_d: [885x2 char]
%          data_t: [885x2 char]
%          d_flag: [885x1 char]
%     data_source: [885x10 char]
%        priority: [885x1 int32]
% Bec Cowley,2 October, 2012

if exist(fn,'file') == 0
    disp(['File ' fn ' does not exist'])
    ncdat = [];
    return
end

% retrieve the netcdf file variables:
finf = ncinfo(fn);

% now get the variables and assign data to a structure:
for a = 1:length(finf.Variables)
    %get the field name
    nn = finf.Variables(a).Name;
    %get the data:
    dat = ncread(fn,nn);
    %get the size and number of dimensions:
    nd = size(dat);
    [nd,ii] = sort(nd,'descend');
    %permute to order dimensions:
    dat = permute(dat,ii);
    
    eval(['s.' nn '= dat;'])
end

ncdat = s;

end