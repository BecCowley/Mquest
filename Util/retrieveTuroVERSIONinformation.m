%Retrieve hardware, software and GUI version information from original
%devil and quoll netcdf files and insert the information into the surface
%codes
%match by date/time/lat/lon/probe serial number/crc. Or just CRC?
clear

%Devil/Quoll netcdf file location:
inputdir = '/home/UOT-data/quest/InvestigatorXBT/QuollData/';
%Mquest database name:
databasedir = '/home/UOT-data/quest/InvestigatorXBT/in2016_v03';

%first, read all the original files and get the information we need
dirlist = dirc(inputdir,'de'); %will work with 2015b version.
vers = [];meta=[];
count = 1;
for a = 1:length(dirlist)
    %get all the files
    flist = dir([inputdir dirlist{a,1} '/*.nc']);
    for b = 1:length(flist)
        fn = [inputdir dirlist{a,1} '/' flist(b).name];
        %avoid the ._* files
        if ~isempty(findstr('._',fn))
            continue
        end
        %now let's read in the identifying metadata. Put in a matrix for easy
        %searching
        meta(count,1) = ncread(fn,'latitude');
        meta(count,2) = ncread(fn,'longitude');
        ti = num2str(ncread(fn,'woce_time'), '%06d');
        meta(count,3) = datenum([num2str(ncread(fn,'woce_date')) ti(1:4)],'yyyymmddHHMM');
        try
            vers(count).crc = ncreadatt(fn,'/','CRC');
        catch
            vers(count).crc = NaN;
        end
        vers(count).cruise = ncreadatt(fn,'/','Voyage');
        vers(count).serial = ncreadatt(fn,'/','SerialNo');
        vers(count).uivers = ncreadatt(fn,'/','UIVersion');
        svrs = ncreadatt(fn,'/','ReleaseVersion');
        [tok,matches] = regexp(svrs,'Version: (.*)','tokens','match');
        if ~isempty(tok)
            vers(count).softvers = char(tok{1});
        else
            vers(count).softvers = '';
        end
        vers(count).hardvers = ncreadatt(fn,'/','HardwareVersion');
        vers(count).firmvers = ncreadatt(fn,'/','FirmwareVersion');
        vers(count).hardserial = ncreadatt(fn,'/','HardwareSerialNo');
        count = count+1;
    end
