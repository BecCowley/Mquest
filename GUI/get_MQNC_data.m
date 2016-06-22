function [lat,lon,stn,tim,deep_d,dtyp,cruise,calls,v1,v2,v3,v4] = get_MQNC_data(kd,rng,var,dset,scr,dups,strp,trng)
% GET_MQNC_DATA  Get ocean cast data from MQNC dataset
%
% INPUT:  
%  kd     keys data from getkeys.m
%  rng    [w e s n] limits of region of required data
%  var    vector of property codes: (see prop_name.m) 
%         1)t   2)s
%  dset   dataset name
%  scr    0 - disable pre-flagged bad-cast and bad-individual-data screening
%         1 - [default] all flags applied
%  dups   0= don't remove any dups
%         1= remove dups [default] 
%  strp   0= return all casts, even if no data
%         1= return only casts with some data in profiles [default]
%  trng   [t1 t2] time range (days since 1900). [default - no restriction]
%
% OUTPUT:
%  lat,lon, then header vars [ncast 1] in order requested, then profile vars
%  [ncast ndep] in order {where ndep may be less than number of depths requested, 
%  if no good data that deep for that particular variable.}
%
% NOTE:  Empty depth columns will only occur if there is deeper good data.
% (this should not happen, but need to check we don't have any deeper good
% data!).
%   If strp=0, all stations will be returned.
%   If strp=1, for each cast-row there will be at least some data in at least one
%   of the returned variables. 
%
% USAGE: [lat,lon,stn,tim,deep_d,dtyp,cruise,v1,v2,v3,v4] = get_MQNC_data(kd,rng,var,dset,scr,dups,strp,trng);

% Author: Bec Cowley CSIRO Dec 2012

%set up the variables:
if isempty(scr)
    scr = 1;
end
if isempty(dups)
    dups = 1;
end
if isempty(strp)
    strp = 1;
end
if isempty(trng)
    trng = [datenum([1600 1 1 0 0 0]) datenum(now)];
end

% make date:
ti = datenum(kd.year,kd.month,kd.day,floor(kd.time/100),rem(kd.time/100,1)*100,repmat(0,length(kd.year),1));

%now subset by the range:
ii = find((kd.obslat >= rng(3) & kd.obslat <= rng(4)) & (kd.obslon >= rng(1) & kd.obslon <= rng(2)) ...
    & (ti >= trng(1) & ti <= trng(2)));

if isempty(ii)
    [lat,lon,stn,tim,deep_d,dtyp,cruise,calls,v1,v2,v3,v4] = deal([]);
    return
end

stn = kd.stnnum(ii,:);
tim = ti(ii);
lat = kd.obslat(ii);
lon = kd.obslon(ii);
dtyp = kd.datatype(ii,:);
calls = kd.callsign(ii,:);

%set up variables:
v1 = NaN*ones(length(ii),7000);
v2 = v1; v3 = v1;v4 = v1;

%Now open each file in the subset and get the data to return:
for a = 1:length(ii)
    %get the name of the file:
    filn = getfilename(num2str(stn(a,:)),0);
    filn = [dset '/' filn]
    
    %open the file
    ncid = netcdf.open(filn,'NC_NOWRITE'); 
    
    %check for DU and skip if requested
    varid = netcdf.inqVarID(ncid,'Dup_Flag');
    df = netcdf.getVar(ncid,varid);    
    if dups == 1 & ~isempty(strmatch('D',df))
        netcdf.close(ncid)
        continue
    end
    
    %now get the data. Check for no data:
    varid = netcdf.inqVarID(ncid,'No_Prof');
    np = netcdf.getVar(ncid,varid);
    varid = netcdf.inqVarID(ncid,'D_P_Code');
    dp = netcdf.getVar(ncid,varid);
    varid = netcdf.inqVarID(ncid,'ProfQP');
    qc = netcdf.getVar(ncid,varid);
    varid = netcdf.inqVarID(ncid,'Deep_Depth');
    dd = netcdf.getVar(ncid,varid);
    varid = netcdf.inqVarID(ncid,'Cruise_ID');
    ci = netcdf.getVar(ncid,varid);
    varid = netcdf.inqVarID(ncid,'Depthpress');
    depth = netcdf.getVar(ncid,varid);
    %convert pressure to depth if needed:
    if ~isempty(strmatch('P',dp))
        depth = sw_dpth(depth,lat(a));
    end
    
    varid = netcdf.inqVarID(ncid,'Profparm');
    ts = netcdf.getVar(ncid,varid);
    
    if np > 1
        %has salinity & or conductivity
        varid = netcdf.inqVarID(ncid,'Prof_Type');
        pt = netcdf.getVar(ncid,varid);
        itemp = strmatch('TEMP',pt');
        isal = strmatch('PSAL',pt');
    else
        itemp = 1;
        isal = [];
        sal = [];
    end
    qc = squeeze(qc);
    ts = squeeze(ts);
    temp = ts(:,itemp);
    if ~isempty(isal)
        sal = ts(:,isal);
        [mm,imaxs] = min(abs(depth(:,isal) - dd(isal)));
    end
    
    [mm,imaxt] = min(abs(depth(:,itemp) - dd(itemp)));
    
    %return good data only:
    if scr == 1
        qct = str2num(qc(1:imaxt,itemp));
        igood = find(qct < 3);
        v1(a,1:length(igood)) = depth(igood,itemp);
        v2(a,1:length(igood)) = temp(igood);
        if ~isempty(isal)
            qcs = str2num(qc(1:imaxs,isal));
            igood = find(qcs < 3);
            v3(a,1:length(igood)) = depth(igood,isal);
            v4(a,1:length(igood)) = sal(igood);
        end
    else%return all data
        v1(a,1:imaxt) = depth(1:imaxt);
        v2(a,1:imaxt) = temp(1:imaxt);
        if ~isempty(isal)
            v3(a,1:imaxs) = sal(1:imaxs);
        end
    end
    
    %record the cruiseid, deep_depth:
    deep_d(a) = dd(1);
    cruise(a,:) = ci';
    netcdf.close(ncid);
    
end
%now get rid of profiles with no data if required:
if strp == 1
    ss = nansum(v1,2);
    ibad = isnan(ss);
    %remove these profiles, no valid data:
    v1(ibad,:) = [];
    v2(ibad,:) = [];
    v3(ibad,:) = [];
    v4(ibad,:) = [];
    dtyp(ibad,:) = [];
    stn(ibad) = [];
    lat(ibad) = [];
    lon(ibad) = [];
    tim(ibad) = [];
    deep_d(ibad) = [];
    cruise(ibad,:) = [];
    calls(ibad,:) = [];
end
end