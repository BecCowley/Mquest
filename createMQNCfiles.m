function createMQNCfiles(profiledata,filenamnew)

% createMQNCfile - creates empty file for filling by writeMQNCfiles
%
% usage:  createMQNCfiles(no_depths,filenamnew)
%       where:
%         no_depths contains the number of depths of the profile to be
%           stored. This is required to ensure that the dimensions of the
%           file are sufficient to hold the entire profile
%         filenamnew contains the complete filename of the file to be created.
%


no_depths=profiledata.ndep;

% convert no_depths to the closest 100
int_depth=((fix(no_depths/100))+1)*100;
if(length(int_depth)>1);
    %correct for missing no_depths from some two-profile file
    if(abs(int_depth(1)-int_depth(2))>1000)
        int_depth(2)=int_depth(1);
        no_depths(2)=no_depths(1);
    end
end

%create the empty netcdf file ready for writing data to

try
    newdatabasefile=netcdf([filenamnew ],'noclobber');
catch
    mkdir([filenamnew(1:length(filenamnew)-7)])
    newdatabasefile=netcdf([ filenamnew ],'clobber');
end
if(isempty(newdatabasefile))
    newdatabasefile=netcdf([ filenamnew ],'clobber');
end
if (~exist(filenamnew,'file'))
    mkdir([ filenamnew(1:length(filenamnew)-7)])
    newdatabasefile=netcdf([filenamnew],'clobber');
end


% create the dimensions
newdatabasefile('N_Prof')=0;
if isempty(newdatabasefile('N_Prof')), error('##Unable to create dimension N_Prof'),end
newdatabasefile('Nparms')=30;
if isempty(newdatabasefile('Nparms')), error('##Unable to create dimension Nparms'),end
newdatabasefile('Nsurfc')=30;
if isempty(newdatabasefile('Nsurfc')), error('##Unable to create dimension Nsurfc'),end
newdatabasefile('Num_Hists')=100;
if isempty(newdatabasefile('Num_Hists')), error('##Unable to create dimension Num_Hists'),end
newdatabasefile('time')=1;
if isempty(newdatabasefile('time')), error('##Unable to create dimension time'),end
newdatabasefile('latitude')=1;
if isempty(newdatabasefile('latitude')), error('##Unable to create dimension latitude'),end
newdatabasefile('longitude')=1;
if isempty(newdatabasefile('longitude')), error('#Unable to create dimension longitude'),end
newdatabasefile('depth')=max(int_depth);
if isempty(newdatabasefile('depth')), error('##Unable to create dimension depth'),end
newdatabasefile('String_1')=1;
if isempty(newdatabasefile('String_1')), error('##Unable to create dimension String_1'),end
newdatabasefile('Single')=1;
if isempty(newdatabasefile('Single')), error('##Unable to create dimension Single'),end
newdatabasefile('String_2')=2;
if isempty(newdatabasefile('String_2')), error('##Unable to create dimension String_2'),end
newdatabasefile('String_4')=4;
if isempty(newdatabasefile('String_4')), error('##Unable to create dimension String_4'),end
newdatabasefile('String_5')=5;
if isempty(newdatabasefile('String_5')), error('##Unable to create dimension String_5'),end
newdatabasefile('String_8')=8;
if isempty(newdatabasefile('String_8')), error('##Unable to create dimension String_8'),end
newdatabasefile('String_10')=10;
if isempty(newdatabasefile('String_10')), error('##Unable to create dimension String_10'),end
newdatabasefile('String_12')=12;
if isempty(newdatabasefile('String_12')), error('##Unable to create dimension String_12'),end
newdatabasefile('String_6')=6;
if isempty(newdatabasefile('String_6')), error('##Unable to create dimension String_6'),end
newdatabasefile('String_16')=16;
if isempty(newdatabasefile('String_16')), error('##Unable to create dimension String_16'),end
newdatabasefile('String_250')=250;
if isempty(newdatabasefile('String_250')), error('##Unable to create dimension String_250'),end


