
function inputMA(inputfile,outputfile)

%inputMA - reads medsascii file and outputs into an MQNC database for
%processing and QC in MQUEST...

%remember to increment uniqueid!!!
CONFIG

clc
disp('*** INPUTTING MEDS ASCII DATA ***')
source = input('Enter a <10-character name for the source of the data:','s');
priority = input('Enter a value for the priority of the data (1-5):','s');
priority = str2num(priority);

fid=fopen(inputfile,'r');

%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
%these are now defined in CONFIG.m

if isempty(source)
source=DATA_SOURCE;
priority=DATA_PRIORITY;
end

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
    
[profiledata,pd]=readMA(fid,uniqueid);
pd.source='          ';
pd.source(1:length(source))=source;
pd.outputfile=prefix;
pd.source(1:length(source))=source;
pd.priority=priority;
if(pd.nsurfc>0)
    kk=strmatch('IOTA',pd.surfcode(:,:));
    if(~isempty(kk))   %csid already exists in this MA file...
        pd.source=pd.surfparm(kk(1),:);
        pd.priority=str2num(pd.surfqparm(kk(1)));
    end
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
                s=num2str(pd.nss);
                ss(1:length(s))=s
                kcsid=strmatch('CSID',pd.surfcode);
                pd.surfparm(kcsid,:)=ss;
                writekeys=0;
            else
                writekeys=1;
            end
            writeMQNCfiles(profiledata,pd,writekeys);
        end
    else
        writeMQNCfiles(profiledata,pd,writekeys);
    end
catch
    disp('Failed on import')
    keyboard
end
end   %while ~feof

%RC - if the MA doesn't have a unique ID(eg the
%RAN2007 files), then we need to save it.

% %CS: Save files
if pd.unqiueid_from_file == 0
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
