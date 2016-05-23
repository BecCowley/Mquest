function [profiledata,pd]=readDEVIL(fname,uniqueid)

global SHIP_NAMES
global CALLS
global DATA_QC_SOURCE
global launchheight

%this function reads a single profile from a DEVIL drop file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
% profiledata = 
% 
%         woce_date: 20160426
%         woce_time: 142500
%              time: 42485
%          latitude: -25.35
%         longitude: 131.03
%         Num_Hists: 1
%           No_Prof: 1
%            Nparms: 0
%            Nsurfc: 13
%               Mky: [8x1 char]
%        One_Deg_Sq: [8x1 char]
%         Cruise_ID: [10x1 char]
%         Data_Type: [2x1 char]
%           Iumsgno: [12x1 char]
%     Stream_Source: ' '
%             Uflag: 'U'
%          MEDS_Sta: [8x1 char]
%             Q_Pos: '1'
%       Q_Date_Time: '1'
%          Q_Record: '1'
%           Up_date: [8x1 char]
%          Bul_Time: [12x1 char]
%        Bul_Header: [6x1 char]
%         Source_ID: [4x1 char]
%      Stream_Ident: [4x1 char]
%        QC_Version: [4x1 char]
%        Data_Avail: 'A'
%         Prof_Type: [16x1 char]
%          Dup_Flag: 'N'
%        Digit_Code: '7'
%          Standard: '2'
%        Deep_Depth: 198.7
%             Pcode: [30x4 char]
%              Parm: [30x10 char]
%            Q_Parm: [30x1 char]
%         SRFC_Code: [30x4 char]
%         SRFC_Parm: [30x10 char]
%       SRFC_Q_Parm: [30x1 char]
%        Ident_Code: [100x2 char]
%          PRC_Code: [100x4 char]
%           Version: [100x4 char]
%          PRC_Date: [100x8 char]
%          Act_Code: [100x2 char]
%          Act_Parm: [100x4 char]
%            Aux_ID: [100x1 single]
%      Previous_Val: [100x10 char]
%     Flag_severity: [100x1 int32]
%          D_P_Code: 'D'
%         No_Depths: 300
%        Depthpress: [400x1 double]
%          Profparm: [400x1 double]
%           DepresQ: [400x1 char]
%            ProfQP: [400x1 char]

%And a holding structure (pd) for QCd data, plotting. Returned to main
%structure at write time.
% pd = 
% 
%          latitude: -25.35
%         longitude: 131.03
%              year: '2016'
%             month: '04'
%              day: '26'
%              ndep: 300
%              time: '14:25'
%             depth: [400x1 double]
%                qc: [400x1 char]
%          depth_qc: [400x1 char]
%              temp: [400x1 double]
%     Flag_severity: [100x1 int32]
%          numhists: 1
%            nparms: 0
%           QC_code: [100x2 char]
%          QC_depth: [100x1 double]
%          PRC_Date: [100x8 char]
%          PRC_Code: [100x4 char]
%           Version: [100x4 char]
%          Act_Parm: [100x4 char]
%      Previous_Val: [100x10 char]
%        Ident_Code: [100x2 char]
%          surfcode: [30x4 char]
%          surfparm: [30x10 char]
%         surfqparm: [30x1 char]
%            nsurfc: 13

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
str2 = '  ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

%Get data and place in structures:
rawdata = nc2struct(fname);

%CS: profile date
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

%CS: Fill these extra fields:
profiledata.Mky=str8;
profiledata.One_Deg_Sq=str8;
profiledata.Cruise_ID=str10; %fill in below
profiledata.Data_Type='XB';
profiledata.Iumsgno=str12;
profiledata.Stream_Source=str1;
profiledata.Uflag='U'; %required for NOAA. 'U' = update, 'S' = skip. Bec Cowley, August 2014.
profiledata.MEDS_Sta=str8;
profiledata.Q_Pos='1';
profiledata.Q_Date_Time='1';
profiledata.Q_Record='1';
profiledata.Bul_Time=str12;
profiledata.Bul_Header=str6;
profiledata.Ident_Code=str2;
profiledata.PRC_Code=repmat(str1,4,100);
profiledata.Version=repmat(str1,4,100);
profiledata.PRC_Date=repmat(str1,8,100);
profiledata.Act_Code=repmat(str1,2,100);
profiledata.Act_Parm=repmat(str1,4,100);
profiledata.Aux_ID=double.empty(100,0);
profiledata.Previous_Val=repmat(str1,4,100);
profiledata.Flag_severity=double.empty(100,0);%zeros here
%     clo=datestr(clock,24);
%     update=[clo(1:2) clo(4:5) clo(7:10)];
%As of August, 2014, the format has been changed to yyyymmdd to agree with
%NOAA formats. Bec Cowley
update = datestr(now,'yyyymmdd');
profiledata.Up_date=update;
profiledata.Source_ID=str4;
profiledata.Stream_Ident=[DATA_QC_SOURCE 'XB'];
profiledata.QC_Version=str4;
profiledata.Data_Avail='A';

