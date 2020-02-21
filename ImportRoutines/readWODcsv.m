function profiledata = readWODcsv(inputfile,outputfile,oflags)
% Function to read csv files from the WOD select and search facility and output to MQNC format
% Inputs:   inputfile - (string) name of file for reading, with extension
%           outputfile - (string) name for output MQNC file
%           oflags - 1 to use originators flags, 0 to ignore flags (default
%           = 0)
% Rebecca Cowley 20 August 2009, updated Feb 2020
if nargin < 2
    error('Not enough input arguments, try again with inputfile and outputfile')
elseif nargin == 2
    oflags = 0;
end

%set up probe type equivalents:
[wpt,gpt]=textread('/home/UOT/programs/matlab_xbtbias/v_5_instrument.csv','%u%u%*s%*s',...
    'delimiter',',');

% %open the list of stns to re-run
% [stnlist,prt] = textread('xbnewcorrFALSE.txt','%f%*s%f%*s%*s%*s','delimiter',' ');
% 
% load unique id from file, use WOD number
fid=fopen(inputfile,'r');
%get data line by line
while ~feof(fid)
    a=0;
    a=a+1;
    txt =fgetl(fid);
    %put in break point if can't find feof
    if ~ischar(txt)
        break
    end
    %get header info out:
    clear profiledata dd
    next = 0;
    nparms = 0;
    nsurfc = 0;
    bott = 0;
    ndf = -1; %set to unknown
    while 1
        ii = strfind(txt,',');
        if isempty(ii)
            return
        end
        str = txt(1:ii(1)-1); %get the first word
        if ~isempty(str2num(str))
            break
        end
        if ~isempty(strmatch('#',str(1)))
            a=a+1;
            txt =fgetl(fid);
            continue
        elseif ~isempty(strmatch('CAST',str))
            profiledata.nss = '          ';
            tt = num2str(str2num(txt(ii(2)+1:ii(3)-1)));
            profiledata.nss(1:length(tt))=tt;
        elseif ~isempty(strmatch('NODC Cruise ID',str))
            profiledata.cruiseID='          ';
            vv = deblank(txt(ii(2)+1:ii(3)-1));
            profiledata.cruiseID(1:length(vv)) = vv;
        elseif ~isempty(strmatch('Latitude',str))
            profiledata.latitude=str2num(txt(ii(2)+1:ii(3)-1));
        elseif ~isempty(strmatch('Longitude',str))
            ln = str2num(txt(ii(2)+1:ii(3)-1));
            kk = find(ln < 0);
            ln(kk) = ln(kk) + 360;
            profiledata.longitude=ln;
        elseif ~isempty(strmatch('Year',str))
            profiledata.year=str2num(txt(ii(2)+1:ii(3)-1));
        elseif ~isempty(strmatch('Month',str))
            profiledata.month=str2num(txt(ii(2)+1:ii(3)-1));
        elseif ~isempty(strmatch('Day',str))
            profiledata.day=str2num(txt(ii(2)+1:ii(3)-1));
        elseif ~isempty(strmatch('Time',str))
            tt=str2num(txt(ii(2)+1:ii(3)-1));
            %convert to string:
            hh = floor(tt);
            if hh < 10
                hh = ['0' num2str(hh)];
            else
                hh = num2str(hh);
            end
            mm = rem(tt,1);
            mm = mm*60;
            if mm < 10
                mm = ['0' num2str(round(mm))];
            else
                mm = num2str(round(mm));
            end
            ss = '00';
            profiledata.time=str2num([hh mm ss]);  %woce_time
        elseif ~isempty(strmatch('Accession Number',str))
            nsurfc = nsurfc+1;
            profiledata.surfpcode(nsurfc,:)='ACCS';
            profiledata.surfparm(nsurfc,:)='          ';
            vv = num2str(str2num(txt(ii(2)+1:ii(3)-1)));
            profiledata.surfparm(nsurfc,1:length(vv))=vv;
            profiledata.surfqparm(nsurfc)='0';
        elseif ~isempty(strmatch('Platform',str))
            nsurfc = nsurfc+1;
            profiledata.surfpcode(nsurfc,:)='PLAT';
            profiledata.surfparm(nsurfc,:)='          ';
            vv = num2str(str2num(txt(ii(2)+1:ii(3)-1)));
