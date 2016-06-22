
function inputMA(inputfile,outputfile)

%inputMA - reads medsascii file and outputs into an MQNC database for
%processing and QC in MQUEST...

%remember to increment uniqueid!!!
CONFIG

clc
disp('*** INPUTTING MEDS ASCII DATA ***')

fid=fopen(inputfile,'r');

%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
%these are now defined in CONFIG.m

s=DATA_SOURCE;
p=DATA_PRIORITY;

%get the existing keys for comparison and identification of dupes:
prefix={outputfile};
mmm={'All'} ;
yy={'All'} ;
qc={'None'};
auto={'1'};
[keysdata]=getkeys(prefix,mmm,yy,qc,auto,'all','None');

%load unique id from file:
if(ispc)
    try
        unique_file=[UNIQUE_ID_PATH_UNIX_FROM_PC 'uniqueid.mat'];
        load (unique_file);
    catch
        unique_file=[UNIQUE_ID_PATH_PC 'uniqueid.mat'];
        load( unique_file);
    end
else
    unique_file=[UNIQUE_ID_PATH_UNIX 'uniqueid.mat'];
    load (unique_file);
end

    whattodo='a';
    alreadychecked=0;

while (~feof(fid))
 
    uniqueid=uniqueid+1
    
profiledata=readMA(fid,uniqueid);
profiledata.source='          ';
profiledata.outputfile=prefix;
if(profiledata.nsurfc>0)
    kk=strmatch('IOTA',profiledata.surfpcode(:,:));
    if(~isempty(kk))   %csid already exists in this MA file...
        profiledata.source=profiledata.surfparm(kk(1),:);
        profiledata.priority=profiledata.surfqparm(kk(1));
    else
        profiledata.source(1:length(s))=s;
        profiledata.priority=p;
    end
else
    profiledata.source(1:length(s))=s;
    profiledata.priority=p;
end

    %CS: Check for duplicates (script not function)
    if(~isempty(keysdata.year))
        checkforduplicates
    else
        d = 0;
    end


writekeys=1;

%deal with duplicates:
try
    if(d)
        if(whattodo~='s')
            if(whattodo=='r')
                ss='          ';
                s=num2str(profiledata.nss);
                ss(1:length(s))=s
                kcsid=strmatch('CSID',profiledata.surfpcode);
                profiledata.surfparm(kcsid,:)=ss;
                writekeys=0;
            else
                writekeys=1;
            end
            writeMQNCfiles(profiledata,writekeys);
        end
    else
        writeMQNCfiles(profiledata,writekeys);
    end
end
end   %while ~feof

%RC - DON'T NEED unique ID as MA has unique ID. Don't save it, it's just
%incrementing the uniqueID unnecessarily.
%This is correct if the MA has a unique ID, but if it doesn't (eg the
%RAN2007 files), then we need to save it.

% %CS: Save files
if profiledata.unqiueid_from_file == 0
    if(ispc)
        try
            unique_file=[UNIQUE_ID_PATH_UNIX_FROM_PC 'uniqueid.mat'];
            save (unique_file,'uniqueid');
        catch
            unique_file=[UNIQUE_ID_PATH_PC 'uniqueid.mat'];
            save (unique_file,'uniqueid');
        end
    else
        unique_file=[UNIQUE_ID_PATH_UNIX 'uniqueid.mat'];
        save (unique_file,'uniqueid');
    end
end

disp('*** INPUT MEDS ASCII DATA COMPLETE ***')

return
