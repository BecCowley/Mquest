%find profile numbers that are not included in the keys file (and therefore
%are not to be considered as profiles.
% Designed as a check for IMOS. They have not read the keys files and have
% just converted ALL the NC files in our databases.
% Bec Cowley, November, 2015


clear
inp = '/home/UOT-data/quest/mer/';
inp2 = '/home/UOT-data/quest/antarctic/';
inp3 = '/home/UOT-data/quest/BOM/';
inp4 = '/home/UOT-data/quest/franklinarchives/';
inp5 = [inp4 'franklin_1994to1996/'];
inp6 = '/home/UOT-data/quest/southernSurveyordata/';

prefix = {'GTSPPmer2003MQNC'  ...
    'GTSPPmer2006MQNC'  'GTSPPmer2014MQNC'...
    'GTSPPmer99MQNC' 'GTSPPmer2005MQNC'...
    'GTSPPmer2010MQNC'  'GTSPPmer96MQNC'    'GTSPPmerMQNC'...
    'antarctic2000MQNC'  'antarctic2010MQNC'...
    'antarctic92to96MQNC' 'antarctic2005MQNC'...
    'antarctic2014MQNC'  'antarctic97to99MQNC' ...
    'BOM2000MQNC'  'BOM2003MQNC'  'BOM2006MQNC'  'BOM2009_090831_add'...
    'BOM2011'  'BOM2014'...
    'BOM2001MQNC'  'BOM2004MQNC'  'BOM2007'     'BOM2009'...
    'BOM2012'  'BOMdataMQNC' ...
    'BOM2002MQNC'  'BOM2005MQNC'  'BOM2008'     'BOM2010'   'BOM2013'...
    'franklinarchiveMQNC' 'franklinarchiveMQNC_old' 'franklin94to96MQNC' ...
    'ss2004_2006' 'ss2007_2012_withss2012t01' 'ss2013t01'  'ss2013_v05'};

ist = 0;
allkeys = [];
%%
for ip = 34:length(prefix)    
    eval(['cd ' inp])
    
    if exist([inp prefix{ip} '_keys.nc'],'file')==0
        eval(['cd ' inp2])
        if exist([inp2 prefix{ip} '_keys.nc'],'file')==0
            eval(['cd ' inp3])
            if exist([inp3 prefix{ip} '_keys.nc'],'file')==0
                eval(['cd ' inp4])
                if exist([inp4 prefix{ip} '_keys.nc'],'file')==0
                    eval(['cd ' inp5])
                    if exist([inp5 prefix{ip} '_keys.nc'],'file')==0
                        eval(['cd ' inp6])
                    end
                end
            end
        end
        
    end
        
    %get the keys station numbers:
    p={prefix{ip}};
    m={'All'};
    y={'All'};
    q={'1'};
    a={'1'};
    tw={'1'};
    sstyle={'None'};
    [keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
    
    
    %list all the folders:
    d = genpath(prefix{ip});
    
    clear pth
    
    ii = strfind(d,':');
    pth{1} = d(1:ii(1)-1);
    for ia = 2:length(ii)-1
        pth{ia} = d(ii(ia)+1:ii(ia+1)-1);
    end
    
    
    for ia = 1:length(pth)
        dd = dir([char(pth{ia}) '/*ed.nc']);
        %set up path:
        ii = strfind(char(pth{ia}),'/');
        nn = char(pth{ia});
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
            %keep info, but only if not in keys list
            stn = [st dd(b).name(1:end-5)];
            
            if isempty(find(keysdata.stnnum == str2num(stn)))
                ist = ist+1;
                allfiles.prefix{ist} = prefix(ip);
                allfiles.stnnum(ist) = str2num(stn);
                filn = [nn '/' dd(b).name];
                t = num2str(getnc(filn,'woce_time'));
                da = num2str(getnc(filn,'woce_date'));
                lat = getnc(filn,'latitude');
                ln = getnc(filn,'longitude');
                ds = getnc(filn,'Stream_Ident');
                srf = getnc(filn,'SRFC_Code');
                srfp = getnc(filn,'SRFC_Parm');
                call = strmatch('GCLL',srf);
                
                if length(t) < 6
                    %pad it
                    dummy(1:6-length(t)) = '0';
                    dummy(6-length(t)+1:6) = t;
                    t=dummy;
                end
                try
                    allfiles.time(ist,:) = t(1:4);
                    allfiles.day(ist,:) = da(7:8);
                    allfiles.month(ist,:) = da(5:6);
                    allfiles.year(ist,:) = da(1:4);
                    allfiles.obslat(ist) = lat;
                    allfiles.obslon(ist) = ln;
                    if ~isempty(call)
                        allfiles.callsign(ist,:) = srfp(call,:);
                    else
                        allfiles.callsign(ist,:) = '          ';
                    end
                catch
                end
            end
        end
    end
    %append all the keysfiles together
    allkeys = [allkeys; keysdata];
end
%%
for ip = 1:length(allkeys)
    %check if any of the extra profiles exist in any GTSPP database
    [c,ia,ib] = intersect(allfiles.stnnum,allkeys(ip).stnnum);
    %if they do, then we need to check if they are the same profile
    %(date/time/lat/lon)
    %if they are, then they are duplicates and in two databases, but only exist
    %in the keys of one (or more?)
    %if they don't, then
    if ~isempty(c)
        disp(ip)
        return
    end
end

return
%% get out known duplciates into a list:
ip = 9;
tim = num2str(allkeys(ip).time);
ii = tim == ' ';
tim(ii) = '0';
mn = num2str(allkeys(ip).month);
ii = mn == ' ';
mn(ii) = '0';
da=num2str(allkeys(ip).day);
ii = da == ' ';
da(ii) = '0';

ti = datenum([num2str(allkeys(ip).year) mn da tim],'yyyymmddHHMM');
[c,ia,ic] = unique(ti,'first'); 

lia = ismember(allkeys(ip).stnnum,allkeys(ip).stnnum(ia));
%copy and paste into a file for iMOS.
allkeys(ip).stnnum(~lia)

%% now look for date/time duplicates in the keys:
ti = [];dset = [];stn = [];lat = [];lon = [];
for ip = 1:numel(allkeys)
    tim = num2str(allkeys(ip).time);
    ii = tim == ' ';
    tim(ii) = '0';
    mn = num2str(allkeys(ip).month);
    ii = mn == ' ';
    mn(ii) = '0';
    da=num2str(allkeys(ip).day);
    ii = da == ' ';
    da(ii) = '0';
    
    ti = [ti;datenum([num2str(allkeys(ip).year) mn da tim],'yyyymmddHHMM')];
    dset = [dset; repmat({allkeys(ip).prefix},length(tim),1)];
    stn = [stn; allkeys(ip).stnnum];
    lat = [lat; allkeys(ip).obslat];
    lon = [lon; allkeys(ip).obslon];
end
[c,ia,ic] = unique(ti,'first');
lia = ismember(stn,stn(ia));
%copy and paste into a file for iMOS.
stn(~lia)

%OK, we have duplicate station numbers in the keys as well.
% Need to think about this....
    