function inputMQNC(inputdir,outputdir)

%inputMQNC - reads MQNC data from another database and adds to the current
%database (good for concatenating databases).
% BEST TO ADD THE LOW QUALITY VERSION TO THE HIGH QUALITY VERSION AND
% CHOOSE 'SKIP' FOR DUPLICATES
% CURRENTLY DISABLED IN IMPORTDATA.M UNTIL IT CAN BE TESTED.
%Bec Cowley 21/3/2012 

CONFIG
DECLAREGLOBALS

clc
disp('*** INPUTTING MQNC DATA ***')


s=DATA_SOURCE;
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

%get the new keys for comparison and identification of dupes:
prefix={inputdir(1:end-8)};
mmm={'All'} ;
yy={'All'} ;
qc={'None'};
auto={'1'};
tw={'1'};
sstyle={'None'};
[keysdata2]=getkeys(prefix,mmm,yy,qc,auto,tw,sstyle);
keysdata2.autoqc = ncread([prefix{:} '_keys.nc'],'autoqc');
stnm = keysdata2.stnnum;

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

whattodo='a'; %assume new profile
alreadychecked=0;
ovdups = [];

if(isempty(keysdata2.stnnum))
    disp('**** there are no data files in this directory ****');
    return
end

for i = 1:length(stnm)
    
    %get the file name:
    filen = getfilename(num2str(stnm(i)),0);
    filed = [inputdir(1:end-8) '/' filen];
    filer = getfilename(num2str(stnm(i)),1);
    filrw = [inputdir(1:end-8) '/' filer];
    
    %display the station name:
    filed
        
    %read data into profile data structure:
    profiledata.year = keysdata2.year(i);
    profiledata.month = keysdata2.month(i);
    profiledata.day = keysdata2.day(i);
    profiledata.time = keysdata2.time(i)*100;
    profiledata.lat = keysdata2.obslat(i);
    profiledata.lon = keysdata2.obslon(i);
    profiledata.latitude = keysdata2.obslat(i);
    profiledata.longitude = keysdata2.obslon(i);
    profiledata.nss = stnm(i);
    profiledata.datat = keysdata2.datatype(i,:);
    profiledata.surfpcode = ncread(filed,'SRFC_Code')';
    profiledata.surfparm = ncread(filed,'SRFC_Parm')';
    profiledata.autoqc = keysdata2.autoqc(i);
    profiledata.source = keysdata2.datasource(i,:);
    profiledata.priority = keysdata2.priority(i);
    
    uniqueid=uniqueid+1
    %now check for duplicates
    if(~isempty(keysdata.year))
        kk=[];
        checkforduplicates
    end
    
    %now copy files if 'r' or 'a' is selected
    if d == 1
        if(whattodo=='r')
            %replace the existing file with the new one, use the existing
            %station number (added to profiledata in checkforduplicates)
            ss='          ';
            s=num2str(profiledata.nss);
            ss(1:length(s))=s;
            %get the existing file name:
            fileo = getfilename(num2str(ss),0);
            filoed = [outputdir '/' fileo];
            fileo = getfilename(num2str(ss),1);
            filorw = [outputdir '/' fileo];
            
            %now overwrite the existing file with the new one:
            eval(['!cp ' filed ' ' filoed])
            eval(['!cp ' filrw ' ' filorw])
            
            %change the srfc_parm station id to the existing station number
            ii = strmatch('CSID',profiledata.surfpcode);
            profiledata.surfparm(ii,:) = ss;
            ncwrite(filoed,'SRFC_Parm',profiledata.surfparm')
            %and the raw file:
            sfc = ncread(filorw,'SRFC_Code');
            ii = strmatch('CSID',sfc');
            sfp = ncread(filorw,'SRFC_Parm');
            sfp(:,ii) = ss';
            ncwrite(filorw,'SRFC_Parm',sfp)
            fid = fopen('dups_replaced.txt','a');
            fprintf(fid,'%s\n',[outputdir ' stn = ' num2str(profiledata.nss) ': ' inputdir(1:end-8) ' stn = ' num2str(stnm(i))]);
            fclose(fid)
        elseif whattodo =='a' %'a' chosen
            ii = find(keysdata.stnnum==stnm(i));
            if ~isempty(ii) & (ii(1) == kk(1)) %duplicate station number, same as 'checkforduplicates' output.
                %already selected append, so need a new CSID
                ss='          ';
                s=num2str(uniqueid);
                ss(1:length(s))=s;
                fileo = getfilename(num2str(ss),0);
                filoed = [outputdir '/' fileo];
                fileo = getfilename(num2str(ss),1);
                filorw = [outputdir '/' fileo];
                %write to new CSID number
                if exist(filoed(1:end-7),'dir') == 7
                    %new file, add it in
                    eval(['!cp ' filed ' ' filoed])
                    eval(['!cp ' filrw ' ' filorw])
                else
                    mkdir(filoed(1:end-7))
                    eval(['!cp ' filed ' ' filoed])
                    eval(['!cp ' filrw ' ' filorw])
                end
                %change the srfc_parm station id to the existing station number
                ii = strmatch('CSID',profiledata.surfpcode);
                profiledata.surfparm(ii,:) = ss;
                ncwrite(filoed,'SRFC_Parm',profiledata.surfparm')
                %and the raw file:
                sfc = ncread(filorw,'SRFC_Code');
                ii = strmatch('CSID',sfc');
                sfp = ncread(filorw,'SRFC_Parm');
                sfp(:,ii) = ss';
                ncwrite(filorw,'SRFC_Parm',sfp)
            else %not a duplicate station number, but a duplicate profile. 'a' chosen
                uniqueid=uniqueid-1;
                if exist([outputdir '/' filen(1:end-7)],'dir') == 7
                    %new file, add it in
                    eval(['!cp ' filed ' ' outputdir '/' filen])
                    eval(['!cp ' filrw ' ' outputdir '/' filer])
                else
                    mkdir([outputdir '/' filen(1:end-7)])
                    eval(['!cp ' filed ' ' outputdir '/' filen])
                    eval(['!cp ' filrw ' ' outputdir '/' filer])
                end
                
            end
            %update the keys file
            profiledata.outputfile = outputdir;
            writeMQNC_keys(profiledata)
        else %skip
            uniqueid=uniqueid-1;
            continue
        end
    elseif d == 0 %no duplicate profile
        % need to check for duplicate station numbers here!!
        ii = find(keysdata.stnnum==stnm(i));
        if ~isempty(ii) %& isempty(ovdups)
            disp(['Station number ' num2str(stnm(i)) ' exists already in this database, but is not a duplicate!'])
            disp(['Information will be written to ''dup_stnnum.txt''. Hit return to continue'])
            pause
            fid = fopen('dup_stnnum.txt','a');
            fprintf(fid,'%s\n',[outputdir ' stn = ' num2str(keysdata.stnnum(ii)) ': ' inputdir(1:end-8) ' stn = ' num2str(stnm(i))]);
            fclose(fid)
%             yn = input('Skip or Append with a new CSID, all duplicate numbers? [s/a]','s');
%             if ~isempty(strmatch('a',yn))
%                 ovdups = 1; %new number please
%             else
%                 ovdups = 0; %skip, don't add new ones to database
%             end
        end
        if ~isempty(ii) %& ovdups == 1 %duplicate station number and new CSID chosen
            ss='          ';
            s=num2str(uniqueid);
            ss(1:length(s))=s;
            fileo = getfilename(num2str(ss),0);
            filoed = [outputdir '/' fileo];
            fileo = getfilename(num2str(ss),1);
            filorw = [outputdir '/' fileo];
            %write to new CSID number
            if exist(filoed(1:end-7),'dir') == 7
                %new file, add it in
                eval(['!cp ' filed ' ' filoed])
                eval(['!cp ' filrw ' ' filorw])
            else
                mkdir(filoed(1:end-7))
                eval(['!cp ' filed ' ' filoed])
                eval(['!cp ' filrw ' ' filorw])
            end
            %change the srfc_parm station id to the existing station number
            ii = strmatch('CSID',profiledata.surfpcode);
            profiledata.surfparm(:,ii) = ss;
            ncwrite(filoed,'SRFC_Parm',profiledata.surfparm')
            %and the raw file:
            sfc = ncread(filorw,'SRFC_Code');
            ii = strmatch('CSID',sfc');
            sfp = ncread(filorw,'SRFC_Parm');
            sfp(:,ii) = ss';
            ncwrite(filorw,'SRFC_Parm',sfp)
            
        else %new profile, just copy over and update the keys
            uniqueid=uniqueid-1;
            if exist([outputdir '/' filen(1:end-7)],'dir') == 7
                %new file, add it in
                eval(['!cp ' filed ' ' outputdir '/' filen])
                eval(['!cp ' filrw ' ' outputdir '/' filer])
            else
                mkdir([outputdir '/' filen(1:end-7)])
                eval(['!cp ' filed ' ' outputdir '/' filen])
                eval(['!cp ' filrw ' ' outputdir '/' filer])
            end
%         elseif ~isempty(ii) & ovdups == 0 %skip the duplicate station number
%             continue
        end
        %update the keys file
        profiledata.outputfile = outputdir;
        writeMQNC_keys(profiledata)
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

disp(['*** INPUT MQNC DATA COMPLETE  - ' num2str(length(stnm)) ' - files imported ***'])

return
