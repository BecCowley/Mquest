clear

yrr = {'2016','2017','2018','2019','2020','2021'};
dirn = '/home/cow074/UOT-data/quest/';
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
uucr = [];aaa = 0;gd = [];bd = [];
for aa = 1:length(yrr)
    yr=yrr{aa};
    if strcmp('2017',yr) | strcmp('2016',yr)
        pref = 'antarctic/antarctic2016MQNC';
    else
        pref = ['antarctic/CSIROXBT' num2str(yr) 'ant'];
    end
    prefix=[dirn pref];
    p={prefix};
    [keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
    
    [dat,alldat] = extractSOOPsummary(str2num(yr),[dirn pref],keysdata);
    
    ucr = unique(alldat.crid,'rows');
    disp(['cruise; total; good; bad; % bad'])
    for b = 1:size(ucr,1)
        aaa = aaa+1;
        ii = strmatch(ucr(b,:),alldat.crid);
        disp([ucr(b,:) '; ' num2str(length(ii)) '; ' num2str(sum(alldat.good(ii))) ...
            '; ' num2str(sum(alldat.bad(ii))) '; ' num2str(sum(alldat.bad(ii))/length(ii) * 100) '%'])
        tot(aaa) = length(ii);
        gd(aaa) = sum(alldat.good(ii));
        bd(aaa) = sum(alldat.bad(ii));
   end
    
    uucr = [uucr;ucr];
end

%remove non astrolabe:
ii = strmatch('AA',uucr);
tot(ii) = [];
gd(ii) = [];
bd(ii) = [];
uucr(ii,:) = [];
ii = strmatch('in',uucr);
tot(ii) = [];
gd(ii) = [];
bd(ii) = [];
uucr(ii,:) = [];


%% plot

figure(1);clf
b = bar([tot',bd'./tot'*100]);
xticks([1:3:length(tot)])
xticklabels(cellstr(uucr(1:3:length(tot),:)))
grid
%line at new ship

h=legend({'Total number deployed','Percentage of failures in first 100m'});
h.AutoUpdate=0;
h=legend({'Total number deployed','Percentage of failures in first 100m'});
h.Location = 'north';

%line at through hull launcher
b(1).CData(end-5:end,:) = repmat([0.5 0 0.5],6,1);
b(2).CData(end-5:end,:) = repmat([0.85 0.1 0.1],6,1);
b(1).FaceColor = 'Flat';
b(2).FaceColor = 'Flat';
% b(1).CData(1,:) = [0.3 0 0.3];
% b(2).CData(1,:) = [0.9 0 0.1];

xline(7.5,'r-',{'New Ship'},'linewidth',2)
xline(22.5,'r-','Through hull launcher','linewidth',2)
yline(5,'-',{'5%'})
