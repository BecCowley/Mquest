function createMQNCfiles(profiledata,filenamnew)

% createMQNCfile - creates empty file for filling by writeMQNCfiles
%
% usage:  createMQNCfiles(no_depths,filenamnew)
%       where:
%         no_depths contains the number of depths of the profile to be
%           stored. This is required to ensure that the dimensions of the
%           file are sufficient to hold the entire profile
%         filenamnew contains the complete filename of the file to be created.
%Updated to use Matlab netcdf library, May, 2016. Bec Cowley
%

if ~exist(filenamnew,'file')
    nc = getMQschema(profiledata,filenamnew);
    %create directory if required
    if ~isempty(findstr('ed',filenamnew))
        if exist([filenamnew(1:length(filenamnew)-7)],'dir') ~= 7
            mkdir([filenamnew(1:length(filenamnew)-7)])
        end
    end
    ncwriteschema(filenamnew,nc);
else
    return
end
end
%If we wanted to create this file by hand, this is the sort of code we need

% no_depths=profiledata.No_Depths;
% 
% % convert no_depths to the closest 100
% int_depth=((fix(no_depths/100))+1)*100;
% if(length(int_depth)>1);
%     %correct for missing no_depths from some two-profile file
%     if(abs(int_depth(1)-int_depth(2))>1000)
%         int_depth(2)=int_depth(1);
%         no_depths(2)=no_depths(1);
%     end
% end
% 
% %create the empty netcdf file ready for writing data to
% if exist([filenamnew(1:length(filenamnew)-7)],'dir') ~= 7
%     mkdir([filenamnew(1:length(filenamnew)-7)])
% end    
% try
%     newdatabasefile = netcdf.create([filenamnew ],'NOCLOBBER');
% catch
%     newdatabasefile = netcdf.create([filenamnew ],'CLOBBER');
% end
% if(isempty(newdatabasefile))
%     newdatabasefile = netcdf.create([filenamnew ],'CLOBBER');
% end
% if ~exist(filenamnew,'file')
%     newdatabasefile = netcdf.create([filenamnew ],'CLOBBER');
% end
% 
% 
% % create the dimensions
% dnprof = netcdf.defDim(newdatabasefile,'N_Prof',netcdf.getConstant('NC_UNLIMITED'));
% dnparms = netcdf.defDim(newdatabasefile,'Nparms',30);
% dnsurfc = netcdf.defDim(newdatabasefile,'Nsurfc',30);
% dnhists = netcdf.defDim(newdatabasefile,'Num_Hists',100);
% dtime = netcdf.defDim(newdatabasefile,'time',1);
% dlat = netcdf.defDim(newdatabasefile,'latitude',1);
% dlon = netcdf.defDim(newdatabasefile,'longitude',1);
% ddepth = netcdf.defDim(newdatabasefile,'depth',max(int_depth));
% ds1 = netcdf.defDim(newdatabasefile,'String_1',1);
% dsingle = netcdf.defDim(newdatabasefile,'Single',1);
% ds2 = netcdf.defDim(newdatabasefile,'String_2',2);
% ds4 = netcdf.defDim(newdatabasefile,'String_4',4);
% ds8 = netcdf.defDim(newdatabasefile,'String_8',8);
% ds10 = netcdf.defDim(newdatabasefile,'String_10',10);
% ds12 = netcdf.defDim(newdatabasefile,'String_12',12);
% ds16 = netcdf.defDim(newdatabasefile,'String_16',16);
% ds250= netcdf.defDim(newdatabasefile,'String_250',250);
% 
% % create the variables & their attributes
% varid = netcdf.defVar(newdatabasefile,'woce_date','NC_INT',dsingle);
% netcdf.putAtt(newdatabasefile,varid,'standard_name','Date');
% netcdf.putAtt(newdatabasefile,varid,'long_name','WOCE date');
% netcdf.putAtt(newdatabasefile,varid,'units','yyyymmdd UTC');
% netcdf.putAtt(newdatabasefile,varid,'data_min',profiledata.woce_date);
% netcdf.putAtt(newdatabasefile,varid,'data_max',profiledata.woce_date);
% 
% varid = netcdf.defVar(newdatabasefile,'woce_time','NC_INT',dtime);
% netcdf.putAtt(newdatabasefile,varid,'standard_name','Time of day');
% netcdf.putAtt(newdatabasefile,varid,'long_name','WOCE time of day');
% netcdf.putAtt(newdatabasefile,varid,'units','hhmmss');
% netcdf.putAtt(newdatabasefile,varid,'data_min',profiledata.woce_time);
% netcdf.putAtt(newdatabasefile,varid,'data_max',profiledata.woce_time);
% 
% varid = netcdf.defVar(newdatabasefile,'time','NC_FLOAT',dtime);
% netcdf.putAtt(newdatabasefile,varid,'standard_name','time');
% netcdf.putAtt(newdatabasefile,varid,'long_name','time');
% netcdf.putAtt(newdatabasefile,varid,'units','days since 1900-01-01 00:00:00');
% netcdf.putAtt(newdatabasefile,varid,'data_min',profiledata.time);
% netcdf.putAtt(newdatabasefile,varid,'data_max',profiledata.time);
% 
% varid = netcdf.defVar(newdatabasefile,'latitude','NC_FLOAT',dlat);
% netcdf.putAtt(newdatabasefile,varid,'standard_name','latitude');
% netcdf.putAtt(newdatabasefile,varid,'long_name','latitude');
% netcdf.putAtt(newdatabasefile,varid,'units','degrees_N');
% netcdf.putAtt(newdatabasefile,varid,'data_min',profiledata.latitude);
% netcdf.putAtt(newdatabasefile,varid,'data_max',profiledata.latitude);
% netcdf.putAtt(newdatabasefile,varid,'valid_min',-90);
% netcdf.putAtt(newdatabasefile,varid,'valid_max',90);
% %do we need these?
% % netcdf.putAtt(newdatabasefile,varid,'C_format','%8.4f');
% % netcdf.putAtt(newdatabasefile,varid,'FORTRAN_format','F8.4');
% 
% varid = netcdf.defVar(newdatabasefile,'longitude','NC_FLOAT',dlon);
% netcdf.putAtt(newdatabasefile,varid,'standard_name','longitude');
% netcdf.putAtt(newdatabasefile,varid,'long_name','longitude');
% netcdf.putAtt(newdatabasefile,varid,'units','360degrees_E');
% netcdf.putAtt(newdatabasefile,varid,'data_min',profiledata.longitude);
% netcdf.putAtt(newdatabasefile,varid,'data_max',profiledata.longitude);
% netcdf.putAtt(newdatabasefile,varid,'valid_min',0);
% netcdf.putAtt(newdatabasefile,varid,'valid_max',360);
% %do we need these?
% % netcdf.putAtt(newdatabasefile,varid,'C_format','%9.4f');
% % netcdf.putAtt(newdatabasefile,varid,'FORTRAN_format','F9.4');
% 
% netcdf.defVar(newdatabasefile,'Num_Hists','NC_INT',dsingle);
% netcdf.defVar(newdatabasefile,'No_Prof','NC_INT',dsingle);
% netcdf.defVar(newdatabasefile,'Nparms','NC_INT',dsingle);
% netcdf.defVar(newdatabasefile,'Nsurfc','NC_INT',dsingle);
% netcdf.defVar(newdatabasefile,'Mky','NC_CHAR',ds8);
% netcdf.defVar(newdatabasefile,'One_Deg_Sq','NC_CHAR',ds8);
% netcdf.defVar(newdatabasefile,'Cruise_ID','NC_CHAR',ds10);
% netcdf.defVar(newdatabasefile,'Data_Type','NC_CHAR',ds2);
% netcdf.defVar(newdatabasefile,'Iumsgno','NC_CHAR',ds12);
% netcdf.defVar(newdatabasefile,'Stream_Source','NC_CHAR',ds1);
% 
% netcdf.defVar(newdatabasefile,'MEDS_Sta','NC_CHAR',ds8);
% netcdf.defVar(newdatabasefile,'Q_Pos','NC_CHAR',ds1);
% netcdf.defVar(newdatabasefile,'Q_Date_Time','NC_CHAR',ds1);
% netcdf.defVar(newdatabasefile,'Q_Record','NC_CHAR',ds1);
% netcdf.defVar(newdatabasefile,'Up_date','NC_CHAR',ds8);
% netcdf.defVar(newdatabasefile,'Bul_Time','NC_CHAR',ds12);
% netcdf.defVar(newdatabasefile,'Bul_Header','NC_CHAR',ds8);
% netcdf.defVar(newdatabasefile,'Source_ID','NC_CHAR',ds4);
% netcdf.defVar(newdatabasefile,'Stream_Ident','NC_CHAR',ds4);
% netcdf.defVar(newdatabasefile,'QC_Version','NC_CHAR',ds4);
% netcdf.defVar(newdatabasefile,'Data_Avail','NC_CHAR',ds1);
% netcdf.defVar(newdatabasefile,'Prof_Type','NC_CHAR',[ds16,dnprof]);
% 
% netcdf.defVar(newdatabasefile,'Dup_Flag','NC_CHAR',[ds1,dnprof]);
% netcdf.defVar(newdatabasefile,'Digit_Code','NC_CHAR',[ds1,dnprof]);
% netcdf.defVar(newdatabasefile,'Standard','NC_CHAR',[ds1,dnprof]);
% netcdf.defVar(newdatabasefile,'Deep_Depth','NC_CHAR',dnprof);
% if isfield(profiledata,'comments_pre')
%     netcdf.defVar(newdatabasefile,'PreDropComments','NC_CHAR',ds250);
% end
% if isfield(profiledata,'comments_post')
%     netcdf.defVar(newdatabasefile,'PostDropComments','NC_CHAR',ds250);
% end
% 
% netcdf.defVar(newdatabasefile,'Uflag','NC_CHAR',ds1);
% netcdf.defVar(newdatabasefile,'Pcode','NC_CHAR',[dnparms,ds4]);
% netcdf.defVar(newdatabasefile,'Parm','NC_CHAR',[dnparms,ds10]);
% netcdf.defVar(newdatabasefile,'Q_Parm','NC_CHAR',[dnparms,ds1]);
% netcdf.defVar(newdatabasefile,'SRFC_Code','NC_CHAR',[dnsurfc,ds4]);
% netcdf.defVar(newdatabasefile,'SRFC_Parm','NC_CHAR',[dnsurfc,ds10]);
% netcdf.defVar(newdatabasefile,'SRFC_Q_Parm','NC_CHAR',[dnsurfc,ds1]);
% netcdf.defVar(newdatabasefile,'Ident_Code','NC_CHAR',[dnhists,ds2]);
% netcdf.defVar(newdatabasefile,'PRC_Code','NC_CHAR',[dnhists,ds4]);
% netcdf.defVar(newdatabasefile,'Version','NC_CHAR',[dnhists,ds4]);
% netcdf.defVar(newdatabasefile,'PRC_Date','NC_CHAR',[dnhists,ds8]);
% netcdf.defVar(newdatabasefile,'Act_Code','NC_CHAR',[dnhists,ds2]);
% netcdf.defVar(newdatabasefile,'Act_Parm','NC_CHAR',[dnhists,ds4]);
% netcdf.defVar(newdatabasefile,'Aux_ID','NC_FLOAT',dnhists);
% netcdf.defVar(newdatabasefile,'Previous_Val','NC_CHAR',[dnhists,ds10]);
% netcdf.defVar(newdatabasefile,'Flag_severity','NC_FLOAT',dnhists);
% netcdf.defVar(newdatabasefile,'D_P_Code','NC_CHAR',[ds1,dnprof]);
% netcdf.defVar(newdatabasefile,'No_Depths','NC_INT',dnprof);
% varid = netcdf.defVar(newdatabasefile,'Depthpress','NC_FLOAT',[ddepth,dnprof]);
% netcdf.putAtt(newdatabasefile,varid,'_FillValue',-99.99);
% varid = netcdf.defVar(newdatabasefile,'Profparm','NC_FLOAT',[ddepth,dtime,dlat,dlon,dnprof]);
% netcdf.putAtt(newdatabasefile,varid,'_FillValue',-99.99);
% netcdf.defVar(newdatabasefile,'DepresQ','NC_CHAR',[ddepth,ds1,dnprof]);
% netcdf.defVar(newdatabasefile,'ProfQP','NC_CHAR',[ddepth,ds1,dtime,dlat,dlon,dnprof]);
% 
% netcdf.endDef(newdatabasefile);
% 
