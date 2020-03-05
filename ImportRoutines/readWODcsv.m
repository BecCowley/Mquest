function [profiledata,pd] = readWODcsv(inputfile,uniqueid,oflags)
% Function to read csv files from the WOD select and search facility and output to MQNC format
% Inputs:   inputfile - (string) name of file for reading, with extension
%           uniquid - (string) uniqueid of the profile
%           oflags - 1 to use originators flags, 0 to ignore flags (default
%           = 0)
% Rebecca Cowley 20 August 2009, updated Feb 2020

global DATA_QC_SOURCE

if nargin < 2
    error('Not enough input arguments, try again with inputfile and outputfile')
elseif nargin == 2
    oflags = 0;
end
% initialise strings
str1 = ' ';
str2 = '  ';
str4 = '    ';
str6 = '      ';
str8 = '        ';
str10 = '          ';
str12 = '            ';

%set up probe type equivalents:
fid = fopen('v_5_instrument.csv');
wpt=textscan(fid,'%u%u%*s%*s',...
    'delimiter',',');
fclose(fid);

% load unique id from file, use WOD number
fid=fopen(inputfile,'r');
%get data 
c = textscan(fid,'%s','delimiter','|');
fclose(fid);
c = c{1};

%get important metadata prepared:
iprofiles = find(cellfun(@isempty,strfind(c,'CAST'))==0);

