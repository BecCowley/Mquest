function profiledata = readargonetcdf(inputfile,outputfile,uniqueid,ds)
%this function reads a single profile from an Argo netcdf file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
%
% Usage:  profiledata - readargonetcdf(inputfile,uniqueid,ds)

dc = {'AO', 'BO', 'CO', 'CS', 'GT', 'JM', ...
    'MD', 'CI', 'IN', 'KM'};
dc = dc{ds};

clear profiledata

%setup output files:
profiledata.nss=num2str(uniqueid);

    profiledata.outputfile{1} = outputfile;
    profiledata.source(1:length(dc)) = dc;
    profiledata.source(length(dc)+1:10) = ' ';
    profiledata.priority = 1;

%Get the header data and ouput to both files:
dt=gregorian(inputfile{'JULD'}(:)+julian(1950, 1, 1));
profiledata.year = dt(1);
profiledata.month=dt(2);
profiledata.day=dt(3);
hh = num2str(dt(4)); MM = num2str(dt(5)); ss = num2str(dt(6));
profiledata.time=str2num([hh MM ss]);  %woce_time

profiledata.latitude=inputfile{'LATITUDE'}(:);
profiledata.longitude=inputfile{'LONGITUDE'}(:);  
profiledata.lat=inputfile{'LATITUDE'}(:);
profiledata.lon=inputfile{'LONGITUDE'}(:);

if(profiledata.longitude<0)
    profiledata.longitude=profiledata.longitude+360;
    profiledata.lon=profiledata.longitude;
end
%if this data is to be added:

profiledata.mky='        ';
profiledata.onedegsq='        ';
profiledata.cruiseID='          ';
profiledata.datat='PF';
profiledata.iumsgno='            ';
profiledata.streamsource=' ';
profiledata.uflag=' ';
profiledata.medssta='        ';
profiledata.qpos='1';
profiledata.qdatetime='1';
profiledata.qrec=' ';
profiledata.update='        ';
profiledata.bultime='            ';
profiledata.bulheader='      ';
profiledata.sourceID='    '; 
profiledata.streamident=[dc 'PF']; 
profiledata.QCversion='    ';
profiledata.dataavail='A';

profiledata.nprof=1;

profiledata.nparms=1;
    
profiledata.nsurfc=0;
profiledata.nhists=0;

profiledata.nosseg=1;
profiledata.deep_depth=0;
profiledata.prof_type(1,1:16)='TEMP            ';
profiledata.standard(1)=' ';
profiledata.dup_flag(1)='N';
profiledata.digit_code(1)=' ';

profiledata.pcode(1,1:4)='PFN$';
cn = num2str(inputfile{'CYCLE_NUMBER'}(:));
mm = length(cn);
profiledata.parm(1,1:mm)=cn;
profiledata.parm(1,mm+1:10) = ' ';
profiledata.qparm='0';

profiledata.surfpcode(1,1:4)=[dc 'ID'];
profiledata.surfparm(1,1:10)='          ';
uniq=num2str(uniqueid);
profiledata.surfparm(1,1:length(uniq))=uniq;
profiledata.surfqparm(1)='0';
profiledata.surfpcode(2,1:4)='IOTA';
profiledata.surfparm(2,1:10)=[dc ' dmPF   '];
profiledata.surfqparm(2)='1';
profiledata.surfpcode(3,1:4)='PEQ$';
profiledata.surfparm(3,1:10)='831       ';
profiledata.surfqparm(3)='0';
profiledata.surfpcode(4,1:4)='SER1';
wmo = inputfile{'PLATFORM_NUMBER'}(:);
profiledata.surfparm(4,1:10)='          ';
profiledata.surfparm(4,1:length(wmo)-1)=wmo(1:length(wmo)-1)';
profiledata.surfqparm(4)='0';
profiledata.surfpcode(5,1:4)='GCLL';
profiledata.surfparm(5,1:10)='          ';
profiledata.surfparm(5,1:length(wmo)-1)=wmo(1:length(wmo)-1)';
profiledata.surfqparm(5)='0';
profiledata.nsurfc=5;

profiledata.identcode='';
profiledata.PRCcode='';
profiledata.Version='';
profiledata.PRCdate='';
profiledata.Actcode='';
profiledata.Actparm='';
profiledata.AuxID=0;
profiledata.PreviousVal='';
profiledata.flagseverity=0;

ndep= size(inputfile('N_LEVELS'),1);
profiledata.ndep = ndep;
tqc = inputfile{'TEMP_ADJUSTED_QC'}(:);
tmp = inputfile{'TEMP_ADJUSTED'}(:);
pqc = inputfile{'PRES_ADJUSTED_QC'}(:);
pres = inputfile{'PRES_ADJUSTED'}(:);
%change the fill values
tmp = change(tmp,'==',99999.,-99.99);
pres = change(pres,'==',99999.,-99.99);


%put the data and QC in:
profiledata.D_P_Code='P';
profiledata.nodepths=ndep;
profiledata.profile_type(1,1,1:4)='TEMP';
profiledata.profparm(:,1,1) = tmp;
profiledata.profQparm(:,1,1) = tqc;
profiledata.depth(:,1,1)=pres;
profiledata.depresQ(:,1,1)=pqc;
profiledata.deep_depth = max(pres);
profiledata.autoqc=0;

return
