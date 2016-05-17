function profiledata=readSCRIPPSdata(fname,uniqueid)
%this function reads a single profile from a Sippican Mk21 file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
%make these global so they can be seen from the reading routine:
global calls
global cruiseID
global DATA_PRIORITY

CONFIG

p=num2str(DATA_PRIORITY);
%setup output files:
profiledata.nss=num2str(uniqueid);

% initialise strings
str1 = ' ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

fid=fopen(fname);
fname=fname
%get the line number to include:
ii = findstr('/',fname);
twi = str10;
twi(1:4) = [fname(ii(end)+1) 'x' fname(ii(end)+2) fname(ii(end)+3)];

%if this is the new 'q' format, we need to identify this as the depth has
%to be /1000.
iq = findstr('q.',fname);

%Get the header data and ouput to both files:

%note - edited for new file format 19/3/2010 AT
% will need to be re-edited if re-run older Pacific ocean files...

d=fgets(fid);
data=sscanf(d(1:13),'%f');
datalatlo=sscanf(d(21:35),'%f');

% data=[sscanf(d(1:13),'%f') sscanf(d(21:35),'%f')];
% if(length(data)==5)
    profiledata.lat=datalatlo(1);
    profiledata.lon=datalatlo(2);
%     probetype=sprintf('%3.3d',data(1));
%     probetype(3:3)='2';
    systemtype=sprintf('%2.2i',data(3));
    probetype=num2str(data(2));
    probetype(2:2)='2';
    calls=d(14:20);
% else
%     profiledata.lat=data(4);
%     profiledata.lon=data(5);
% %     probetype=sprintf('%3.3d',data(1))
% %     probetype(3:3)='2';
%     systemtype='40';
% end    
    profiledata.latitude=profiledata.lat;
% probetype='052'    
d=fgets(fid);
profiledata.time=(str2num(d(14:15))*100 + str2num(d(17:18)))*100;
profiledata.year=str2num(d(8:11));
profiledata.day=str2num(d(2:3));
profiledata.month=str2num(d(5:6));
try
    my=d(46:49);
    mm=d(40:41);
    md=d(43:44);
    mfd = [md '/' mm '/' my];
catch
    disp('no manufacture date')
    mfd = '          ';
end

%get SEASid and probe serial number
seasid = str10;sern = str10;
seasid(1:8) = d(23:30);
sern(1:7) = d(32:38);
   
%need to multiply longitude by -1 and change to 360 degree long
profiledata.longitude=profiledata.lon;
if(profiledata.longitude<0)
    profiledata.longitude=360+profiledata.longitude;
end
profiledata.lon=profiledata.longitude;
        
%if this data is to be added:
%CS: Fill these extra fields:
profiledata.mky=str8;
profiledata.onedegsq=str8;
% profiledata.cruiseID=cruiseID; %fill in below
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
profiledata.streamident='SCXB';
profiledata.QCversion=str4;
profiledata.dataavail='A';

%read the extra bits in the file:
 
%  NOTE - these are all using the old coefficients and MUST be converted
%  before storage!!!

profiledata.nparms=0;
profiledata.nsurfc=0;
profiledata.nhists=0;

profiledata.dup_flag='';
profiledata.digit_code='';
profiledata.standard='';

profiledata.profiledata.pcode='';
profiledata.profiledata.parm='';
profiledata.profiledata.qparm='';
profiledata.surfpcode='';
profiledata.surfparm='';
profiledata.surfqparm='';
profiledata.identcode='';
profiledata.PRCcode='';
profiledata.Version='';
profiledata.PRCdate='';
profiledata.Actcode='';
profiledata.Actparm='';
profiledata.AuxID=0;
profiledata.PreviousVal='';
profiledata.flagseverity=0;

profiledata.D_P_Code='';
profiledata.profile_type='';


if length(cruiseID)>10
    c=cruiseID;
    clear cruiseID;
    cruiseID=c(1:10);
end
%CS: need to pad to string10 - can't think of a better way
blk = ' ';
nblk = length(str10)-length(cruiseID);
for j = 1:nblk, cruiseID=[cruiseID blk]; end

profiledata.cruiseID=cruiseID;

