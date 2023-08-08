% plot yearly summary for SOOP
% extracts information for JCOMMOPS for a year
% LK: Updated for Bureau use. 26/2/2019

% clear

% Enter year of report:
yr=input('Enter the year for this SOOP metadata report: ');
% Which agency:
who=input('Which agency: b (Bureau) or c (CSIRO) ','s');

% CSIRO set up
if who == 'c' 
  agency='CSIRO';
%  agency='AU';
  dirn = '/home/cow074/ocean_obs/UOT-data/quest/';
  pref = {['mer/CSIROXBT' num2str(yr)],['antarctic/CSIROXBT' num2str(yr) 'ant']};
%   pref = {['mer/CSIROXBT2019'],['antarctic/CSIROXBT' num2str(yr) 'ant']};
%   pref = {['mer/CSIROXBT2019'],['antarctic/CSIROXBT' num2str(yr) 'ant'],['BOM/BOM' num2str(yr)]};
%   pref = {['mer/GTSPPmer2017MQNC'],['antarctic/CSIROXBT2016ant']};
  v= [100 200.,-80,20];
  agency_title = ['CSIRO SOOP High and Low Density sampling - ' num2str(yr)];

% Bureau set up
else
  agency='BOM';
  dirn = '/xbt/xbt_web/';
  pref = {[agency num2str(yr)]};
  v= [90 160.,-45,25];
  agency_title = ['Bureau SOOP XBT sampling - ' num2str(yr)];
end


%% 1 first, set up the  databases - assume using quest...  This cell runs first.
lat = [];
lon = [];
calls = [];
sotid = [];
trans = yr*10000 + 100;

%% Open metadata text file
outputf = [dirn 'SOOP_' agency '_XBT_' num2str(yr) '_metadata.txt']
fid = fopen(outputf,'w'); %starts a new file.

% write header row.
fprintf(fid,'%s\n',['line,cruiseid,transect#,Date,Time,SOT_ID,callsign,latitude,longitude,operator,telecom type,' ...
    'probetype,recordertype,fallratecoeffA,fallratecoeffB,software,software version,'...
    'Firmware version,launcher model,installation date, deinstallation'...
    'date,deployment height,serial number, batch date,' ...
    'good/bad,ship full name,Maximum depth of good data/10']);
fclose(fid);

% For each dataset
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

 % Extract metadata to a txt file
  [dat,alldat] = extractSOOPsummary(yr,[dirn pref{aa}],keysdata);
  lat = [lat;alldat.lat];
  lon = [lon;alldat.lon];
  calls = [calls;alldat.calls];
  sotid = [sotid;alldat.sotid];
    
  % display dataset line summary 
  disp(' ')
  disp(['Sampling summary for ' pref{aa}])
  disp('LINE, SHIP, CALLSIGN, SECTIONS, TOTAL PROFILES, GOOD PROFILES')
  for b = 1:size(dat.callsign,1)
    disp([dat.line(b,:),'; ',dat.ship(b,:),'; ' dat.callsign(b,:),'; '...
        num2str(dat.sections(b)),'; ',num2str(dat.count_total(b)),'; ',...
        num2str(dat.count_good(b))])
  end
  disp(' ');
    
  % now plot XBT positions
  xlabel('Longitude'),ylabel('Latitude')
  %colorbar
  hold on
       
  %updated file as of 2017 (for 2016 dataset onwards)
  % line,cruiseid,transect#,yyyymmdd,HHMM,callsign,lat,long,operator,telecom type,
  % probetype,recordertype,fallratecoeffA,fallratecoeffB,software,
  % Firmware version,launcher model,installation date, deinstallation
  % date,deployment height,serial number, batch date, good/bad,ship full name
  %,max depth of good data/10.
    
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
    
  disp(['Created metadata report: ' outputf])
  disp(' ')

  fid = fopen(outputf,'a'); %appends for each dataset.
  for a = 1:length(alldat.ti)
    if alldat.good(a) == 1
      gb = 'good';
    else
      gb = ' bad';
    end

    comms = 'IRIDIUM';

         
    fprintf(fid,'%s\n',[alldat.line(a,:) ',' strtrim(alldat.source(a,:)) alldat.crid(a,:) ',' ...
      num2str(alldat.trans(a)) ',' datestr(alldat.ti(a),'yyyymmdd') ',' datestr(alldat.ti(a),'HHMM') ','...
      alldat.sotid(a,:) ',' alldat.calls(a,:) ',' num2str(alldat.lat(a),'%8.2f') ',' num2str(alldat.lon(a),'%9.2f') ...
      ',' strtrim(alldat.source(a,:)) ',' comms ',' alldat.probet(a,:) ',' alldat.rct(a,:) ',' ...
      num2str(alldat.ac(a)) ',' num2str(alldat.bc(a)) ',' strtrim(alldat.source(a,:)) ' ' alldat.rctn(a,:) ',,,2,' ...
      alldat.date_start(a,:) ',' alldat.date_end(a,:)  ',' ...
      num2str(alldat.height(a,:)) ',' strtrim(alldat.serial(a,:)) ',' strtrim(alldat.mfd(a,:)) ',' ...
      gb ',' alldat.ship(a,:) ',' num2str(alldat.max(a),'%5.2f')]);
        
  end
 fclose(fid);
 
end

%%
% add water depth contours
figure(1);clf;hold on
plot(lon,lat,'bx');

coast('k-');
t=title(agency_title);
set(t,'FontSize',12)
set(t,'FontWeight','bold')
x=ylabel('Latitude');
set(x,'FontWeight','bold')
set(x,'FontSize',12)
x=xlabel('Longitude');
set(x,'FontWeight','bold')
set(x,'FontSize',12)
axis(v)
text(170, -60, ['Total deployments: ' num2str(length(lat))], 'fontsize',14)
%axis equal

print('-dpng',[dirn 'SOOP_' agency '_XBT_' num2str(yr) '_locations.png']);
disp(['Created ' dirn 'SOOP_' agency '_XBT_' num2str(yr) '_locations.png'])

%% to figure out the number of SBD messages sent:
% cd ~/UOT/archives/XBT/realtime/gts_messages/2022
% ls IOSS*XEK*.bin |wc

