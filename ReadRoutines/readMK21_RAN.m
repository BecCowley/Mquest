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

%if this data is to be added:
%CS: Fill these extra fields:
profiledata.Mky=str8';
profiledata.One_Deg_Sq=str8';
profiledata.Cruise_ID=cruiseID';
profiledata.Data_Type=('XB')';
profiledata.Iumsgno=str12';
profiledata.Stream_Source=str1;
profiledata.Uflag='U';
profiledata.MEDS_Sta=str8';
profiledata.Q_Pos='1';
profiledata.Q_Date_Time='1';
profiledata.Q_Record='1';
profiledata.Bul_Time=str12';
profiledata.Bul_Header=str6';
%     clo=datestr(clock,24);
%     update=[clo(1:2) clo(4:5) clo(7:10)];
%As of August, 2014, the format has been changed to yyyymmdd to agree with
%NOAA formats. Bec Cowley
update = datestr(now,'yyyymmdd');
profiledata.Up_date=update';
profiledata.Source_ID=str4';
profiledata.Stream_Ident=[DATA_QC_SOURCE 'XB']';


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
            
            fnm='ships.txt';
            
            fid = fopen(fnm,'r');
            j=0;
            tmpdb = textscan(fid,'%s','delimiter',',');
            fclose(fid);
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
profiledata.QC_Version=str4';
profiledata.Data_Avail='A';
coeff4=[];
profiledata.Nparms=0;
profiledata.Nsurfc=0;
profiledata.Num_Hists=0;

profiledata.Dup_Flag='';
profiledata.Digit_Code='';
profiledata.Standard='';

profiledata.Pcode=str4';
profiledata.Parm=str10';
profiledata.Q_Parm=str1;
profiledata.SRFC_Code='';
profiledata.SRFC_Parm='';
profiledata.SRFC_Q_Parm='';
profiledata.Ident_Code=repmat(str1,2,100);
profiledata.PRC_Code=repmat(str1,4,100);
profiledata.Version=repmat(str1,4,100);
profiledata.PRC_Date=repmat(str1,8,100);
profiledata.Act_Code=repmat(str1,2,100);
profiledata.Act_Parm=repmat(str1,4,100);
profiledata.Aux_ID=double.empty(100,0);
profiledata.Previous_Val=repmat(str1,4,100);
profiledata.Flag_severity=double.empty(100,0);%zeros here

profiledata.D_P_Code='D';
profiledata.Prof_Type='';

correctDepths=0;

fid=fopen(fname);
%Get the header data and ouput to both files:
d=fgets(fid);

while isempty(strmatch('Depth (m)',d))
    
    if(strmatch('Date',d))
        
        pd.year=d(24:27);
        pd.day=d(21:22);
        pd.month=d(18:19);
        %set up woce_date and woce_time variables
        wd = [d(24:27) d(18:19) d(21:22)];
        profiledata.woce_date = strrep(wd,' ','0');

    elseif(strmatch('Time',d))
        
        %change time to decimal:
        pd.time = d(18:22);
        profiledata.woce_time = num2str((str2num(d(18:19))*100 + str2num(d(21:22))) *100);
        
    elseif(strmatch('Latitude',d))
        
        s=find(d=='S');
        if(isempty(s));
            s=find(d=='N');
            ss=0;
        else
            ss=1;
        end
        if ~isempty(s)
            profiledata.latitude=str2num(d(18:19))+str2num(d(21:s-1))/60;
            if(ss);profiledata.latitude=-profiledata.latitude;end
        else
            profiledata.latitude=[];
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
            profiledata.longitude=str2num(d(18:18+space(1)-1))+str2num(d(18+space(1):e-1))/60;
            if(~ee);profiledata.longitude=-profiledata.longitude;end
            %need to multiply longitude by -1 and change to 360 degree long
            if(profiledata.longitude<0)
                profiledata.longitude=360+profiledata.longitude;
            end
        else
            profiledata.longitude=[];
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
        probetype='001';
        correctDepths=1;
        %        pause
    end
elseif ~isempty(strmatch('T-7',probetypec))
    if(str2num(coeff2)==6.691)
        probetype='042';
    else
        probetype='041';
        correctDepths=1;
        %        pause
    end
elseif ~isempty(strmatch('Deep',probetypec))
    if(str2num(coeff2)==6.691)
        probetype='052';
    else
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


profiledata.No_Depths=0;

proftypes=d;
kk=find(proftypes=='-');
profiledata.No_Prof=length(kk);

kt=strfind(proftypes,'Temp');
ks=strfind(proftypes,'Sal');
ksv=strfind(proftypes,'Sound');
kd=strfind(proftypes,'Dens');
kc=strfind(proftypes,'Cond');

if(~isempty(kt))
    kindt=find(kk<kt);
    profiledata.Prof_Type(kindt(end),:)='TEMP            ';
end
if(~isempty(ks))
    kinds=find(kk<ks);
    profiledata.Prof_Type(kinds(end),:)='PSAL            ';
