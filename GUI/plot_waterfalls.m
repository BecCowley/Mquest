prefix=input('enter the database prefix:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[kd]=getkeys(p,m,y,q,a,tw,sstyle);
ti = datenum(kd.year,kd.month,kd.day,...
    floor(kd.time/100),rem(kd.time/100,1)*100,repmat(0,length(kd.year),1));
%limit to our voyage:
st = input('start date of voyage (ddmmyyyy): ','s');
ed = input('end date of voyage (ddmmyyyy): ','s');
call = input('callsign: ','s');
% rct = input('enter the rec type number (eg, 71 for Devil, 72 for Quoll); ','s');
% crid = input('enter the cruise ID name: ','s')'
st = datenum([st '0000'],'ddmmyyyyHHMM');
ed = datenum([ed '2359'],'ddmmyyyyHHMM');
ii = strmatch(call,kd.callsign);
idat = find(ti(ii) >= st & ti(ii) <= ed);
stn = kd.stnnum(ii(idat));
%% 
figure(1)
clf;hold on
ad = 0;
for a = 1:length(stn)
    raw=0;
prof = readMQNC_function(prefix,stn(a),raw);
    
    %get just the good data:
    ii = str2num(prof.qc') < 3;
    dep = prof.depth(ii);
    tem = prof.temp(ii);
    
    %plot it on the waterfall:
    plot(tem+ad,dep,'b-')
    ad = ad+1;
%     pause
end

axis ij
title(['Southern Surveyor Transit 02 XBT profiles'])
set(gca,'xtick',[])
ylabel('Depth (m)')

print -dtiff /home/cowley/work/hdxbt/ss2012_t02_xbt.tif