nblk = length(str10)-length(calls);
for j = 1:nblk, calls=[calls blk]; end
uqid = char(num2str(uniqueid));
nblk = length(str10)-length(uqid);
for j = 1:nblk, uqid=[uqid blk]; end
nblk = length(str10)-length(probetype);
for j = 1:nblk, probetype=[probetype blk]; end
nblk = length(str10)-length(systemtype);
for j = 1:nblk, systemtype=[systemtype blk]; end
nblk = length(str10)-length(p);
for j = 1:nblk, p=[p blk]; end

% nblk = length(str10)-length(serno);
% for j = 1:nblk, serno=[serno blk]; end

%fill surface codes group:

surfpcode = ['IOTA';...
             'GCLL';...
             'CSID';...
             'PEQ$';...
             'RCT$';...
             'SEC$';...
             'SER#';...
             'MFD#';...
             'TWI#'];
surfparm  = [p;...
             calls;...
             uqid;...
             probetype;...
             systemtype;...
             seasid;...
             sern;...
             mfd;...
             twi];      
surfqparm = repmat('0',1,length(surfpcode));
profiledata.nsurfc=length(surfqparm);

profiledata.surfpcode=surfpcode;
profiledata.surfparm=surfparm;
profiledata.surfqparm=surfqparm;

profiledata.depth(1,1,1)=0;
profiledata.depresQ(1,1,1)='0';
profiledata.profParm(1,1,1)=0;
profiledata.profQparm(1,1,1)='0';
profiledata.nodepths=0;

%now read the data types, then the data
%while (strmatch('Depth (m)',d)==0 | isempty(strmatch('Depth (m)',d)))
   profiledata.prof_type(1,:)='TEMP            ';
  
   hist=0;
    m=0;
while(~feof(fid) & d~=-1)
    d=fgets(fid);
    finished=0;
    clear data
    data = sscanf(d, '%f%f%i%s%f');
        
    m=m+1;
     if ~isempty(iq)
         data(1)=data(1)*.001*1.0336;
     else
         data(1)=data(1)*1.0336;
     end
    data(2)=data(2)./1000;
    profiledata.depth(1,m)=data(1);
    profiledata.depresQ(1,m)='0';
    profiledata.profparm(1,m)=data(2);
    if(length(data)>=3)
        profiledata.profQparm(1,m)=num2str(data(3));
    else
        profiledata.profQparm(1,m)='0';
    end
    if isempty(iq)
        if(length(d)>11 & ~(d(13)==' '))
            hist=hist+1;
            if(hist>100);hist=100;end
            profiledata.identcode(hist,1:2)='SC';
            profiledata.PRCcode(hist,1:4)='CSCB';
            cc=strtrim(d(12:15));
            profiledata.Actcode(hist,1:2)=cc(1:2);
            profiledata.Actparm(hist,1:4)='TEMP';
            profiledata.Version(hist,1:4)=' 1.0';
            profiledata.PRCdate(hist,1:8)=update;
            profiledata.AuxID(hist)=data(1);
            profiledata.PreviousVal(hist,1:10)='          ';
            if length(d) > 16
                pv = num2str(str2num(d(16:21))./1000);
                profiledata.PreviousVal(hist,1:length(pv)) = pv;
            end
            profiledata.flagseverity(hist)=data(3);    %int32(data(3));
        end
    else
        if ~(d(17)==' ')
            hist=hist+1;
            if(hist>100);hist=100;end
            profiledata.identcode(hist,1:2)='SC';
            profiledata.PRCcode(hist,1:4)='CSCB';
            cc=strtrim(d(16:18));
            profiledata.Actcode(hist,1:2)=cc(1:2);
            profiledata.Actparm(hist,1:4)='TEMP';
            profiledata.Version(hist,1:4)=' 1.0';
            profiledata.PRCdate(hist,1:8)=update;
            profiledata.AuxID(hist)=data(1);
            profiledata.PreviousVal(hist,1:10)='          ';
            if length(d) > 19
                pv = num2str(str2num(d(19:24))./1000);
                profiledata.PreviousVal(hist,1:length(pv)) = pv;
            end
            profiledata.flagseverity(hist)=data(3);    %int32(data(3));
        end
    end
end
profiledata.nhists=min(hist,100);  
profiledata.nprof=1;
for i=1:profiledata.nprof
    profiledata.dup_flag(i)='N';
    profiledata.digit_code(i)='7';
    profiledata.standard(i)='2';
    profiledata.ndep(i)=m;
    profiledata.D_P_Code(i)='D';
    profiledata.deep_depth(i)=profiledata.depth(i,m);   
end
profiledata.autoqc=0;
fclose(fid)
return