end
if(~isempty(ksv))
    kindsv=find(kk<ksv);
    profiledata.Prof_Type(kindsv(end),:)='SVEL            ';
end
if(~isempty(kd))
    kindd=find(kk<kd);
    profiledata.Prof_Type(kindd(end),:)='DENS            ';
end
if(~isempty(kc))
    kindc=find(kk<kc);
    profiledata.Prof_Type(kindc(end),:)='COND            ';
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
        profiledata.Depthpress(m,j-1)=data(1);
        profiledata.DepresQ(1,m,j-1)='0';
        profiledata.Profparm(1,1,m,1,j-1)=data(j);
        profiledata.ProfQP(1,1,1,m,1,j-1)='0';
    end
    d=fgets(fid);
    
end
fclose(fid);

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
    profiledata.Depthpress(m,j-1)=data(1);
    profiledata.DepresQ(1,m,j-1)='0';
    profiledata.Profparm(1,1,m,1,j-1)=data(j);
    profiledata.ProfQP(1,1,1,m,1,j-1)='0';
end

if isempty(profiledata.latitude)
    profiledata.latitude=input('enter DECIMAL latitude:');
end
if isempty(profiledata.longitude)
    profiledata.longitude=input('enter DECIMAL longitude (360 degree globe):');
end

if correctDepths
    disp('Old coefficients used, updating to new')
    profiledata = calc_depths(probetype,profiledata);    
    probetype(3:3)='2';
    coeff2='6.691';
    coeff3='-0.00225';
end


for i=1:profiledata.No_Prof
    profiledata.Dup_Flag(i)='N';
    profiledata.Digit_Code(i)='7';
    profiledata.Standard(i)='2';
    profiledata.No_Depths(i)=m;
    profiledata.D_P_Code(i)='D';
    profiledata.Deep_Depth(i)=profiledata.Depthpress(m,i);
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
recordertype = '06';
surfcodeNames = {'CSID','GCLL','PEQ$','RCT$',...
    'SER#','SHP#'};
varsList = {'uqid','calls','probetype','recordertype', ...
    'serno','shortname'};
surfpcode = [];
surfparm =[];
surfqparm = [];
for a = 1:length(surfcodeNames)
    eval(['dat = ' varsList{a} ';'])
    if ~isempty(dat)
        surfpcode = [surfpcode; surfcodeNames{a}];
        d = str10;
        d(1:length(dat)) = dat;
        surfparm =[surfparm; d];
        surfqparm = [surfqparm; '0'];
    end
end

if exist('soundsal','var')
    surfpcode(length(surfqparm)+1,:)='SSPS';  % sound velocity reference salinity
    surfparm(length(surfqparm)+1,:)=soundsal;
    surfqparm(length(surfqparm)+1)='0';
end

profiledata.Nsurfc=length(surfqparm);

profiledata.SRFC_Code=surfpcode';
profiledata.SRFC_Parm=surfparm';
profiledata.SRFC_Q_Parm=surfqparm';

%now read the data types, then the data
%while (strmatch('Depth (m)',d)==0 | isempty(strmatch('Depth (m)',d)))

% profiledata.autoqc=0;

%make the pd structure for plotting and adding QC
pd.latitude=profiledata.latitude;
pd.longitude=profiledata.longitude;
pd.ndep=profiledata.No_Depths;
pd.depth = squeeze(profiledata.Depthpress);
pd.deep_depth = profiledata.Deep_Depth;
pd.qc = squeeze(profiledata.ProfQP);
pd.depth_qc = squeeze(profiledata.DepresQ);
pd.temp = squeeze(profiledata.Profparm);
pd.Flag_severity = profiledata.Flag_severity;
pd.numhists = profiledata.Num_Hists;
pd.nparms = profiledata.Nparms;
pd.QC_code = profiledata.Act_Code';
pd.QC_depth = profiledata.Aux_ID;
pd.PRC_Date = profiledata.PRC_Date';
pd.PRC_Code = profiledata.PRC_Code';
pd.Version = profiledata.Version';
pd.Act_Parm = profiledata.Act_Parm;
pd.Previous_Val = profiledata.Previous_Val;
pd.Ident_Code = profiledata.Ident_Code;
pd.surfcode = profiledata.SRFC_Code';
pd.surfparm = profiledata.SRFC_Parm';
pd.surfqparm = profiledata.SRFC_Q_Parm';
pd.nsurfc = profiledata.Nsurfc;
pd.ptype = profiledata.Prof_Type;

profiledata.Prof_Type = profiledata.Prof_Type';
%add in some more stuff to profiledata
ju=julian([str2num(pd.year) str2num(pd.month) str2num(pd.day) ...
    floor(profiledata.woce_time/100) rem(profiledata.woce_time,100) 0])-2415020.5;
profiledata.time = ju;
profiledata.woce_time = int32(profiledata.woce_time);
profiledata.woce_date = int32(str2double(profiledata.woce_date));

return