%             vv = txt(ii(4)+1:ii(5)-1);
%             try
%                 profiledata.surfparm(nsurfc,1:10)=vv(1:10);
%             catch
                profiledata.surfparm(nsurfc,1:length(vv))=vv;
%             end
            profiledata.surfqparm(nsurfc)='0';
        elseif ~isempty(strmatch('Institute',str))
            nsurfc = nsurfc+1;
            profiledata.surfpcode(nsurfc,:)='INS1';
            profiledata.surfparm(nsurfc,:)='          ';
            vv = num2str(str2num(txt(ii(2)+1:ii(3)-1)));
            profiledata.surfparm(nsurfc,1:length(vv))=vv;
            profiledata.surfqparm(nsurfc)='0';
        elseif ~isempty(strmatch('Investigator',str))
            nsurfc = nsurfc+1;
            profiledata.surfpcode(nsurfc,:)='PICD';
            profiledata.surfparm(nsurfc,:)='          ';
            vv = num2str(str2num(txt(ii(2)+1:ii(3)-1)));
            profiledata.surfparm(nsurfc,1:length(vv))=vv;
            profiledata.surfqparm(nsurfc)='0';
        elseif ~isempty(strmatch('probe_type',str))
            tt = str2num(txt(ii(2)+1:ii(3)-1));
            switch tt
                case 1 %mbt
                    profiledata.datat='MB';
                    profiledata.streamident='WAMB';
                case 2 %xbt
                    profiledata.datat='XB';
                    profiledata.streamident='WAXB';
                case 4 %ctd
%                     nsurfc = nsurfc+1;
%                     profiledata.surfpcode(nsurfc,:)='PEQ$';
%                     profiledata.surfparm(nsurfc,:)='830       ';
%                     profiledata.surfqparm(nsurfc,:)='1';
                    profiledata.datat='CT';
                    profiledata.streamident='WACT';
                case {5,7} %std/bottle
                    bott = 1;
                    nsurfc = nsurfc+1;
                    profiledata.surfpcode(nsurfc,:)='PEQ$';
                    profiledata.surfparm(nsurfc,:)='810       ';
                    profiledata.surfqparm(nsurfc)='1';
                    profiledata.datat='BO';
                    profiledata.streamident='WABO';
                case 6 %xctd
                    profiledata.datat='XC';
                    profiledata.streamident='WAXC';
                otherwise
                    disp(['Probe type = ' num2str(tt) ',Profile = ' profiledata.nss])
                    return
            end
        elseif ~isempty(strmatch('Recorder',str))
            nsurfc = nsurfc+1;
            profiledata.surfpcode(nsurfc,:)='RCT$';
            profiledata.surfparm(nsurfc,:)='          ';
            vv = num2str(str2num(txt(ii(2)+1:ii(3)-1)));
            profiledata.surfparm(nsurfc,1:length(vv))=vv;
            profiledata.surfqparm(nsurfc)='0';
           
        elseif ~isempty(strmatch('Instrument',str))
            tt = str2num(txt(ii(2)+1:ii(3)-1));
            ii = find(tt == wpt);
            ptt = tt;
            if tt == 4 && bott == 1 %probetype says bottle, instrument says CTD
                a=a+1;
                txt =fgetl(fid);
                continue
            end
            nsurfc = nsurfc+1;
            profiledata.surfpcode(nsurfc,:)='PEQ$';
            profiledata.surfparm(nsurfc,:)='          ';
            gp = num2str(gpt(ii));
            if length(gp) == 2
                gp = ['0' gp];
            elseif length(gp) == 1
                gp = ['00' gp];
            end
            profiledata.surfparm(nsurfc,1:3) = gp;
            profiledata.surfqparm(nsurfc)='1';
        elseif ~isempty(strmatch('UNITS',str))
            if ~isempty(strmatch('m',txt(ii(1)+1:ii(2)-1)))
                profiledata.D_P_Code='D';
            else
                profiledata.D_P_Code='P';
            end
        elseif ~isempty(strmatch('Needs Depth Fix',str))|~isempty(strmatch('needs_depth_fix',str))
            ndf = str2num(txt(ii(2)+1:ii(3)-1));
            if ndf == -1
                ndf = 1;
            end
        elseif ~isempty(strmatch('VARIABLES',str))
            if isempty(strfind(txt,'Temp'))
                %cycle through to next profile
                while 1
                    if isempty(strfind(txt,'#----------'))
                        txt =fgetl(fid);
                    else
                        break
                    end
                end
                next = 1;
                break
            end
                %get the order in which they appear:
            is(1) = strfind(txt,'Depth');
            is(2) = strfind(txt,'Temp');
            try
                is(3) = strfind(txt,'Salinity');
            catch
                is(3) = NaN;
            end
            for b = 1:3
                nn =  find(ii == is(b)-1);
                if isempty(nn)
                    ij(b) = NaN;
                else
                    ij(b) = nn;
                end
            end
        elseif ~isempty(strmatch('BIOLOGY',str)) %skip all this section
            while 1
                if isempty(strfind(txt,'#----------'))
                    txt =fgetl(fid);
                else
                    break
                end
                if ~ischar(txt)
                    break
                end
            end
            next = 1;
            break
        else
            a=a+1;
            txt =fgetl(fid);
            continue
        end
        a=a+1;
        txt =fgetl(fid);
    end
    if next
        continue
    end
    if ~isfield(profiledata,'time')
        profiledata.time = 0;
    end
    %setup output files:
    %read the profile data into variables:
    while 1
        ii = strfind(txt,',');
        if isempty(ii)
            break
        end
        str = txt(1:ii(1)-1); %get the first word
        if isempty(str2num(str))
            break
        end
        a = str2num(txt(1:ii(1)-1));
        
        for b = 1:length(ii)-1
            nn = str2num(txt(ii(b)+1:ii(b+1)-1));
            if isempty(nn)
                dd(a,b) = NaN;
            else
                dd(a,b) = nn;
            end
        end
        txt =fgetl(fid);
        
    end
    
