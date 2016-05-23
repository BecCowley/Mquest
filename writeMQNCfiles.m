function writeMQNCfiles(profiledata,pd,writekeys)
%
%writeMQNCfiles - writes the full file for a single profile, creating the
%file if required. Used in the import function.
%
%usage:  writeMQNCfiles(profiledata,writekeys)
%where:  profiledata is the structure containing the data to be written -
%               with appropriate names. This must be set up in the routine
%               that inputs the data.
%and     writekeys is a logical variable that determines whether or not you
%               need the dey information added to the keys database.
%
%The structure and variable types () required are:
%
%profiledata = 
%             nss: [character*8]   %unique id of the profile
%            year: [integer]    %year
%           month: [integer]    %month    
%             day: [integer]    %day
%            time: [integer]    %time as integer (04:35 = 435)
%             lat: [single]     %latitude
%             lon: [single]     %longitude
%             mky: [character*8] %a meds ascii variable that will exist
%                                       only if the input file is MA
%        onedegsq: [character*8]   %a meds ascii variable that will exist
%                                       only if the input file is MA
%        cruiseID: [character*10]  %the cruise identifier (e.g., la0502a)
%           datat: [character*2]   %the data type - e.g., 'XB' or 'CT'
%         iumsgno: [character*12]  %a meds ascii variable that will exist
%                                       only if the input file is MA
%    streamsource: [character*1]   %a meds ascii variable that will exist
%                                       only if the input file is MA
%           uflag: [character*1]   %a meds ascii variable that will exist
%                                       only if the input file is MA
%         medssta: [character*8]   %a meds ascii variable that will exist
%                                       only if the input file is MA
%            qpos: [character*1]   %the quality of the position - starts as
%                                       '1'
%       qdatetime: [character*1]   %the quality of the date/time fields -
%                                       starts as '1'
%            qrec: [character*1]   %the quality of the profile data -
%                                       equals the WORST quality in the profile!
%          update: [character*8]   %the data this file was updated
%         bultime: [character*12]  %a meds ascii variable that will exist
%                                       only if the input file is MA
%       bulheader: [character*6]   %a meds ascii variable that will exist
%                                       only if the input file is MA
%        sourceID: [character*4]   %where did this profile originate (blank
%                                       for our data)
%     streamident: [character*4]   %who collected this data (CSXB for CSIRO
%                                       XBT data
%       QCversion: [character*4]   %identification of the QC process used
%                                       (CSCB for CSIRO COOKBOOK)
%       dataavail: [character*1]   %is the data available for
%                                       distribution ('A' = yes, 'N' = no)
%           nprof: [integer]       %number of profiles in the file - e.g.,
%                                       if both salinity and temperature are 
%                                       present, nprof=2
%          nparms: [integer]       %number of parameters present - we don't
%                                       currently set any of these but they may 
%                                       come from NODC i na
%                                       meds-ascii file...
%          nsurfc: [integer]       %number of surface codes present  -
%                                       these include things like probe type 
%                                       and fallrate equation and probe serial number.    
%          nhists: [integer]       %number of history records present -
%                                       these are added to as you QC the profile.
%          nosseg: [integer]       %the number of segments in the profile -
%                                       only really relevant to the meds-ascii 
%                                       files where a max of 1500 data values is
%                                       allowed per segment.
%      deep_depth: [real]          %the deepest depth in the profile 
%       prof_type: [nprof x character*16]  %an array identifying the data within
%                                       the file - TEMP= temperature data, 
%                                       PSAL = salinity data 
%        dup_flag: [character*1]   %is this profile a duplicate of another profile 
%                                       in the database? ('Y' = yes, 'N' = no)
%      digit_code: '7'             %? always has this value?
%        standard: '2'             %? always has this value?
%           pcode: [nparms x character*4]  %parameter identifier
%            parm: [nparms x character*10] %parameter value
%           qparm: [nparms x character*1]  %quality of the parameter
%       surfpcode: [nsurfc x 4 char]
%        surfparm: [nsurfc x 10 char]
%       surfqparm: '10000000'
%       identcode: 'CS'
%         PRCcode: 'CSCB'
%         Version: ' 1.0'
%         PRCdate: '24042006'
%         Actcode: 'TP'
%         Actparm: 'TEMP'
%           AuxID: 0.6700
%     PreviousVal: '    14.050'
%    flagseverity: 0
%        D_P_Code: 'D'
%    profile_type: [1x1x4 char]
%           depth: [1x900 double]
%         depresQ: [1x900 double]
%        profParm: 0
%       profQparm: [1x900 double]
%        nodepths: 900
%        profparm: [1x900 double]
%       no_depths: 900
%          autoqc: 0
%         nossegs: 0


if(pd.ndep==0)
    return
end
filenam=pd.outputfile{1};
n=str2num(pd.nss);
nss=num2str(n);

for j=1:2:length(nss);
    
    if(j+1>length(nss))
        if(ispc)
            filenam=[filenam '\' nss(j)];
        else
            filenam=[filenam '/' nss(j)];
        end
    else
        if(ispc)
            filenam=[filenam '\' nss(j:j+1)];
        else
            filenam=[filenam '/' nss(j:j+1)];
        end
    end
end

filenam1=[filenam 'ed.nc'];
filenam2=[filenam 'raw.nc'];

%Now start writing:

filenamnew=filenam1
createMQNCfiles(profiledata,filenamnew)
filenamnew=filenam2;
createMQNCfiles(profiledata,filenamnew)

% check that the csid is set properly...

%checkcsid
%flip some fields around:
profiledata.SRFC_Code=profiledata.SRFC_Code';
profiledata.SRFC_Parm=profiledata.SRFC_Parm';
profiledata.SRFC_Q_Parm=profiledata.SRFC_Q_Parm';

% Extract data from the profiledata structure created with the input
% function

flds = fieldnames(profiledata);
for a = 1:length(flds)
    try
    if ~isempty(profiledata.(flds{a}))
        %     write edited file
        ncwrite(filenam1,flds{a},profiledata.(flds{a}));
        %write raw file
        ncwrite(filenam2,flds{a},profiledata.(flds{a}));
    end
    catch
        disp([num2str(a) ' ' flds{a}])
        continue
    end
end

prof=profiledata.profparm;
profQ=profiledata.profQparm;
dep=profiledata.depth(:,:);
depQ=profiledata.depresQ;

wocedate=profiledata.year*10000 + profiledata.month*100 + profiledata.day;
profilestats=[wocedate  profiledata.latitude profiledata.longitude]

editedncfile{'woce_date' }(:) = wocedate ;
editedncfile{'woce_time' }(:) = profiledata.time ;
ju=julian([profiledata.year profiledata.month profiledata.day ...
    floor(profiledata.time/10000) rem(profiledata.time,100) 0])-2415020.5;
editedncfile{'time' }(:) =  ju;
editedncfile{'latitude' }(:) = profiledata.lat;
editedncfile{'longitude' }(:) = profiledata.lon;
editedncfile{'Num_Hists' }(:) = profiledata.nhists;
editedncfile{'No_Prof' }(:) = profiledata.nprof;
editedncfile{'Nparms' }(:) = profiledata.nparms;
editedncfile{'Nsurfc' }(:) = profiledata.nsurfc;
editedncfile{'Mky'}(1:8) = profiledata.mky(1:8);
editedncfile{'One_Deg_Sq' }(1:8) = profiledata.onedegsq;
editedncfile{'Cruise_ID' }(1:10) = profiledata.cruiseID;
editedncfile{'Data_Type' }(1:2) = profiledata.datat;
editedncfile{'Iumsgno' }(1:12) = profiledata.iumsgno;
editedncfile{'Stream_Source' }(:) =profiledata.streamsource ;
editedncfile{'Uflag' }(:) = profiledata.uflag;
editedncfile{'MEDS_Sta' }(1:8) = profiledata.medssta;
editedncfile{'Q_Pos' }(:) = profiledata.qpos;
editedncfile{'Q_Date_Time' }(:) = profiledata.qdatetime;
editedncfile{'Q_Record' }(:) = profiledata.qrec;
editedncfile{'Up_date' }(:) = profiledata.update;
editedncfile{'Bul_Time' }(1:12) = profiledata.bultime;
editedncfile{'Bul_Header' }(1:6) = profiledata.bulheader;
editedncfile{'Source_ID' }(1:4) = profiledata.sourceID;
editedncfile{'Stream_Ident' }(1:4) = profiledata.streamident;
editedncfile{'QC_Version' }(1:4) = profiledata.QCversion;
editedncfile{'Data_Avail' }(:) = profiledata.dataavail;
editedncfile{'Prof_Type' }(1:profiledata.nprof,1:16) = profiledata.prof_type(1:profiledata.nprof,1:16);
editedncfile{'Dup_Flag' }(1:profiledata.nprof,:) = profiledata.dup_flag;
editedncfile{'Digit_Code' }(1:profiledata.nprof,:) = profiledata.digit_code;
editedncfile{'Standard' }(1:profiledata.nprof,:) = profiledata.standard;
editedncfile{'Deep_Depth' }(1:profiledata.nprof) = profiledata.deep_depth;
if(profiledata.nparms~=0)
    editedncfile{'Pcode' }(1:profiledata.nparms,1:4) = profiledata.pcode;
    editedncfile{'Parm' }(1:profiledata.nparms,1:10) = profiledata.parm;
    editedncfile{'Q_Parm' }(1:profiledata.nparms,1) = profiledata.qparm;
end
if(profiledata.nsurfc~=0)
    editedncfile{'SRFC_Code' }(1:profiledata.nsurfc,1:4) = profiledata.surfpcode;
    editedncfile{'SRFC_Parm' }(1:profiledata.nsurfc,1:10) = profiledata.surfparm;
    editedncfile{'SRFC_Q_Parm' }(1:profiledata.nsurfc,1) = profiledata.surfqparm;
end
if(profiledata.nhists~=0)
    editedncfile{'Ident_Code' }(1:profiledata.nhists,1:2) = profiledata.identcode;
    editedncfile{'PRC_Code' }(1:profiledata.nhists,1:4) = profiledata.PRCcode;
    editedncfile{'Version' }(1:profiledata.nhists,1:4) = profiledata.Version;
    editedncfile{'PRC_Date' }(1:profiledata.nhists,1:8) = profiledata.PRCdate;
    editedncfile{'Act_Code' }(1:profiledata.nhists,1:2) = profiledata.Actcode;
    editedncfile{'Act_Parm' }(1:profiledata.nhists,1:4) = profiledata.Actparm;
    editedncfile{'Aux_ID' }(1:profiledata.nhists) = profiledata.AuxID;
    editedncfile{'Previous_Val' }(1:profiledata.nhists,1:10) = profiledata.PreviousVal;
%     fs(1:length(profiledata.flagseverity))=profiledata.flagseverity;
%     fs(length(profiledata.flagseverity+1:100))=0;
    editedncfile{'Flag_severity' }(1:profiledata.nhists) = profiledata.flagseverity;
else
    c4(1:100)={'    '};
    c2(1:100,:)={'  '};
    c10(1:100,:)={'          '};
    c8(1:100,:)={'        '};
    c0(1:100)=int32(0);
    editedncfile{'Ident_Code' } (1:100,:)= char(c2);
    editedncfile{'PRC_Code' } (1:100,:)= char(c4);
    editedncfile{'Version' }(1:100,:) = char(c4);
    editedncfile{'PRC_Date' }(1:100,:) = char(c8);
    editedncfile{'Act_Code' }(1:100,:) = char(c2);
    editedncfile{'Act_Parm' }(1:100,:) = char(c4);
    editedncfile{'Aux_ID' }(1:100) = c0;
    editedncfile{'Previous_Val' }(1:100,1:10) = char(c10);
    editedncfile{'Flag_severity' }(1:100) = c0; 
end
editedncfile{'D_P_Code' }(1:profiledata.nprof) = profiledata.D_P_Code;
editedncfile{'No_Depths' }(1:profiledata.nprof) = profiledata.ndep;
editedncfile{'Depthpress' }(1:profiledata.nprof,1:profiledata.ndep) = dep(1:profiledata.nprof,1:profiledata.ndep);
editedncfile{'Profparm' }(1:profiledata.nprof,1,1:profiledata.ndep,1,1) = prof(1:profiledata.nprof,1:profiledata.ndep);
editedncfile{'ProfQP' }(1:profiledata.nprof,1,1:profiledata.ndep,1,1,1) = profQ(1:profiledata.nprof,1:profiledata.ndep);
editedncfile{'DepresQ' }(1:profiledata.nprof,1:profiledata.ndep,1) = depQ(1:profiledata.nprof,1:profiledata.ndep);
 %add comments if available
if isfield(profiledata,'comments_pre')
    editedncfile{'PreDropComments'}(1:length(profiledata.comments_pre)) = profiledata.comments_pre;
end
if isfield(profiledata,'comments_post')
    editedncfile{'PostDropComments'}(1:length(profiledata.comments_post)) = profiledata.comments_post;
end
   

%****  Now write the raw file:

rawncfile{'woce_date' }(:) = wocedate ;
rawncfile{'woce_time' }(:) = profiledata.time ;
ju=julian([profiledata.year profiledata.month profiledata.day ...
    floor(profiledata.time/100) rem(profiledata.time,100) 0])-2415020.5;
rawncfile{'time' }(:) =  ju;

rawncfile{'latitude' }(:) = profiledata.lat;
rawncfile{'longitude' }(:) = profiledata.lon;
rawncfile{'Num_Hists' }(:) = profiledata.nhists;
rawncfile{'No_Prof' }(:) = profiledata.nprof;
rawncfile{'Nparms' }(:) = profiledata.nparms;
rawncfile{'Nsurfc' }(:) = profiledata.nsurfc;
rawncfile{'Mky'}(1:8) = profiledata.mky(1:8);
rawncfile{'One_Deg_Sq' }(1:8) = profiledata.onedegsq;
rawncfile{'Cruise_ID' }(1:10) = profiledata.cruiseID;
rawncfile{'Data_Type' }(1:2) = profiledata.datat;
rawncfile{'Iumsgno' }(1:12) = profiledata.iumsgno;
rawncfile{'Stream_Source' }(:) = profiledata.streamsource ;
rawncfile{'Uflag' }(:) = profiledata.uflag;
rawncfile{'MEDS_Sta' }(1:8) = profiledata.medssta;
rawncfile{'Q_Pos' }(:) = profiledata.qpos;
rawncfile{'Q_Date_Time' }(:) = profiledata.qdatetime;
rawncfile{'Q_Record' }(:) = profiledata.qrec;
rawncfile{'Up_date' }(:) = profiledata.update;
rawncfile{'Bul_Time' }(1:12) = profiledata.bultime;
rawncfile{'Bul_Header' }(1:6) = profiledata.bulheader;
rawncfile{'Source_ID' }(1:4) = profiledata.sourceID;
rawncfile{'Stream_Ident' }(1:4) = profiledata.streamident;
rawncfile{'QC_Version' }(1:4) = profiledata.QCversion;
rawncfile{'Data_Avail' }(:) = profiledata.dataavail;
rawncfile{'Prof_Type' }(1:profiledata.nprof,1:16) = profiledata.prof_type(1:profiledata.nprof,1:16);
rawncfile{'Dup_Flag' }(1:profiledata.nprof,:) = profiledata.dup_flag;
rawncfile{'Digit_Code' }(1:profiledata.nprof,:) = profiledata.digit_code;
rawncfile{'Standard' }(1:profiledata.nprof,:) = profiledata.standard;
rawncfile{'Deep_Depth' }(1:profiledata.nprof) = profiledata.deep_depth;
if(profiledata.nparms~=0)
    rawncfile{'Pcode' }(1:profiledata.nparms,1:4) = profiledata.pcode;
    rawncfile{'Parm' }(1:profiledata.nparms,1:10) = profiledata.parm;
    rawncfile{'Q_Parm' }(1:profiledata.nparms,1) = profiledata.qparm;
end
if(profiledata.nsurfc~=0)
    rawncfile{'SRFC_Code' }(1:profiledata.nsurfc,1:4) = profiledata.surfpcode;
    rawncfile{'SRFC_Parm' }(1:profiledata.nsurfc,1:10) = profiledata.surfparm;
    rawncfile{'SRFC_Q_Parm' }(1:profiledata.nsurfc,1) = profiledata.surfqparm;
end
if(profiledata.nhists~=0)
    rawncfile{'Ident_Code' }(1:profiledata.nhists,1:2) = profiledata.identcode;
    rawncfile{'PRC_Code' }(1:profiledata.nhists,1:4) = profiledata.PRCcode;
    rawncfile{'Version' }(1:profiledata.nhists,1:4) = profiledata.Version;
    rawncfile{'PRC_Date' }(1:profiledata.nhists,1:8) = profiledata.PRCdate;
    rawncfile{'Act_Code' }(1:profiledata.nhists,1:2) = profiledata.Actcode;
    rawncfile{'Act_Parm' }(1:profiledata.nhists,1:4) = profiledata.Actparm;
    rawncfile{'Aux_ID' }(1:profiledata.nhists) = profiledata.AuxID;
    rawncfile{'Previous_Val' }(1:profiledata.nhists,1:10) = profiledata.PreviousVal;
    rawncfile{'Flag_severity' }(1:profiledata.nhists) = profiledata.flagseverity;
end
rawncfile{'D_P_Code' }(1:profiledata.nprof) = profiledata.D_P_Code;
rawncfile{'No_Depths' }(1:profiledata.nprof) = profiledata.ndep;
rawncfile{'Depthpress' }(1:profiledata.nprof,1:profiledata.ndep) = dep(1:profiledata.nprof,1:profiledata.ndep);
rawncfile{'Profparm' }(1:profiledata.nprof,1,1:profiledata.ndep,1,1) = prof(1:profiledata.nprof,1:profiledata.ndep);
rawncfile{'ProfQP' }(1:profiledata.nprof,1,1:profiledata.ndep,1,1,1) = profQ(1:profiledata.nprof,1:profiledata.ndep);
rawncfile{'DepresQ' }(1:profiledata.nprof,1:profiledata.ndep,1) = depQ(1:profiledata.nprof,1:profiledata.ndep);

 %add comments if available
if isfield(profiledata,'comments_pre')
    rawncfile{'PreDropComments'}(1:length(profiledata.comments_pre)) = profiledata.comments_pre;
end
if isfield(profiledata,'comments_post')
    rawncfile{'PostDropComments'}(1:length(profiledata.comments_post)) = profiledata.comments_post;
end
close(editedncfile);
close(rawncfile);

    


%write keys files - create if it doesn't exist...

if(writekeys)
    
    keysfile=[profiledata.outputfile{1} '_keys.nc'];
    try
        newkeysdata=netcdf(keysfile,'write');
        d1 = newkeysdata{'stn_num'};
    catch
        newkeysdata = [];
    end
    if(isempty(newkeysdata)) || isempty(d1)
        %create keys file...
        createkeys
        newkeysdata=netcdf(keysfile,'write');
    end

    %fill keys file:
    nc=netcdf(keysfile);
    holdthis=nc{'priority'}(:);
    if(length(holdthis)==1)
        if(isempty(holdthis(1)))
            holdthis=[];
        end
    end
    dimkeys=length(holdthis)+1;
        close(nc)

    ss=num2str(profiledata.nss);
    ssn='          ';
    ssn(1:length(ss))=ss;
    calls='          ';
    kk=strmatch('GCLL',profiledata.surfpcode);
    if(~isempty(kk))
        calls=profiledata.surfparm(kk,:);
    end
    newkeysdata{'obslat'}(dimkeys) = profiledata.lat;
    newkeysdata{'obslng'}(dimkeys) = profiledata.lon;
    newkeysdata{'c360long'}(dimkeys) = profiledata.lon;
    newkeysdata{'autoqc'}(dimkeys) = profiledata.autoqc;

    newkeysdata{'stn_num'}(dimkeys,1:10) = ssn;
    newkeysdata{'callsign'}(dimkeys,1:10) = calls;
    newkeysdata{'obs_y'}(dimkeys,1:4) = num2str(profiledata.year);

    mm=sprintf('%2i',profiledata.month);
    dd=sprintf('%2i',profiledata.day);
    newkeysdata{'obs_m'}(dimkeys,1:2) = mm;
    newkeysdata{'obs_d'}(dimkeys,1:2) = dd;

    tt=sprintf('%6i',profiledata.time);
    newkeysdata{'obs_t'}(dimkeys,1:4)=tt(1:4);

    newkeysdata{'data_t'}(dimkeys,1:2) = profiledata.datat;
    newkeysdata{'d_flag'}(dimkeys) = 'N';
    newkeysdata{'data_source'}(dimkeys,1:10)= profiledata.source;
    newkeysdata{'priority'}(dimkeys) = profiledata.priority;

    close(newkeysdata);

end

return
