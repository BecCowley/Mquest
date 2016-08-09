function nc = getMQschema(profiledata,filn)
% create the netcdf schema for MQuest files.
% Bec Cowley, May 2016

% load up the blank netcdf schema from mat file:

if exist('blank_nc.mat','file')
    load blank_nc.mat
    nc = ncblank;
    %fill in the max/min data information from the profiledata structure
    nc.Variables(1).Attributes(3).Value = profiledata.woce_date;
    nc.Variables(1).Attributes(4).Value = profiledata.woce_date;
    nc.Variables(2).Attributes(3).Value = profiledata.woce_time;
    nc.Variables(2).Attributes(4).Value = profiledata.woce_time;
    nc.Variables(3).Attributes(3).Value = profiledata.time;
    nc.Variables(3).Attributes(4).Value = profiledata.time;
    nc.Dimensions(8).Length = profiledata.No_Depths;
    nc.Variables(52).Dimensions(1).Length = profiledata.No_Depths;
    nc.Variables(52).Size(1) = profiledata.No_Depths;
    nc.Variables(53).Dimensions(3).Length = profiledata.No_Depths;
    nc.Variables(53).Size(3) = profiledata.No_Depths;
    nc.Variables(54).Dimensions(2).Length = profiledata.No_Depths;
    nc.Variables(54).Size(2) = profiledata.No_Depths;
    nc.Variables(55).Dimensions(4).Length = profiledata.No_Depths;
    nc.Variables(55).Size(4) = profiledata.No_Depths;
    return
else
    disp('Unable to make the netcdf file from scratch, need to do more coding here')
    return
end
    %make it from scratch. This needs to be developed, but shouldn't be
    %needed if the blank_nc.mat file is available.
    
no_depths = profiledata.No_Depths;

%Dimensions
dimnames = {'N_Prof','Nparms','Nsurfc','Num_Hists','time','latitude',...
    'longitude','depth','String_1','String_2','String_4','String_5'...
    'String_6','String_8','String_10','String_12','String_16','String_250'};

dimlen = [0,30,30,100,1,1,1,no_depths,1,2,4,5,6,8,10,12,16,250];

dimunlim = logical([1,zeros(1,length(dimnames) - 1)]);

for a = 1:length(dimnames)
    dims(:,:,a) = {dimnames{a};dimlen(a);dimunlim(a)};
end

flds = {'Name'
    'Length'
    'Unlimited'};

nc.Dimensions = cell2struct(dims,flds);

%%% OK UP TO HERE. NEEDS WORK.
%Variables

varnames = { 'woce_date'    'woce_time'    'time'    'latitude'    'longitude' ...
    'Num_Hists'    'No_Prof'    'Nparms' ...
    'Nsurfc'    'Mky'    'One_Deg_Sq'    'Cruise_ID'    'Data_Type'   ...
    'Iumsgno'    'Stream_Source'    'Uflag' ...
    'MEDS_Sta'    'Q_Pos'    'Q_Date_Time'    'Q_Record'    'Up_date'  ...
    'Bul_Time'    'Bul_Header' ...
    'Source_ID'    'Stream_Ident'    'QC_Version'    'Data_Avail'  ...
    'Prof_Type'    'Dup_Flag'    'Digit_Code' ...
    'Standard'    'Deep_Depth'    'PreDropComments'    'PostDropComments'  ...
    'Pcode'    'Parm'    'Q_Parm' ...
    'SRFC_Code'    'SRFC_Parm'    'SRFC_Q_Parm'    'Ident_Code'   ...
    'PRC_Code'    'Version'    'PRC_Date' ...
    'Act_Code'    'Act_Parm'    'Aux_ID'    'Previous_Val'   ...
    'Flag_severity'    'D_P_Code'    'No_Depths' ...
    'Depthpress'    'Profparm'    'DepresQ'    'ProfQP'};

vardimsize = [ 1   1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     2     2     2     2     1     1     1 ...
     2     2     2     2     2     2     2     2     2     2     2     2 ...
     1     2     1     2     1     2     5     3     6];

 vardt = {'int32','int32','single','single','single','int32',...
     'int32','int32','int32','char','char','char','char','char',...
     'char','char','char','char','char','char','char','char','char',...
     'char','char','char','char','char','char','char','char','single',...
     'char','char','char','char','char','char','char','char','char',...
     'char','char','char','char','char','single','char','int32','char',...
     'int32','single','single','char','char'};

