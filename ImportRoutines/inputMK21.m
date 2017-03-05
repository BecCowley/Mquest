
function inputMK21(inputdir,outputfile,ran)

%inputMK21 - reads mk21 edf files and outputs them to profiledata structure
%for processing and QC in MQUEST...

%remember to increment uniqueid!!!

DECLAREGLOBALS
  d=0.
disp('*** INPUTTING SIPPICAN MK21 ASCII DATA ***')

%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
%these are now defined in CONFIG.m

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
   b=dirc(inputdir);
   pref = b(:,1);
   suff2=b(:,3);
   [m,n]=size(b);
   
    for i=1:m
        isdrop=strfind(upper(suff2{i}),'EDF');
        doubledot=strfind(suff2{i},'.');
        if(~isempty(isdrop))
            isdrop2(i)=1;
        else
            isdrop2(i)=0;
        end
    end
    kk=find(isdrop2==1);

%end

%CS: matrix to hold drop filenames
drop = [];

for i=1:length(kk)
drop = [drop; pref(kk(i),1)];
end

for i = 1:length(drop)
    %check if the file is binary, if so, skip
    fid=fopen([inputdir drop{i}]);
    d=fgets(fid);
    if int8(d(1)) < 32
        continue
    end
    
    %CS: Increment uniqueid
    uniqueid=uniqueid+1;
    
    %CS: Create structure
    if ran == 0
        profiledata=readMK21([inputdir drop{i}],uniqueid);
    else
        profiledata=readMK21_RAN([inputdir drop{i}],uniqueid);
    end
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
            d=0.
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
                ssn=num2str(profiledata.nss);
                ss(1:length(ssn))=ssn
                kcsid=strmatch('CSID',profiledata.surfpcode);
                profiledata.surfparm(kcsid,:)=ss;
                writekeys=0;
            else
                writekeys=1;
            end
            writeMQNCfiles(profiledata,pd,writekeys);
        end
    else
        writeMQNCfiles(profiledata,pd,writekeys);
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

disp('*** INPUT MK21 DATA COMPLETE ***')

return
