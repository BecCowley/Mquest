function [profiledata,pd]=readMK21_RAN(fname,uniqueid)
%this function reads a single profile from a Sippican Mk21 file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
%Updated August 16, 2016 to match the profiledata format from Devil files and
%pd structure used throughout Mquest now. Bec Cowley.


%make these global so they can be seen from the reading routine:
global calls
global cruiseID
global DATA_QC_SOURCE
global SHIP_NAMES
global shipname

CONFIG
% get the ship name database:

if (isempty(SHIP_NAMES))
    S = getshipnames;
else
    S = SHIP_NAMES;
end

%setup output files:
pd.nss=num2str(uniqueid);

% initialise strings
str1 = ' ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

profiledata.woce_date = num2str(rawdata.woce_date);
%CS: profile time - get rid of milliseconds
time = rawdata.woce_time;
profiledata.woce_time = floor(time/100)*100;
profiledata.latitude = rawdata.latitude;
%CS: need to multiply lon by -1 so same convention as MA
profiledata.longitude = rawdata.longitude;
if profiledata.longitude < 0
    profiledata.longitude = profiledata.longitude +360;
end

%if this data is to be added:
%CS: Fill these extra fields:
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


if(~isempty(shipname))
    kk=strmatch(upper(shipname),upper(S.fullname),'exact');
    if(~isempty(kk))
        shortname=S.shortname(kk);
        s=shortname;
        shortname=s{1};
    else
        if ~isempty(strmatch('RV METOC',shipname)) || ...
                (~isempty(strmatch('SHIP',calls)) || ~isempty(strmatch('ship',calls)))
            %default for RAN data, check what ship it belongs to
            if ispc
                global MQUEST_DIRECTORY_PC
                fnm=[ MQUEST_DIRECTORY_PC '\calls.txt'];
            else
                global MQUEST_DIRECTORY_UNIX
                fnm=[ MQUEST_DIRECTORY_UNIX '/calls.txt'];
            end
            fid = fopen(fnm,'r');
            tmpdb = textscan(fid,'%s%s%s','delimiter',',','bufsize',10000);
            fclose(fid);
            ij = strfind(fname,'.');
            ii = strmatch(fname(ij(1)+1:ij(1)+2),tmpdb{:,3});
            if ~isempty(ii)
                ij = strmatch(tmpdb{:,1}(ii),S.fullname);
                shortname=S.shortname{ij};
                shipname = S.fullname{ij};
            end
        else
            disp('Ship name does not match any existing entries in ships.txt')
            disp(['Ship name = "' shipname '" from file = "' fname '"'])
            %long_shipname=input('Please enter full ship name: ','s')
            disp(['Current Ship.txt contains:'])

            if(ispc)
                global MQUEST_DIRECTORY_PC
                fnm=[ MQUEST_DIRECTORY_PC '\ships.txt'];
            else
                global MQUEST_DIRECTORY_UNIX
                fnm=[ MQUEST_DIRECTORY_UNIX '/ships.txt'];
            end

            fid = fopen(fnm,'r');
            j=0;
            tmpdb = textscan(fid,'%s','delimiter',',','bufsize',10000);
            fclose(fid)
            tmpdb = tmpdb{1};
            for i=1:2:length(tmpdb)
                j=j+1;
                disp(['   ' S.fullname{j} ',' S.shortname{j}])
            end

            shortname=input('Please enter 10-characters for that ship name: ','s')
            while(length(shortname)>10)
                shortname=input('I said enter 10-CHARACTERS for that ship name: ','s')
            end

            long_shipname=shipname;
            S=writeshipnames(long_shipname,shortname);
    end
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

%Bec: Adjust the code so that it checks for 'SHIP' in callsign and looks
%for the correct callsign. For RAN DATA
if ~isempty(strmatch('SHIP',calls)) || ~isempty(strmatch('ship',calls))
    if (isempty(CALLS))
        C = getcalls;
    else
        C = CALLS;
    end
    ii = strmatch(shipname,C.shipname,'exact');
    if ~isempty(ii) && length(ii) == 1
        calls = char(C.calls(ii));
    else
        cl = input(['No callsign for this ship: ' shipname '. Please enter a callsign (default = ''SHIP''):'],'s');
        if isempty(cl)
            calls = 'SHIP'
        else
            calls = cl;
        end
        CALLS.shipname{end+1} = shipname;
        CALLS.calls{end+1} = calls;
    end
    
end
profiledata.QCversion=str4;
profiledata.dataavail='A';
coeff4=[];
profiledata.nparms=0;
profiledata.nsurfc=0;
profiledata.nhists=0;

profiledata.dup_flag='';
profiledata.digit_code='';
profiledata.standard='';

