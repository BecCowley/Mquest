
function inputRTQC(inputfile,outputfile)

%inputRTQC - reads xbt text files and outputs them to profiledata structure
%for processing and QC in MQUEST...

DECLAREGLOBALS
  
clc

d=0.
disp('*** INPUTTING REAL TIME XBT ASCII DATA ***')

%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
s=DATA_SOURCE;
p=DATA_PRIORITY;
num_imported=0;

%make these global so they can be seen by the reading routine:
global calls
global cruiseID

%calls=input('enter the callsign of the ship:','s')
%cruiseID=input('enter the voyage number:','s')

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
% if(ispc)
%     try
%         unique_file=[UNIQUE_ID_PATH_UNIX_FROM_PC 'uniqueid.mat'];
%         load (unique_file);
%     catch
%         unique_file=[UNIQUE_ID_PATH_PC 'uniqueid.mat'];
%         load (unique_file);
%     end
% else
%     unique_file=[UNIQUE_ID_PATH_UNIX 'uniqueid.mat'];
%     load (unique_file);
% end

    whattodo='a';
    alreadychecked=0;
    
%CS: Write drops to file so can cycle through them
%if(ispc)

fid=fopen(inputfile);
   
%CS: matrix to hold drop filenames

while(~feof(fid))
    dropfile=fgets(fid);
    
    profiledata=readRTQC(dropfile);
    profiledata.outputfile=prefix;
    profiledata.source(1:length(s))=s;
    profiledata.priority=p;
    profiledata.surfqparm(1)=num2str(p);
    ss='          ';
    ss(1:length(s))=s; 
    profiledata.surfparm(1,:)=ss;
    profiledata.source=ss;
    
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
  kcsid=strmatch('AOID',profiledata.surfparm);
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

disp('*** INPUT RTQC DATA COMPLETE ***')

return
