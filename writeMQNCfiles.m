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
        disp(['writeMQNCfiles: Unable to write item: ' num2str(a) ' ' flds{a}])
        continue
    end
end

    
%write keys files - create if it doesn't exist...

if(writekeys)
    
    keysfile=[pd.outputfile{1} '_keys.nc'];
    if exist(keysfile,'file') ~= 2
        %create keys file...
        createkeys
    end

    %fill keys file:
    kf = ncinfo(keysfile);
    np = kf.Dimensions(1).Length;
    
    ss=pd.nss;
    ssn='          ';
    ssn(1:length(ss))=ss;
    calls='          ';
    kk=strmatch('GCLL',pd.surfcode);
    if(~isempty(kk))
        calls=pd.surfparm(kk,:);
    end
    ncwrite(keysfile,'obslat',pd.latitude,np+1);
    ncwrite(keysfile,'obslng',pd.longitude,np+1);
    ncwrite(keysfile,'c360long',pd.longitude,np+1);
    ncwrite(keysfile,'autoqc',0,np+1);

    ncwrite(keysfile,'stn_num',ssn',[1,np+1]);
    ncwrite(keysfile,'callsign',calls',[1,np+1]);
    ncwrite(keysfile,'obs_y',pd.year',[1,np+1]);
    ncwrite(keysfile,'obs_m',pd.month',[1,np+1]);
    ncwrite(keysfile,'obs_d',pd.day',[1,np+1]);
    tt=[pd.time(1:2) pd.time(4:5)];
    ncwrite(keysfile,'obs_t',tt',[1,np+1]);

    ncwrite(keysfile,'data_t',profiledata.Data_Type',[1,np+1]);
    ncwrite(keysfile,'d_flag','N',[1,np+1]);
    ncwrite(keysfile,'data_source',pd.source',[1,np+1]);
    ncwrite(keysfile,'priority',pd.priority,np+1);

end

return