profiledata.pcode='';
profiledata.parm='';
profiledata.qparm='';
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

correctDepths=0;

fid=fopen(fname);
%Get the header data and ouput to both files:
d=fgets(fid);

while isempty(strmatch('Depth (m)',d))
    
    if(strmatch('Date',d))
        
        profiledata.year=str2num(d(24:27));
        profiledata.day=str2num(d(21:22));
        profiledata.month=str2num(d(18:19));
        
    elseif(strmatch('Time',d))
        
        %change time to decimal:
        profiledata.time=(str2num(d(18:19))*100 + str2num(d(21:22))) *100;
        
    elseif(strmatch('Latitude',d))
        
        s=find(d=='S');
        if(isempty(s));
            s=find(d=='N');
            ss=0;
        else
            ss=1;
        end
        if ~isempty(s)
            profiledata.lat=str2num(d(18:19))+str2num(d(21:s-1))/60;
            if(ss);profiledata.lat=-profiledata.lat;end
            profiledata.latitude=profiledata.lat;
        else
            profiledata.lat=[];
        end
        
    elseif(strmatch('Longitude',d))
        
        e=find(d=='E');
        if(isempty(e))
            e=find(d=='W');
            ee=0;
        else
            ee=1;
        end
        space=find(d(18:end)==' ');
        if ~isempty(space)
            profiledata.lon=str2num(d(18:18+space(1)-1))+str2num(d(18+space(1):e-1))/60;
            if(~ee);profiledata.lon=-profiledata.lon;end
            %need to multiply longitude by -1 and change to 360 degree long
            profiledata.longitude=profiledata.lon;
            if(profiledata.longitude<0)
                profiledata.longitude=360+profiledata.longitude;
            end
            profiledata.lon=profiledata.longitude;
        else
            profiledata.lon=[];
        end
        
    elseif(strmatch('Serial',d))
        
        serno=deblank(d(18:end));
        
    elseif(strmatch('Probe',d))
        
        probetypec=d(21:end);
    elseif(strmatch('Depth Coeff. 1',d))
        coeff1=deblank(d(21:end-1));
        
    elseif(strmatch('Depth Coeff. 2',d))
        coeff2=deblank(d(21:end-1));
        
    elseif(strmatch('Depth Coeff. 3',d))
        coeff3=deblank(d(21:end-1));
        
    elseif(strmatch('Depth Coeff. 4',d))
        coeff4=deblank(d(21:end-1));
        
    elseif(strmatch('// Sound',d))
        soundsal=d(49:58);
        
    end
    d=fgets(fid);
end

%start of profile data:
if ~isempty(strmatch('T-4',probetypec));
    if (str2num(coeff2)==6.691)
        probetype='002';
    else
        disp('ERROR!!! - you must use the new fall rate coefficients')
        probetype='001';
        correctDepths=1;
        %        pause
    end
elseif ~isempty(strmatch('T-7',probetypec)) 
    if(str2num(coeff2)==6.691)
        probetype='042';
    else
        disp('ERROR!!! - you must use the new fall rate coefficients')
        probetype='041';
        correctDepths=1;
        %        pause
    end
elseif ~isempty(strmatch('Deep',probetypec))
    if(str2num(coeff2)==6.691)
        probetype='052';
    else
        disp('ERROR!!! - you must use the new fall rate coefficients')
        probetype='051';
        correctDepths=1;
        %        pause
    end
elseif ~isempty(strmatch('XCTD',probetypec));
    probetype='700';
    profiledata.datat='XC';
elseif ~isempty(strmatch('T-5',probetypec));
    probetype='011';
elseif ~isempty(strmatch('T-10',probetypec));
    probetype='061';
else
    disp([probetypec ' probe type found - only Deep Blue, T-7, T-4, T-5 and XCTD probes are coded'])
    keyboard
end


profiledata.depth(1,1,1)=0;
profiledata.depresQ(1,1,1)=0;
profiledata.profparm(1,1,1)=0;
profiledata.profQparm(1,1,1)=0;
profiledata.nodepths=0;

proftypes=d;
kk=find(proftypes=='-');
profiledata.nprof=length(kk);

kt=strfind(proftypes,'Temp');
ks=strfind(proftypes,'Sal');
ksv=strfind(proftypes,'Sound');
kd=strfind(proftypes,'Dens');
kc=strfind(proftypes,'Cond');

if(~isempty(kt))
    kindt=find(kk<kt);
    profiledata.prof_type(kindt(end),:)='TEMP            ';
end
if(~isempty(ks))
    kinds=find(kk<ks);
    profiledata.prof_type(kinds(end),:)='PSAL            ';
end
if(~isempty(ksv))
    kindsv=find(kk<ksv);
    profiledata.prof_type(kindsv(end),:)='SVEL            ';