%CS: Only 1 profile per file
profiledata.No_Prof=1;
profiledata.Nparms=0;
profiledata.Num_Hists=0;

% profiledata.nosseg=1;
profiledata.Prof_Type='TEMP            ';
profiledata.Dup_Flag='N';
profiledata.Digit_Code='7';
profiledata.Standard='2';

profiledata.Pcode=str4;
profiledata.Parm=str10;
profiledata.Q_Parm=str1;

%RC: Get global attributes
namesList = {'CallSign','Code','Voyage','InterfaceType','InterfaceCode', ...
    'SerialNo','BatchDate','DropHeight','CaseNo','Scale','Offset','CRC', ...
    'LineNo','Ship','PreDropComments','PostDropComments'};
varsList = {'gcll','probetype','cruiseID','cardtype','recordertype', ...
    'serno','mfd','dropheight','caseno','scale','offset','crc','lineno', ...
    'shipname','profiledata.comments_pre','profiledata.comments_post'};

%read the Quoll/Devil file attributes
finfo = ncinfo(fname);
atts = squeeze(struct2cell(finfo.Attributes));
shipname=[];recordertype = [];mfd = [];

for a = 1:length(namesList)
    ii = find(strcmp(atts(1,:),namesList{a})==1);
    if ~isempty(ii)
        eval([varsList{a} ' = atts{2,ii};']);
    else
        eval([varsList{a},' = [];'])
    end
end

if length(serno) > 10
    while length(serno) > 10
        disp('LENGTH OF SERIAL NUMBER > 10!!')
        disp(['Serial number = ' serno])
        serno = input('Enter correct number (<10 characters): ','s');
    end
end

%BEC: add this section to use the folder name for cruise ID for RAN data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pt = fname(1:end-3);
ij = strfind(pt,'.');
ik = strfind(pt,'RAN');
if ~isempty(ij) && ~isempty(ik)
    disp('ALTERING CRUISE_ID AND STREAM_IDENT FOR RAN DATA!!')
    pt = pt(ij-5:ij+2);
    ij = strfind(pt,'.');
    pt(ij) = [];
    cruiseID = '          ';
    cruiseID(1:length(pt)) = pt;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(shipname))
    kk=strcmpi(shipname,S.fullname);
    if(~isempty(kk))
        shortname=S.shortname(kk);
        s=shortname;
        shortname=s{1};
    else
        if ~isempty(strmatch('RV METOC',shipname)) || ...
                (~isempty(strmatch('SHIP',gcll)) || ~isempty(strmatch('ship',gcll)))
            %default for RAN data, check what ship it belongs to
            if ispc
                global MQUEST_DIRECTORY_PC
                fnm=[ MQUEST_DIRECTORY_PC '\calls.txt'];
            else
                global MQUEST_DIRECTORY_UNIX
                fnm=[ MQUEST_DIRECTORY_UNIX '/calls.txt'];
            end
            fid = fopen(fnm,'r');
            tmpdb = textscan(fid,'%s%s%s','delimiter',',');
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
            tmpdb = textscan(fid,'%s','delimiter',',');
            fclose(fid);
            tmpdb = tmpdb{1};
            for i=1:2:length(tmpdb)
                j=j+1;
                disp(['   ' S.fullname{j} ',' S.shortname{j}])
            end

            shortname=input('Please enter 10-characters for that ship name: ','s');
            while(length(shortname)>10)
                shortname=input('I said enter 10-CHARACTERS for that ship name: ','s');
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

if length(cruiseID)>10
    c=cruiseID;
    clear cruiseID;
    cruiseID=c(1:10);
end

%Bec: Adjust the code so that it checks for 'SHIP' in callsign and looks
%for the correct callsign. For RAN DATA
if ~isempty(strmatch('SHIP',gcll)) || ~isempty(strmatch('ship',gcll))
    if (isempty(CALLS))
        C = getcalls;
    else
        C = CALLS;
    end
    ii = strmatch(shipname,C.shipname,'exact');
    if ~isempty(ii) && length(ii) == 1
        gcll = char(C.calls(ii));
    else
        cl = input(['No callsign for this ship: ' shipname '. Please enter a callsign (default = ''SHIP''):'],'s');
        if isempty(cl)
            gcll = 'SHIP';
        else
            gcll = cl;
        end
        CALLS.shipname{end+1} = shipname;
        CALLS.gcll{end+1} = gcll;
    end
    