end
%adjust longitudes for +/-180 values:
ii = find(meta(:,2) < 0);
meta(ii,2) = meta(ii,2)+360;
% read each of the database files and find the match in the original files
stn = ncread([databasedir '_keys.nc'],'stn_num')';
for a = 1:length(stn)
    st = stn(a,1:2);
    for b = 3:2:length(stn(a,:))-2
        st = [st '/' stn(a,b:b+1)];
    end
    fn = [databasedir '/' st 'ed.nc'];
    %don't look at it if it isn't an XBT
    type = ncread(fn,'Data_Type');
    if ~strcmp('XB',type')
        continue
    end
    %match them and write out the new version information to the database file
    %if it doesn't already exist.
    lat = ncread(fn,'latitude');
    lon = ncread(fn,'longitude');
    ti = num2str(ncread(fn,'woce_time'), '%06d');
    time = datenum([num2str(ncread(fn,'woce_date')) ti],'yyyymmddHHMMSS');
    voy = ncread(fn,'Cruise_ID')';
    srfcode = ncread(fn,'SRFC_Code')';
    srfparm = ncread(fn,'SRFC_Parm')';
    nsurfc = ncread(fn,'Nsurfc');
    ii = strmatch('SER#',srfcode);
    if ~isempty(ii)
        serial = strtrim(srfparm(ii,:));
    else
        serial = '';
    end
    ii = strmatch('CRC$',srfcode);
    if ~isempty(ii)
        crc = strtrim(srfparm(ii,:));
    else
        crc = NaN;
    end
    
    %now lets find matches
    ii = find(meta(:,3) == time & abs(meta(:,1)-lat) < 0.1 & abs(meta(:,2)-lon) < 0.1);
    if isempty(ii)
        disp(['No match for ' fn])
        keyboard
        continue
    end
    
    %if more than one match
    if length(ii) > 1
        disp(['Multiple matches for ' fn])
    end
    %check the serial number and crc
    for b = 1:length(ii)
        ij = strcmp(serial,vers(ii(b)).serial);
        ik = strcmp(crc,vers(ii(b)).crc);
        if ~isempty(ij) & ~isempty(ik)
            %matched, write it out
            %software version
            if ~isempty(vers(ii(b)).softvers) & isempty(strmatch('VERS',srfcode))
                srfcode(nsurfc+1,:) = 'VERS';
                parm = '          ';
                parm(1:length(vers(ii(b)).softvers)) = vers(ii(b)).softvers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %GUI version
            if ~isempty(vers(ii(b)).uivers) & isempty(strmatch('UVRS',srfcode))
                srfcode(nsurfc+1,:) = 'UVRS';
                parm = '          ';
                parm(1:length(vers(ii(b)).uivers)) = vers(ii(b)).uivers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %hardware version
            if ~isempty(vers(ii(b)).hardvers) & isempty(strmatch('HVRS',srfcode))
                srfcode(nsurfc+1,:) = 'HVRS';
                parm = '          ';
                parm(1:length(vers(ii(b)).hardvers)) = vers(ii(b)).hardvers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %firmware version
            if ~isempty(vers(ii(b)).firmvers) & isempty(strmatch('FVRS',srfcode))
                srfcode(nsurfc+1,:) = 'FVRS';
                parm = '          ';
                parm(1:length(vers(ii(b)).firmvers)) = vers(ii(b)).firmvers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %hardware serial number
            if ~isempty(vers(ii(b)).hardserial) & isempty(strmatch('SER1',srfcode))
                srfcode(nsurfc+1,:) = 'SER1';
                parm = '          ';
                parm(1:length(vers(ii(b)).hardserial)) = vers(ii(b)).hardserial;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %update the surface codes record, ed file
            ncwrite(fn,'SRFC_Code',srfcode')
            ncwrite(fn,'SRFC_Parm',srfparm')
            ncwrite(fn,'Nsurfc',nsurfc)
            
            %raw file
            fn = [databasedir '/' st 'raw.nc'];
            srfcode = ncread(fn,'SRFC_Code')';
            srfparm = ncread(fn,'SRFC_Parm')';
            nsurfc = ncread(fn,'Nsurfc');
            
            %software version
            if ~isempty(vers(ii(b)).softvers) & isempty(strmatch('VERS',srfcode))
                srfcode(nsurfc+1,:) = 'VERS';
                parm = '          ';
                parm(1:length(vers(ii(b)).softvers)) = vers(ii(b)).softvers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %GUI version
            if ~isempty(vers(ii(b)).uivers) & isempty(strmatch('UVRS',srfcode))
                srfcode(nsurfc+1,:) = 'UVRS';
                parm = '          ';
                parm(1:length(vers(ii(b)).uivers)) = vers(ii(b)).uivers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %hardware version
            if ~isempty(vers(ii(b)).hardvers) & isempty(strmatch('HVRS',srfcode))
                srfcode(nsurfc+1,:) = 'HVRS';
                parm = '          ';
                parm(1:length(vers(ii(b)).hardvers)) = vers(ii(b)).hardvers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %firmware version
            if ~isempty(vers(ii(b)).firmvers) & isempty(strmatch('FVRS',srfcode))
                srfcode(nsurfc+1,:) = 'FVRS';
                parm = '          ';
                parm(1:length(vers(ii(b)).firmvers)) = vers(ii(b)).firmvers;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %hardware serial number
            if ~isempty(vers(ii(b)).hardserial) & isempty(strmatch('SER1',srfcode))
                srfcode(nsurfc+1,:) = 'SER1';
                parm = '          ';
                parm(1:length(vers(ii(b)).hardserial)) = vers(ii(b)).hardserial;
                srfparm(nsurfc+1,:) = parm;
                nsurfc = nsurfc + 1;
            end
            %update the surface codes record, raw file
            ncwrite(fn,'SRFC_Code',srfcode')
            ncwrite(fn,'SRFC_Parm',srfparm')
            ncwrite(fn,'Nsurfc',nsurfc)
            continue
        else
            if b == length(ii) %none of these matched
                disp(['No matches for ' fn])
                keyboard
            end
        end
    end

end

