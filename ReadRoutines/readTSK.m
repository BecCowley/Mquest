function profiledata=readTSK(fid,uniqueid)
%this function reads a single profile from a Japanese TSK file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
% edited from readMA.m. Bec Cowley 13 Jan, 2012
global calls
global cruiseID

CONFIG
% initialise strings
str1 = ' ';
str2 = '  ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

%setup output files
clear profiledata:
profiledata.nss=num2str(uniqueid);

%Get the header data:
d = textscan(fid,'%s',12,'delimiter',',');

% profiledata.year=str2num(datestr(datenum(d{1}(1),'yy/mm/dd'),'yyyy'));
% profiledata.month=str2num(datestr(datenum(d{1}(1),'yy/mm/dd'),'mm'));
% profiledata.day=str2num(datestr(datenum(d{1}(1),'yy/mm/dd'),'dd'));
% profiledata.time=str2num([datestr(datenum(d{1}(2),'HH:MM'),'HHMM') '00']);
profiledata.year=str2num(datestr(datenum(d{1}(3),'yyyymmdd'),'yyyy'));
profiledata.month=str2num(datestr(datenum(d{1}(3),'yyyymmdd'),'mm'));
profiledata.day=str2num(datestr(datenum(d{1}(3),'yyyymmdd'),'dd'));
profiledata.time=str2num([datestr(datenum(d{1}(4),'HHMMSS'),'HHMM') '00']);

%get lat:
dd = char(d{1}(5));
ii = strfind(dd,'-');
ij = strfind(dd,'N');
neg = 1;
if isempty(ij)
    ij = strfind(dd,'S');
    neg = -1;
end    

% lat = degrees + minutes/60
lat = neg*(str2double(dd(1:ii-1)) + str2double(dd(ii+1:ij-1))/60); 
profiledata.lat=lat;
profiledata.latitude=profiledata.lat;

%get lon:
dd = char(d{1}(6));
ii = strfind(dd,'-');
ij = strfind(dd,'E');
neg = 1;
if isempty(ij)
    ij = strfind(dd,'W');
    neg = -1;
end    

%need to change to 360 degree long if west:
lon = neg*(str2double(dd(1:ii-1)) + str2double(dd(ii+1:ij-1))/60); 
if(lon<0)
    lon=360+lon;
end
profiledata.lon=lon;
profiledata.longitude = lon; 

%get the probetype and recorder type - needs editing to suit.
pt = char(d{1}(6));
if ~isempty(strmatch('TSK T07',pt))
    probetype = '222       ';
elseif ~isempty(strmatch('T07',pt))
    probetype = '052       ';
else
    probetype = '999       ';
end
rct = char(d{1}(7))
if strmatch('TSK MK130',rct)
    rctyp = '46        ';
else
    rctyp = '99        ';
end

%get serial number:
sn = char(d{1}(1));
serno = str10;
if ~isempty(sn)
    serno(1:length(sn)) = sn;
end   
%other stuff:

profiledata.mky=str8;
profiledata.onedegsq=str8;
profiledata.cruiseID=cruiseID; 
profiledata.datat='XB';
profiledata.iumsgno=str12;
profiledata.streamsource=str1;
profiledata.uflag=str1;
profiledata.medssta=str8;
profiledata.qpos='1';
profiledata.qdatetime='1';
profiledata.qrec='1';
profiledata.bultime=str12;
profiledata.bulheader=str6;
%     clo=datestr(clock,24);
%     update=[clo(1:2) clo(4:5) clo(7:10)];
%As of August, 2014, the format has been changed to yyyymmdd to agree with
%NOAA formats. Bec Cowley
update = datestr(now,'yyyymmdd');
profiledata.update=update;
profiledata.sourceID=str4;
profiledata.streamident=[DATA_QC_SOURCE 'XB']; 
profiledata.QCversion=str4;
profiledata.dataavail=str1;
profiledata.nparms=0;
profiledata.nsurfc=0;
profiledata.nhists=0;

profiledata.nprof=1; %just a single profile
profiledata.nparms=1; %only temperature. If this was a CTD, would have 2 or 3
profiledata.nhists=0;

%read the data:
d = textscan(fid,'%f%f','delimiter',',');
% d = d{:};
% %get rid of 99.99 values:
% ibad = d == 99.99;
% d(ibad) = [];
% %assign depths (this is for 1m data points)
% deps = 1:length(d);
deps = d{1};
temps = d{2};

profiledata.nosseg='';
md = max(deps);
profiledata.deep_depth = md;
profiledata.prof_type(1,1,:)='TEMP            ';
profiledata.dup_flag='N';
profiledata.digit_code='7'; %digitized at regular depth intervals.
profiledata.standard='H'; %accuracy or precision measure: 0.1 to 0.2degC
profiledata.nosseg=0;

profiledata.pcode=str4;
profiledata.parm=str10;
profiledata.qparm=' ';
nss = str10;
nss(1:length(profiledata.nss)) = profiledata.nss;

surfpcode = [[DATA_QC_SOURCE 'ID'];...
             'GCLL';...
             'PEQ$';...
             'RCT$';...
             'SER#'];

surfparm  = [nss; ...
             calls;...
             probetype;...
             rctyp;...
             serno];      
surfqparm = ['0';'0';'0';'0';'0'];
profiledata.nsurfc=5;

profiledata.surfpcode=surfpcode;
profiledata.surfparm=surfparm;
profiledata.surfqparm=surfqparm;


profiledata.identcode=str2;
profiledata.PRCcode=str4;
profiledata.Version=str4;
profiledata.PRCdate=str8;
profiledata.Actcode=str2;
profiledata.Actparm=str4;
profiledata.AuxID=0;
profiledata.PreviousVal=str10;
profiledata.flagseverity=0;

profiledata.D_P_Code='D'; %D for Depth, P for pressure
profiledata.profile_type='';

profiledata.depth(1,1,:) = deps;
profiledata.depresQ(1,1,1:length(deps))=0;
profiledata.profparm(1,1,:)=temps;
profiledata.profQparm(1,1,1:length(temps))=0;
profiledata.nodepths=length(deps);

profiledata.ndep=sum(profiledata.nodepths,2);

profiledata.autoqc=0;

return
