function inputSCRIPPSdata(inputdir,outputfile)

%inputSCRIPPSdata - reads scripps 2m files and outputs them to profiledata structure
%for processing and QC in MQUEST...

%remember to increment uniqueid!!!

CONFIG

DECLAREGLOBALS
global calls
global cruiseID

clc
d=0.;
disp('*** INPUTTING SCRIPPS ASCII DATA ***')

%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
%these are now defined in CONFIG.m

s='SCRIPPS';
DATA_PRIORITY=2;
p=DATA_PRIORITY;

%make these global so they can be seen by the reading routine:

% calls=input('enter the callsign of the ship:','s')

% cruiseID=  first 7 or 8 digits of file name...

%get the existing keys for comparison and identification of dupes:
prefix={outputfile};
mmm={'All'} ;
yy={'All'} ;
qc={'None'};
auto={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(prefix,mmm,yy,qc,auto,tw,sstyle);

%load unique id from file:
if(ispc)
    try
        unique_file=[UNIQUE_ID_PATH_UNIX_FROM_PC 'uniqueid.mat'];
        load (unique_file);
    catch
        unique_file=[UNIQUE_ID_PATH_PC 'uniqueid.mat'];
        load (unique_file);
    end
else
    unique_file=[UNIQUE_ID_PATH_UNIX 'uniqueid.mat'];
    load (unique_file);
end

    whattodo='a';
    alreadychecked=0;

%CS: Write drops to file so can cycle through them
%if(ispc)
b = dirc([inputdir '*q.*']); %use the full resolution files if available
if isempty(b)
   b=dirc([inputdir '*e.*']); %otherwise, use the 2m res files.
end
   suff2=b(:,1);
   [m,n]=size(b);
%end

for i = 1:m
    if(~b{i,6})  %not interested in directories!
        %ignore 'old' suffix files:
        if ~isempty(findstr('old',b{i,1}))
            continue
        end
        %CS: Increment uniqueid
        uniqueid=uniqueid+1;

        %CS: Create structure
        cruiseID = b{i,1}(1:length(b{i,1})-5);
        profiledata=readSCRIPPSdata([inputdir b{i,1}],uniqueid);
        profiledata.source='          ';
        profiledata.outputfile=prefix;
        profiledata.source(1:length(s))=s;
        profiledata.priority=p;
        profiledata.surfqparm(1)=num2str(p);
        ss='          ';
        ss(1:length(s))=s;
        profiledata.surfparm(1,:)=ss;

        %CS: Check for duplicates (script not function)
        if(~isempty(keysdata.year))
            d=0.;
            checkforduplicates
        end

        %CS: To use as a function, use line below
        %[profiledata,uniqueid]=checkforduplicates_function(keysdata,...
        %profiledata,uniqueid,whattodo,alreadychecked)

        writekeys=1;

        %deal with duplicates:
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

%CS: Save files
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

disp('*** INPUT SCRIPPS DATA COMPLETE ***')

return
