function readssCTD_NCtoMQNC(inputfile,outputfile,updown)
% Function to read 2m netcdf CTD CSIRO files from SSurveyor/Franklin and output to mqnc
% Inputs:   inputfile - (string) name of file for reading, with extension
%           outputfile - (string) name for output MQNC file
%           updown - optional (string) 'CU' for upcast 'CT' for downcast. Defaults
%           to 'CT'
% Rebecca Cowley 16 October 2009
%Updated to include Franklin 9/12/2009 RC
% addpath /home/UOT/programs/Mquest
if nargin < 2
    error('Not enough input arguments, try again with inputfile and outputfile')
end

if nargin < 3
    updown = 'CT'
end

% load unique id from file:
load uniqueid.mat
uniqueid = uniqueid +1;

%get data:
nc = netcdf(inputfile);
clear profiledata

%setup output files:
profiledata.nss=num2str(uniqueid);
ndep=length(nc{'pressure'}(:));
profiledata.ndep = ndep;
str = nc{'time'}.units(:);
ii = strfind(str,' ');
str = str(ii(2)+1:ii(4));
dt = datenum(str)+nc{'time'}(1)/(3600*24);
profiledata.year=str2double(datestr(dt,'YYYY'));
profiledata.month=str2double(datestr(dt,'mm'));
profiledata.day=str2double(datestr(dt,'DD'));
hh=datestr(dt,'HH');
mm = datestr(dt,'MM');
ss = datestr(dt,'ss');
profiledata.time=str2double([hh mm ss]);  %woce_time

long = nc{'longitude'}(1);
if long < 0;
    long = long +360;
end
profiledata.latitude=nc{'latitude'}(1);
profiledata.longitude=long;
profiledata.lat=nc{'latitude'}(1);
profiledata.lon=long;

profiledata.mky='        ';
profiledata.onedegsq='        ';
profiledata.cruiseID='          ';
vv = nc.Survey(:);
profiledata.cruiseID(1:length(vv)) = vv;
profiledata.datat=updown;
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
profiledata.streamident=['CS' updown];  %CSIRO ctd up or downcast
profiledata.QCversion='    ';
profiledata.dataavail='A';

profiledata.nprof=2;
profiledata.nparms=0;
profiledata.nsurfc=0;
profiledata.nhists=0;

profiledata.nosseg='';
profiledata.deep_depth='';
profiledata.prof_type='';
profiledata.dup_flag='';
profiledata.digit_code='';
profiledata.standard='';
profiledata.deep_depth=0;
profiledata.nosseg=0;
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
    profiledata.digit_code(i)='A';
end

profiledata.pcode='';
profiledata.parm='';
profiledata.qparm='';

profiledata.surfpcode(1,1:4)='CSID';
profiledata.surfparm(1,1:10)=[num2str(uniqueid) '  '];
profiledata.surfqparm(1)='0';
profiledata.surfpcode(2,1:4)='IOTA';
profiledata.surfparm(2,1:10)='          ';
profiledata.surfqparm(2)='0';
profiledata.surfpcode(3,1:4)='PEQ$';
profiledata.surfparm(3,1:10)='830       ';
profiledata.surfqparm(3)='0';
if ~isempty(strfind(nc.Vessel(:),'Invest'))
    profiledata.surfpcode(4,1:4)='GCLL';
    profiledata.surfparm(4,1:10)='VLMJ      ';
    profiledata.surfqparm(4)='0';
    profiledata.surfpcode(5,1:4)='SHP#';
    profiledata.surfparm(5,1:10)='Investigat';
    profiledata.surfqparm(5)='0';
%     profiledata.surfpcode(6,1:4)='PLAT';
%     profiledata.surfparm(6,1:10)='09FA      ';
%     profiledata.surfqparm(6)='0';
else
    profiledata.surfpcode(4,1:4)='GCLL';
    profiledata.surfparm(4,1:10)='VLHJ      ';
    profiledata.surfqparm(4)='0';
    profiledata.surfpcode(5,1:4)='SHP#';
    profiledata.surfparm(5,1:10)='SouthernS ';
    profiledata.surfqparm(5)='0';
    profiledata.surfpcode(6,1:4)='PLAT';
    profiledata.surfparm(6,1:10)='09SS      ';
    profiledata.surfqparm(6)='0';
end

profiledata.nsurfc=size(profiledata.surfpcode,1);

profiledata.identcode='';
profiledata.PRCcode='';
profiledata.Version='';
profiledata.PRCdate='';
profiledata.Actcode='';
profiledata.Actparm='';
profiledata.AuxID=0;
profiledata.PreviousVal='';
profiledata.flagseverity=0;

profiledata.D_P_Code='P';
profiledata.profile_type='';
for b=1:profiledata.nprof
    %get the depth temp pairs etc out of the file,
    %then read the next segment if relevant:
    profiledata.nodepths(b)=ndep;
    if b==1
        profiledata.profile_type(1,1,1:4)='TEMP';
        profiledata.profparm(b,1,:)=nc{'temperature'}(:);
        
        %check quality flags:
        profiledata.profQparm(b,1,:)='0';
        im = find(nc{'temperatureQC'}(:) > 63 & nc{'temperatureQC'}(:) <= 127); %suspect data
        profiledata.profQparm(b,1,im)='3';
        im = find(nc{'temperatureQC'}(:) >= -128 & nc{'temperatureQC'}(:) <=-65); %bad data
        profiledata.profQparm(b,1,im)='4';
        im = find(nc{'temperatureQC'}(:) >= 0 & nc{'temperatureQC'}(:) < 64); %good data
        profiledata.profQparm(b,1,im)='1';
        ii = isnan(profiledata.profparm(b,1,:));
        profiledata.profparm(b,1,ii) = 99.99;
        profiledata.profQparm(b,1,ii) = '9';
        
    elseif b==2
        profiledata.profile_type(1,1,1:4)='PSAL';
        profiledata.profparm(b,1,:)=nc{'salinity'}(:);
        
        %check quality flags:
        profiledata.profQparm(b,1,:)='0';
        im = find(nc{'salinityQC'}(:) > 63 & nc{'salinityQC'}(:) <= 127); %suspect data
        profiledata.profQparm(b,1,im)='3';
        im = find(nc{'salinityQC'}(:) >= -128 & nc{'salinityQC'}(:) <=-65); %bad data
        profiledata.profQparm(b,1,im)='4';
        im = find(nc{'salinityQC'}(:) >= 0 & nc{'salinityQC'}(:) < 64); %good data
        profiledata.profQparm(b,1,im)='1';
        ii = isnan(profiledata.profparm(b,1,:));
        profiledata.profparm(b,1,ii) = 99.99;
        profiledata.profQparm(b,1,ii) = '9';
    end
    profiledata.depth(b,1,:)=nc{'pressure'}(:);
    profiledata.depresQ(b,1,1:length(nc{'pressure'}(:)))='1';
    
end
for b=1:profiledata.nprof
    profiledata.deep_depth(b)=max(nc{'pressure'}(:));
end
no_depths='';

close(nc)

profiledata.autoqc=0;

writekeys=1;
profiledata.outputfile = {outputfile};
profiledata.source = 'CSIRO     ';
profiledata.priority = 1;
writeMQNCfiles(profiledata,writekeys);

% Save files
save /media/sf_Mquest/Mquest/uniqueid.mat uniqueid

end
