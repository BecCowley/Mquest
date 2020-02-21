
function inputWODcsv(inputdir,outputfile)

%inputWODcsv - reads WOD csv files and outputs them to profiledata structure
%for processing and QC in MQUEST.
% input arguments: inputdir - directory where the csv file is located
%                   outputfile - mQuest outputfilename
% Rebecca Cowley, Feb, 2020

DECLAREGLOBALS
d=0.;
disp('*** INPUTTING WOD CSV DATA ***')

s=DATA_SOURCE;
p=DATA_PRIORITY;

%make these global so they can be seen by the reading routine:
global calls
global cruiseID
global shipname

calls=input('enter the callsign of the ship:','s')
cid=input('enter the voyage number:','s')
cruiseID = '          ';
cruiseID(1:length(cid)) = cid;
shipname=input('enter the full ship name:','s')

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
    unique_file=[UNIQUE_ID_PATH_PC 'uniqueid.mat'];
    load (unique_file);
    mquest_path = MQUEST_DIRECTORY_PC;
else
    unique_file=[UNIQUE_ID_PATH_UNIX 'uniqueid.mat'];
    load (unique_file);
    mquest_path = MQUEST_DIRECTORY_UNIX;
end

whattodo='a';
alreadychecked=0;

%Write drops to file so can cycle through them
   b=dirc(inputdir,'f');
   pref = b(:,1);
   suff2=b(:,3);
   [m,n]=size(b);
   if isempty(m)
       disp(['No datafiles for import in ' inputdir])
       return
   end
   kk = find(cellfun(@isempty,strfind(upper(suff2),'CSV')) == 0);


drop = pref(kk);

for i = 1:length(drop)
    %check if the file is binary, if so, skip
    fid=fopen([inputdir drop{i}]);
    d=fgets(fid);
    fclose(fid);
    if int8(d(1)) < 32
        continue
    end
    
    %CS: Increment uniqueid
    uniqueid=uniqueid+1;
    
    %check if the unique ID is already in use in this database. Possible if
    %someone's uniqueID path is shared and is incorrect in CONFIG file.
    if isfield(keysdata,'stnnum') && any(keysdata.stnnum == uniqueid)
        disp('This uniqueid already exists in the database. Please check your CONFIG.m file for correct UNIQUE_ID_PATH_UNIX path.');
        disp('Import has stopped.');
        return
    end
    
    %Read the datafile
    [profiledata,pd]=readWODcsv([inputdir drop{i}],uniqueid);
    
    if isempty(pd)
        continue
    end
    pd.source='          ';
    pd.outputfile=prefix;
    pd.source(1:length(s))=s;
    pd.priority=p;

    %CS: Check for duplicates (script not function)
    d=0;
    if(~isempty(keysdata.year))
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
                ssn=num2str(pd.nss);
                ss(1:length(ssn))=ssn
                kcsid=strmatch('CSID',pd.surfcode);
                pd.surfparm(kcsid,:)=ss;
                profiledata.SRFC_Parm = pd.surfparm';
                writekeys=0;
            else
                writekeys=1;
            end
            writeMQNCfiles(profiledata,pd,writekeys);
        end
    else
        writeMQNCfiles(profiledata,pd,writekeys);
    end
      

end   

%Save files
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

disp('*** INPUT MK12 DATA COMPLETE ***')

return
