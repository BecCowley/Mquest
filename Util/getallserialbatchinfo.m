% get all the batch and serial information I can from all our records and
% save it for a reference to enable me to fix serial/batch information and
% also to publish for future fall rate corrections.
% Bec Cowley, Jan 2024

clear
% let's use the existing filelist and add to it rather than search every
% time we make this file:
if exist('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/allprobeserialinfo.mat','file')
    load('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/allprobeserialinfo.mat','flist')
else
    % this will take ages due to the multiple folders in this directory
    flist = dir('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/**/*_keys.nc');
    % tidy up a few names we don't want
    ibad = [];
    for a = 1:length(flist)
        if matches(flist(a).name,'ArgoBuddyData_keys.nc') | ...
                matches(flist(a).name,'_keys.nc') | ...
                contains(flist(a).name,'test')
            ibad = [ibad,a];
        end
    end
    flist(ibad) = [];
    save('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/allprobeserialinfo.mat', ...
        'flist','-append');
end
% set up a master array of empty variables
[serial,batch,height,scale,offset,deploydate,...
    testprobe,database, uniqueid] = ...
        deal([]);
[recordertype,probetype,cruiseid] = deal({});
%%
for a = 1:length(flist)
    db = flist(a).name;
    prefix=db(1:length(db)-8);
    stnnum = str2num(ncread([flist(a).folder '/' db],'stn_num')');
    % get serial numbers and batch dates:
    [ser,bat,heig,sc,off,dd] = ...
        deal(NaN*ones(size(stnnum,1),1)); 
    [rect,prt,crid] = deal(repmat({''},size(stnnum,1),1));
    db = repmat({db},size(stnnum,1),1);
    tp = zeros(size(stnnum,1),1);
    for aa=1:size(stnnum,1)

        raw= 0;
        filen=getfilename(num2str(stnnum(aa)),raw);
        filenam=[flist(a).folder '/' prefix '/' filen];
        if ~exist(filenam,'file')
            continue
        end
        % check if there is any data in there
        dat = ncread(filenam, 'Profparm');
        if isempty(dat)
            continue
        end
        srfccodes=ncread(filenam,'SRFC_Code');
        srfccodes = convertCharsToStrings(cellstr(srfccodes'));
        srfcparm=ncread(filenam,'SRFC_Parm');
        qccode = ncread(filenam,'Act_Code');
        qccode = convertCharsToStrings(cellstr(qccode'));
        crid{aa} = ncread(filenam,'Cruise_ID')';
        % dd(aa) = double(datenum('1900-01-01 00:00:00') + ncread(filenam,'time'));
        try
            wd=num2str(ncread(filenam,'woce_date'));
        catch
            wd=num2str(ncread(filenam,'date'));
        end
        try
            wt=(ncread(filenam,'woce_time'));
        catch
            wt=(ncread(filenam,'time_of_day'));
        end
        wt=floor(wt/100);
        wt2=sprintf('%4i',wt);
        jk=strfind(wt2,' ');
        if(~isempty(jk))
            wt2(jk)='0';
        end
        ti=datenum([wd wt2],'yyyymmddHHMM');
        if ti > now
            keyboard
        else
            dd(aa) = ti;
        end

        kk=find(matches(srfccodes,'MFD#'));
        if(~isempty(kk))
            try
                bat(aa) = datenum(srfcparm(:,kk)','yyyymmdd');
            catch
                bat(aa) = datenum(srfcparm(:,kk)');
            end
        end

        kk=find(matches(srfccodes,'SER#'));
        if(~isempty(kk))
            try
                ser(aa) = str2num(srfcparm(:,kk)');
            catch
                ser(aa) = NaN;
            end
        end
        kk=find(matches(srfccodes,'HTL$'));
        if(~isempty(kk))
            hh = str2num(srfcparm(:,kk)');
            if ~isempty(hh)
                heig(aa) = hh;
            end
        end
        kk=find(matches(srfccodes,'PEQ$') | matches(srfccodes,'PTYP'));
        if(~isempty(kk))
            pt = srfcparm(:,kk)';
            prt{aa} = pt;
        end
        kk=find(matches(srfccodes,'RCT$') | matches(srfccodes,'SYST'));
        if(~isempty(kk))
            rct = srfcparm(:,kk)';
            rect{aa} = rct;
        end
        % extract scale and offset information for probe types:
        kk=find(matches(srfccodes,'SCAL'));
        if(~isempty(kk))
            sc(aa) = str2num(srfcparm(:,kk)');
        end

        kk=find(matches(srfccodes,'OFFS'));
        if(~isempty(kk))
            value = str2num(srfcparm(:,kk)');
            if ~isempty(value)
                off(aa) = value;
            end
        end
        % is it a test probe?
        kk=find(matches(qccode,'TP'));
        if(~isempty(kk))
            tp(aa) = 1;
        end

    end
    %add the information to the master array
    serial = [serial;ser];
    testprobe = [testprobe;tp];
    scale = [scale;sc];
    offset = [offset;off];
    probetype = [probetype;prt];
    recordertype = [recordertype;rect];
    height = [height;heig];
    batch = [batch;bat];
    deploydate = [deploydate;dd];
    cruiseid = [cruiseid;crid];
    database = [database;db];
    uniqueid = [uniqueid;stnnum];
end

% tidy up extra characters in probetype array
p = probetype;
p = strrep(p,'T- 4','2   ');
p = strrep(p,'T- 5','11  ');
p = strrep(p,'T- 7','42  '); % really need to check if corrections applied, but for now use 42
% tidy up extra characters in recordertype array
rt = NaN*ones(size(recordertype));
pt = rt;
for a = 1:length(recordertype)
    if ~isempty(recordertype{a})
        if ~isempty(str2num(recordertype{a}(1:2)))
            rt(a) = str2num(recordertype{a}(1:2));
        end
    end
    if ~isempty(p{a})
        if ~isempty(str2num(p{a}(1:3)))
            if size(p{a},1) > 1
                for b = 1:size(p{a},1)
                    tt = str2num(p{a}(b,:));
                    if ~isempty(tt)
                        pt(a) = str2num(p{a}(b,:));
                        continue
                    end
                end
            end
            pt(a) = str2num(p{a}(1:3));
        end
    end
end

probetype = pt;
recordertype = rt;

% clean up empty or skipped records where the file doesn't exist or there
% is no data in the file
im = isnan(deploydate);
serial(im) = [];
testprobe(im)=[];
scale(im)=[];
offset(im)=[];
probetype(im)=[];
recordertype(im)=[];
height(im)=[];
batch(im)=[];
deploydate(im)=[];
cruiseid(im)=[];
database(im)=[];
uniqueid(im) = [];

save('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/allprobeserialinfo.mat', ...
    'testprobe','serial','scale','offset','probetype','recordertype','height','batch',...
    'deploydate','cruiseid','database','uniqueid','-append')
return
%% load the file rather than recreating it
clear
load('/oa-decadal-climate/work/observations/oceanobs_data/UOT-data/quest/allprobeserialinfo.mat')

%% now plot this information
figure(1);clf
plot(batch,serial,'ko')
datetick('x','mm/yy')
grid
title( ...
    'All serial and batch information')

figure(2);clf;hold on
uu = unique(probetype(~isnan(probetype)));
cc = jet(length(uu));
for a = 1:length(uu)
    jj = find(probetype == uu(a)); 
    plot(batch(jj),serial(jj),'.','MarkerSize',14,'Color',cc(a,:))
end
datetick('x','mm/yyyy')
grid on
legend(num2str(uu),'location','best')
title('Batch vs serial by probe type')

figure(3);clf;hold on
plot(deploydate,serial,'.','MarkerSize',14)
grid on
datetick('x','mm/yyyy')

%% let's look at serial numbers for each probe type, regardless of if there
% is a batch date associated or not
figure(7);clf;hold on
leg = [];
for a =1:length(uu)
    jj = find(probetype == uu(a) & ~isnan(serial));
    if ~isempty(jj)
        plot(deploydate(jj),serial(jj),'.','MarkerSize',14,'Color',cc(a,:))
        disp(uu(a))
        % pause
        leg = [leg;uu(a)];
    end
end  
title('Serial vs deploy date by probetype')
datetick('x','mm/yyyy')
grid on
legend(num2str(leg),'location','westoutside')

%% focus on the scale and offset information

figure(4);clf
plot(deploydate,scale,'.','MarkerSize',14)
title('Scale values by date')
datetick('x','mm/yyyy')
grid on

figure(5);clf
plot(deploydate,offset,'.','MarkerSize',14)
title('Offset values by date')
datetick('x','mm/yyyy')
grid on

figure(6);clf
plot(scale,offset,'.','MarkerSize',14)
title('scale vs offset')
xlabel('scale')
ylabel('offset')
grid on

figure(8);clf;hold on
leg = [];
cc = hsv(12);aa=1;
for a =1:length(uu)
    jj = find(probetype == uu(a) & ~isnan(scale));
    if ~isempty(jj)
        plot(deploydate(jj),scale(jj),'.','MarkerSize',14,'Color',cc(aa,:))
        disp(uu(a))
        % pause
        leg = [leg;uu(a)];
        aa=aa+1;
    end
end  
title('Scale vs deploy date by probetype')
datetick('x','mm/yyyy')
grid on
legend(num2str(leg),'location','westoutside')

%% by recorder type
figure(10);clf;hold on
figure(9);clf;hold on
figure(11);clf;hold on
ii = find(~isnan(scale));
uc = unique(cell2mat(cruiseid(ii)),'rows');
ur = unique(recordertype(~isnan(recordertype)));
mr = {'+','o','*','.','x','square','diamond','diamond','diamond','v',...
    'v','^','<','<','<','<','>','>','>','>','pentagram'};
cc = hsv(length(uc));
for a =1:length(ur)
    disp(ur(a))
    jj = find(recordertype == ur(a) & ~isnan(scale));
    if ~isempty(jj)
        rr = unique(cell2mat(cruiseid(jj)),'rows');
        for aa = 1:size(rr,1)
            bb = strmatch(rr(aa,:),uc);
            jj = find(recordertype == ur(a) & ~isnan(scale) & contains(cruiseid,rr(aa,:)));
            figure(9)
            plot(deploydate(jj),scale(jj),'Marker',mr{a},'LineStyle','none','Color',cc(bb,:))
            figure(10)
            plot(deploydate(jj),offset(jj),'Marker',mr{a},'LineStyle','none','Color',cc(bb,:))
            figure(11)
            plot(scale(jj),offset(jj),'Marker',mr{a},'LineStyle','none','Color',cc(bb,:))
        end
    end
    pause
end  
figure(9)
title('Scale vs deploy date by cruiseid')
datetick('x','mm/yyyy')
grid on

figure(10)
title('Offset vs deploy date by cruiseid')
datetick('x','mm/yyyy')
grid on
figure(11)
title('Scale vs Offset by cruiseid')
grid on