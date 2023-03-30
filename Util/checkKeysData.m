function [lat,lon,c360lon,calls,datetime,time,dtype,dsource,testp] = checkKeysData(filenam,index, keysdat)
%function to check the metadata in the keys file matches the metadata in
%the edited file (or raw file if input)
% called by fix_missingMetadata.m
%Bec Cowley, June, 2022

narginchk(3,3)

%assume all ok to start
lat = 1;
lon = 1;
c360lon = 1;
calls = 1;
datetime = 1;
time = 1;
dtype = 1;
dsource = 1;
testp = 0;

%TP and DU flags
flg=ncread(filenam,'Act_Code');
if ~isempty(strmatch('TP',flg')) | ~isempty(strmatch('DU',flg'))
    %let's ignore these profiles for this exercise
    testp = 1;
    return
end


% of course, the keys file has different variable names to what is in the
% actual file, so have to be painful and match them up.

%lat/long
lt = ncread(filenam,'latitude');
if lt ~= keysdat.obslat(index);
    lat = 0;
end
ln = ncread(filenam,'longitude');
if ln ~= keysdat.obslng(index);
    lon = 0;
end
if ln ~= keysdat.c360long(index);
    c360lon = 0;
end

%date/time
dtt = [keysdat.obs_y(:,index)' keysdat.obs_m(:,index)' keysdat.obs_d(:,index)' ...
    keysdat.obs_t(:,index)'];
%pad with zeros where blanks
dtt(isspace(dtt)) = '0';
datt = datenum(dtt,'yyyymmddHHMM');
tim = double(ncread(filenam,'time') + datenum('1900-01-01 00:00:00', 'yyyy-mm-dd HH:MM:SS'));
wd = ncread(filenam,'woce_date');
wt = ncread(filenam,'woce_time');
wdt = datenum([num2str(wd,'%06.0f') num2str(wt,'%06.0f')],'yyyymmddHHMMSS');

if wdt ~= datt
    datetime = 0;
end
if tim ~= datt
    time = 0;
end

%stn_num
% this check is performed by the CSID check

%callsign
srfccodes=ncread(filenam,'SRFC_Code');
srfcparm=ncread(filenam,'SRFC_Parm');

kk = strmatch('GCLL',srfccodes');
if ~isempty(kk)
    clls = srfcparm(:,kk)';
    if ~strcmp(clls,keysdat.callsign(:,index)')
        calls = 0;
    end
else
    calls = 0;
end

%data_t
dt = ncread(filenam,'Data_Type');
if ~strcmp(dt,keysdat.data_t(:,index))
    dtype = 0;
end

%d_flag - probably not important, sometimes isn't right anyway.

%data_source
ds = ncread(filenam,'Stream_Ident');
if all(upper(ds(1:2,:)) ~= upper(keysdat.data_source(1:2,index)))
    dsource = 0;
end

%priority not useful