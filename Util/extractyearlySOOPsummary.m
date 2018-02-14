% plot yearly summary for SOOP
%extracts information for JCOMMOPS for a year

clear
yr = 2016;
dirn = '/home/UOT-data/quest/';
pref = {'mer/GTSPPmer2016MQNC'};

%% 1 first, set up the  databases - assume using quest...  This cell runs
%first.
figure(1);clf;hold on
lat = [];
lon = [];
calls = [];
trans = yr*10000 + 100;
outputf = [dirn 'SOOP' num2str(yr) '12.txt'];
fid = fopen(outputf,'w'); %starts a new file.
%Header row.
fprintf(fid,'%s\n',['line,cruiseid,transect#,Date,Time,callsign,latitude,longitude,operator,telecom type,' ...
    'probetype,recordertype,fallratecoeffA,fallratecoeffB,software,software version,'...
    'Firmware version,launcher model,installation date, deinstallation'...
    'date,deployment height,serial number, batch date,' ...
    'good/bad,ship full name,Maximum depth of good data/10']);
fclose(fid);
for aa = 1:length(pref)
    prefix=[dirn pref{aa}];
    p={prefix};
    m={'All'};
    y={'All'};
    q={'1'};
    a={'1'};
    tw={'1'};
    sstyle={'None'};
    [keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
    
    % now plot XBT positions
    xlabel('Longitude'),ylabel('Latitude')
    %colorbar
    hold on
    
    iyr=find(keysdata.year==yr);
        
    
% output information for SOT reporting:
% get the summary of how many good profiles along each section

    %get summary information and output the metadata to a txt file
    [dat,alldat] = extractSOOPsummary(yr,[dirn pref{aa}],keysdata);
    lat = [lat;alldat.lat];
    lon = [lon;alldat.lon];
    calls = [calls;alldat.calls];
    
    %display it:
    disp('LINE, SHIP, CALLSIGN, SECTIONS, TOTAL PROFILES, GOOD PROFILES')
    for b = 1:size(dat.callsign,1)
        disp([dat.line(b,:),'; ',dat.ship(b,:),'; ' dat.callsign(b,:),'; '...
            num2str(dat.sections(b)),'; ',num2str(dat.count_total(b)),'; ',...
            num2str(dat.count_good(b))])
    end
    
    % now plot XBT positions
    xlabel('Longitude'),ylabel('Latitude')
    %colorbar
    hold on
       
    
    plot(alldat.lon,alldat.lat,'bx');
    
    %updated file as of 2017 (for 2016 dataset onwards)

    % line,cruiseid,transect#,yyyymmdd,HHMM,callsign,lat,long,operator,telecom type,
    % probetype,recordertype,fallratecoeffA,fallratecoeffB,software,
    % Firmware version,launcher model,installation date, deinstallation
    % date,deployment height,serial number, batch date,
    % good/bad,ship full name
    %,max depth of good data/10.
    %
    
    voy = unique(alldat.crid,'rows');
    alldat.date_start = repmat('          ',length(alldat.ti),1);
    alldat.date_end = alldat.date_start;
    for b = 1:size(voy,1)
        trans = trans + 1;
        ii = strmatch(voy(b,:),alldat.crid);
        alldat.trans(ii) = trans;
        alldat.date_start(ii,1:8) = repmat(datestr(min(alldat.ti(ii)),'yyyymmdd'),length(ii),1);
        alldat.date_end(ii,1:8) = repmat(datestr(max(alldat.ti(ii)),'yyyymmdd'),length(ii),1);
    end
    
    fid = fopen(outputf,'a'); %appends for each dataset.
    for a = 1:length(alldat.ti)
        if alldat.good(a) == 1
            gb = 'good';
        else
            gb = ' bad';
        end
        fprintf(fid,'%s\n',[alldat.line(a,:) ',CSIRO' alldat.crid(a,:) ',' num2str(alldat.trans(a)) ','...
            datestr(alldat.ti(a),'yyyymmdd') ',' datestr(alldat.ti(a),'HHMM') ','...
            alldat.calls(a,:) ',' num2str(alldat.lat(a),'%8.2f') ',' num2str(alldat.lon(a),'%9.2f') ...
            ',CSIRO,IRIDIUM,' alldat.probet(a,:) ',' alldat.rct(a,:) ',' ...
            num2str(alldat.ac(a)) ',' num2str(alldat.bc(a)) ',CSIRO Quoll    ,,,2,' ...
            alldat.date_start(a,:) ',' alldat.date_end(a,:)  ',' ...
            num2str(alldat.height(a,:)) ',' strtrim(alldat.serial(a,:)) ',' strtrim(alldat.mfd(a,:)) ',' ...
            gb ',' alldat.ship(a,:) ',' num2str(alldat.max(a),'%5.2f')]);
        
    end
    
    fclose(fid)
end

