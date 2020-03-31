function inputWODcsv(inputdir,outputfile)

%inputWODcsv - reads WOD csv files and outputs them to profiledata structure
%for processing and QC in MQUEST.
% input arguments: inputdir - directory where the csv file is located
%                   outputfile - mQuest outputfilename
% Rebecca Cowley, Feb, 2020

DECLAREGLOBALS

disp('*** INPUTTING WOD CSV DATA ***')

s=DATA_SOURCE;
p=DATA_PRIORITY;

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
    try
        [profiledata,pd]=readWODcsv([inputdir drop{i}],uniqueid);
    catch Me
        %exit nicely
        disp(['Error on import of CSV file ' inputdir ])
        disp(Me.message)
        for jk = 1:length(Me.stack)
            disp(Me.stack(jk).file)
            disp(['Line: ' num2str(Me.stack(jk).line)])
        end
        uniqueid=uniqueid-1;
        save (unique_file,'uniqueid');
        return
    end
    
    if isempty(pd)
        continue
    end
    pd.source='          ';
    pd.outputfile=prefix;
    pd.source(1:length(s))=s;
    pd.priority=p;
    
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
                ss(1:length(ssn))=ssn;
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
                disp(['Error on writing of csv file ' inputdir ])
                disp(['May need to remove this file from the keys file and database: ' num2str(uniqueid)])
                for jk = 1:length(Me.stack)
                    logerr(5,Me.stack(jk).file)
                    logerr(5,['Line: ' num2str(Me.stack(jk).line)])
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
            disp(['Error on writing of csv file ' inputdir ])
            disp(['May need to remove this file from the keys file and database: ' num2str(uniqueid)])
            for jk = 1:length(Me.stack)
                logerr(5,Me.stack(jk).file)
                logerr(5,['Line: ' num2str(Me.stack(jk).line)])
            end
            save (unique_file,'uniqueid');
            return
        end
    end
    
  %save uniqueid after every profile import in case of crash.
  save (unique_file,'uniqueid');
end

disp('*** INPUT WOD csv DATA COMPLETE ***')

return