vardimnames = {'time','time','time','latitude','longitude',...
    'time','time','time','time','String_8','String_8',...
    'String_10','String_2','String_12','String_1','String_1',...
    'String_8','String_1','String_1','String_1','String_8',...
    'String_12','String_6','String_4','String_4','String_4',...
    'String_1','String_16','N_Prof','String_1','N_Prof','String_1',...
    'N_Prof','String_1','N_Prof','N_Prof','String_250','String_250',...
    'String_4','Nparms','String_10','Nparms','String_1',...
    'Nparms','String_4','Nsurfc','String_10','Nsurfc',...
    'String_1','Nsurfc','String_2','Num_Hists','String_4',...
    'Num_Hists','String_4','Num_Hists','String_8','Num_Hists',...
    'String_2','Num_Hists','String_4','Num_Hists','Num_Hists',...
    'String_10','Num_Hists','Num_Hists','String_1','N_Prof',...
    'N_Prof','depth','N_Prof','longitude','latitude','depth',...
    'time','N_Prof','String_1','depth','N_Prof','String_1',...
    'longitude','latitude','depth','time','N_Prof'};

varattlen = [4     4     4     8     8     0     0     0     0     0     ...
    0     0     0     0     0     0     0     0 ...
    0     0     0     0     0     0     0     0     0     0 ...
    0     0     0     0     0     0     0     0 ...
    0     0     0     0     0     0     0     0     0  ...
    0     0     0     0     0     0     1     1   0  0];

varattname = {'long_name','units','data_min','data_max','long_name',...
    'units','data_min','data_max','long_name','units','data_min',...
    'data_max','long_name','units','valid_min','valid_max','C_format',...
    'FORTRAN_format','data_min','data_max','long_name','units',...
    'valid_min','valid_max','C_format','FORTRAN_format','data_min',...
    'data_max','_FillValue','_FillValue'};

varattval = {'date'    'yyyymmdd UTC'    profiledata.woce_date    profiledata.woce_date   ...
    'time of day'    'hhmmss'    profiledata.woce_time    profiledata.woce_time ...
    'time'    'days since 1900-01-01 00:00:00'     profiledata.time    profiledata.time    ...
    'latitude'    'degrees_N'    -90    90 ...
    '%8.4f'    'F8.4'    -60    -60    'longitude'    '360degrees_E'  ...
    0    360    '%9.4f'    'F9.4' ...
    190    190    -99.99    -99.99};

flds = { 'Name'
    'Dimensions'
    'Size'
    'Datatype'
    'Attributes'
    'ChunkSize'
    'FillValue'
    'DeflateLevel'
    'Shuffle'};
for a = 1:length(varnames)
    dims(:,:,a) = {dimnames{a};dimlen(a);dimunlim(a)};
end

clear nc
nc.Filename = filn;
nc.Name = '/';
nc.Format = 'classic';

%make the schema dimensions

for a = 1:length(dimnames)
    nc.Dimensions(a).Name = dimnames{a};
    nc.Dimensions(a).Length = dimlen(a);
    nc.Dimensions(a).Unlimited = dimunlim(a);
end

%Make the schema variables
x = 1;
y = 1;
for a =1:length(varnames)
    nc.Variables(a).Name = varnames{a};
    for b = 1:vardimsize(a);
        nc.Variables(a).Dimensions(b).Name = vardimnames{x};
        ii = find(strcmp(vardimnames{x},dimnames)==1);
        nc.Variables(a).Dimensions(b).Length = dimlen(ii);
        nc.Variables(a).Dimensions(b).Unlimited = dimunlim(ii);
        nc.Variables(a).Size(b) = dimlen(ii);
        x = x+1;
    end
    nc.Variables(a).Datatype = vardt{a};
    for b = 1:varattlen(a)
        nc.Variables(a).Attributes(b).Name = varattname{y};
        nc.Variables(a).Attributes(b).Value = varattval{y};
        y = y+1;
    end
    nc.Variables(a).FillValue = [];
end

end