function [keysdata]=getkeys(prefix,mmm,yy,qc,auto,timewindow,sstyle)
%function [keysdata]=getkeys(prefix,mmm,yy,qc,auto)
%   extracts the data required to find individual profiles within 
%   the database and returns it in "keysdata" 
%
%   required inputs are:
%       prefix = the prefix of the database - generally the directory name
%       mmm = the month required as a numeric in character*2 with "all" or
%           "All" indicating that all months are required.
%       yy = the year required as a numeric in character*4 with "all" or
%           "All" indicating that all years are required.
%       qc = a logical variable indicating whether data with particular qc
%          flags are required - this is not currently implemented
%       auto = a logical variable indicating whether data that have failed
%           the autoQC tests are required. If so, ONLY these profiles are displayed.
%       timewindow = the variable that helps you subset the keys - "3" gives you
%           gives you +/- 15 days, all others give you only the month requested
%       sstyle = the sort style required - lat sorts by latitude, ship
%           sorts by callsign/date/time
%
%   the output is a structure of profile information that allows you to retrieve the 
%           profiles that meet the requirements.  The structure is:
%
%    keysdata = 
%           time: [#profiles x 1 double]   hhmm
%            day: [#profiles x 1 double]   
%          month: [#profiles x 1 double]   
%           year: [#profiles x 1 double]
%         obslat: [#profiles x 1 double]   latitude(+ = north)
%         obslon: [#profiles x 1 double]   longitude (+ = east)
%       callsign: [#profiles x 10 char]    ship identifier (usually the callsign)      
%         stnnum: [#profiles x 10 char]    unique identifying number for
%                                               each profile - this forms the
%                                               directory tree to allow
%                                               retrieval of a profile from the
%                                               database directory
%       priority: [#profiles x 1 double]   indication of how "good" a profile is 
%                                               (1 is best, 9 is worst) 
%     datasource: [#profiles x 10 char]    where is the data from (CSIRO,
%                                               BOM, WOCE, LEVITUS, etc.
%    masterrecno: [1 x #profiles - double] a tally of where, within the
%                                               entire database, this record came 
%                                               from - allows you to rewrite data
%                                               without searching for it's original location.
%         prefix: 'database name'          the name of the directory which holds the profiles 
%       datatype: [#profiles x 2 char]     eg. XB (xbt), CT (CTD), TE
%                                               (tesac), etc.

global waiting

needqc=str2num(qc{1})-1;
if(needqc)

    keysfile=[prefix{1} '_keysQC.nc'];
    if(~exist(keysfile))
        errordlg('error - you must create this file using extractqcprofiles first!!')
        keysdata.prefix=prefix{1};
        return
    end
        
else

    keysfile=[prefix{1} '_keys.nc'];

end

col=['g' 'b' 'y' 'r' 'g'];
    if(~exist(keysfile))
% you must create the file before you can add to it...
            createkeys
            mkdir(prefix{1}) 
            dir2=pwd;
% and you must fill the file before you can use it!!!
waiting=1;
try
    delete (handles.QuotaQuest)
end
            importdata('UserData',{prefix(1),dir2});
          
    end
    
    stationnumber=getnc(keysfile,'stn_num');

    if(isempty(stationnumber))
    %    errordlg('this appears to be a new file - returning')
        keysdata.prefix=prefix{1};
        keysdata.year=[];
        dir2=pwd;
% and you must fill the file before you can use it!!!
%        waiting=1;
%        importdata('UserData',{prefix(1),dir2});
%        stationnumber=getnc(keysfile,'stn_num');
%        if(isempty(stationnumber))
%             errordlg('this is an empty file - returning and will crash')
%             return
%        end
return
    end
month=getnc(keysfile,'obs_m');
year=getnc(keysfile,'obs_y');
day=getnc(keysfile,'obs_d');
time=getnc(keysfile,'obs_t');
for iii=1:size(time,1)
    tt = time(iii,:);
    kkk=strfind(tt,' ');
    tt(kkk)='0';
    time(iii,:) = tt;
end
kkk=strmatch('  ',month);
for iii=1:length(kkk)
    month(kkk(iii),:)='00';
end
kkk=strmatch('  ',year);
for iii=1:length(kkk)
    year(kkk(iii),:)='0000';
end
kkk=strmatch('  ',day);
for iii=1:length(kkk)
    day(kkk(iii),:)='00';
end

latitude=getnc(keysfile,'obslat');
longitude=getnc(keysfile,'c360long',-1,-1,-1,-1,1);
autoqc=getnc(keysfile,'autoqc');
callsign=getnc(keysfile,'callsign');
dsource=getnc(keysfile,'data_source');
datat=getnc(keysfile,'data_t');
priority=getnc(keysfile,'priority');
stnnum=getnc(keysfile,'stn_num');

if(~isempty(strmatch('all',mmm{1})) | ~isempty(strmatch('All',mmm{1})))
 kk=1:length(latitude);   
else
    
    mm=(findstr('janfebmaraprmayjunjulaugsepoctnovdec',mmm{1})+2)/3;
    if(isempty(mm))
        mm=(findstr('JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC',mmm{1})+2)/3;
        if(isempty(mm))
            mm=(findstr('JanFebMarAprMayJunJulAugSepOctNovDec',mmm{1})+2)/3;
        end
    end
    if(str2num(timewindow{1})==3)
%    if(strmatch(timewindow,'3','exact'))
        mv=mm-1:mm+1;
        mv(find(mv==0))=12;
        mv(find(mv==13))=1;
        k1=find(str2num(month(:,1:2))==mv(1) & str2num(day(:,1:2))>=15);
        k2=find(str2num(month(:,1:2))==mv(2));
        k3=find(str2num(month(:,1:2))==mv(3) & str2num(day(:,1:2))<=15);
        kk=[k1' k2' k3'];
    else
        kk=find(str2num(month(:,1:2))==mm);
    end
    if(isempty(kk))
        kk=1:length(month);
    end
    length(kk);

end


if(~isempty(strmatch('all',yy{1})) | ~isempty(strmatch('All',yy{1})))
    ll=1:length(kk);
else
    ll=find(str2num(year(kk,1:4))==str2num(yy{1}));
end
 
a=str2num(auto{1})-1;
if a == 2
    jj=find(autoqc(kk(ll))==2);
elseif a == 1
    jj=find(autoqc(kk(ll)) == 1);
elseif a == 3
    jj=find(autoqc(kk(ll)) == 3 | autoqc(kk(ll)) == 2);
elseif a == 4
    jj=find(autoqc(kk(ll)) == 3);
else
    jj=1:length(kk(ll));
end

%resize time, day, month,year if only one profile:
if length(kk) == 1
    time = time';
    day = day';
    month = month';
    year = year';
    callsign = callsign';
    stnnum = stnnum';
    datat = datat';
    dsource = dsource';
end
    
%sort keys:
t=time(kk(ll(jj)),:);
d=day(kk(ll(jj)),:);
m=month(kk(ll(jj)),:);
y=year(kk(ll(jj)),:);
ola=latitude(kk(ll(jj)));
olo=longitude(kk(ll(jj)));
callsgn=callsign(kk(ll(jj)),:);
p=priority(kk(ll(jj)),:);
stn=stnnum(kk(ll(jj)),:);
ds=dsource(kk(ll(jj)),:);
mr=kk(ll(jj));
dt=datat(kk(ll(jj)),:);

clear a
[mt,nt]=size(t);

if(strmatch(sstyle,'lat','exact'))
    a=ola;
elseif(strmatch(sstyle,'ship','exact'))
    for i=1:mt
        if(~isempty(strfind(t(i,:),':')))
            a{i}=[callsgn(i,:) y(i,:) m(i,:) d(i,:) t(i,1:2) t(i,4:5)];
        else
            a{i}=[callsgn(i,:) y(i,:) m(i,:) d(i,:) t(i,:)];
        end
            kk=find(a{i}(:)==' ');
            if(~isempty(kk))
                a{i}(kk)='0';
            end
    end
else
    a=1:mt;
end

[sortedkeys,ind]=sort(a);

keysdata.time=str2num(t(ind,:));              %ime(kk(ll(jj)),:));
keysdata.day=str2num(d(ind,:));               %ay(kk(ll(jj)),:));
keysdata.month=str2num(m(ind,:));             %onth(kk(ll(jj)),:));
keysdata.year=str2num(y(ind,:));              %ear(kk(ll(jj)),:));
keysdata.obslat=ola(ind);                   %titude(kk(ll(jj)));
keysdata.obslon=olo(ind);                   %ngitude(kk(ll(jj)));
keysdata.callsign=callsgn(ind,:);             %(kk(ll(jj)),:);
keysdata.stnnum=str2num(stn(ind,:));          %num(kk(ll(jj)),:));
keysdata.priority=p(ind);                   %riority(kk(ll(jj)),:);
keysdata.datasource=ds(ind,:);                %ource(kk(ll(jj)),:);
keysdata.masterrecno=mr(ind);               %kk(ll(jj));
keysdata.prefix=prefix{1};
keysdata.datatype=dt(ind,:);                  %atat(ll(jj),:);
keysdata.auto=autoqc(ind,:);                  %atat(ll(jj),:);

if all(olo < 60 & olo > 280)%(max(olo)>280 & min (olo)<60)
    keysdata.map180=1;
    ll=find(keysdata.obslon>180.)
    keysdata.lon180=keysdata.obslon;
    keysdata.lon180(ll)=-(360-keysdata.obslon(ll));
else
    keysdata.map180=0;
    keysdata.lon180=keysdata.obslon;
end


g=keysdata.month;
number_of_master_profiles=length(g)

if(needqc)

    masterstn=getnc([prefix{1} '_keys.nc'],'stn_num');
    masterstn=str2num(masterstn);
    [icomm,ia,ib]=intersect(keysdata.stnnum,masterstn,'rows');
    keysdata.masterrecno(ia)=ib;

end

return

