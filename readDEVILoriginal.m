function profiledata=readDEVIL(fname,uniqueid)

global SHIP_NAMES

%this function reads a single profile from a DEVIL drop file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.

% get the ship name database:

if (isempty(SHIP_NAMES))
    S = getshipnames;
else
    S = SHIP_NAMES;
end
%setup output files:
profiledata.nss=num2str(uniqueid);

% initialise strings
str1 = ' ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

%Get data and place in structures:
%CS: profile date
woce_date = num2str(getnc(fname,'woce_date'));
profiledata.year=str2num(woce_date(1:4));
profiledata.month=str2num(woce_date(5:6));
profiledata.day=str2num(woce_date(7:8));
%CS: profile time - get rid of milliseconds
time = getnc(fname,'woce_time');
profiledata.time = floor(time/100)*100;
profiledata.latitude = getnc(fname,'latitude');
%CS: need to multiply lon by -1 so same convention as MA
profiledata.longitude = getnc(fname,'longitude');
profiledata.lon=profiledata.longitude;
profiledata.lat=profiledata.latitude;

%CS: Fill these extra fields:
profiledata.mky=str8;
profiledata.onedegsq=str8;
profiledata.cruiseID=str10; %fill in below
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
    clo=datestr(clock,24);
    update=[clo(1:2) clo(4:5) clo(7:10)];
profiledata.update=update;
profiledata.sourceID=str4;
profiledata.streamident='CSXB';
profiledata.QCversion=str4;
profiledata.dataavail='A';

%CS: Only 1 profile per file
profiledata.nprof=1;
profiledata.nparms=0;
profiledata.nhists=0;

profiledata.nosseg=1;
profiledata.prof_type='TEMP            ';
profiledata.dup_flag='N';
profiledata.digit_code='7';
profiledata.standard='2';
profiledata.deep_depth=0; %deepest depth - fill below

profiledata.profiledata.pcode=str4;
profiledata.profiledata.parm=str10;
profiledata.profiledata.qparm=str1;

%CS: Get global attributes
[att_vals,att_name] = attnc(fname);
att_name = char(att_name);
shipname=[];
for i = 1:length(att_vals)
    if att_name(i,1:4) == 'Call',calls=att_vals{i};end
    if att_name(i,1:4) == 'Code',probetype=att_vals{i};end
    if att_name(i,1:4) == 'Voya',cruiseID=att_vals{i};end
    if att_name(i,1:4) == 'Inte',cardtype=att_vals{i};end
    if att_name(i,1:4) == 'Seri',serno=att_vals{i};end
    if att_name(i,1:4) == 'Scal',scale=att_vals{i};end
    if att_name(i,1:4) == 'Offs',offset=att_vals{i};end
    if att_name(i,1:3) == 'CRC',crc=att_vals{i};end
    if att_name(i,1:4) == 'Line',lineno=att_vals{i};end
    if att_name(i,1:4) == 'Ship',shipname=att_vals{i};end
end
%hardwire cruiseid this time only!!!
%cruiseID='VG3405H   '

if(~isempty(shipname))
    kk=strmatch(shipname,S.fullname);
    if(~isempty(kk))
        shortname=S.shortname(kk);
        s=shortname;
        shortname=s{1};
    else
        disp('Ship name does not match any existing entries in ships.txt')
%         long_shipname=input('Please enter full ship name: ','s')
        long_shipname=shipname;
        disp(['The ship name found is: ' shipname])
        shortname=input('Please enter 10-character ship name: ','s')
        S=writeshipnames(long_shipname,shortname);
    end
else
    disp('No ship name has been specified! Please enter full ship name: ')
    long_shipname=input('Please enter full ship name: ','s')
    shortname=input('Please enter 10-character ship name: ','s')
    S=writeshipnames(long_shipname,shortname);
end
try
    cc='          '
    cc(1:length(crc))=crc;
end

if length(cruiseID)>10
    c=cruiseID;
    clear cruiseID;
    cruiseID=c(1:10);
end
%CS: need to pad to string10 - can't think of a better way
blk = ' ';
nblk = length(str10)-length(cruiseID);
for j = 1:nblk; cruiseID=[cruiseID blk]; end
nblk = length(str10)-length(calls);
for j = 1:nblk; calls=[calls blk]; end
uqid = char(num2str(uniqueid));
nblk = length(str10)-length(uqid);
for j = 1:nblk; uqid=[uqid blk]; end
nblk = length(str10)-length(probetype);
for j = 1:nblk; probetype=[probetype blk]; end
nblk = length(str10)-length(offset);
for j = 1:nblk; offset=[offset blk]; end
nblk = length(str10)-length(scale);
for j = 1:nblk; scale=[scale blk]; end
nblk = length(str10)-length(serno);
for j = 1:nblk; serno=[serno blk]; end
nblk = length(str10)-length(lineno);
for j = 1:nblk; lineno=[lineno blk]; end
nblk = length(str10)-length(shortname)
for j = 1:nblk; shortname=[shortname blk]; end

profiledata.cruiseID=cruiseID;
surfpcode = ['IOTA';...
             'GCLL';...
             'CSID';...
             'PEQ$';...
             'RCT$';...
             'OFFS';...
             'SCAL';...
             'SER#';...
             'CRC$';...
             'TWI#';...
             'SHP#'];
surfparm  = ['          ';...
             calls;...
             uqid;...
             probetype;...
             '71        ';...
             offset;...
             scale;...
             serno;...
             cc;...
             lineno;...
             shortname];      
surfqparm = ['0';'0';'0';'0';'0';'0';'0';'0';'0';'0';'0'];
profiledata.nsurfc=length(surfqparm);

profiledata.surfpcode=surfpcode;
profiledata.surfparm=surfparm;
profiledata.surfqparm=surfqparm;

%CS: Fill in other fields in profiledata
profiledata.identcode='';
profiledata.PRCcode='';
profiledata.Version='';
profiledata.PRCdate='';
profiledata.Actcode='';
profiledata.Actparm='';
profiledata.AuxID='';
profiledata.PreviousVal='';
profiledata.flagseverity='';

profiledata.D_P_Code='D';
profiledata.profile_type='TEMP            '; %CHECK
 
%CS: Parameter data and QC flags
%CS: Depths
depths = getnc(fname,'depth');
ndepths = length(depths);
profiledata.depth(1,1,1)=0; 
profiledata.depth(1,1,1:ndepths) = depths;
profiledata.deep_depth=max(depths);
profiledata.nodepths=ndepths;
%CS: Depth QC
profiledata.depresQ(1,1,1:ndepths)='0';
%CS: Profile parameter
profiledata.profparm(1,1,1)=0;
profiledata.profparm(1,1,1:ndepths) = getnc(fname,'temperature');
%CS: Profile parameter QC
profiledata.profQparm(1,1,1:ndepths)='0';

profiledata.ndep=profiledata.nodepths; %CHECK
profiledata.autoqc=0;

return
