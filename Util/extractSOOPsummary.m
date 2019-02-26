function [dat,alldat] = extractSOOPsummary(yr,pref,kd);
%    function dat = extractSOOPsummary(yr,pref);
% replaces the fortran code to extract yearly summary information for SOOP
% reporting purposes. Will create the same text file as the original
% 'extractSOOPMQNC64' fortran, to 'outputf'. Adds to existing file if
% available.
% dat.line
% dat.sections
% dat.callsign
% dat.count_total
% dat.count_good
% Bec Cowley, March 2014

%ship callsigns for each line, number of drops for each ship for this year
ti = datenum(kd.year,kd.month,kd.day,...
    floor(kd.time/100),rem(kd.time/100,1)*100,repmat(0,length(kd.year),1));
% include the next years' info because
%the l'astrolabe sometimes goes into the next year.
iyr=find(kd.year>=yr & kd.year < yr + 1);

flds = fieldnames(kd);
%subset

for a = 1:length(flds)
    eval(['d = kd.' flds{a} ';'])
    [m,n]=size(d);
    if m ~= length(ti) & n ~= length(ti)
        continue
    end
    if ischar(d)
        d = d(iyr,:);
    else
        d = d(iyr);
    end
    eval(['kd.' flds{a} ' = d;'])
end
    
%fill in the source first
alldat.source = kd.datasource;
alldat.ti = ti(iyr);

[alldat.calls,alldat.line,alldat.crid,alldat.ship,alldat.probet,alldat.rct,alldat.rctn,alldat.serial,alldat.mfd] ...
    = deal(repmat('          ',length(alldat.ti),1));
[alldat.good,alldat.bad,dup_test,alldat.max,alldat.height] = deal(zeros(length(alldat.ti),1)); 
[alldat.lat,alldat.lon,alldat.ac,alldat.bc] = deal(NaN*zeros(length(alldat.ti),1));

for a = 1:length(alldat.ti)
    a
    %only XBTs
    if isempty(strmatch('XB',kd.datatype(a,:)))
        continue
    end
    
    raw=0;
    filen=getfilename(num2str(kd.stnnum(a)),raw);
    filenam=[pref '/' filen];
%     nc=netcdf(filenam,'nowrite');
    
    %don't include test probes and duplicate flags:
    qccode = ncread(filenam,'Act_Code')';
    ibad = strmatch('TP',qccode(:,:)); %test probe
    ibad2 = strmatch('DU',qccode(:,:)); %DUR flag
    if ~isempty(ibad) | ~isempty(ibad2)
        dup_test(a) = 1;
        continue
    end
    alldat.lat(a) = ncread(filenam,'latitude');
    alldat.lon(a) = ncread(filenam,'longitude');
    
    alldat.crid(a,:) = ncread(filenam,'Cruise_ID');
    srfccode=ncread(filenam,'SRFC_Code')';
    srfcparm=ncread(filenam,'SRFC_Parm')';
    qflags = squeeze(ncread(filenam,'ProfQP'));
    deps = ncread(filenam,'Depthpress');
    deps = deps(:);
    ndeps = ncread(filenam,'No_Depths');
    qflags(ndeps+1:end) = '0';
    qflags = str2num(qflags);
    
    kk=strmatch('GCLL',srfccode(:,:)); % callsign
    mm=strmatch('TWI#',srfccode(:,:)); %line label
    nn = strmatch('SHP#',srfccode(:,:)); %ship name
    oo = strmatch('PEQ$',srfccode(:,:));%probe type
    pp = strmatch('RCT$',srfccode(:,:));%recorder type
    qq = strmatch('HTL$',srfccode(:,:));%launch height
    rr = strmatch('SER#',srfccode(:,:));%serial number
    ss = strmatch('MFD#',srfccode(:,:));%manufacture date
    
    
%     close(nc)
    %record the information:
    if ~isempty(kk)
        alldat.calls(a,:) = srfcparm(kk,:);
    end
    if ~isempty(mm)
        alldat.line(a,:) = srfcparm(mm,:);
    end
    if ~isempty(nn)
        alldat.ship(a,:) = srfcparm(nn,:);
    end
    if ~isempty(oo)
        pt = srfcparm(oo,:);
        alldat.probet(a,:) = pt;
        pt = str2num(pt);
        if pt == 2 | pt == 32 | pt == 42 | pt == 52 ...
                | pt == 202 | pt == 212 | pt == 222 | pt == 252
            alldat.ac(a) = 6.691;
            alldat.bc(a) = -2.25;
        elseif pt == 1 | pt == 31 | pt == 41 | pt == 51 ...
                | pt == 201 | pt == 211 | pt == 221 | pt == 251
            alldat.ac(a) = 6.472;
            alldat.bc(a) = -2.16;
        elseif pt == 11
            alldat.ac(a) = 6.828;
            alldat.bc(a) = -1.82;
        elseif pt == 21
            alldat.ac(a) = 6.346;
            alldat.bc(a) = -1.82;
        elseif pt == 61
            alldat.ac(a) = 6.301;
            alldat.bc(a) = -2.16;
        elseif pt == 71
            alldat.ac(a) = 1.779;
            alldat.bc(a) = -0.255;
        end            
    end
    if ~isempty(pp)
        alldat.rct(a,:) = srfcparm(pp,:);
        if str2num(srfcparm(pp,:)) == 71;
            alldat.rctn(a,:) = 'Devil     ';
        elseif  str2num(srfcparm(pp,:)) == 72;
            alldat.rctn(a,:) = 'Quoll     ';
        end
    end
    if ~isempty(qq)
        try
            alldat.height(a,:) = str2num(srfcparm(qq,:));
        catch
            alldat.height(a,:) = [];
        end            
    end
    if ~isempty(rr)
        alldat.serial(a,:) = srfcparm(rr,:);
    end
    if ~isempty(ss)
        alldat.mfd(a,:) = srfcparm(ss,:);
    end
    