%     igo = find(stnlist == str2num(profiledata.nss));
%     if isempty(igo)
%         continue
%     end
%     gp = num2str(prt(igo));
%     if length(gp) == 2
%         gp = ['0' gp];
%     elseif length(gp) == 1
%         gp = ['00' gp];
%     end
%     ip = strmatch('PEQ$',profiledata.surfpcode);
%     if isempty(ip)
%         nsurfc = nsurfc+1;
%         profiledata.surfpcode(nsurfc,:)='PEQ$';
%         profiledata.surfparm(nsurfc,:)='          ';
%         profiledata.surfparm(nsurfc,1:3) = gp;
%         profiledata.surfqparm(nsurfc)='1';
%     else
%         profiledata.surfparm(ip,1:3) = gp;
%     end
% 
    dd = change(dd,'>',99990,NaN);
    nprof = length(find(~isnan(ij)))-1;
    ndep = a;
    profiledata.ndep = a;
    
    profiledata.lat=profiledata.latitude;
    profiledata.lon=profiledata.longitude;
    
    profiledata.mky='        ';
    profiledata.onedegsq='        ';
    profiledata.iumsgno='            ';
    profiledata.streamsource=' ';
    profiledata.uflag=' ';
    profiledata.medssta='        ';
    profiledata.qpos='1';
    profiledata.qdatetime='1'; 
    profiledata.qrec=' ';
    profiledata.update=datestr(datenum(date),'yyyymmdd');
    profiledata.bultime='            ';
    profiledata.bulheader='      ';
    profiledata.sourceID='    ';
    profiledata.QCversion='    ';
    profiledata.dataavail='A';
    
    profiledata.nprof=nprof;
    profiledata.nhists=0;
    
    for i=1:profiledata.nprof
        profiledata.nosseg(i)=1;
        if i==1
            profiledata.prof_type(i,1:4)='TEMP';
            profiledata.standard(i)='1';
        elseif i==2
            profiledata.prof_type(i,1:4)='PSAL';
            profiledata.standard(i)='2';
        end
        profiledata.prof_type(i,5:16)='            ';
        profiledata.dup_flag(i)='N';
        profiledata.digit_code(i)='0';
    end
    nsurfc = nsurfc + 1;
    profiledata.surfpcode(nsurfc,1:4)='WAID';
    profiledata.surfparm(nsurfc,:) = '          ';
    profiledata.surfparm(nsurfc,1:length(num2str(profiledata.nss)))=num2str(profiledata.nss);
    profiledata.surfqparm(nsurfc)='1';
    
    profiledata.identcode='';
    profiledata.PRCcode='';
    profiledata.Version='';
    profiledata.PRCdate='';
    profiledata.Actcode='';
    profiledata.Actparm='';
    profiledata.AuxID=0;
    profiledata.PreviousVal='';
    profiledata.flagseverity=0;
    
    profiledata.profile_type='';
    for b=1:profiledata.nprof
        %get the depth temp pairs etc out of the file,
        %then read the next segment if relevant:
        profiledata.nodepths(b)=ndep;
        if b==1
            profiledata.profile_type(1,1,1:4)='TEMP';
            profiledata.profparm(b,1,:)=dd(:,ij(2));
            if oflags %use originators flags
                flg = dd(:,ij(2)+2);
                flg = change(flg,'==',NaN,0);
                flg = num2str(flg);
                profiledata.profQparm(b,1,1:ndep) = flg;
            else
                profiledata.profQparm(b,1,1:ndep)='0';
            end
            
        elseif b==2
            profiledata.profile_type(1,1,1:4)='PSAL';
            profiledata.profparm(b,1,:)=dd(:,ij(3));
            if oflags %use originators flags
                flg = dd(:,ij(2)+2);
                flg = change(flg,'==',NaN,0);
                flg = num2str(flg);
                profiledata.profQparm(b,1,1:ndep) = flg;
            else
                profiledata.profQparm(b,1,1:ndep)='0';
            end
        end
        
        %NOTE THAT DPC$ IS NOT WORKING PROPERLY - DPC IS BEING INSERTED
        %WHERE NO DEPTH CORR IS DONE - EG FOR T5s
        %NEEDS FIXING - RC 1/12/2009.
