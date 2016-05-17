function inputDEVIL(inputdir,outputdir)

%inputDEVIL - reads DEVIL drop files and outputs into an MQNC database for
%processing and QC in MQUEST...
% !!!remember to increment uniqueid!!!
%CS: Claire Spillman 22 May 2006
global launchheight

launchheight = [];

CONFIG

clc
disp('*** INPUTTING DEVIL DATA ***')

%CS: Enter details
%s=input('enter the data source:','s')
%p=input('enter the data priority (1 is best, 9 is worst):')
%these are now defined in CONFIG.m

source=DATA_SOURCE;
p=DATA_PRIORITY;
num_imported=0;

%get the existing keys for comparison and identification of dupes:
prefix={outputdir};
mmm={'All'} ;
yy={'All'} ;
qc={'None'};
auto={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(prefix,mmm,yy,qc,auto,tw,sstyle);

%CS: Load unique ID file
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
   suff2=b(:,1);
   [m,n]=size(b);
   
    for i=1:m
        cksuff=suff2{i};
        isdrop{1}=strfind(cksuff(max(1,end-2):end),'.nc');
        doubledot=strfind(suff2(i),'.');
        if(~isempty(isdrop{1}) & length(doubledot{1})==1)
            isdrop2(i)=1;
        else
            isdrop2(i)=0;
        end
    end
    kk=find(isdrop2==1);

%end

%CS: matrix to hold drop filenames
drop = [];
if(isempty(kk) | length(kk)<1)
    disp('**** there are no data files in this directory ****');
    return
end

for i=1:length(kk)
drop = [drop; suff2(kk(i),1)];
end

clear call_voy line_voy crid_voy
for i = 1:length(drop)
    
    %CS: Increment uniqueid
    uniqueid=uniqueid+1;
    
    %get information from previous profile:
    if exist('profiledata','var')
        %keep the callsign, line and voyage information:
        icalls = strmatch('GCLL',profiledata.surfpcode);
        calls = profiledata.surfparm(icalls,:);
        iline = strmatch('TWI#',profiledata.surfpcode);
        line = profiledata.surfparm(iline,:);
        crid = profiledata.cruiseID;
    else
        calls = 'empty';
        line = 'empty';
        crid = 'empty';
    end
    
    %CS: Create structure
    profiledata=readDEVIL([inputdir drop{i}],uniqueid);
    
    %check the callsign, line and voyage information is OK, RC, March 2014
    icalls = strmatch('GCLL',profiledata.surfpcode);
    if isempty(strmatch(calls,profiledata.surfparm(icalls,:))) & ~exist('call_voy','var')
        disp(['Callsign = ' profiledata.surfparm(icalls,:)])
        calls = input('Enter correct callsign for this voyage, or return to accept: ','s');
        if isempty(calls)
            call_voy = profiledata.surfparm(icalls,:);
        else
            call_voy = calls;
        end
    end
    
    %assign the voyage callsign if required
    if exist('call_voy')
        profiledata.surfparm(icalls,:) = '          ';
        profiledata.surfparm(icalls,1:length(call_voy)) = call_voy;
    end
    
    %LINE
    iline = strmatch('TWI#',profiledata.surfpcode);
    if isempty(strmatch(line,profiledata.surfparm(iline,:))) & ~exist('line_voy','var')
        disp(['Line = ' profiledata.surfparm(iline,:)])
        line = input('Enter correct line for this voyage, or return to accept: ','s');
        if isempty(line)
            line_voy = profiledata.surfparm(iline,:);
        else
            line_voy = line;
        end
    end
    
    %assign the voyage line if required
    if exist('line_voy')
        profiledata.surfparm(iline,:) = '          ';
        profiledata.surfparm(iline,1:length(line_voy)) = line_voy;
    end
    
    %cruiseID
    if isempty(strmatch(crid,profiledata.cruiseID)) & ~exist('crid_voy','var')
        disp(['CruiseID = ' profiledata.cruiseID])
        crid = input('Enter correct cruiseID for this voyage, or return to accept: ','s');
        if isempty(crid)
            crid_voy = profiledata.cruiseID;
        else
            crid_voy = crid;
        end
    end
    
    %assign the voyage line if required
    if exist('crid_voy')
        profiledata.cruiseID = '          ';
        profiledata.cruiseID(1:length(crid_voy)) = crid_voy;
    end
    
    
    profiledata.source='          ';
    profiledata.outputfile=prefix;
    profiledata.source(1:length(source))=source;
    profiledata.priority=p;
%     profiledata.surfqparm(1)=num2str(p);
%     ss='          ';
%     ss(1:length(source))=source; 
%     profiledata.surfparm(1,:)=ss;
    

    % if the lat and long are out of range, give error message and SKIP...
    
  if(profiledata.latitude>90 | profiledata.latitude <-90 | ...
            profiledata.longitude<-360 | profiledata.longitude>360)
%        errordlg('error - latitude or longitude out of range')
        profiledata.datafile=drop{i};
        [profiledatan]=bad_lat_long('UserData',{[profiledata]});
      
        if(~isempty(profiledatan))
            profiledata=profiledatan;
        end
  end
  
  if(profiledata.latitude>90 | profiledata.latitude <-90 | ...
            profiledata.longitude<-360 | profiledata.longitude>360)
        disp('error - latitude or longitude out of range')
        pause
  else
    %CS: Check for duplicates (script not function)
    if(~isempty(keysdata.year))
        kk=[];
        checkforduplicates
    end
    %CS: To use as a function, use line below
    %[profiledata,uniqueid]=checkforduplicates_function(keysdata,...
    %profiledata,uniqueid,whattodo,alreadychecked)

    writekeys=1;

    %CS: Create file
        if(whattodo~='s' | isempty(kk))
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
  end
end 

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

disp(['*** INPUT DEVIL DATA COMPLETE  - ' num2str(length(drop)) ' - files imported ***'])

return
