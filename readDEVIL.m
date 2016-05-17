function profiledata=readDEVIL(fname,uniqueid)

global SHIP_NAMES
global CALLS
global DATA_QC_SOURCE
global launchheight

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
woce_date = num2str(ncread(fname,'woce_date'));
profiledata.year=str2num(woce_date(1:4));
profiledata.month=str2num(woce_date(5:6));
profiledata.day=str2num(woce_date(7:8));
%CS: profile time - get rid of milliseconds
time = ncread(fname,'woce_time');
profiledata.time = floor(time/100)*100;
profiledata.latitude = ncread(fname,'latitude');
%CS: need to multiply lon by -1 so same convention as MA
profiledata.longitude = ncread(fname,'longitude');
if profiledata.longitude < 0
    profiledata.longitude = profiledata.longitude +360;
end
profiledata.lon=profiledata.longitude;
profiledata.lat=profiledata.latitude;

%CS: Fill these extra fields:
profiledata.mky=str8;
profiledata.onedegsq=str8;
profiledata.cruiseID=str10; %fill in below
profiledata.datat='XB';
profiledata.iumsgno=str12;
profiledata.streamsource=str1;
profiledata.uflag='U'; %required for NOAA. 'U' = update, 'S' = skip. Bec Cowley, August 2014.
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
    kk=strmatch(upper(shipname),upper(S.fullname),'exact');
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
profiledata.cruiseID=cruiseID;
surfcodeNames = {'CSID','GCLL','PEQ$','RCT$','OFFS','SCAL',...
             'SER#','MFD#','HTL$','CRC$','TWI#','SHP#'};
varsList = {'profiledata.nss','gcll','probetype','recordertype', ...
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
depths = ncread(fname,'depth');
ndepths = length(depths);
profiledata.depth(1,1,1)=0; 
profiledata.depth(1,1,1:ndepths) = depths;
profiledata.deep_depth=max(depths);
profiledata.nodepths=ndepths;
%CS: Depth QC
profiledata.depresQ(1,1,1:ndepths)='0';
%CS: Profile parameter
profiledata.profparm(1,1,1)=0;
profiledata.profparm(1,1,1:ndepths) = ncread(fname,'temperature');
%CS: Profile parameter QC
profiledata.profQparm(1,1,1:ndepths)='0';

profiledata.ndep=profiledata.nodepths; %CHECK
profiledata.autoqc=0;

return
