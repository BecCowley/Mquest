function createkeys_fromDirectory(database)
%Create a keys file from the directory structure
%for when you lose the keys
% Inputs: createkeys_fromDirectory(database)
%   database = full path name of the database folder (eg:
%   '/home/XBTdata/databasename')
%
%Bec Cowley, Jan, 2020

if nargin < 1
    disp('function requires a full path to the database structure')
    return
end
global DATA_SOURCE

CONFIG

keysfile = [database '_keys.nc'];
createkeys(keysfile)
% prefix={database};
% mmm={'All'} ;
% yy={'All'} ;
% qc={'None'};
% auto={'1'};
% tw={'1'};
% sstyle={'None'};
% [keysdata]=getkeys(prefix,mmm,yy,qc,auto,tw,sstyle);

keysdata.prefix = database;
d = genpath(database);
ii = strfind(d,':');
pth{1} = cellstr(d(1:ii(1)-1));
for a = 2:length(ii)-1
    pth{a} = d(ii(a)+1:ii(a+1)-1);
end
ist = 0;
for a = 1:length(pth)
    dd = dir([char(pth{a}) '/*ed.nc']);
    %set up path:
    ii = strfind(char(pth{a}),'/');
    nn = char(pth{a});
    st=[];
    for c = 1:length(ii)-1
        ss = nn(ii(c)+1:ii(c+1)-1);
        if ~isempty(str2num(ss))
            st = [st ss];
        end
    end
    if ~isempty(st)
        st = [st nn(ii(end)+1:end)];
    else
        continue
    end
    for b = 1:length(dd)
        ist = ist+1;
        %include in keys:
        stn = [st dd(b).name(1:2)];
        dummy = '          ';
        dummy(1:length(stn)) =stn;
        keysdata.stnnum(ist,:) = dummy;
        filn = [nn '/' dd(b).name];
        t = num2str(ncread(filn,'woce_time'));
        da = num2str(ncread(filn,'woce_date'));
        lat = ncread(filn,'latitude');
        ln = ncread(filn,'longitude');
        ds = ncread(filn,'Stream_Ident');
        srf = ncread(filn,'SRFC_Code');
        srfp = ncread(filn,'SRFC_Parm');
        call = strmatch('GCLL',srf');
        
        if length(t) < 6
            %pad it
            dummy(1:6-length(t)) = '0';
            dummy(6-length(t)+1:6) = t;
            t=dummy;
        end
        keysdata.time(ist,:) = t(1:4);
        keysdata.day(ist,:) = da(7:8);
        keysdata.month(ist,:) = da(5:6);
        keysdata.year(ist,:) = da(1:4);
        keysdata.obslat(ist) = lat;
        keysdata.obslon(ist) = ln;
        if ~isempty(call)
            keysdata.callsign(ist,:) = srfp(:,call)';
        else
            keysdata.callsign(ist,:) = '          ';
        end
        keysdata.priority(ist) = 1;
        keysdata.datasource(ist,:) = '          ';
        keysdata.datasource(ist,1:length(DATA_SOURCE)) = DATA_SOURCE;
        keysdata.datatype(ist,:) = ds(3:4);
    end
end

keysdata.obslat = keysdata.obslat';
keysdata.obslon = keysdata.obslon';
keysdata.priority = keysdata.priority';
keysdata.autoqc(1:length(keysdata.obslat))=0;

ncwrite(keysfile,'obslat',keysdata.obslat)
ncwrite(keysfile,'obslng',keysdata.obslon);
ncwrite(keysfile,'c360long',keysdata.obslon);
ncwrite(keysfile,'autoqc',keysdata.autoqc);
ncwrite(keysfile,'stn_num',keysdata.stnnum');
ncwrite(keysfile,'callsign',keysdata.callsign');
ncwrite(keysfile,'obs_y',keysdata.year');
ncwrite(keysfile,'obs_d',keysdata.day');
ncwrite(keysfile,'obs_m',keysdata.month');
ncwrite(keysfile,'obs_t',keysdata.time');
ncwrite(keysfile,'data_t',keysdata.datatype');
ncwrite(keysfile,'data_source',keysdata.datasource');
ncwrite(keysfile,'priority',keysdata.priority);
  
