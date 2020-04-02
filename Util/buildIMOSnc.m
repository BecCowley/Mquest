clear
nc = getIMOSnc_schema;

%add the _ADJUSTED fields:
fldn = {'DEPTH','TEMP'};
ii = NaN*ones(1,length(fldn));
jj = ii;
for a = 1:length(fldn)
    for b = 1:length(nc.Variables)
        i = strmatch(nc.Variables(b).Name,fldn{a},'exact');
        if ~isempty(i)
            ii(a) = b;
        end
        j = strmatch(nc.Variables(b).Name,[fldn{a} '_quality_control'],'exact');
        if ~isempty(j)
            jj(a) = b;
        end
    end
end
nc.Dimensions.Length = 0;

if ~isempty(ii)
    for a = 1:length(fldn)
        %found a match
        var = nc.Variables(ii(a));
        var.Dimensions.Length = 0;
        var.Size = 0;
        nc.Variables(ii(a)) = var;
        var.Name = [fldn{a} '_ADJUSTED'];
        nc.Variables(end+1) = var;
    end
end

if ~isempty(jj)
    for a = 1:length(fldn)
        %found a match
        var = nc.Variables(jj(a));
        var.Dimensions.Length = 0;
        var.Size = 0;
        nc.Variables(jj(a)) = var;
        var.Name = [fldn{a} '_ADJUSTED_quality_control'];
        nc.Variables(end+1) = var;
    end
end

%tidy up the Attributes, put some of it into a new HISTORY variable set
%add some dimensions:
dims = {'N_HISTORY','STRING2','STRING4','STRING16','DATE_TIME'};
dimlen = [0,2,4,16,64,14];
dimunlim = [1,0,0,0,0,0];
for a = 1:length(dims)
    nc.Dimensions(end+1).Name = dims{a};
    nc.Dimensions(end).Length = dimlen(a);
    nc.Dimensions(end).Unlimited = logical(dimunlim(a));
end

varns = {'HISTORY_INSTITUTION','HISTORY_STEP','HISTORY_SOFTWARE',...
    'HISTORY_SOFTWARE_RELEASE','HISTORY_DATE',...
    'HISTORY_PARAMETER','HISTORY_START_DEPTH',...
    'HISTORY_STOP_DEPTH','HISTORY_PREVIOUS_VALUE','HISTORY_QCTEST'};
vardims = [4,2;4,2;5,2;5,2;6,2;5,2;2,NaN;2,NaN;2,NaN;3,2];
vardtypes = {'char','char','char','char','char','char','single','single','single','char'};
attlname = {'Institution which performed action','Step in data processing',...
    'Name of software which performed action','Version/Release of software which performed action',...
    'Date the history record was created',...
    'Parameter that action is performed on',...
    'Start depth action applied to','End depth action applied to',...
    'Parameter/Flag previous value before action','QC test performed'};
    
attconv = {'GTSPP IDENT_CODE table','GTSPP PRC_CODE table','Institution dependent',...
    'Institution dependent','yyyymmddHHMMSS',...
    'GTSPP PC_PROF table','m','m','','GTSPP ACT_CODE table and CSIRO XBT Cookbook'};
attfills = {' ',' ',' ',' ',' ',' ',' ','99999','99999','99999',' '};

for a = 1:length(varns)
    var.Name = varns{a};
    var.Datatype = vardtypes{a};
    var.FillValue = [];
    %dimensions
    for b = 1:2
        if isnan(vardims(a,b))
            try
                var.Dimensions(b) = [];
            catch
            end
        else
            var.Dimensions(b) = nc.Dimensions(vardims(a,b));
        end
    end
    %attributes
    var.Attributes = [];
    var.Attributes(1).Name = 'long_name';
    var.Attributes(1).Value = attlname{a};
    var.Attributes(2).Name = 'Conventions';
    var.Attributes(2).Value = attconv{a};
    var.Attributes(3).Name = '_FillValue';
    var.Attributes(3).Value = attfills{a};
    
    %assign to nc:
    nc.Variables(end+1) = var;
end

%% tidy the global attributes:
atts = 'history';
for a = 1:length(nc.Attributes)
    if ~isempty(strfind(atts,nc.Attributes(a).Name))
        nc.Attributes(a).Value = [];
        break
    end
end

%% test the file by writing it out:
ncwriteschema('test.nc',nc)

%% read in the data and output to the sample file
atts = 'XBT_input_filename';
for a = 1:length(nc.Attributes)
    if ~isempty(strfind(atts,nc.Attributes(a).Name))
        break
    end
end

fn = ['/Volumes/UOT-data/quest/antarctic/' nc.Attributes(a).Value];
nco = ncinfo(fn);
%add the data and move the qc codes to the new histories fields. 
temp = squeeze(ncread(fn,'Profparm'));
depth = squeeze(ncread(fn,'Depthpress'));
tempqc = squeeze(ncread(fn,'ProfQP'));
depthqc = squeeze(ncread(fn,'DepresQ'));

%get previous values to restore raw data:
nhists = ncread(fn,'Num_Hists');
histdate = ncread(fn,'PRC_Date')';
actc = ncread(fn,'Act_Code')';
actp = ncread(fn,'Act_Parm')';
auxid = ncread(fn,'Aux_ID');
prevv = ncread(fn,'Previous_Val');
prevv = str2num(prevv');
inst = ncread(fn,'Stream_Ident')';
inst = inst(1:2);
ver = ncread(fn,'Version')';

tempraw = temp; depthraw = depth;
for a = 1:nhists
    if contains('TEMP',actp(a,:))
        ii = find(depth==auxid(a));
        if isempty(ii)
            disp('PROBLEM!!')
            keyboard
        end
        tempraw(ii) = prevv(a);
    else
        %contains DEPH, not coded
        disp('contains depth in act parm')
        keyboard
    end
end
%write data
ncwrite('test.nc','DEPTH',depthraw)
ncwrite('test.nc','TEMP',tempraw)
ncwrite('test.nc','DEPTH_ADJUSTED',depth)
ncwrite('test.nc','TEMP_ADJUSTED',temp)
ncwrite('test.nc','DEPTH_ADJUSTED_quality_control',str2num(depthqc'))
ncwrite('test.nc','TEMP_ADJUSTED_quality_control',str2num(tempqc))
ncwrite('test.nc','DEPTH_quality_control',0*str2num(depthqc'))
ncwrite('test.nc','TEMP_quality_control',0*str2num(tempqc))

cb = 'CSCB'; sw = 'Mquest';
%write HISTORIES:
vdat = {'inst','cb','sw','ver','histdate','actp','auxid','max(depth)','prevv','actc'};
for a = 1:length(varns)
    eval(['dat = ' vdat{a} ';'])
    %constants:
    if size(dat,1) == 1
        ncwrite('test.nc',varns{a},repmat(dat',1,nhists))
    else
        %nhists
        ncwrite('test.nc',varns{a},dat(1:nhists,:)')
    end
    
end
%lat/long/date/time:


