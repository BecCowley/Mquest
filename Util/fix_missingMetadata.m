%% check any of the Mquest databases for missing or corrupted metadata
% allow fixing by the operator, not automated
% Issues that I know about so far:
%   1. Mis match in CSID (uniqueid) in file and filename - assume what has
%       happened is that the uniqueid's have been updated to avoid duplication,
%       but the CSID in the SRFC_parm wasn't updated.
%   2. Missing or duplicated TWI information
%   3. Update and  PRC codes dates wrong format (ddmmyyyy instead of yyyymmdd)
%
% Other things to check might be:
%   1. Consistency between keys file and actual records in the file
%   2. Fall rate applied
%   3. For older files, the presence of the PTYP flag instead of PEQ$. And
%       I think there might be a similar issue with recorder type.
%   4. Check that QC has been applied to the data - some files in databases
%   without QC, probably because they are in other databases
%   5. Ignore TP and DU profiles as they aren't exported to other formats
%   6. Check for duplicated station numbers in keys files
%
%Bec Cowley, June, 2022

clear
prefix=input('enter the database prefix:','s');
keysdat = nc2struct([prefix '_keys.nc']);
stn = str2num(keysdat.stn_num');

% check for duplicate station numbers in this database:
ustn = unique(stn);
if length(ustn) ~= length(stn)
    disp(['Duplicated stations in this database ' prefix])
    return
end
%set up some strings
prtyp = {'PRT$','PTYP','PTY$','PFR$', 'PEQ$'};
str10 = '          ';

%% Go through each profile and check the TWI, get the fields for reformatting dates and checking csid too
% these checks are only performed on the ed file, but corrections are made
% to both ed and raw files.
clear twi crid fixed_twi fixed_csid csid csidr ship wd ok metaok qc
[fixed_twi,fixed_csid,fixed_crid,tp] = deal(zeros(size(stn,1),1));
[ok,qc] = deal(ones(size(stn,1),1));
for aa=1:size(stn,1)
    stnn = stn(aa);
    filen=getfilename(num2str(stnn),0);
    filenam=[prefix '/' filen];
    filenr=getfilename(num2str(stnn),1);
    filenamr=[prefix '/' filenr];
    
    %check the keysdata against the file's data:
    [metaok.lat(aa),metaok.lon(aa),metaok.c360lon(aa),metaok.calls(aa),...
        metaok.datetime(aa),metaok.time(aa),metaok.dtype(aa),metaok.dsource(aa),...
        metaok.testp(aa)] = checkKeysData(filenam,aa,keysdat);
    
    %read the cruise id and line information if there, and check for QC
    %flag
    srfccodes=ncread(filenam,'SRFC_Code');
    srfcparm=ncread(filenam,'SRFC_Parm');
    nsrfc = ncread(filenam,'Nsurfc');
    srfccodesr=ncread(filenamr,'SRFC_Code');
    srfcparmr=ncread(filenamr,'SRFC_Parm');
    crid(aa,:) = ncread(filenam,'Cruise_ID')';
    qcf = ncread(filenam,'Act_Code');
    
    %jump over TP and DU flagged profiles, check QC is there for others
    if ~isempty(strmatch('TP',qcf')) | ~isempty(strmatch('DU',qcf'))
        tp(aa) = 1;
    end
    if all(all(isstrprop(qcf','alphanum')))
        %this profile hasn't been QC'd
        qc(aa) = 0;
    end
    
    %let's grab shipname, a month and year to help
    kk = strmatch('SHP#',srfccodes');
    if ~isempty(kk)
        ship(aa,:) = srfcparm(:,kk)';
    else
        ship(aa,:) = str10;
    end
    wd(aa) = ncread(filenam,'woce_date');
    
    %line information first
    kk=strmatch('TWI#',srfccodes');
    
    if length(kk) > 1
        disp([crid(aa,:) ' removing blank TWI#'])
        srfcparm(:,kk(2)) = str10';
        srfccodes(:,kk(2)) = '    ';
        keyboard
        ncwrite(filenam,'Nsurfc',nsrfc-1);
    end
    kk=strmatch('TWI#',srfccodes');
    
    if isempty(kk)
        twi(aa,:) = str10;%we'll add a TWI if it's missing later
    else
        twi(aa,:) = srfcparm(:,kk)';
    end
    
    %get csid/unique id for checking ED file
    kk=strmatch('CSID',srfccodes');
    if length(kk) > 1 %shouldn't happen, we hope
        disp([num2str(stnn) ': More than one CSID in ed file!'])
        keyboard
    end
    if isempty(kk)
        csid(aa,:) = str10;%we'll add a CSID if it's missing
    else
        csid(aa,:) = srfcparm(:,kk)';
    end
    %check CSID raw file
    kk=strmatch('CSID',srfccodesr');
    if length(kk) > 1 %shouldn't happen, we hope
        disp([num2str(stnn) ': More than one CSID in raw file!'])
        keyboard
    end
    if isempty(kk)
        csidr(aa,:) = str10;%we'll add a CSID if it's missing
    else
        csidr(aa,:) = srfcparmr(:,kk)';
    end
    %if the csid is not the same as the file path name, then we need to fix
    %it
    if str2num(csid(aa,:)) ~= stnn | str2num(csidr(aa,:)) ~= stnn 
        disp(['CSID mismatch, filename: ' num2str(stnn) '; CSID: ' csid(aa,:) '; CSIDraw: ' csidr(aa,:)])
        fixed_csid(aa) = 1;
    end
    
    %and now the probe type match
    ii = cellfun(@(a) strmatch(a, cellstr(srfccodes')),prtyp,'uniform',false);
    prt = prtyp(find(cellfun(@isempty,ii) == 0)); %this tells us which code is in the file
    %now get the corresponding code
    if ~isempty(prt)
        ii = strmatch(prt,srfccodes');
        peq = strtrim(srfcparm(:,ii)');
    else %missing
        peq = NaN;
    end
    %pass the peq string and the depths into the depth correction check
    deps = ncread(filenam,'Depthpress');
    ndep = ncread(filenam,'No_Depths');
    [ok(aa),dif] = checkFREandPEQ(deps(1:ndep),peq);
end

%first, let's deal with the non-qc'd files - display them to decide if we
%throw them away
if any(~qc)
    disp(['These ' num2str(sum(~qc)) ' files have not been QC''d'])
    disp([num2str(find(~qc)) repmat(', ',sum(~qc),1) num2str(stn(~qc)) repmat(', ',sum(~qc),1) crid(~qc,:) num2str(wd(~qc)')])
else
    disp('All profiles have QC')
end
        
%display issues with metadata in keys file and ed file:
flds = fieldnames(metaok);
for a = 1:length(flds)
    if strcmp('testp',flds{a}) | strcmp('time',flds{a}) %time field is ureliable and not really used in the IMOS format transfer
        continue
    end
    dat = metaok.(flds{a});
    disp([flds{a} ': '])
    if any(~dat)
        disp([num2str(find(~dat)') repmat(', ',sum(~dat),1) num2str(stn(~dat))])
        disp([': ' flds{a} ])
    end
    pause
end

%display the cruise IDs that don't have correct fre's
if any(ok)
    disp('Bad FREs on these ones:')
    disp([num2str(find(~ok)) repmat(', ',sum(~ok),1) num2str(stn(~ok)) repmat(', ',sum(~ok),1) crid(~ok,:)])
else
    disp('All FREs OK')
end

[c,ia,ib]= unique(crid,'rows');
disp('Current TWI values:')
for a  =1:length(c)
    uu=unique(ship(ib==a,:),'rows');
    ut = unique(twi(ib==a,:),'rows');
    disp([num2str(a) '; ' num2str(ia(a)) ': ' c(a,:) ': ' uu ': ' num2str(min(wd(ib==a))) ' to ' num2str(max(wd(ib==a))) ': ' ut ]) %will break if more than one twi match per cruise
end
%% fixing cruise id's if needed
%commented out so I don't run by accident
% ii = [19,20,21];
% disp('About to fix the following Cruise IDs:')
% for a = 1:length(ii)
%     disp(['cruiseid: ' c(ii(a),:)])
%     ss = input('Enter correct cruiseid: ','s');
%     s = str10;
%     s(1:length(ss)) = ss;
%     %now fix all the files with this cruise id
%     stnfix = stn(ib == ii(a));
%     for aa = 1:length(stnfix)
%         for b = 1:2
%             raw = b-1;
%             filen=getfilename(num2str(stnfix(aa)),raw);
%             filenam=[prefix '/' filen];
%             disp(filenam)
%             ncwrite(filenam,'Cruise_ID',s);
%         end
%     end
% end
%% fixing metadata issues - only use if needed and will need fiddling to suit
%commented out so I don't run by accident.

% flds
% 
% for aa = 5 %datetime issues
%     dat = metaok.(flds{aa});
%     disp([flds{aa} ': '])
%     ii = find(~dat);
%     for a = 4%1:length(ii)
%         for b = 1:2
%             raw = b-1;
%             filen=getfilename(num2str(stn(ii(a))),raw);
%             filenam=[prefix '/' filen];
%             wt = ncread(filenam,'woce_time')
%             wt = 180000;
%             ncwrite(filenam,'woce_time',wt);
%         end
%     end
% end
%% fixing FREs - not implemented yet
%% fixing the TWI values before writing to file
%get the unique cruise ids and ask for line numbers where there are none
disp('TWI values to fix:')
for a  =1:length(c)
    if all(~isstrprop(unique(twi(ib==a,:),'rows'),'alphanum'),2)
        uu=unique(ship(ib==a,:),'rows');
        ut = unique(twi(ib==a,:),'rows');
        disp([c(a,:) ': ' uu ': ' num2str(min(wd(ib==a))) ' to ' num2str(max(wd(ib==a))) ': ' ut ]) %will break if more than one twi match per cruise
        % Let's offer a fix if the field is blank:
        %this is empty
        s = input('Please enter a line for this voyage: ','s');
        line = str10;
        line(1:length(s)) = s;
        twi(ib==a,:) = repmat(line,sum(ib==a),1);
        fixed_twi(ib == a) = 1;
    end
end

%redisplay the filled values for checking:
if sum(fixed_twi) > 0
    disp('Fixed TWI values are: ')
    [c,ia,ib]= unique(crid,'rows');
    for a  =1:length(c)
        disp([num2str(a) '; ' c(a,:) ': ' unique(twi(ib==a,:),'rows')]) %will break if more than one twi match per cruise
    end
end
return
%% Q_pos fix - some files have empty Q_Pos, which is interesting. I think somehow the stuff above has mucked it up.
% need to check maybe.
disp('Checking Q_Pos values')
for aa=1:size(stn,1)
    for bb = 1:2
        stnn = stn(aa);
        raw=bb-1;
        filen=getfilename(num2str(stnn),raw);
        filenam=[prefix '/' filen];
        %read the Q_Pos
        qp=ncread(filenam,'Q_Pos');
        if ~isstrprop(qp,'alphanum')
            disp([num2str(aa) '; fixing ' filenam])
            ncwrite(filenam,'Q_Pos','1')
        end
    end
end
%% now write TWI and CSID fixes to the files. And check the datestring formats
disp('Checking datestrings and updating TWI and CSID values to the files that need it')
for aa=1:size(stn,1)
    for bb = 1:2
        stnn = stn(aa);
        raw=bb-1;
        filen=getfilename(num2str(stnn),raw);
        filenam=[prefix '/' filen];
        %read the surface parms
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        nsrfc = ncread(filenam,'Nsurfc');
        
        if fixed_twi(aa)
            disp(['TWI update: ' num2str(aa) ', ' num2str(stn(aa)) ', ' crid(aa,:)])
            kk=strmatch('TWI#',srfccodes');
            if isempty(kk)
                %need to add TWI to the srfcparms
                disp('adding TWI#')
                srfccodes(1:4,nsrfc+1) = 'TWI#';
                kk = nsrfc+1;
                ncwrite(filenam,'Nsurfc',nsrfc+1);
            end
            
            %add the updated line information:
            line = twi(aa,:);
            srfcparm(:,kk) = str10';
            srfcparm(1:length(line),kk) = line;
            ncwrite(filenam,'SRFC_Parm',srfcparm);
            ncwrite(filenam,'SRFC_Code',srfccodes);
        end
        %update CSID if required
        if fixed_csid(aa)
            disp(['CSID update: ' num2str(aa) ', ' num2str(stn(aa)) ', ' crid(aa,:)])
            kk=strmatch('CSID',srfccodes');
            if isempty(kk)
                %need to add CSID to the srfcparms
                disp('adding CSID')
                srfccodes(1:4,nsrfc+1) = 'CSID';
                kk = nsrfc+1;
                ncwrite(filenam,'Nsurfc',nsrfc+1);
            end
            %add the CSID update
            csid=num2str(stnn);
            srfcparm(:,kk)=str10';
            srfcparm(1:length(csid),kk) = csid;
            ncwrite(filenam,'SRFC_Parm',srfcparm);
            ncwrite(filenam,'SRFC_Code',srfccodes);
        end
        
        %now check and fix date strings if required:
        %read the prcdate, update and nsurfc fields
        prcdate = ncread(filenam,'PRC_Date');
        update = ncread(filenam,'Up_date');
        nhists = ncread(filenam,'Num_Hists');
        [prcdate,update, changed] = reformatdates_util(nhists,prcdate,update);
        if changed(1)
            ncwrite(filenam,'Up_date',update);
        end
        if changed(2)
            ncwrite(filenam,'PRC_Date',prcdate);
        end

    end
end

return



