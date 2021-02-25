% plot yearly summary for SOOP
%extracts information for JCOMM and BOM and to get number of jjvv messages,
%run jjvv_yearlycounts.m

%Can use this command in terminal to get a count of files in the directory
% find *.sbd -newermt "01 Jan 2015" ! -newerct "31 Dec 2015" -ls | wc

clear
yr = 2020;
dirn = '/home/UOT-data/quest/';
pref = {'mer/CSIROXBT2019','antarctic/CSIROXBT2020ant'};

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
% the fortran is not working, let's do it in matlab - March, 2014.
% !/home/UOT/programs/fortran/tethys_code/extractsoopMQNC
% !cat SOOP201312.txt | grep IX28 | wc
% !cat SOOP201312.txt | grep IX28 | grep good | wc     %etc....
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
    
    %at this stage, output to .txt file to replace teh fortran for SOT
    %reporting:
    %     PX30      ,CSIROPG3001  , 20120105,2012 311,  11,YJZC5     ,  -23.08,  167.25,CSIRO,ARGOS,052 ,72  ,6.691,-2.25,999            ,,,,,good,"Pacific Gas    ",,Australian SOOP,   40.40,
    % line,cruiseid,transect#,yyyymmdd,HHMM,callsign,lat,long,operator,???,
    % probetype,recordertype,fallratecoeffA,fallratecoeffB,software,good/bad,ship full name
    %,max depth of good data/10.
    %
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

%%
% add water depth contours

v= [100 200.,-80,20];
% 
% if ~exist('hb')
% %     addpath /home/dunn/matlab
%     xb = getnc('/home/netcdf-data/terrainbase','lon');
%     yb = getnc('/home/netcdf-data/terrainbase','lat');
%     ix = find(xb > v(1) & xb < v(2));
% %     ix = [1:length(xb)];
%     iy = find(yb > v(3) & yb < v(4));
%     
%     hb = -1*getnc('/home/netcdf-data/terrainbase','height',[min(iy) min(ix)],[max(iy) max(ix)]);
%     vx = xb(ix);
%     vy = yb(iy);
% end
% 
% contourf(vx,vy,hb,[0:100:2000]);
coast('k-')
t=title(['CSIRO SOOP High Density sampling - ' num2str(yr)])
set(t,'FontSize',12)
set(t,'FontWeight','bold')
x=ylabel('Latitude')
set(x,'FontWeight','bold')
set(x,'FontSize',12)
x=xlabel('Longitude')
set(x,'FontWeight','bold')
set(x,'FontSize',12)
axis(v)
axis equal

print('-dpng',['/home/UOT-data/quest/CSIRO_SOOPdata' num2str(yr) '.png'])


%% output the data to csv for BOM:

fid = fopen([dirn 'CSIRO_SOOPlocs' num2str(yr) '.csv'],'w');
for a = 1:length(lat)
    fprintf(fid,'%f,%f\n',[lat(a) lon(a)]);
end
fclose(fid)

return
%% as a one-off, extract the 2015 RAN lat/lon information for group plot:
clear
yr = 2015;
dirn = '/home/UOT-data/quest/RANdata/RANxbt15/';
pref = 'RANxbt2015';

lat = ncread([dirn pref '_keys.nc'],'obslat');
lon = ncread([dirn pref '_keys.nc'],'obslng');

fid = fopen([dirn 'RAN_SOOPlocs' num2str(yr) '.csv'],'w');
for a = 1:length(lat)
    fprintf(fid,'%f,%f\n',[lat(a) lon(a)]);
end
fclose(fid)

%% NOW plot all of them on a map:
yr = '2016';
figure(2);clf;hold on
filn = {['CSIRO_SOOPlocs' yr '.csv'],['BOM' yr 'SOOP_locations.csv']}; %['RAN_SOOPlocs' yr '.csv'],
cc = {'r','b'};

for a = 1:length(filn)
    dat = csvread(filn{a});
    
    plot(dat(:,2),dat(:,1),'.','markeredgecolor',cc{a},'markersize',14)
end

coast('k')

xlim([0 360])
ylim([-65 60])
axis equal
legend('CSIRO','BoM','location','n')%'RAN',
xlabel('Longitude')
ylabel('Latitude')

print('-dpng',['combined_SOOPlocs_' yr '.png'])