% create the variables
newdatabasefile{'woce_date'}=nclong('Single');
newdatabasefile{'woce_date'}.long_name='date';
newdatabasefile{'woce_date'}.units='yyyymmdd UTC';
date1=profiledata.year*10000+profiledata.month*100+profiledata.day;
newdatabasefile{'woce_date'}.data_min=date1;
newdatabasefile{'woce_date'}.data_max=date1;

newdatabasefile{'woce_time'}=nclong('time');
newdatabasefile{'woce_time'}.long_name='time of day';
newdatabasefile{'woce_time'}.units='hhmmss';
newdatabasefile{'woce_time'}.data_min=profiledata.time;
newdatabasefile{'woce_time'}.data_max=profiledata.time;

newdatabasefile{'time'}=ncfloat('time');
ju=julian([profiledata.year profiledata.month profiledata.day ...
    floor(profiledata.time/100) rem(profiledata.time,100) 0])-2415020.5;
newdatabasefile{'time'}.long_name='time of day';
newdatabasefile{'time'}.units='days since 1900-01-01 00:00:00';
newdatabasefile{'time'}.data_min=ju;
newdatabasefile{'time'}.data_max=ju;

newdatabasefile{'latitude'}=ncfloat('latitude');
newdatabasefile{'latitude'}.long_name='latitude';
newdatabasefile{'latitude'}.units='degrees_N';
newdatabasefile{'latitude'}.valid_min=ncfloat(-90.);
newdatabasefile{'latitude'}.valid_max=ncfloat(90.);
newdatabasefile{'latitude'}.C_format='%8.4f';
newdatabasefile{'latitude'}.FORTRAN_format='F8.4';
newdatabasefile{'latitude'}.data_min=ncfloat(profiledata.latitude);
newdatabasefile{'latitude'}.data_max=ncfloat(profiledata.latitude);

newdatabasefile{'longitude'}=ncfloat('longitude');
newdatabasefile{'longitude'}.long_name='longitude';
newdatabasefile{'longitude'}.units='360degrees_E';
newdatabasefile{'longitude'}.valid_min=ncfloat(0.);
newdatabasefile{'longitude'}.valid_max=ncfloat(360.);
newdatabasefile{'longitude'}.C_format='%9.4f';
newdatabasefile{'longitude'}.FORTRAN_format='F9.4';
newdatabasefile{'longitude'}.data_min=ncfloat(profiledata.longitude);
newdatabasefile{'longitude'}.data_max=ncfloat(profiledata.longitude);

newdatabasefile{'Num_Hists'}=nclong('Single');
newdatabasefile{'No_Prof'}=nclong('Single');
newdatabasefile{'Nparms'}=nclong('Single');
newdatabasefile{'Nsurfc'}=nclong('Single');
newdatabasefile{'Mky'}=ncchar('String_8');
newdatabasefile{'One_Deg_Sq'}=ncchar('String_8');
newdatabasefile{'Cruise_ID'}=ncchar('String_10');
newdatabasefile{'Data_Type'}=ncchar('String_2');
newdatabasefile{'Iumsgno'}=ncchar('String_12');
newdatabasefile{'Stream_Source'}=ncchar('String_1');
newdatabasefile{'Uflag'}=ncchar('String_1');
newdatabasefile{'MEDS_Sta'}=ncchar('String_8');
newdatabasefile{'Q_Pos'}=ncchar('String_1');
newdatabasefile{'Q_Date_Time'}=ncchar('String_1');
newdatabasefile{'Q_Record'}=ncchar('String_1');
newdatabasefile{'Up_date'}=ncchar('String_8');
newdatabasefile{'Bul_Time'}=ncchar('String_12');
newdatabasefile{'Bul_Header'}=ncchar('String_6');
newdatabasefile{'Source_ID'}=ncchar('String_4');
newdatabasefile{'Stream_Ident'}=ncchar('String_4');
newdatabasefile{'QC_Version'}=ncchar('String_4');
newdatabasefile{'Data_Avail'}=ncchar('String_1');
newdatabasefile{'Prof_Type'}=ncchar('N_Prof','String_16');
newdatabasefile{'Dup_Flag'}=ncchar('N_Prof','String_1');
newdatabasefile{'Digit_Code'}=ncchar('N_Prof','String_1');
newdatabasefile{'Standard'}=ncchar('N_Prof','String_1');
newdatabasefile{'Deep_Depth'}=ncfloat('N_Prof');
if isfield(profiledata,'comments_pre')
    newdatabasefile{'PreDropComments'}=ncchar('String_250');
