
function inputMK21(inputdir,outputfile)

%inputMK21 - reads mk21 edf files and outputs them to profiledata structure
%for processing and QC in MQUEST...

%remember to increment uniqueid!!!

DECLAREGLOBALS
  d=0.
disp('*** INPUTTING TSK ASCII DATA ***')

%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
%these are now defined in CONFIG.m

s=DATA_SOURCE;
p=DATA_PRIORITY;

%make these global so they can be seen by the reading routine:
global calls
global cruiseID

clls=input('enter the callsign of the ship:','s')
crID=input('enter the voyage number:','s')

calls = '          ';
cruiseID = '          ';
calls(1:length(clls)) = clls;
cruiseID(1:length(crID)) = crID;

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
   b=dirc(strtrim(inputdir));
   suff2=b(:,1);
   [m,n]=size(b);
   
    for i=1:m
        isdrop=strfind(suff2(i),'.all');
%         isdrop=strfind(suff2(i),'1m');
        doubledot=strfind(suff2(i),'.');
        if(~isempty(isdrop{1}))
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
drop = [drop; suff2(kk(i),1)];
end

for i = 1:length(drop)
    

    %CS: Increment uniqueid
    uniqueid=uniqueid+1;
    
    %CS: Create structure
    fid = fopen([strtrim(inputdir) drop{i}]);
    profiledata=readTSK(fid,uniqueid);
    fclose(fid);
    profiledata.source='          ';
    profiledata.outputfile=prefix;
    profiledata.source(1:length(s))=s;
    profiledata.priority=p;

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
  s=num2str(profiledata.nss); 
  ss(1:length(s))=s
  kcsid=strmatch(DATA_SOURCE,profiledata.surfparm);
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

disp('*** INPUT TSK DATA COMPLETE ***')

return