end
if(~isempty(kd))
    kindd=find(kk<kd);
    profiledata.prof_type(kindd(end),:)='DENS            ';
end
if(~isempty(kc))
    kindc=find(kk<kc);
    profiledata.prof_type(kindc(end),:)='COND            ';
end

m=0;
d=fgets(fid);

while(~feof(fid))
    finished=0;
    nd=0;
    clear data
    while ~finished
        [tt, d] = strtok(d);
        if isempty(d)
            finished = 1;
        else
            nd = nd + 1;
            data(nd) = sscanf(tt, '%f');
        end
    end
    
    m=m+1;
    
    for j=2:length(data)
        profiledata.depth(j-1,m)=data(1);
        profiledata.depresQ(j-1,m)='0';
        profiledata.profparm(j-1,m)=data(j);
        profiledata.profQparm(j-1,m)='0';
    end
    d=fgets(fid);
    
end
fclose(fid)

%convert last point:
finished=0;
nd=0;
data = [];
while ~finished
    [tt, d] = strtok(d);
    if isempty(d)
        finished = 1;
    else
        nd = nd + 1;
        data(nd) = sscanf(tt, '%f');
    end
end

if ~isempty(data)
    
    m=m+size(data,1);
end

for j=2:length(data)
    profiledata.depth(j-1,m)=data(1);
    profiledata.depresQ(j-1,m)='0';
    profiledata.profparm(j-1,m)=data(j);
    profiledata.profQparm(j-1,m)='0';
end

if isempty(profiledata.lat)
    profiledata.lat=input('enter DECIMAL latitude:');
    profiledata.latitude=profiledata.lat;
end
if isempty(profiledata.lon)
    profiledata.lon=input('enter DECIMAL longitude (360 degree globe):');
    profiledata.longitude=profiledata.lon;
end

if correctDepths
    calc_depths;
    [mm,nn]=size(profiledata.depth);
    profiledata.depth=[];
    for j=1:mm
        profiledata.depth(j,1:nn)=[0 z(1:nn-1)];
    end
    
    probetype(3:3)='2';
    coeff2='6.691';
    coeff3='-0.00225';
end


for i=1:profiledata.nprof
    profiledata.dup_flag(i)='N';
    profiledata.digit_code(i)='7';
    profiledata.standard(i)='2';
    profiledata.ndep=m;
    profiledata.D_P_Code(i)='D';
    profiledata.deep_depth(i)=profiledata.depth(i,m);
end



%convert the extra bits in the file:
%set it up for the finish...


%CS: need to pad to string10 - can't think of a better way
blk = ' ';
nblk = length(str10)-length(calls);
for j = 1:nblk, calls=[calls blk]; end
uqid = char(num2str(uniqueid));
nblk = length(str10)-length(uqid);
for j = 1:nblk, uqid=[uqid blk]; end
nblk = length(str10)-length(probetype);
for j = 1:nblk, probetype=[probetype blk]; end

nblk = length(str10)-length(coeff1);
for j = 1:nblk, coeff1=[coeff1 blk]; end
nblk = length(str10)-length(coeff2);
for j = 1:nblk, coeff2=[coeff2 blk]; end
nblk = length(str10)-length(coeff3);
for j = 1:nblk, coeff3=[coeff3 blk]; end
nblk = length(str10)-length(coeff4);
for j = 1:nblk, coeff4=[coeff4 blk]; end

nblk = length(str10)-length(serno);
for j = 1:nblk, serno=[serno blk]; end

if exist('soundsal','var')
    nblk=length(str10)-length(soundsal);
    for j = 1:nblk, soundsal=[soundsal blk]; end
end

%fill surface codes group:

surfpcode = ['IOTA';...
    'GCLL';...
    'CSID';...
    'PEQ$';...
    'RCT$';...
    'SER#';...
    'SHP#'];

surfparm  = ['          ';...
    calls;...
    uqid;...
    probetype;...
    '06        ';...
    serno;...
    shortname];
surfqparm = ['0';'0';'0';'0';'0';'0';'0';'0';'0';'0';'0'];
if exist('soundsal','var')
    surfpcode(length(surfqparm)+1,:)='SSPS';  % sound velocity reference salinity
    surfparm(length(surfqparm)+1,:)=soundsal;
    surfqparm(length(surfqparm)+1)='0';
end
profiledata.nsurfc=length(surfqparm);

profiledata.surfpcode=surfpcode;
profiledata.surfparm=surfparm;
profiledata.surfqparm=surfqparm;

%now read the data types, then the data
%while (strmatch('Depth (m)',d)==0 | isempty(strmatch('Depth (m)',d)))

profiledata.autoqc=0;

return