end
if isfield(profiledata,'comments_post')
    newdatabasefile{'PostDropComments'}=ncchar('String_250');
end
newdatabasefile{'Deep_Depth'}=ncfloat('N_Prof');
newdatabasefile{'Deep_Depth'}=ncfloat('N_Prof');
newdatabasefile{'Pcode'}=ncchar('Nparms','String_4');
newdatabasefile{'Parm'}=ncchar('Nparms','String_10');
newdatabasefile{'Q_Parm'}=ncchar('Nparms','String_1');
newdatabasefile{'SRFC_Code'}=ncchar('Nsurfc','String_4');
newdatabasefile{'SRFC_Parm'}=ncchar('Nsurfc','String_10');
newdatabasefile{'SRFC_Q_Parm'}=ncchar('Nsurfc','String_1');
newdatabasefile{'Ident_Code'}=ncchar('Num_Hists','String_2');
newdatabasefile{'PRC_Code'}=ncchar('Num_Hists','String_4');
newdatabasefile{'Version'}=ncchar('Num_Hists','String_4');
newdatabasefile{'PRC_Date'}=ncchar('Num_Hists','String_8');
newdatabasefile{'Act_Code'}=ncchar('Num_Hists','String_2');
newdatabasefile{'Act_Parm'}=ncchar('Num_Hists','String_4');
newdatabasefile{'Aux_ID'}=ncfloat('Num_Hists');
newdatabasefile{'Previous_Val'}=ncchar('Num_Hists','String_10');
newdatabasefile{'Flag_severity'}=nclong('Num_Hists');
newdatabasefile{'D_P_Code'}=ncchar('N_Prof','String_1');
newdatabasefile{'No_Depths'}=nclong('N_Prof');
newdatabasefile{'Depthpress'}=ncfloat('N_Prof','depth');
newdatabasefile{'Profparm'}=ncfloat('N_Prof','time','depth','latitude','longitude');
newdatabasefile{'DepresQ'}=ncchar('N_Prof','depth','String_1');
newdatabasefile{'ProfQP'}=ncchar('N_Prof','time','depth','latitude','longitude','String_1');

%create the attributes (some need creation while filling)
newdatabasefile{'woce_date'}.long_name=ncchar('date');
newdatabasefile{'woce_date'}.units=ncchar('yyyymmdd UTC');

newdatabasefile{'woce_time'}.long_name=ncchar('time of day');
newdatabasefile{'woce_time'}.units=ncchar('hhmmss');

newdatabasefile{'time'}.long_name=ncchar('time');
newdatabasefile{'time'}.units=ncchar('days since 1900-01-01 00:00:00');

newdatabasefile{'latitude'}.long_name=ncchar('latitude');
newdatabasefile{'latitude'}.units=ncchar('degrees_N');
newdatabasefile{'latitude'}.valid_min=ncfloat(-90);
newdatabasefile{'latitude'}.valid_max=ncfloat(90);
newdatabasefile{'latitude'}.C_format=ncchar('%8.4f');
newdatabasefile{'latitude'}.FORTRAN_format=ncchar('F8.4');

newdatabasefile{'longitude'}.long_name=ncchar('longitude');
newdatabasefile{'longitude'}.units=ncchar('360degrees_E');
%newdatabasefile{'longitude'}.scale_factor=ncfloat(-1);
newdatabasefile{'longitude'}.valid_min=ncfloat(0.);
newdatabasefile{'longitude'}.valid_max=ncfloat(360.);
newdatabasefile{'longitude'}.C_format=ncchar('%9.4f');
newdatabasefile{'longitude'}.FORTRAN_format=ncchar('F9.4');

newdatabasefile{'Depthpress'}.FillValue_=ncfloat(-99.99);

newdatabasefile{'Profparm'}.FillValue_=ncfloat(-99.99);

close(newdatabasefile);