%DPC$ = 01, known, needs correction
%       02, known, no correction required
%       03, Unknown type, leave as is
%       04, Known type, correction done
%       05, unknown type, correction done
        if ndf <= 0 && ~isempty(strmatch(profiledata.datat,'XB'));
            profiledata.depth(b,1,:)=dd(:,ij(1));
            if b == 1 && ptt == 2
                nsurfc = nsurfc + 1;
                profiledata.surfpcode(nsurfc,:)='DPC$';
                profiledata.surfparm(nsurfc,:)='        03';
                profiledata.surfqparm(nsurfc)=' ';
            elseif b == 1 && ptt ~=2
                nsurfc = nsurfc + 1;
                profiledata.surfpcode(nsurfc,:)='DPC$';
                profiledata.surfparm(nsurfc,:)='        02';
                profiledata.surfqparm(nsurfc)=' ';                
            end
             do = dd(:,ij(1));
       elseif (ndf == 1 || ndf == 2) && ptt ~= 2 %Hanawa correction:
            do = dd(:,ij(1));
            %             dn = (1.0417*do)-(75.906*(1-((1-(0.0002063*do)))^0.5));
            do = 1.0336*do;
            profiledata.depth(b,1,:)=do;
            if b == 1
                nsurfc = nsurfc + 1;
                profiledata.surfpcode(nsurfc,:)='DPC$';
                profiledata.surfparm(nsurfc,:)='        04';
                profiledata.surfqparm(nsurfc)=' ';
                nsurfc = nsurfc + 1;
                profiledata.surfpcode(nsurfc,:)='FRA$';
                profiledata.surfparm(nsurfc,:)='1.0336    ';
                profiledata.surfqparm(nsurfc)=' ';
            end