%cycle through the file. Allow for multiple profiles in a file:
for a = 1:length(iprofiles)
    if a == length(iprofiles)
        prof = c(iprofiles(a):end);
    else
        prof = c(iprofiles(a):iprofiles(a+1)-1);
    end
    nparms = 0;
    nsurfc = 0;
    bott = 0;
    ndf = -1; %set to unknown
    
     clear profiledata pd
   %set the unique ID. Use  WOD value if available
    ii = find(cellfun(@isempty,strfind(prof,'CAST'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    pd.nss = str10;
    tt = num2str(str2num(txt(ij(2)+1:ij(3)-1)));
    if ~isempty(tt)
        pd.nss(1:length(tt))=tt;
    else
        pd.nss = num2str(uniqueid);
    end
    
    %get the cruiseID
    ii = find(cellfun(@isempty,strfind(prof,'Originators Cruise ID'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    profiledata.Cruise_ID='          ';
    vv = strtrim(txt(ij(2)+1:ij(3)-1));
    profiledata.Cruise_ID(1:length(vv)) = vv;
    
    %lat and long information
    ii = find(cellfun(@isempty,strfind(prof,'Latitude'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    profiledata.latitude=str2num(txt(ij(2)+1:ij(3)-1));
    pd.latitude = profiledata.latitude;
    
    ii = find(cellfun(@isempty,strfind(prof,'Longitude'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    ln = str2num(txt(ij(2)+1:ij(3)-1));
    kk = find(ln < 0);
    ln(kk) = ln(kk) + 360;
    profiledata.longitude=ln;
    pd.longitude=ln;
    
    %date/time information
%         woce_date: 20160426
%         woce_time: 142500
%              time: 42485
    ii = find(cellfun(@isempty,strfind(prof,'Year'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    pd.year=strtrim(txt(ij(2)+1:ij(3)-1));
    
    ii = find(cellfun(@isempty,strfind(prof,'Month'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    mm=strtrim(txt(ij(2)+1:ij(3)-1));
    pd.month = sprintf('%02i',str2num(mm));

    ii = find(cellfun(@isempty,strfind(prof,'Day'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    dd = strtrim(txt(ij(2)+1:ij(3)-1));
    pd.day=sprintf('%02i',str2num(dd));
    
    %set up woce_date and woce_time variables
    wd = [pd.year pd.month pd.day];
    profiledata.woce_date = str2num(strrep(wd,' ','0'));
    
    ii = find(cellfun(@isempty,strfind(prof,'Time'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    tt=str2num(txt(ij(2)+1:ij(3)-1));
    units = txt(ij(3)+1:ij(4)-1);
    h = findstr('hours',units);
    m = findstr('minutes',units);
    s = findstr('seconds',units);
    if ~isempty(h) & ~isempty(m) & ~isempty(s)
        tfmt = 'HHMMSS';
        ss = '';
    elseif ~isempty(h) & ~isempty(m)
        tfmt = 'HHMM';
        ss = '00';
    end
    ttn = datenum(num2str(tt),tfmt);
    %need to check for the time and convert to UTC if needed
    %     NZDT	New Zealand Daylight Time	UTC +13
    %     NZST	New Zealand Standard Time	UTC +12
    tstr = {'NZDT','NZST'};
    for b  = 1:length(tstr)
        lt = findstr(tstr{b},units);
        if ~isempty(lt)
            if b == 1
                ttn = ttn - 13/24;
            else
                ttn = ttn - 12/24;
            end
            tt = num2str(datestr(ttn,tfmt));
                break
        end
    end
    
    profiledata.woce_time=str2num([tt ss]);  %woce_time
    wt=profiledata.woce_time;
    wt=floor(wt/100);
    wt2=sprintf('%4i',wt);
    jk=strfind(wt2,' ');
    if(~isempty(jk))
        wt2(jk)='0';
    end
    pd.time=[wt2(1:2) ':' wt2(3:4)];
    %add in some more stuff to profiledata
    ju=julian([str2num(pd.year) str2num(pd.month) str2num(pd.day) ...
        floor(wt/100) rem(wt,100) 0])-2415020.5;
    profiledata.time = ju;
  
    %surface code information
    %profiledata
    %       SRFC_Code: [30x4 char]
    %       SRFC_Parm: [30x10 char]
    %     SRFC_Q_Parm: [30x1 char] 
    %       Nsurfc: 13
    %pd:
    %          surfcode: [30x4 char]
    %          surfparm: [30x10 char]
    %         surfqparm: [30x1 char]
    %            nsurfc: 13    
    
    ii = find(cellfun(@isempty,strfind(prof,'Accession Number'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    vv = num2str(str2num(txt(ij(2)+1:ij(3)-1)));
    if ~isempty(vv)
        nsurfc = nsurfc+1;
        profiledata.SRFC_Code(nsurfc,:)='ACCS';
        profiledata.SRFC_Parm(nsurfc,:)='          ';
        profiledata.SRFC_Parm(nsurfc,1:length(vv))=vv;
        profiledata.SRFC_Q_Parm(nsurfc)='0';
    end
    
    ii = find(cellfun(@isempty,strfind(prof,'Platform'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    vv = num2str(str2num(txt(ij(2)+1:ij(3)-1)));
    shipname = txt(ij(4)+1:ij(5)-1);
    [callsign,m] =regexp(txt,'\w*call sign (\w+);.*','tokens','match');
    callsign = char(callsign{:});
    ibr = strfind(shipname,'(');
    if ~isempty(ibr)
        shipname = shipname(1:ibr-1);
    else
        shipname = shipname(1:10);
    end
    if ~isempty(vv)
        nsurfc = nsurfc+1;
        profiledata.SRFC_Code(nsurfc,:)='PLAT';
        profiledata.SRFC_Parm(nsurfc,:)=str10;
        profiledata.SRFC_Parm(nsurfc,1:length(vv))=vv;
        profiledata.SRFC_Q_Parm(nsurfc)='0';
        %shipname
        nsurfc = nsurfc+1;
        profiledata.SRFC_Code(nsurfc,:)='SHP#';
        profiledata.SRFC_Parm(nsurfc,:)=str10;
        profiledata.SRFC_Parm(nsurfc,1:length(shipname))=shipname;
        profiledata.SRFC_Q_Parm(nsurfc)='0';
        %callsign
        nsurfc = nsurfc+1;
        profiledata.SRFC_Code(nsurfc,:)='GCLL';
        profiledata.SRFC_Parm(nsurfc,:)=str10;
        profiledata.SRFC_Parm(nsurfc,1:length(callsign))=callsign;
        profiledata.SRFC_Q_Parm(nsurfc)='0';
    end

    ii = find(cellfun(@isempty,strfind(prof,'Institute'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    vv = num2str(str2num(txt(ij(2)+1:ij(3)-1)));
    if ~isempty(vv)
        nsurfc = nsurfc+1;
        profiledata.SRFC_Code(nsurfc,:)='INS1';
        profiledata.SRFC_Parm(nsurfc,:)=str10;
        profiledata.SRFC_Parm(nsurfc,1:length(vv))=vv;
        profiledata.SRFC_Q_Parm(nsurfc)='0';
    end

    ii = find(cellfun(@isempty,strfind(prof,'probe_type'))==0);
    if ~isempty(ii)
        txt = prof{ii};
        ij = strfind(txt,',');
        tt = strtrim(txt(ij(2)+1:ij(3)-1));
        
        switch tt(1)
            case '1' %mbt
                profiledata.Data_Type='MB';
                profiledata.Stream_Ident=[DATA_QC_SOURCE 'MB'];
            case '2' %xbt
                profiledata.Data_Type='XB';
                profiledata.Stream_Ident=[DATA_QC_SOURCE 'XB'];
            case '4' %ctd
                profiledata.Data_Type='CT';
                profiledata.Stream_Ident=[DATA_QC_SOURCE 'CT'];
            case {'5','7'} %std/bottle
                profiledata.Data_Type='BO';
                profiledata.Stream_Ident=[DATA_QC_SOURCE 'BO'];
            case '6' %xctd
                pd.Data_Type='XC';
                pd.Stream_Ident=[DATA_QC_SOURCE 'XC'];
            otherwise
                disp(['Probe type = ' num2str(tt) ',Profile = ' profiledata.nss])
                return
        end
    end
            
    ii = find(cellfun(@isempty,strfind(prof,'Recorder'))==0);
    if ~isempty(ii)
        txt = prof{ii};
        ij = strfind(txt,',');
        vv = num2str(str2num(txt(ij(2)+1:ij(3)-1)));
        if ~isempty(vv)
            nsurfc = nsurfc+1;
            profiledata.SRFC_Code(nsurfc,:)='RCT$';
            profiledata.SRFC_Parm(nsurfc,:)=str10;
            profiledata.SRFC_Parm(nsurfc,1:length(vv))=vv;
            profiledata.SRFC_Q_Parm(nsurfc)='0';
        end
    end
           
    ii = find(cellfun(@isempty,strfind(prof,'Instrument'))==0);
    txt = c{ii(1)};
    ij = strfind(txt,',');
    tt = str2num(txt(ij(2)+1:ij(3)-1));
    if ~isempty(tt)
        ii = find(tt == wpt{1});
        ptt = tt;
        gp = num2str(wpt{2}(ii));
        if length(gp) == 2
            gp = ['0' gp];
        elseif length(gp) == 1
            gp = ['00' gp];
        end
        nsurfc = nsurfc+1;
        profiledata.SRFC_Code(nsurfc,:)='PEQ$';
        profiledata.SRFC_Parm(nsurfc,:)=str10;
        profiledata.SRFC_Parm(nsurfc,1:length(gp))=gp;
        profiledata.SRFC_Q_Parm(nsurfc)='0';
    end

    ii = find(cellfun(@isempty,strfind(prof,'UNITS'))==0);
    txt = prof{ii};
    ij = strfind(txt,',');
    vv = txt(ij(1)+1:ij(2)-1);
    if ~isempty(strmatch('m',vv))
        profiledata.D_P_Code='D';
    else
        profiledata.D_P_Code='P';
    end
    
    ii = find(cellfun(@isempty,strfind(upper(prof),'NEEDS DEPTH FIX'))==0);
    if ~isempty(ii)
        txt = prof{ii};
        ij = strfind(txt,',');
        vv = str2num(txt(ij(2)+1:ij(3)-1));
        if ndf == -1
            ndf = 1;
        end
    end
   
    %Now the actual profile data
    ii = find(cellfun(@isempty,strfind(upper(prof),'VARIABLES'))==0);
    if ~isempty(ii)
        %get the order in which they appear:
        txt = prof{ii};
        ij = strfind(txt,',');
        fmt = repmat('%s',1,length(ij));
        headers = textscan(txt,fmt,'delimiter',',');
        idep = find(cellfun(@isempty,strfind(upper([headers{:}]),'DEPTH'))==0);
        itmp = find(cellfun(@isempty,strfind(upper([headers{:}]),'TEMP'))==0);
        isal = find(cellfun(@isempty,strfind(upper([headers{:}]),'SALINITY'))==0);
    end
       
    %read the profile data into variables:
    ii = ii+2;
    dat = NaN*ones(size(prof,1)-ii,3);
    txt = prof{ii+1};
    ij = strfind(txt,',');
    fmt = repmat('%f',1,length(ij));
    for b = 1:size(dat,1)
        txt = prof{ii+b};
        ln = textscan(txt,fmt,'delimiter',',');
        dat(b,:) = [ln{idep},ln{itmp},ln{isal}];
    end
    
    dat = change(dat,'>',99990,NaN);
    
    nprof = length(find(~isnan(nansum(dat))))-1;
    ndep = repmat(size(dat,1),1,size(dat,2)-1);
    profiledata.No_Depths = ndep;
    profiledata.D_P_Code=repmat(profiledata.D_P_Code,1,size(dat,2)-1);
    
    profiledata.Data_Type = profiledata.Data_Type';
    profiledata.Mky=str8';
    profiledata.One_Deg_Sq=str8';
    profiledata.Iumsgno=str12';
    profiledata.Stream_Source=str1;
    profiledata.Uflag=str1;
    profiledata.MEDS_Sta=str8';
    profiledata.Q_Pos='1';
    profiledata.Q_Date_Time='1'; 
    profiledata.Q_Record='1';
    profiledata.Up_date=(datestr(now,'yyyymmdd'))';
    profiledata.Bul_Time=str12';
    profiledata.Bul_Header=str6';
    profiledata.Source_ID=str4';
    profiledata.QC_Version=str4';
    profiledata.Data_Avail='A';
    profiledata.Ident_Code=repmat(str1,2,100);
    profiledata.PRC_Code=repmat(str1,4,100);
    profiledata.Version=repmat(str1,4,100);
    profiledata.PRC_Date=repmat(str1,8,100);
    profiledata.Act_Code=repmat(str1,2,100);
    profiledata.Act_Parm=repmat(str1,4,100);
    profiledata.Aux_ID=double.empty(100,0);
    profiledata.Previous_Val=repmat(str1,4,100);
    profiledata.Flag_severity=double.empty(100,0);
    
    profiledata.No_Prof=nprof;
    profiledata.Num_Hists=0;
    
    if ~isempty(itmp)
        profiledata.Prof_Type(1,5:16)='            ';
        profiledata.Prof_Type(1,1:4)='TEMP';
        profiledata.Standard(1)='1';
        %put the data in
        profiledata.Depthpress(1,1:ndep) = dat(:,1);
        profiledata.DepresQ(1,1:ndep,1)='0';
        profiledata.Profparm(1,1,1:ndep,1,1) = dat(:,2);
        profiledata.ProfQP(1,1,1,1:ndep,1,1)='0';
        profiledata.Dup_Flag(1)='N';
        profiledata.Digit_Code(1)='0';
    end
    if ~isempty(isal)
        profiledata.Prof_Type(2,5:16)='            ';
        profiledata.Prof_Type(2,1:4)='PSAL';
        profiledata.Standard(2)='2';
        %put the data in
        profiledata.Depthpress(2,1:ndep) = dat(:,1);
        profiledata.DepresQ(1,1:ndep,2)='0';
        profiledata.Profparm(1,1,1:ndep,1,2) = dat(:,3);
        profiledata.ProfQP(1,1,1,1:ndep,1,2)='0';
        profiledata.Dup_Flag(2)='N';
        profiledata.Digit_Code(2)='0';
    end
    
    
    %add the uniqueid information
    nsurfc = nsurfc + 1;
    profiledata.SRFC_Code(nsurfc,1:4)=[DATA_QC_SOURCE 'ID'];
    profiledata.SRFC_Parm(nsurfc,:) = '          ';
    profiledata.SRFC_Parm(nsurfc,1:length(num2str(pd.nss)))=num2str(pd.nss);
    profiledata.SRFC_Q_Parm(nsurfc)='1';
    
    for b=1:profiledata.No_Prof
        inan = isnan(dat(:,b));
        profiledata.Deep_Depth(b)=max(dat(~inan,1));
    end
    pd.deep_depth = profiledata.Deep_Depth;
    
    profiledata.Nparms=nparms;
    profiledata.Nsurfc=nsurfc;
    profiledata.SRFC_Code=profiledata.SRFC_Code';
    profiledata.SRFC_Parm=profiledata.SRFC_Parm';
    profiledata.Cruise_ID=profiledata.Cruise_ID';
    profiledata.Prof_Type=profiledata.Prof_Type';
    profiledata.Depthpress = profiledata.Depthpress';
    profiledata.DepresQ = profiledata.DepresQ;
    profiledata.Pcode=str4';
    profiledata.Parm=str10';
    profiledata.Q_Parm=str1;
    
    %add in more for pd
    pd.ndep = ndep;
    pd.depth = profiledata.Depthpress;
    pd.qc = squeeze(profiledata.ProfQP);
    pd.depth_qc = profiledata.DepresQ;
    pd.temp = squeeze(profiledata.Profparm);
    pd.Flag_severity = profiledata.Flag_severity;
    pd.numhists = profiledata.Num_Hists;
    pd.nparms = profiledata.Nparms;
    pd.QC_code = profiledata.Act_Code';
    pd.QC_depth = profiledata.Aux_ID;
    pd.PRC_Date = profiledata.PRC_Date';
    pd.PRC_Code = profiledata.PRC_Code';
    pd.Version = profiledata.Version';
    pd.Act_Parm = profiledata.Act_Parm;
    pd.Previous_Val = profiledata.Previous_Val;
    pd.Ident_Code = profiledata.Ident_Code;
    pd.surfcode = profiledata.SRFC_Code';
    pd.surfparm = profiledata.SRFC_Parm';
    pd.surfqparm = profiledata.SRFC_Q_Parm';
    pd.nsurfc = profiledata.Nsurfc;
    pd.ptype = profiledata.Prof_Type';

end
end