end
%look for missing recorder type (happens sometimes in early versions of
%devil software). Bec, Sept 2014
if isempty(recordertype)
    recordertype = input('Missing recordertype, please enter in GTSPP code: ','s');
end

%ask for missing launch height and batch date information
if ~exist('launchheight','var')
    launchheight = dropheight;
end
if isempty(dropheight) && ~isempty(launchheight)
    lh = input(['Please enter a launch height: [default: ' ...
        launchheight 'm]'],'s');
    if isempty(lh); lh = launchheight; end
    dropheight = launchheight;
elseif isempty(dropheight) & isempty(launchheight)
    launchheight = input('Please enter a launch height in m[default: ''Unknown'']:','s');
    if isempty(launchheight)
        launchheight = 'Unknown';
    end
    dropheight = launchheight;
end

if  isempty(mfd)
    disp(fname)
    mfd = input('Please enter a batch date for this probe (mm/dd/yy)[''Unknown'']:','s');
    if isempty(mfd)
        mfd = 'Unknown';
    end
end
%reformat the batch date to yyyymmdd
if isempty(strmatch('UNKNOWN',upper(mfd)))
    dt = datenum(mfd,'mm/dd/yy');
    mfd = datestr(dt,'yyyymmdd');
end

%fill values for surface parm 
profiledata.Cruise_ID=cruiseID;
surfcodeNames = {'CSID','GCLL','PEQ$','RCT$','OFFS','SCAL',...
             'SER#','MFD#','HTL$','CRC$','TWI#','SHP#'};
varsList = {'pd.nss','gcll','probetype','recordertype', ...
    'offset','scale','serno','mfd','dropheight','crc','lineno', ...
    'shortname'};

surfpcode = [];
surfparm =[];
surfqparm = [];
for a = 1:length(surfcodeNames)
    eval(['dat = ' varsList{a} ';'])
    if ~isempty(dat)
        surfpcode = [surfpcode; surfcodeNames{a}];
        d = str10;
        d(1:length(dat)) = dat;
        surfparm = [surfparm; d];
        surfqparm = [surfqparm; '0'];
    end
end
profiledata.Nsurfc=length(surfqparm);

profiledata.SRFC_Code=surfpcode;
profiledata.SRFC_Parm=surfparm;
profiledata.SRFC_Q_Parm=surfqparm;

profiledata.D_P_Code='D';
profiledata.Prof_Type='TEMP            ';
 
% Parameter data and QC flags
depths = rawdata.depth;
ndepths = length(depths);
profiledata.Depthpress(:,1) = depths;
profiledata.Deep_Depth=max(depths);
profiledata.No_Depths=ndepths;
profiledata.DepresQ(1,1:ndepths,1)='0';
profiledata.Profparm(1,1,:,1,1) = ncread(fname,'temperature');
profiledata.ProfQP(1,1,1,1:ndepths,1,1)='0';

profiledata.Aux_ID=0; %was profiledata.autoqc

%make the pd structure for plotting and adding QC
pd.latitude=profiledata.latitude;
pd.longitude=profiledata.longitude;
pd.year=profiledata.woce_date(1:4);
pd.month=profiledata.woce_date(5:6);
pd.day=profiledata.woce_date(7:8);
pd.ndep=profiledata.No_Depths;
wt=profiledata.woce_time;
wt=floor(wt/100);
wt2=sprintf('%4i',wt);
jk=strfind(wt2,' ');
if(~isempty(jk))
    wt2(jk)='0';
end
pd.time=[wt2(1:2) ':' wt2(3:4)];
pd.depth = depths;
pd.qc = profiledata.ProfQP;
pd.depth_qc = profiledata.DepresQ;
pd.temp = profiledata.Profparm;
pd.Flag_severity = profiledata.Flag_severity;
pd.numhists = profiledata.Num_Hists;
pd.nparms = profiledata.Nparms;
pd.QC_code = profiledata.Act_Code;
pd.QC_depth = profiledata.Aux_ID;
pd.PRC_Date = profiledata.PRC_Date;
pd.PRC_Code = profiledata.PRC_Code;
pd.Version = profiledata.Version;
pd.Act_Parm = profiledata.Act_Parm;
pd.Previous_Val = profiledata.Previous_Val;
pd.Ident_Code = profiledata.Ident_Code;
pd.surfcode = profiledata.SRFC_Code;
pd.surfparm = profiledata.SRFC_Parm;
pd.surfqparm = profiledata.SRFC_Q_Parm;
pd.nsurfc = profiledata.Nsurfc;

%add in some more stuff to profiledata"
ju=julian([pd.year pd.month pd.day ...
    floor(pd.time/100) rem(pd.time,100) 0])-2415020.5;
profiledata.time = ju;
profiledata.woce_time = int32(profiledata.woce_time);
profiledata.woce_date = int32(str2double(profiledata.woce_date));
return
