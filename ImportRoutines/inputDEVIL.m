function inputDEVIL(inputdir,outputdir)

%inputDEVIL - reads DEVIL drop files and outputs into an MQNC database for
%processing and QC in MQUEST...
% !!!remember to increment uniqueid!!!
%CS: Claire Spillman 22 May 2006
global launchheight

launchheight = [];

CONFIG


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
b=dir(inputdir);

for i=1:size(b,1)
    cksuff=b(i).name;
    isdrop=strfind(cksuff(max(1,end-2):end),'.nc');
    doubledot=strfind(b(i).name,'.');
    if(~isempty(isdrop) & length(doubledot)==1)
        isdrop2(i)=1;
    else
        isdrop2(i)=0;
    end
end
kk=find(isdrop2==1);

%end

%CS: matrix to hold drop filenames

if(isempty(kk) | length(kk)<1)
    disp('**** there are no data files in this directory ****');
    return
end

for i=1:length(kk)
    drop{i} = b(kk(i)).name;
end

clear call_voy line_voy crid_voy
for i = 1:length(drop)
    
    %CS: Increment uniqueid
    uniqueid=uniqueid+1;
    
    %check if the unique ID is already in use in this database. Possible if
    %someone's uniqueID path is shared and is incorrect in CONFIG file.
    if isfield(keysdata,'stnnum') && any(keysdata.stnnum == uniqueid)
        disp('This uniqueid already exists in the database. Please check your CONFIG.m file for correct UNIQUE_ID_PATH_UNIX path.');
        disp('Import has stopped.');
        return
    end
    
    %get information from previous profile:
    if exist('profiledata','var')
        %keep the callsign, line and voyage information:
        icalls = strmatch('GCLL',profiledata.SRFC_Code);
        calls = profiledata.SRFC_Parm(icalls,:);
        iline = strmatch('TWI#',profiledata.SRFC_Code);
        line = profiledata.SRFC_Parm(iline,:);
        crid = profiledata.Cruise_ID;
    else
        calls = 'empty';
        line = 'empty';
        crid = 'empty';
    end
    
    %CS: Create structure
    try
        [profiledata,pd]=readDEVIL([inputdir drop{i}],uniqueid);
    catch Me
        %exit nicely
        disp(['Error on import of Devil file ' inputdir ])
        for jk = 1:length(Me.stack)
            disp(Me.stack(jk).file)
            disp(['Line: ' num2str(Me.stack(jk).line)])
        end
        uniqueid=uniqueid-1;
        save (unique_file,'uniqueid');
        return
    end
    
    %check the callsign, line and voyage information is OK, RC, March 2014
    icalls = strmatch('GCLL',pd.surfcode);
    if isempty(strmatch(calls,pd.surfparm(icalls,:))) & ~exist('call_voy','var')
        disp(['Callsign = ' pd.surfparm(icalls,:)])
        calls = input('Enter correct callsign for this voyage, or return to accept: ','s');
        if isempty(calls)
            call_voy = pd.surfparm(icalls,:);
        else
            call_voy = calls;
        end
    end
    
    %assign the voyage callsign if required
    if exist('call_voy')
        pd.surfparm(icalls,:) = '          ';
        pd.surfparm(icalls,1:length(call_voy)) = call_voy;
    end
    
    %LINE
    iline = strmatch('TWI#',pd.surfcode);
    if ~isempty(iline)
        if isempty(strmatch(line,pd.surfparm(iline,:))) & ~exist('line_voy','var')
            disp(['Line = ' pd.surfparm(iline,:)])
            line = input('Enter correct line for this voyage, or return to accept: ','s');
            if isempty(line)
                line_voy = pd.surfparm(iline,:);
            else
                line_voy = line;
            end
        end
        
        %assign the voyage line if required
        if exist('line_voy')
            pd.surfparm(iline,:) = '          ';
            pd.surfparm(iline,1:length(line_voy)) = line_voy;
        end
    end
    %cruiseID
    if isempty(strmatch(crid,profiledata.Cruise_ID)) & ~exist('crid_voy','var')
        disp(['CruiseID = ' profiledata.Cruise_ID'])
        crid = input('Enter correct cruiseID for this voyage, or return to accept: ','s');
        if isempty(crid)
            crid_voy = profiledata.Cruise_ID';
        else
            crid_voy = crid;
        end
    end
    
    %assign the voyage line if required
    if exist('crid_voy')
        profiledata.Cruise_ID = ('          ')';
        profiledata.Cruise_ID(1:length(crid_voy)) = crid_voy';
    end
    
    %
    pd.source='          ';
    pd.outputfile=prefix;
    pd.source(1:length(source))=source;
    pd.priority=p;
    pd.surfqparm(1)=num2str(p);
    
    % if the lat and long are out of range, give error message and SKIP...
    
    if(pd.latitude>90 | pd.latitude <-90 | ...
            pd.longitude<-360 | pd.longitude>360)
        %        errordlg('error - latitude or longitude out of range')
        pd.datafile=drop{i};
        [profiledatan]=bad_lat_long('UserData',{[pd]});
        
        if(~isempty(profiledatan))
            pd=profiledatan;
            profiledata.longitude = pd.longitude;
            profiledata.latitude = pd.latitude;
        end
    end
    
    if(pd.latitude>90 | pd.latitude <-90 | ...
            pd.longitude<-360 | pd.longitude>360)
        disp('error - latitude or longitude out of range')
        pause
    else
        %CS: Check for duplicates (script not function)
        checkforduplicates
        %CS: To use as a function, use line below
        %[pd,uniqueid]=checkforduplicates_function(keysdata,...
        %pd,uniqueid,whattodo,alreadychecked)
        
        writekeys=1;
        
        %CS: Create file
        if(d)
            if(whattodo~='s')
                if(whattodo=='r')
                    ss='          ';
                    s=num2str(pd.nss);
                    ss(1:length(s))=s;
                    kcsid=strmatch([DATA_QC_SOURCE 'ID'],pd.surfcode);
                    pd.surfparm(kcsid,:)=ss;
                    profiledata.SRFC_Parm = pd.surfparm';
                    writekeys=0;
                else
                    writekeys=1;
                end
                try
                    writeMQNCfiles(profiledata,pd,writekeys);
                catch Me
                    %exit nicely
                    disp(['Error on writing of Devil file ' inputdir ])
                    disp(['May need to remove this file from the keys file and database: ' num2str(uniqueid)])
                    for jk = 1:length(Me.stack)
                        disp(Me.stack(jk).file)
                        disp(['Line: ' num2str(Me.stack(jk).line)])
                    end
                    save (unique_file,'uniqueid');
                    return
                end
            end
        else
            try
                writeMQNCfiles(profiledata,pd,writekeys);
            catch Me
                %exit nicely
                disp(['Error on writing of Devil file ' inputdir ])
                disp(['May need to remove this file from the keys file and database: ' num2str(uniqueid)])
                for jk = 1:length(Me.stack)
                    disp(Me.stack(jk).file)
                    disp(['Line: ' num2str(Me.stack(jk).line)])
                end
                save (unique_file,'uniqueid');
                return
            end
        end
        
    end
    %save uniqueid after every profile import in case of crash.
    save (unique_file,'uniqueid');
end

disp(['*** INPUT DEVIL DATA COMPLETE  - ' num2str(length(drop)) ' - files imported ***'])

return
