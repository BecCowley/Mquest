function profiledata=readRTQC(fname)
%this function reads a single profile from a MA file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
%make these global so they can be seen from the reading routine:
global calls
global cruiseID

CONFIG

%setup output files:

% initialise strings
str1 = ' ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

fname2=deblank(fname);
fid=fopen(fname2);
%Get the header data and ouput to both files:
d=fgets(fid);
profiledata.nss=num2str(d(41:end-1));
uniqueid=profiledata.nss;

d=fgets(fid);
profiledata.year=str2num(d(41:44));
profiledata.day=str2num(d(49:50));
profiledata.month=str2num(d(46:47));
profiledata.time=(str2num(d(52:53))*100 + str2num(d(55:56))) *100;

d=fgets(fid);
profiledata.lat=str2num(d(41:end-1));
profiledata.latitude=profiledata.lat;

d=fgets(fid);
profiledata.lon=str2num(d(41:end-1)); 
%need to multiply longitude by -1 and change to 360 degree long
profiledata.longitude=profiledata.lon;
if(profiledata.longitude<0)
    profiledata.longitude=360+profiledata.longitude;
end
profiledata.lon=profiledata.longitude;

d=fgets(fid);
d=fgets(fid);

d=fgets(fid);
calls=d(41:end-1);

d=fgets(fid);
d=fgets(fid);

d=fgets(fid);
probetype=['0' d(41:end-1)];

d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);

d=fgets(fid);
recordtype=d(41:end-1);

d=fgets(fid);

d=fgets(fid);
profiledata.nodepths=str2num(d(41:end-1));

d=fgets(fid);
ncolumn=str2num(d(41:end-1));

for i=1:ncolumn
    d=fgets(fid);
end
  
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);
d=fgets(fid);

d=fgets(fid);

analtime=d(41:50);

d=fgets(fid);

for i=1:profiledata.nodepths
    d=fgets(fid);
    profiledata.depth(i,1)=str2num(d(1:6));
        profiledata.depresQ(i,1)='0';
    profiledata.profparm(i,1)=str2num(d(8:12));
        profiledata.profQparm(i,1)='0';
end

     
%if this data is to be added:
%CS: Fill these extra fields:
profiledata.mky=str8;
profiledata.onedegsq=str8;
profiledata.cruiseID=str10; %fill in below
profiledata.datat='BA';
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
profiledata.sourceID='AOML';
profiledata.streamident='AOBA';
profiledata.QCversion=str4;
profiledata.dataavail='A';

%read the extra bits in the file:

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

    cruiseID=str10;

    %CS: need to pad to string10 - can't think of a better way
blk = ' ';
nblk = length(str10)-length(calls);
for j = 1:nblk, calls=[calls blk]; end
uqid = char(num2str(uniqueid));
nblk = length(str10)-length(uqid);
for j = 1:nblk, uqid=[uqid blk]; end
nblk = length(str10)-length(probetype);
for j = 1:nblk, probetype=[probetype blk]; end
nblk = length(str10)-length(recordtype);
for j = 1:nblk, recordtype=[recordtype blk]; end
% nblk = length(str10)-length(analtime);
% for j = 1:nblk, analtime=[analtime blk]; end

%fill surface codes group:

surfpcode = ['IOTA';...
             'GCLL';...
             'AOID';...
             'PEQ$';...
             'RCT$';...
             'ANTI'];
surfparm  = ['          ';...
             calls;...
             uqid;...
             probetype;...
             recordtype;...
             analtime]; 
         
surfqparm = ['0';'0';'0';'0';'0';'0'];
profiledata.nsurfc=length(surfqparm);

profiledata.surfpcode=surfpcode;
profiledata.surfparm=surfparm;
profiledata.surfqparm=surfqparm;

profiledata.depth(1,1,1)=0;
profiledata.depresQ(1,1,1)=0;
profiledata.profParm(1,1,1)=0;
profiledata.profQparm(1,1,1)=0;

%now read the data types, then the data
%while (strmatch('Depth (m)',d)==0 | isempty(strmatch('Depth (m)',d)))


profiledata.nprof=1;
   profiledata.prof_type(1,:)='TEMP            ';
   
m=1;
% while(~feof(fid))
%     d=fgets(fid);
%     finished=0;
%     nd=0;
%     clear data
%     while ~finished
%         [tt, d] = strtok(d);
%         if isempty(d) 
%             finished = 1;
%         else
%             nd = nd + 1;
%           data(nd) = sscanf(tt, '%f');
%         end
%     end
% 
%    m=m+1;    

for i=1:profiledata.nprof
    profiledata.dup_flag(i)='N';
    profiledata.digit_code(i)='7';
    profiledata.standard(i)='2';
    profiledata.ndep(i)=profiledata.nodepths;
    profiledata.D_P_Code(i)='D';
    profiledata.deep_depth(i)=profiledata.depth(i,1);   
end
profiledata.autoqc=0;

return
