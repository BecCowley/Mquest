% plot yearly summary for SOOP
clear
yr = 2012;
dirn = '/home/UOT-data/quest/';
pref = {'mer/GTSPPmer2010MQNC','antarctic/antarctic2010MQNC'};

%% 1 first, set up the  databases - assume using quest...  This cell runs
%first.
figure(1);clf;hold on
lat = [];
lon = [];
for a = 1:length(pref)
    prefix=[dirn pref{a}];
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
    
    jj=find(keysdata.year==yr);
    
    plot(keysdata.obslon(jj),keysdata.obslat(jj),'bx');
    
    lat = [lat;keysdata.obslat(jj)];
    lon = [lon;keysdata.obslon(jj)];
end

%% output the data to csv for BOM:

fid = fopen([dirn 'BOM_SOOPlocs' num2str(yr) '.csv'],'w');
for a = 1:length(lat)
fprintf(fid,'%f,%f\n',[lat(a) lon(a)])
end
fclose(fid)