%     if ~isempty(ibad) | ~isempty(ibad2)
%         %no good data past 100m
%         alldat.bad(a) = 1;
%         alldat.max(a) = 0;
%     else
        %check for good data to at least 100m
        ibad = (qflags > 2 &  qflags < 5) & deps < 100;
        if sum(ibad)~=0
            alldat.bad(a) = 1;
            alldat.good(a) = 0;
        else
            alldat.good(a) = 1;
        end
        %max depth of good data:
        ibad = (qflags > 2 &  qflags < 5);
        if sum(ibad) < length(qflags)
            alldat.max(a) = max(deps(~ibad))/10;
        else
            alldat.max(a) = NaN;
        end
        if isnan(alldat.max(a))
            alldat.max(a) = 0;
        end
%     end
    
    
end

%clean up empty cruise ids that are there from test probes:
idel = isnan(alldat.bc);
flds = fieldnames(alldat);
for b = 1:length(flds)
    if ischar(alldat.(flds{b}))
        alldat.(flds{b})(idel,:) = [];
    else
        alldat.(flds{b})(idel) = [];
    end
end
% start summarizing:

%get unique callsigns:
[callsign,ii,jj] = unique(alldat.calls,'rows');
dat.callsign = [];
dat.line = [];dat.sections = [];
dat.ship = [];dat.count_total = [];
dat.count_good = [];
%what line does each ship do? Assumes that one ship is on one line!!!
for b = 1:length(ii)
    %how many sections in each line for each ship?
    iship = find(jj == b);
    uship = unique(alldat.ship(iship,:),'rows');
    [uline,ia,ib] =  unique(alldat.line(iship,:),'rows');
    calls = callsign(b,:);
    
    %quick fix for missing lines. Will fall over if two different lines are
    %found.
    
  if size(uline,1) ~= size(uship,1)
    % which is greater than 1?
    if size(uline,1) > 1
      disp(['More than one line for this ship: ' uship ])
      disp(uline)
      ans = input('Did this ship do all lines? (y/n)','s');
      if ~isempty(strmatch('y',ans))
        uship = repmat(uship,size(uline,1),1);
        calls = repmat(callsign(b,:),size(uline,1),1);
      else
        mline = input('Enter the correct line: ','s');
        ml = '          ';
        ml(1:length(mline)) = mline;
        mline = ml;
        iline = input('Enter the number this line replaces (eg, 1 or 2): ');
        %put the correct line in the original data:
        ifix = strmatch(uline(iline,:),alldat.line(iship,:));
        alldat.line(iship(ifix),:) = repmat(mline,length(ifix),1);
        uline = unique(alldat.line(iship,:),'rows');
        if size(uline,1) ~= size(uship,1)
          disp('Still not the right number of lines for callsigns!')
          return
        end
      end
    else
      disp(['Check your database! Multiple ship names for this callsign: ' calls ]);
    end
  end
        
    dat.callsign = [dat.callsign;calls];
    dat.line = [dat.line ; uline];
    dat.ship = [dat.ship;uship];

    %subset by ship:
    for c = 1:size(uline,1)
        kk = iship(ib == c);
        cr = alldat.crid(kk,:);
        gd = alldat.good(kk);
        bd = alldat.bad(kk);
        voy = unique(cr,'rows');
        dat.sections(end+1) = size(voy,1);
        dat.count_total(end+1) = sum(gd) + sum(bd);
        dat.count_good(end+1) = sum(gd);
    end
        
end

    




% 
% lin = {'PX30','PX34','IX28'};
% ll = [153,180,-28,-16;
%     150,175,-42,-33;
%     135,155,-70,-43];
%     
% for a = 1:length(lin)
%     jj = find((lat > ll(a,3) & lat < ll(a,4)) & (lon > ll(a,1) & lon < ll(a,2)));
%     cc = unique(calls(jj,:),'rows');
%     disp([lin{a}])
%     for b = 1:size(cc,1)
%         kk = strmatch(cc(b,:),calls);
%         disp([cc(b,:) ': ' num2str(length(kk))])
%     end
% end