%         elseif ndf == 2  && ptt ~= 2 %Kizu correction:
%             profiledata.depth(b,1,:)=dd(:,ij(1));
%             
%             if b == 1
%                 nsurfc = nsurfc + 1;
%                 profiledata.surfpcode(nsurfc,:)='DPC$';
%                 profiledata.surfparm(nsurfc,:)='        01';
%                 profiledata.surfqparm(nsurfc)=' ';
%                 nsurfc = nsurfc + 1;
%                 profiledata.surfpcode(nsurfc,:)='FRA$';
%                 profiledata.surfparm(nsurfc,:)='KIZU2005  ';
%                 profiledata.surfqparm(nsurfc)=' ';
%                 disp('KIZU correction!')
%                 pause
%             end
        elseif ndf == 1 || ndf == 2 && ptt == 2 %unknown, needs fix:
            do = dd(:,ij(1));
            %             dn = (1.0417*do)-(75.906*(1-((1-(0.0002063*do)))^0.5));
            dn = 1.0336*do;
            profiledata.depth(b,1,:)=dn;
            if b == 1
                nsurfc = nsurfc + 1;
                profiledata.surfpcode(nsurfc,:)='DPC$';
                profiledata.surfparm(nsurfc,:)='        05';
                profiledata.surfqparm(nsurfc)=' ';
                nsurfc = nsurfc + 1;
                profiledata.surfpcode(nsurfc,:)='FRA$';
                profiledata.surfparm(nsurfc,:)='1.0336    ';
                profiledata.surfqparm(nsurfc)=' ';
            end
        else
            profiledata.depth(b,1,:)=dd(:,ij(1));
            do = dd(:,ij(1));
        end
        profiledata.depresQ(b,1,1:ndep)='1';
        
    end
    for b=1:profiledata.nprof
        profiledata.deep_depth(b)=max(do);
    end
    no_depths='';
    profiledata.nparms=nparms;
    profiledata.nsurfc=nsurfc;
    
    profiledata.autoqc=0;
    writekeys=1;
    profiledata.outputfile = {outputfile};
    profiledata.source = 'WOD2005   ';
    profiledata.priority = 2;
        
    writeMQNCfiles(profiledata,writekeys);
   
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %TEMPORARY ALTERATION TO UPDATE HEADER INFO IN WORKING FILES
%     % 1/12/2009 RC
%     
% 
% %fix the working files with the correct header info:
% clear filenam
%     filenam=outputfile;
%     n=str2num(profiledata.nss);
%     nss=num2str(n);
%     
% for j=1:2:length(nss);
%     
%     if(j+1>length(nss))
%         if(ispc)
%             filenam=[filenam '\' nss(j)];
%         else
%             filenam=[filenam '/' nss(j)];
%         end
%     else
%         if(ispc)
%             filenam=[filenam '\' nss(j:j+1)];
%         else
%             filenam=[filenam '/' nss(j:j+1)];
%         end
%     end
% end
% 
% filenam1=[filenam 'ed.nc']
% filenam2=[filenam 'raw.nc'];
% 
% nc = netcdf(filenam1,'write');
% ncr = netcdf(filenam2,'write');
% 
% np = nc{'Nparms'}(:);
% if np ~= 0
% 
% nc{'Pcode'}(1:np,:) = repmat('    ',[np,1]);
% ncr{'Pcode'}(1:np,:) = repmat('    ',[np,1]);
% nc{'Parm'}(1:np,:) = repmat('          ',[np,1]);
% ncr{'Parm'}(1:np,:) = repmat('          ',[np,1]);
% nc{'Q_Parm'}(1:np,:) = repmat(' ',[np,1]);
% ncr{'Q_Parm'}(1:np,:) = repmat(' ',[np,1]);
% end
% pp = nc{'SRFC_Code'}(:);
% ppr = ncr{'SRFC_Code'}(:);
% ppp = nc{'SRFC_Parm'}(:);
% pppr = ncr{'SRFC_Parm'}(:);
% 
% ipp = strmatch('DPC$',pp);
% ippr = strmatch('DPC$',ppr);
% 
% nc{'SRFC_Code'}(1:nsurfc,:) = profiledata.surfpcode;
% ncr{'SRFC_Code'}(1:nsurfc,:) = profiledata.surfpcode;
% nc{'SRFC_Parm'}(1:nsurfc,:) = profiledata.surfparm;
% ncr{'SRFC_Parm'}(1:nsurfc,:) = profiledata.surfparm;
% nc{'SRFC_Q_Parm'}(1:nsurfc,:) = profiledata.surfqparm;
% ncr{'SRFC_Q_Parm'}(1:nsurfc,:) = profiledata.surfqparm;
% 
% iold = strmatch('DPC$',nc{'SRFC_Code'}(1:nsurfc,:));
% if ~isempty(iold) && ~isempty(ipp)
% nc{'SRFC_Parm'}(iold,:) = ppp(ipp(1),:);
% iold = strmatch('DPC$',ncr{'SRFC_Code'}(1:nsurfc,:));
% ncr{'SRFC_Parm'}(iold,:) = pppr(ippr(1),:);
% end
% 
% nc{'Nparms'}(:) = nparms;
% ncr{'Nparms'}(:) = nparms;
% nc{'Nsurfc'}(:) = nsurfc;
% ncr{'Nsurfc'}(:) = nsurfc;
% 
% close(nc)
% close(ncr)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
disp('*** Transfer of WOD csv files complete ***')
fclose(fid)
end

