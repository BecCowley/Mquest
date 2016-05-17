%% fixeverything_cells
% put all fixes in here and use cell mode to run individual bits...

%list of processes so far : (sequence, process, description, author, date)
% 1 (line 33) - set up databases - input keysdata - run this first (AT)
% 2 (line 61) - fixtimes - changes 8 digit times to 6 and 4 digit times to 6 (AT)
% 3 changeattributes - changes missing value for temp attribute from -99.99 to 99.99
% 4 c360degreelongitudes - replaces old longitudes held in obslng with those
% 5 fix360degreelongitudedatabase
% 6 (line 392) - fixCSID - CSID in some files has been corrupted. Check all files and
% 7 fixqualityvalues - 
% 8 repair keys file problems with date/time:
% 9 Fix the overwritten files from tasman master set. BOM files were
%       overwritten with WOCE files with the same numbers
% 10 (line 825) - fix the priority and source in the devil data - wrongly encoded as
%       cruise ID and 0 when first started mporting devil data using matlab.
% 11 Fix profiles with duplicated data
% 12 list files that HAVE NOT BEEN DEPTH CORRECTED!!!
% 13 now check for the max depth of the profiles above
% 14 (line 1012) - fix longitudes in bernadettes' data - can be adapted to any data set
%       that needs wholesale changes to position
% 15 further fixes for Bernadette's xctd data...
% 16 (line 1081) - Fix raw files that need depth correction applied
% 17 (line 1306) - fix xbt data with extra or missing data points in the ed files
% 18 (line 1549) - eliminate unwanted profiles by eliminating keys from the keys.nc file
%       (see #20 for alternative)
% 19 (line 1660) - create new keys list of all profiles with scripps rejected data...
% 20 rewrite keys list without specific stations - from a char array of
%       station numbers (alternative to #18)
% 21 (line 1773) - create new keys from a list of stations (char array)
% 22 (deleted) (line 1844) - Replace XBT depths with standard depths (full resolution data only)
% 23 (line 1835) - fix CS flags that are incorrectly identified with too severe a
%       flag severity and find profiles with bad data but no identifiable
%       flags
% 24 (line 1944) = fix bad missing values - profiles padded with 99.99 instead
%       of -99.99 after max depth
% 25 (line 2043) - fix julian dates of edited files which are based on the wrong start date
% 26 (line 2139) - Condense NC files (create a shortened version of the *good.nc
%       file)
% 27 - Get specific files from a backup copy
% 28 Find casts that have two profiles (eg BO's and XCTD'S with salinity
% 29 Fix the casts with two or more profiles and missing salinity
% 30 Run Tim Boyer's list of DBID's that need PEQ changed from XBT to CTD
% 31 - check MBTs for depth problem
% 32 (line 2643) - extract profiles with bad/good data and tally
% 33 (line 2667) - use a list of station numbers to flag out these as duplicates
% 34 (line 2715) - Update the ALACE - t only floats information
% 36 Find the woce PF that have failed the screen in more than 40% profiles
% 37 Find MBTs and XBTs that are mixed up (eg, MBTs that have been
% changed to XBTs and info not updated correctly
% 38 (line 3163) - based on 32, extract tallies of flags.  Supply the
% variable 'flag_req' and you get a tally through time from the prefix_list
% databases.
% 39 (line 3245) - find farseasfisheries profiles in master file, match with
% re-extracted data and combine the QC into the new profiles if the data is
% the same.
% 40 (line 3752) - Fix deep-depth value to the deepest value in the file
% 41 (line 3789) - Create a keys file from the directory structure
%      for when you lose the keys....
% 42 (line 3927) - fix longitudes in sprightly data - can be adapted to any data set
%      that needs wholesale changes to position  Based on #14.
% 43 (line 4000) - fix sprightly double decimal latitudes -
% 45 - fix scale factor in longitude
% 46 - replace lats/longs in files with those in keys
% 47 - fix PLA ndeps and deep depth and qc flags...
% 48  find a specific QC flag
% 49 fix data source in keys and in files
% 50 Fix date formats from ddmmyyyy to yyyymmdd in histories and update
% fields, as per NOAA meds-ascii requirements
%% 1 first, set up the  databases - assume using quest...  This cell runs
%first.

CONFIG

global DATA_QC_SOURCE

prefix=input('enter the database prefix:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);

% end of keys setup

% use "filename=getfilename(stnnum,raw)" to return the filename if you
% don't want to read the entire file using readnetcdf

% eg:  for i=1:length(keysdata.stnnum)
%        raw=0;
%        filen=getfilename(num2str(keysdata.stnnum(i)),raw);
%        if(ispc)
%           filenam=[prefix '\' filen];
%        else
%           filenam=[prefix '/' filen];
%        end
%           ...

%% 2 fixtimes - changes 8 digit times to 6 and 4 digit times to 6 in the raw
% and edited netcdf files
% created by Ann Thresher - 21/11/2006

lastonedone=0;
for i=1:length(keysdata.stnnum)
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    
    nc=netcdf(filenam,'write');
%    wt=getnc(filenam,'woce_time'); getnc slows down the code
    wt=nc{'woce_time'}(:);
    
  if(mod(wt,100)~=0 | mod(wt,10000)==0 | lastonedone)
    lastonedone=0;
    profileinfo=[num2str(i) '   ' num2str(keysdata.month(i)) ' ' num2str(keysdata.day(i)) ' '...
        num2str(keysdata.year(i)) ' ' num2str(wt) ' ' num2str(keysdata.obslon(i))...
         ' ' num2str(keysdata.obslat(i)) '  ' keysdata.callsign(i,:)]

    ch=input('enter 4 if is 4 digit and 8 if is 8 digit time, cr = no change');

    if (ch==4)
        wt=wt*100;
        nc{'woce_time'}(:)=wt;
        close(nc);
        if(strfind(filenam,'ed.nc'))
            filenam(strfind(filenam,'ed.nc'):end+1)='raw.nc'
        else
            filenam(strfind(filenam,'raw.nc'):end)='ed.nc '
        end
        nc=netcdf(filenam,'write');
        nc{'woce_time'}(:)=wt;
        close(nc);
        lastonedone=1;
    elseif (ch==8)
    
        wt=wt/100;
        nc{'woce_time'}(:)=wt;
        close(nc);
        if(strfind(filenam,'ed.nc'))
            filenam(strfind(filenam,'ed.nc'):end+1)='raw.nc'
        else
            filenam(strfind(filenam,'raw.nc'):end)='ed.nc '
        end
        nc=netcdf(filenam,'write');
        nc{'woce_time'}(:)=wt;
        close(nc);
        lastonedone=1;
    else
        close(nc)
    end
  end
end
   

%% 3 changeattributes - changes missing value for temp attribute from -99.99 to 99.99
% created by Ann Thresher - 21/11/2006

for i=1:length(keysdata.stnnum)
    i=i
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw)
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    
    nc=netcdf(filenam,'write');
    attr=nc{'Profparm'}.FillValue_(:);
    if(attr<99.8 & attr>0)
    else
        nc{'Profparm'}.FillValue_=ncfloat(-99.99);
    end
    close(nc)
 
    if(strfind(filenam,'ed.nc'))
        filenam(strfind(filenam,'ed.nc'):end+1)='raw.nc';
    else
        filenam(strfind(filenam,'raw.nc'):end)='ed.nc ';
    end
    nc=netcdf(filenam,'write');
    attr=nc{'Profparm'}.FillValue_(:);
    if(attr<99.8 & attr>0)
    else
        nc{'Profparm'}.FillValue_=ncfloat(-99.99);
    end
    close(nc)
end

    
    
%% 4 c360degreelongitudes - replaces old longitudes held in obslng with those
%held in c360long (these hold the 360 degree globe, not the +/- version of
%most databases).

% note - this changes every "keys" file in the directory so you must be in
% the right place to run this.

%created by Ann Thresher 11/2006

d=dir('argobuddiestasMQNC*.nc')
for i=1:length(d)
    filen=d(i).name;
    nc=netcdf(filen,'write');
    m=size(nc{'obslng'});
    if m(1)~=0  %only do those keys with records in them
%        nc{'obslng'}(:)=nc{'c360long'}(:);
        ii = find(nc{'c360long'}(:) < -150);
        ln = nc{'c360long'}(:);
        ln(ii)=ln(ii)+360;
        nc{'obslng'}(:)=ln;
        nc{'c360long'}(:) = ln;
    end
    close(nc)
end


%% 5 fix360degreelongitudedatabase
% this opens the database and changes the longitudes in both edited and raw
% files to 360 degrees - it also saves the old longitude in the surface
% codes section of the record.

% Note - you must have the directory for the data files you need to update -
% this does all databases in the directory so make sure you're in the right
% place before you run it...

%created by Ann Thresher 11/2006

d=dir('argobuddiestasMQNC_keys.nc')

for i=1:length(d)
    filen=d(i).name;
    nc=netcdf(filen,'write');
    m=size(nc{'obslng'});
    if m(1)~=0  %only do those keys with records in them
    spa=strfind(d(i).name,'_');
    prefix=d(i).name(1:spa(1)-1);
    stnnum=nc{'stn_num'};
    c360l=nc{'c360long'};
    c=clock;
    if length(num2str(c(3)))<2
        dd=['0' num2str(c(3))];
    else
        dd=num2str(c(3));
    end
    if length(num2str(c(2)))<2
        mm=['0' num2str(c(2))];
    else
        mm=num2str(c(2));
    end
    update=[num2str(c(1)) mm dd];
    
  for j=1:length(stnnum)
      stnnum(j,:)',j
      raw=1;
      clear filen
      filen=getfilename(stnnum(j,:)',raw);
      if(ispc)
          filenam=[prefix '\' filen];
      else
          filenam=[prefix '/' filen];
      end
   
      %check to see if this has already been done - if existing longitude =
      %keys file longitude, then you don't need to do anything more:
      
%      lo=getnc(filenam,'longitude',1,1,1,1,1,-1); gives positive values
%      for some longs. Use ncraw to find lo. Also slows down the program.
           
      ncraw=netcdf(filenam,'write');
      lo=ncraw{'longitude'}(:);
      
      raw=0;
      clear filen
      filen=getfilename(stnnum(j,:)',raw);
      if(ispc)
       nced=netcdf([prefix '\' filen],'write');
      else
       nced=netcdf([prefix '/' filen],'write');
      end
 
      % change the attributes
      ncraw{'longitude'}.units='360degrees_E';
      ncraw{'longitude'}.valid_min=ncfloat(0);
      ncraw{'longitude'}.valid_max=ncfloat(360);
      ncraw{'longitude'}.data_min=ncfloat(c360l(j));
      ncraw{'longitude'}.data_max=ncfloat(c360l(j));
     if ~isempty(ncraw{'longitude'}.scale_factor)
        ncraw{'longitude'}.scale_factor=[];
     end
      nced{'longitude'}.units='360degrees_E';
      nced{'longitude'}.valid_min=ncfloat(0);
      nced{'longitude'}.valid_max=ncfloat(360);
      nced{'longitude'}.data_min=ncfloat(c360l(j));
      nced{'longitude'}.data_max=ncfloat(c360l(j));
     if ~isempty(nced{'longitude'}.scale_factor)
      nced{'longitude'}.scale_factor=[];
     end
     
     
     if(lo~=c360l(j))        
%      if lo < -150
      %%increment the number of histories:
      ncraw{'Num_Hists'}(1)=ncraw{'Num_Hists'}(1)+1;
      nced{'Num_Hists'}(1)=nced{'Num_Hists'}(1)+1;
      if(nced{'Num_Hists'}(1)>100)
          nced{'Num_Hists'}(1)=100;
      end
      nrh=ncraw{'Num_Hists'}(1);
      neh=nced{'Num_Hists'}(1);
     
      clear hist*
      %%change the history section, one bit at a time..
      %first change the ident code...
      histrawIC=ncraw{'Ident_Code'};
      histedIC=nced{'Ident_Code'};
      histrawIC(nrh,:)=DATA_QC_SOURCE;
      histedIC(neh,:)=DATA_QC_SOURCE;
      ncraw{'Ident_Code'}(:,:)=histrawIC(:,:);
      nced{'Ident_Code'}(:,:)=histedIC(:,:);
      
      %%now change the PRC_Code
      histrawPRC=ncraw{'PRC_Code'};
      histedPRC=nced{'PRC_Code'};
      histrawPRC(nrh,:)='CSCB';
      histedPRC(neh,:)='CSCB';
      ncraw{'PRC_Code'}(:,:)=histrawPRC(:,:);
      nced{'PRC_Code'}(:,:)=histedPRC(:,:);
      
      %%now change the version:
      histrawV=ncraw{'Version'};
      histedV=nced{'Version'};
      histrawV(nrh,:)='1.0 ';
      histedV(neh,:)='1.0 ';
      ncraw{'Version'}(:,:)=histrawV(:,:);
      nced{'Version'}(:,:)=histedV(:,:);

      %%now change the PRC_Date
      histrawD=ncraw{'PRC_Date'};
      histedD=nced{'PRC_Date'};
      histrawD(nrh,:)=update;
      histedD(neh,:)=update;
      ncraw{'PRC_Date'}(:,:)=histrawD(:,:);
      nced{'PRC_Date'}(:,:)=histedD(:,:);
      
      %%now change the Act_Code
      histrawAC=ncraw{'Act_Code'};
      histedAC=nced{'Act_Code'};
      histrawAC(nrh,:)='PE';
      histedAC(neh,:)='PE';
      ncraw{'Act_Code'}(:,:)=histrawAC(:,:);
      nced{'Act_Code'}(:,:)=histedAC(:,:);

      %%now change the Act_Parm
      histrawAP=ncraw{'Act_Parm'};
      histedAP=nced{'Act_Parm'};
      histrawAP(nrh,:)='LONG';
      histedAP(neh,:)='LONG';
      ncraw{'Act_Parm'}(:,:)=histrawAP(:,:);
      nced{'Act_Parm'}(:,:)=histedAP(:,:);

      %%now change the Aux_ID
      histrawAID=ncraw{'Aux_ID'};
      histedAID=nced{'Aux_ID'};
      histrawAID(nrh)=0.;
      histedAID(neh)=0.;
      ncraw{'Aux_ID'}(:)=histrawAID(:);
      nced{'Aux_ID'}(:)=histedAID(:);
      
      %%now change the Flag_Severity
      histrawFS=ncraw{'Flag_severity'};
      histedFS=nced{'Flag_severity'};
      histrawFS(nrh)=0;
      histedFS(neh)=0;
      ncraw{'Flag_severity'}(:)=histrawFS(:);
      nced{'Flag_severity'}(:)=histedFS(:);
      
      %%now change the Previous_Val
      histrawPV=ncraw{'Previous_Val'};
      histedPV=nced{'Previous_Val'};
      l=num2str(ncraw{'longitude'}(1));
      ls='          ';
      ls(1:min(10,length(l)))=l(1:min(10,length(l)));
      histrawPV(nrh,1:10)=ls;
      histedPV(neh,1:10)=ls;
      ncraw{'Previous_Val'}(:,:)=histrawPV(:,:);
      nced{'Previous_Val'}(:,:)=histedPV(:,:);

      %%finally, change the longitude in both these files:
            ncraw{'longitude'}(1)=c360l(j);
            nced{'longitude'}(1)=c360l(j);
%       ncraw{'longitude'}(1)=ncraw{'longitude'}(1)+360;
%       nced{'longitude'}(1)=nced{'longitude'}(1)+360;
     end
  close(nced)
  close(ncraw)

  end
    end
end

%% 6 fixCSID - CSID in some files has been corrupted. Check all files and
% change the csid where necessary to match station_number

for i=1:length(keysdata.stnnum)
        
    i=i
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw)
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    srfccodes=nc{'SRFC_Code'};
    srfcparm=nc{'SRFC_Parm'};
    
    kk=strmatch('CSID',srfccodes(:,:));
    if(~isempty(kk))
        csid=str2num(srfcparm(kk,:));
        if(csid~=keysdata.stnnum(i))
            ss2='          ';
            ss=num2str(keysdata.stnnum(i));
            ss2(1:length(ss))=ss;
            srfcparm(kk,1:10)=ss2;
            nc{'SRFC_Parm'}(:,:)=srfcparm(:,:);
        end
    else
        errmsg('error - no csid')
        s=srfccodes(:,:)
        pause
    end
    close(nc)
    %then do the raw file (and fix the update date here...)
    raw=1;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw)
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    srfccodes=nc{'SRFC_Code'};
    srfcparm=nc{'SRFC_Parm'};
    %     clo=datestr(clock,24);
    %     update=[clo(1:2) clo(4:5) clo(7:10)];
    %As of August, 2014, the format has been changed to yyyymmdd to agree with
    %NOAA formats. Bec Cowley
    update = datestr(now,'yyyymmdd');
    
    nc{'Up_date'}(1:length(update))=update(:);    
    kk=strmatch('CSID',srfccodes(:,:));
    if(~isempty(kk))
        csid=str2num(srfcparm(kk,:));
        if(csid~=keysdata.stnnum(i))
            ss2='          ';
            ss=num2str(keysdata.stnnum(i));
            ss2(1:length(ss))=ss;
            srfcparm(kk,1:length(ss))=ss;
            nc{'SRFC_Parm'}(:,:)=srfcparm(:,:);
        end
    else
        errmsg('error - no csid')
        s=srfccodes(:,:)
        pause
    end
    close(nc)
end


%% 7 fixqualityvalues - 
% where WOCE data has arrived with good data flagged
% below bad data, we need to remove the quality flags and retain the
% station numbers for further checking...

for i=1:length(keysdata.stnnum)
        
    i=i
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw)
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    pqual=nc{'ProfQP'}(:);
    proft=nc{'Prof_Type'}(:);
    tp=strmatch(proft,'TEMP');
    nprof=nc{'No_Prof'}(:);
    if(nprof>1)
        pq=str2num(pqual(tp,:));
    else
        pq=str2num(pqual)
    end
    kk=find(pq == 3 | pq == 4);
    if(~isempty(pq))
        gg=find(pq == 1 | pq == 2 | pq == 0 | pq ==5)
    end
    if(any(gg>kk(1)))
       pqual(tp,k(1):gg(end))='0'; 
       nc{'ProfQP'}(:)=pqual;
    end
    close(nc)
end


%% 8 repair keys file problems with date/time:

filea='mastertasmanMQNC_keys.nc' % file with the BAD keys!
 fileb='holdmasterstages/BOMtasmannc_keys.nc'  %file with the GOOD keys!
% fileb='holdmasterstages/addwocetasmanWNC_keys.nc'

 lnga=getnc(filea,'obslng');
 clnga=getnc(filea,'c360long');
 lata=getnc(filea,'obslat');
 stnnoa=getnc(filea,'stn_num');
 stnnoa=str2num(stnnoa);
da=getnc(filea,'obs_d');
ya=getnc(filea,'obs_y');
ma=getnc(filea,'obs_m');
ta=getnc(filea,'obs_t');
% 
 lngb=getnc(fileb,'obslng');
 clngb=getnc(fileb,'c360long');
 latb=getnc(fileb,'obslat');
 stnnob=getnc(fileb,'stn_num');
 stnnob=str2num(stnnob);
db=getnc(fileb,'obs_d');
yb=getnc(fileb,'obs_y');
mb=getnc(fileb,'obs_m');
tb=getnc(fileb,'obs_t');

%  stnnoc=getnc(filec,'stn_num');
%  stnnoc=str2num(stnnoc);
%find the common stations and their indices in each matrix
[icomm,ia,ib]=intersect(stnnoa,stnnob,'rows');
% [icomm,ic,ib]=intersect(stnnoc,stnnob,'rows');

%make the missing datasource equal the non-missing datasource
 lnga(ia)=lngb(ib);
 clnga(ia)=clngb(ib);
 lata(ia)=latb(ib);
da(ia,:)=db(ib,:);
ya(ia,:)=yb(ib,:);
ma(ia,:)=mb(ib,:);
ta(ia,:)=tb(ib,:);

%write it out to the keys file
nc=netcdf(filea,'write');
 nc{'c360long'}(:)=clnga(:);
 nc{'obslng'}(:)=lnga(:);
 nc{'obslat'}(:)=lata(:);
nc{'obs_d'}(:)=da(:);
nc{'obs_m'}(:)=ma(:);
nc{'obs_y'}(:)=ya(:);
nc{'obs_t'}(:)=ta(:);
close(nc)
%% 9 Fix the overwritten files from tasman master set. BOM files were
% overwritten with WOCE files with the same numbers
% may have to run this bit by bit

% Find the BOM and woce profiles with the same numbers
filec='mastertasmanMQNC_keysQC.nc' % file with the BAD keys!
fileb='holdmasterstages/BOMtasmanMQNC_keys.nc'  
filea='holdmasterstages/addwocetasmanWNC_keys.nc'
stnnoa=getnc(filea,'stn_num');
stnnoa=str2num(stnnoa);
a360=getnc(filea,'c360long');
alng=getnc(filea,'obslng');
alat=getnc(filea,'obslat');
aday=getnc(filea,'obs_d');
amn=getnc(filea,'obs_m');
ayr=getnc(filea,'obs_y');
atime=getnc(filea,'obs_t');
adata_t=getnc(filea,'data_t');
acalls=getnc(filea,'callsign');
aaut=getnc(filea,'autoqc');
aprior=getnc(filea,'priority');
aflag=getnc(filea,'d_flag');
asource=getnc(filea,'data_source');

stnnob=getnc(fileb,'stn_num');
stnnob=str2num(stnnob);
b360=getnc(fileb,'c360long');
blng=getnc(fileb,'obslng');
blat=getnc(fileb,'obslat');
bday=getnc(fileb,'obs_d');
bmn=getnc(fileb,'obs_m');
byr=getnc(fileb,'obs_y');
btime=getnc(fileb,'obs_t');
bdata_t=getnc(fileb,'data_t');
bcalls=getnc(fileb,'callsign');
baut=getnc(fileb,'autoqc');
bprior=getnc(fileb,'priority');
bflag=getnc(fileb,'d_flag');
bsource=getnc(fileb,'data_source');

stnnoc=getnc(filec,'stn_num');
stnnoc=str2num(stnnoc);
[icomm,ia,ib]=intersect(stnnoa,stnnob,'rows');
%[ico,ibc,ic]=intersect(stnnob,stnnoc,'rows');

%open the master keys file for writing
nc=netcdf(filec,'write');

%Assign new numbers to the BOM stations
%load('/home/ghost2/gronell/uniqueid.mat') %loads uniqueid
uniqueid=88163692;
for i=1:length(ib)
    stnnobold=stnnob(ib(i))
    uniqueid
    
     clear filenam
    filenam='mastertasmanMQNC';
    nss=num2str(uniqueid);
    
%copy the BOM backup to the new number in the master file
for j=1:2:length(nss);

	if(j+1>length(nss))
        if(ispc)
filenam=[filenam '\' nss(j)];
        else
filenam=[filenam '/' nss(j)]; 
        end
    else	
        if(ispc)
filenam=[filenam '\' nss(j:j+1)];
        else
filenam=[filenam '/' nss(j:j+1)];
        end
	end
end

filenam1=[filenam 'ed.nc']; 
filenam2=[filenam 'raw.nc'];
% try
%     newdatabasefile=netcdf([filenam1 ],'noclobber');
% catch
%     mkdir([filenam1(1:length(filenam1)-8)])
% end
   
%now the backup files
clear filenamold
nssold=num2str(stnnobold);
filenamold='holdmasterstages/BOMtasmanMQNC';
for j=1:2:length(nssold);

	if(j+1>length(nssold))
        if(ispc)
filenamold=[filenamold '\' nssold(j)];
        else
filenamold=[filenamold '/' nssold(j)]; 
        end
    else	
        if(ispc)
filenamold=[filenamold '\' nssold(j:j+1)];
        else
filenamold=[filenamold '/' nssold(j:j+1)];
        end
	end
end

filenam1old=[filenamold 'ed.nc']; 
filenam2old=[filenamold 'raw.nc'];


% eval(['!cp ./' filenam1old ' ' filenam1])
% eval(['!cp ./' filenam2old ' ' filenam2])

%find the keys record in the master file that needs fixing
imaster=find(stnnoc==stnnob(ib(i)));
if ~isempty(imaster)
%update the keys file
disp Fixing!
stn=[num2str(uniqueid) '  '];
nc{'stn_num'}(imaster(1),1:10)=stn;
nc{'c360long'}(imaster(1),:)=b360(ib(i),:);
nc{'obslng'}(imaster(1),:)=blng(ib(i),:);
nc{'obslat'}(imaster(1),:)=blat(ib(i),:);
nc{'obs_d'}(imaster(1),:)=bday(ib(i),:);
nc{'obs_m'}(imaster(1),:)=bmn(ib(i),:);
nc{'obs_y'}(imaster(1),:)=byr(ib(i),:);
nc{'obs_t'}(imaster(1),:)=btime(ib(i),:);
nc{'data_t'}(imaster(1),:)=bdata_t(ib(i),:);
nc{'data_source'}(imaster(1),:)=bsource(ib(i),:);
nc{'priority'}(imaster(1))=bprior(ib(i));
nc{'autoqc'}(imaster(1))=baut(ib(i));
nc{'d_flag'}(imaster(1),1)='N';
nc{'callsign'}(imaster(1),:)=bcalls(ib(i),:);

%for stn 3666 only as it was only written once, and therefore the woce
%version is missing
if length(imaster)==1
%     eval('!cp /home/ghost1/iotaonlinebu/tasmanonlinebu/newaddwocetasmanWNC/36/66ed.nc mastertasmanMQNC/36/66ed.nc');
%     eval('!cp /home/ghost1/iotaonlinebu/tasmanonlinebu/newaddwocetasmanWNC/36/66raw.nc mastertasmanMQNC/36/66raw.nc'); 
  %add this to the keys
  ncasts=nc('N_Casts')+1;
nc{'stn_num'}(ncasts,1:10)='3666      ';
nc{'c360long'}(ncasts,:)=a360(ia(i),:);
nc{'obslng'}(ncasts,:)=alng(ia(i),:);
nc{'obslat'}(ncasts,:)=alat(ia(i),:);
nc{'obs_d'}(ncasts,:)=aday(ia(i),:);
nc{'obs_m'}(ncasts,:)=amn(ia(i),:);
nc{'obs_y'}(ncasts,:)=ayr(ia(i),:);
nc{'obs_t'}(ncasts,:)=atime(ia(i),:);
nc{'data_t'}(ncasts,:)=adata_t(ia(i),:);
nc{'data_source'}(ncasts,:)=asource(ia(i),:);
nc{'priority'}(ncasts,:)=aprior(ia(i));
nc{'autoqc'}(ncasts,:)=aaut(ia(i));
nc{'d_flag'}(ncasts,1)='N';
nc{'callsign'}(ncasts,:)=acalls(ia(i),:);
end
end
%increase uniqueid
uniqueid=uniqueid+1;
end

% save /home/ghost2/gronell/uniqueid.mat uniqueid
close(nc)

% add a history record to the BOM files that have had ID changed
%uniqueid=88163692;
    c=clock;
    if length(num2str(c(3)))<2
        dd=['0' num2str(c(3))];
    else
        dd=num2str(c(3));
    end
    if length(num2str(c(2)))<2
        mm=['0' num2str(c(2))];
    else
        mm=num2str(c(2));
    end
    update=[num2str(c(1)) mm dd];
for i=3:length(ib)
    stnnobold=stnnob(ib(i))
    uniqueid
    
     clear filenam
    filenam='mastertasmanMQNC';
    nss=num2str(uniqueid);
    
for j=1:2:length(nss);

	if(j+1>length(nss))
        if(ispc)
filenam=[filenam '\' nss(j)];
        else
filenam=[filenam '/' nss(j)]; 
        end
    else	
        if(ispc)
filenam=[filenam '\' nss(j:j+1)];
        else
filenam=[filenam '/' nss(j:j+1)];
        end
	end
end

filenam1=[filenam 'ed.nc']; 
filenam2=[filenam 'raw.nc'];

nced=netcdf(filenam1,'write');
ncraw=netcdf(filenam2,'write');

      %%increment the number of histories:
      ncraw{'Num_Hists'}(1)=ncraw{'Num_Hists'}(1)+1;
      nced{'Num_Hists'}(1)=nced{'Num_Hists'}(1)+1;
      if(nced{'Num_Hists'}(1)>100)
          nced{'Num_Hists'}(1)=100;
      end
      nrh=ncraw{'Num_Hists'}(1);
      neh=nced{'Num_Hists'}(1);
     
      clear hist*
      %%change the history section, one bit at a time..
      %first change the ident code...
      histrawIC=ncraw{'Ident_Code'};
      histedIC=nced{'Ident_Code'};
      histrawIC(nrh,:)=DATA_QC_SOURCE;
      histedIC(neh,:)=DATA_QC_SOURCE;
      ncraw{'Ident_Code'}(:,:)=histrawIC(:,:);
      nced{'Ident_Code'}(:,:)=histedIC(:,:);
      
      %%now change the PRC_Code
      histrawPRC=ncraw{'PRC_Code'};
      histedPRC=nced{'PRC_Code'};
      histrawPRC(nrh,:)='CSCB';
      histedPRC(neh,:)='CSCB';
      ncraw{'PRC_Code'}(:,:)=histrawPRC(:,:);
      nced{'PRC_Code'}(:,:)=histedPRC(:,:);
      
      %%now change the version:
      histrawV=ncraw{'Version'};
      histedV=nced{'Version'};
      histrawV(nrh,:)='1.0 ';
      histedV(neh,:)='1.0 ';
      ncraw{'Version'}(:,:)=histrawV(:,:);
      nced{'Version'}(:,:)=histedV(:,:);

      %%now change the PRC_Date
      histrawD=ncraw{'PRC_Date'};
      histedD=nced{'PRC_Date'};
      histrawD(nrh,:)=update;
      histedD(neh,:)=update;
      ncraw{'PRC_Date'}(:,:)=histrawD(:,:);
      nced{'PRC_Date'}(:,:)=histedD(:,:);
      
      %%now change the Act_Code
      histrawAC=ncraw{'Act_Code'};
      histedAC=nced{'Act_Code'};
      histrawAC(nrh,:)='ID';
      histedAC(neh,:)='ID';
      ncraw{'Act_Code'}(:,:)=histrawAC(:,:);
      nced{'Act_Code'}(:,:)=histedAC(:,:);

      %%now change the Act_Parm
      histrawAP=ncraw{'Act_Parm'};
      histedAP=nced{'Act_Parm'};
      histrawAP(nrh,:)='CSID';
      histedAP(neh,:)='CSID';
      ncraw{'Act_Parm'}(:,:)=histrawAP(:,:);
      nced{'Act_Parm'}(:,:)=histedAP(:,:);

      %%now change the Aux_ID
      histrawAID=ncraw{'Aux_ID'};
      histedAID=nced{'Aux_ID'};
      histrawAID(nrh)=0.;
      histedAID(neh)=0.;
      ncraw{'Aux_ID'}(:)=histrawAID(:);
      nced{'Aux_ID'}(:)=histedAID(:);
      
      %%now change the Flag_Severity
      histrawFS=ncraw{'Flag_severity'};
      histedFS=nced{'Flag_severity'};
      histrawFS(nrh)=0;
      histedFS(neh)=0;
      ncraw{'Flag_severity'}(:)=histrawFS(:);
      nced{'Flag_severity'}(:)=histedFS(:);
      
      %%now change the Previous_Val
      histrawPV=ncraw{'Previous_Val'};
      histedPV=nced{'Previous_Val'};
      l=num2str(stnnobold);
      ls='          ';
      ls(1:min(10,length(l)))=l(1:min(10,length(l)));
      histrawPV(nrh,1:10)=ls;
      histedPV(neh,1:10)=ls;
      ncraw{'Previous_Val'}(:,:)=histrawPV(:,:);
      nced{'Previous_Val'}(:,:)=histedPV(:,:);

      close(nced)
      close(ncraw)
      uniqueid=uniqueid+1;
end



%% 10 fix the priority and source in the devil data - wrongly encoded as
% cruise ID and 0 when first started mporting devil data using matlab.

  for i=1:length(keysdata.stnnum)
      i=i
        raw=0;
        clear filen
        clear filenam
        filen=getfilename(num2str(keysdata.stnnum(i)),raw);
        if(ispc)
           filenam=[prefix '\' filen];
        else
           filenam=[prefix '/' filen];
        end

        srfcc=getnc(filenam,'SRFC_Code');
        srfcp=getnc(filenam,'SRFC_Parm');
        srfqp=getnc(filenam,'SRFC_Q_Parm');
        
        kk=strmatch('IOTA',srfcc);
        if(~isempty(kk))
            srfcp(kk,:)='CSIRO     ';
            srfqp(kk,1)='1';
        end
        nc=netcdf(filenam,'write');
        nc{'SRFC_Parm'}(:,:)=srfcp;
        nc{'SRFC_Q_Parm'}(:,:)=srfqp;
        close(nc)
        
        raw=1;
        clear filen
        clear filenam
        filen=getfilename(num2str(keysdata.stnnum(i)),raw);
        if(ispc)
           filenam=[prefix '\' filen];
        else
           filenam=[prefix '/' filen];
        end

        srfcc=getnc(filenam,'SRFC_Code');
        srfcp=getnc(filenam,'SRFC_Parm');
        srfqp=getnc(filenam,'SRFC_Q_Parm');
        
        kk=strmatch('IOTA',srfcc);
        if(~isempty(kk))
            srfcp(kk,:)='CSIRO     ';
            srfqp(kk,1)='1';
        end
        nc=netcdf(filenam,'write');
        nc{'SRFC_Parm'}(:,:)=srfcp;
        nc{'SRFC_Q_Parm'}(:,:)=srfqp;
        close(nc)
  end
   
%% 11 Fix profiles with duplicated data
% Remove the second set of data from these. 

filen='adda3levitustasmanMQNC/86/20/71/09';

nced=netcdf([filen 'ed.nc'],'write');
ncraw=netcdf([filen 'raw.nc'],'write');

dep=nced{'No_Depths'}(:);
nprof=nced{'No_Prof'}(:);
%fix the no depths
nced{'No_Depths'}(:)=dep/2;
ncraw{'No_Depths'}(:)=dep/2;

for a=1:nprof
    %fix the depthpress
    nced{'Depthpress'}(a,(dep/2)+1:dep)=-99.99;
    ncraw{'Depthpress'}(a,(dep/2)+1:dep)=-99.99;

    %fix the profparm
    nced{'Profparm'}(a,1,(dep/2)+1:dep,1,1)=-99.99;
    ncraw{'Profparm'}(a,1,(dep/2)+1:dep,1,1)=-99.99;
    
    %fix the dpressQ
    nced{'DepresQ'}(a,(dep/2)+1:dep,1)=' ';
    ncraw{'DepresQ'}(a,(dep/2)+1:dep,1)=' ';
    
    %fix the profQP
    nced{'ProfQP'}(a,1,(dep/2)+1:dep,1,1,1)=' ';
    ncraw{'ProfQP'}(a,1,(dep/2)+1:dep,1,1,1)=' ';
    

    
end
close(nced)
close(ncraw)
disp DONE!


%% 12 list files that HAVE NOT BEEN DEPTH CORRECTED!!!

% open each file and read the surf codes to find ptyp or peq$
%  if either ends in 1 or is blank, list station number to variable and
%  output at end to mat file.
clear holdstnno
datat=getnc(file,'data_t');
dtk=strmatch('XB',datat);
%lj=intersect(stnno(dtk),holdstnno);
source=getnc(file,'data_source');
%dts=strmatch('levitus',source);
m=0
for i=1:length(dtk)
    if(~isempty(strmatch('levitus',deblank(source(dtk,:)))))
           raw=0;
        filen=getfilename(num2str(keysdata.stnnum(dtk(i))),raw);
        if(ispc)
           filenam=[prefix '\' filen];
        else
           filenam=[prefix '/' filen];
        end
      deepd=getnc(filenam,'Deep_Depth');
      if(deepd<=900 & deepd >=200)
        surfc=getnc(filenam,'SRFC_Code');
        surfp=getnc(filenam,'SRFC_Parm');
        kk=strmatch('PTY$',surfc);
        ptype=[];
        if (~isempty(kk))
            ptype=deblank(surfp(kk,:));
        else
            kk=strmatch('PEQ$',surfc);
            if(~isempty(kk))
                ptype=deblank(surfp(kk,:));
            end
        end
        if(isempty(ptype) | ptype(end)==1)
            i=i
            m=m+1
          holdstnno(m)=keysdata.stnnum(i);
        end
      end
    end
end
save nodepthfixstnnums.mat holdstnno
disp('Done!')
%% 13 now check for the max depth of the profiles above (if hasn't been done
% already)
m=0
clear holdfinalstnno
for i=1:length(lj)
    raw=0;
    filen=getfilename(num2str(lj(i)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    deepd=getnc(filenam,'Deep_Depth');
    if(deepd<=900 & deepd >=200)
        m=m+1
        i=i
        holdfinalstnno(m)=lj(i);
    end
end
save nodepthfixstnnumsfinal.mat holdfinalstnno
disp('Done!')


%% 14 fix longitudes in bernadettes' data - can be adapted to any data set
% that needs wholesale changes to position

%  note: kk is index to those profiles needing change in the keysdata
%  set.

% adapted to correct Sprightly longitudes (all set to 114.6833 for some
% reason) AT: 17/9/08

%kk=find(keysdata.obslon>300);
ssn=keysdata.stnnum;
kk=1:length(keysdata);
lon=keysdata.obslon;

for i=1:length(kk)
    raw=0;
    filen=getfilename(num2str(ssn(kk(i))),raw)
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    raw=1;
    filen=getfilename(num2str(ssn(kk(i))),raw)
    if(ispc)
        filenamr=[prefix '\' filen];
    else
        filenamr=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    ncr=netcdf(filenamr,'write');
    longi=nc{'longitude'}(:);
    actc=nc{'Act_Code'}(:,:);
    prevv=nc{'Previous_Val'}(:,:);
    
    ll=strmatch('PE',actc);
    if(~isempty(ll))
        pv=prevv(ll);
        pvf=str2num(pv);
        if(pvf~=lon(i))
            pause
        end
    end
    
    
 %   longi=longi-90.;
    if(longi~=lon(kk(i)))
        pause
    end
    nc{'longitude'}(:)=longi;
    ncr{'longitude'}(:)=longi;
    
    close(nc);
    close(ncr);
end

filekeys=[prefix '_keys.nc']
nc=netcdf(filekeys,'write');
nc{'obslng'}(:)=lon(:);
close(nc)

%% 15 further fixes for Bernadette's xctd data...

 latnew=getnc(filenew,'obslat');
 lonnew=getnc(filenew,'obslng');
 daynew=getnc(filenew,'obs_d');
 monthnew=getnc(filenew,'obs_m');
 yearnew=getnc(filenew,'obs_y');
 timenew=getnc(filenew,'obs_t');
 month=getnc(filen,'obs_m');
 day=getnc(filen,'obs_d');
 time=getnc(filen,'obs_t');
 year=getnc(filen,'obs_y');

 lonnewkeys=obslon;
 
for i=1:length(yearnew)
    kk=find(yearnew(i)==year & monthnew(i)==month & daynew(i)==day & latnew(i)==obslat);
    if(length(kk)>1)
        hold==kk
        pause
    elseif(length(kk)==1)
        if(lonnew(i)~=obslon(kk))
            ssn=keysdata.stnnum(kk);
            
            raw=0;
            filen=getfilename(num2str(ssn),raw)
            if(ispc)
                filenam=[prefix '\' filen];
            else
                filenam=[prefix '/' filen];
            end
            raw=1;
            filen=getfilename(num2str(ssn),raw)
            if(ispc)
                filenamr=[prefix '\' filen];
            else
                filenamr=[prefix '/' filen];
            end

            nc=netcdf(filenam,'write');
            ncr=netcdf(filenamr,'write');
            longi=nc{'longitude'}(:);
            longi=lonnew(i);

            nc{'longitude'}(:)=longi;
            ncr{'longitude'}(:)=longi;
            lonnewkeys(kk)=longi

            close(nc);
            close(ncr);
        end
    end
end
 filekeys=[prefix '_keys.nc']
nc=netcdf(filekeys,'write');
nc{'obslng'}(:)=lonnewkeys(:);
close(nc)

%% 16 Fix raw files that need depth correction applied

filen = input('enter the file for correction:','s');

%get a list of station names
stn = getnc([filen '_keys.nc'],'stn_num');
% and a list of data types
dt = getnc([filen '_keys.nc'],'data_t');
% index by XBT/BA
xb = strmatch('BA',dt);
% xb = strmatch('XB',dt);
% get today's date    
    c=clock;
    if length(num2str(c(3)))<2
        dd=['0' num2str(c(3))];
    else
        dd=num2str(c(3));
    end
    if length(num2str(c(2)))<2
        mm=['0' num2str(c(2))];
    else
        mm=num2str(c(2));
    end
    update=[num2str(c(1)) mm dd];

b=0;c=0;

for a = 1:length(xb)
%turn them into directories
    raw = 1;
    stnraw=getfilename(stn(xb(a),:),raw);
    stnraw=[filen '/' stnraw];
    raw=0;
    stned=getfilename(stn(xb(a),:),raw);
    stned=[filen '/' stned]
    
% load up the depths
    nced = netcdf(stned,'write');
    ncraw = netcdf(stnraw,'write');
    rawd = ncraw{'Depthpress'}(:);
    edd = nced{'Depthpress'}(:);
    
    %check for nans
%     if length(edd) > length(rawd)
%         edd = repnan(edd,0);
%         inan = find(edd == 0);
%         edd = edd(1:inan-1);
%         if length(edd) > length(rawd)
%             return
%         end
%     end
    
% check the difference
    [rr,ir]=find(rawd > -99);
    [ee,ie]=find(edd > -99);
    try
        diffd = edd(ie)./rawd(ir);
    catch
        try
            diffd = edd(ie)./rawd(1:length(ir)+1);
        catch
            %write this to the to be fixed file
            c=c+1;
            stnstofix(c,:)= stn(xb(a),:);
            close(nced)
            close(ncraw)
            continue
        end

    end
    meand = nanmean(diffd)
    

    if meand < 0.9999 | meand > 1.000001  %there is a difference

        %check the size of the depth arrays. An extra point was
        %interpolated in some xbts in the past at 3.7m. This needs to be
        %removed in the ed file.
        if length(ie) == length(ir)+1
            %remove the extra data point from depth, temperature and
            %quality flags
            irem = find(edd > 3.81 & edd < 3.83);
            if isempty(irem)
                irem = find(edd > 3.69 & edd < 3.71);
                if isempty(irem)
                  return
                end
            end
            edd(irem:end-1) = edd(irem+1:end);
            nced{'Profparm'}(1,1,irem:end-1,1,1) = nced{'Profparm'}(1,1,irem+1:end,1,1);
            nced{'DepresQ'}(1,irem:end-1,:) = nced{'DepresQ'}(1,irem+1:end,1,:);
            nced{'ProfQP'}(1,1,irem:end-1,1,1,:) = nced{'ProfQP'}(1,1,irem+1:end,1,1,:);
            [ee,ie]=find(edd > -99);
        end
        
        %check diffd and meand - should be equal to 1 now.
        diffd = edd(ie)./rawd(ir);
        meand = nanmean(diffd)
        if meand > 0.99999 & meand < 1.000001
            close(nced)
            close(ncraw)
            continue  %go to the next record, this doesn't need correcting
     
        elseif meand > 1.0335 & meand < 1.0337  %has the 1.0336 correction

            b=b+1;
            %write the station number to a list
            stfixed(b,:) = stn(xb(a),:);
            %correct the raw file and flag appropriately
            rawd(ir) = edd(ie);
            ncraw{'Depthpress'}(1,:)=rawd(:);
            nced{'No_Depths'}(:)=length(ie);
            ncraw{'No_Depths'}(:) = nced{'No_Depths'}(:);
            nced{'Deep_Depth'}(:) = edd(ie(end));
            ncraw{'Deep_Depth'}(:) = nced{'Deep_Depth'}(:);
            
            %fix Aux_ID depth values to suit corrected depths
            num_hists=ncraw{'Num_Hists'}(:);
            if num_hists > 0
                auxid = ncraw{'Aux_ID'}(1:num_hists);
                auxid = auxid * 1.0336;
                ncraw{'Aux_ID'}(1:num_hists) = auxid;
            end
            
            %if not already done, add histories to raw
            dpr = ncraw{'Act_Code'}(:);
            if isempty(strmatch('DP',dpr))
                %add histories to raw
                num_hists=ncraw{'Num_Hists'}(:);
                num_hists=num_hists+1;
                ncraw{'Num_Hists'}(:)=num_hists;
                ncraw{'Act_Code'}(num_hists,:)='DP';
                ncraw{'Ident_Code'}(num_hists,:)= DATA_QC_SOURCE;
                ncraw{'PRC_Code'}(num_hists,:)='CSCB' ;
                ncraw{'Version'}(num_hists,:)='1.0 ';
                ncraw{'PRC_Date'}(num_hists,:)=update;
                ncraw{'Act_Parm'}(num_hists,:)='DEPH';
                ncraw{'Aux_ID'}(num_hists)=0;
                ncraw{'Flag_severity'}(num_hists)=0;
                ncraw{'Previous_Val'}(num_hists,:)='999.999   ' ;
            end

            %if not already done, add histories to ed
            dpc = nced{'Act_Code'}(:);
            if isempty(strmatch('DP',dpc))
                num_hists=nced{'Num_Hists'}(:);
                num_hists=num_hists+1;
                nced{'Num_Hists'}(:)=num_hists(:);
                nced{'Act_Code'}(num_hists,:)='DP';
                nced{'Ident_Code'}(num_hists,:)= DATA_QC_SOURCE;
                nced{'PRC_Code'}(num_hists,:)='CSCB' ;
                nced{'Version'}(num_hists,:)='1.0 ';
                nced{'PRC_Date'}(num_hists,:)=update;
                nced{'Act_Parm'}(num_hists,:)='DEPH';
                nced{'Aux_ID'}(num_hists)=0;
                nced{'Flag_severity'}(num_hists)=0;
                nced{'Previous_Val'}(num_hists,:)='999.999   ' ;
            end

            %If not already done, add appropriate surface codes to ed
            fra = nced{'SRFC_Code'}(:);
            if isempty(strmatch('DPC$',fra))
                nsurfc = nced{'Nsurfc'}(:);
                %             if isempty(nsurfc)  %no nsurfc variable in netcdf file!!
                %                 scode = nced{'SRFC_Code'}(:);
                %                 ic=strmatch('    ',scode);
                %                 nced{'Nsurfc'} = nclong('Single');
                %                 nced{'Nsurfc'}(:) = ic(1) - 1;
                %                 nsurfc = nced{'Nsurfc'}(:);
                %             end
                nsurfc=nsurfc+1;
                nced{'Nsurfc'}(:) = nsurfc;
                nced{'SRFC_Code'}(nsurfc,:)='DPC$';
                nced{'SRFC_Q_Parm'}(nsurfc,:)='1';
                if strmatch('PEQ$',fra)  %ie, we know the probe type and correction was done
                    nced{'SRFC_Parm'}(nsurfc,:)='04        ';
                else  %we don't know the probe type, but correction was done
                    nced{'SRFC_Parm'}(nsurfc,:)='05        ';
                end
            end

            % and the surface code for fall rate equations
            if isempty(strmatch('FRA$',fra))
                nsurfc=nced{'Nsurfc'}(:);
                nsurfc=nsurfc+1;
                nced{'Nsurfc'}(:) = nsurfc;
                nced{'SRFC_Code'}(nsurfc,:)='FRA$';
                nced{'SRFC_Q_Parm'}(nsurfc,:)='1';
                nced{'SRFC_Parm'}(nsurfc,:)='1.0336    ';
            end

            %copy surface codes to raw (these should only be different where we
            %have corrected depths
            ncraw{'Nsurfc'}(:) = nced{'Nsurfc'}(:);
            ncraw{'SRFC_Code'}(:) = nced{'SRFC_Code'}(:);
            ncraw{'SRFC_Parm'}(:) = nced{'SRFC_Parm'}(:);
            ncraw{'SRFC_Q_Parm'}(:) = nced{'SRFC_Q_Parm'}(:);

            close(nced)
            close(ncraw)
        else
            %this file probably has duplicate depths or missing depths,
            %write to file for fixing later
            c=c+1;
            stnstofix(c,:)= stn(xb(a),:);
            close(nced)
            close(ncraw)
            continue
        end
    else
        close(nced)
        close(ncraw)
    end
end
%save the station number
xbstn=stn(xb,:);
save rawdepthcorrfixed2.mat xbstn stfixed stnstofix


%% 17 fix xbt data with extra or missing data points in the ed files
load  xbmissextra2list.txt                           %rawdepthcorrfixed
filen = 'mastertasmanMQNC'
b=0;
stnstofix=num2str(xbmissextra2list);


% to just fix 3.7m - use this code:
% for a=1:length(stnstofix)
% turn them into directories
%     raw = 1;
%     stnraw=getfilename(stnstofix(a,:),raw);
%     stnraw=[filen '/' stnraw];
%       raw=0;
%     stned=getfilename(stnstofix(a,:),raw);
%     stned=[filen '/' stned]
%     nced = netcdf(stned,'write');
%     edd = nced{'Depthpress'}(:);
%     ncraw = netcdf(stnraw,'write');
%     rawd = ncraw{'Depthpress'}(:);
% 
%     irem = find(edd > 3.69 & edd < 3.71);
%     edd(irem:end-1) = edd(irem+1:end);     
%     
%     nced{'Depthpress'}(:,:) = edd(:,:)
%     nced{'Profparm'}(1,1,irem:end-1,1,1) = nced{'Profparm'}(1,1,irem+1:end,1,1);
%     nced{'DepresQ'}(1,irem:end-1,:) = nced{'DepresQ'}(1,irem+1:end,1,:);
%     nced{'ProfQP'}(1,1,irem:end-1,1,1,:) = nced{'ProfQP'}(1,1,irem+1:end,1,1,:);
%     [ee,ie]=find(edd > -99);
%     nced{'Deep_Depth'}(1,:)=edd(ie(end));
%     close(nced)
%     
%     now do raw..
%     irem = find(rawd > 3.69 & rawd < 3.71);
%     rawd(irem:end-1) = rawd(irem+1:end);     
%     
%     ncraw{'Depthpress'}(:,:) = rawd(:,:)
%     ncraw{'Profparm'}(1,1,irem:end-1,1,1) = ncraw{'Profparm'}(1,1,irem+1:end,1,1);
%     ncraw{'DepresQ'}(1,irem:end-1,:) = ncraw{'DepresQ'}(1,irem+1:end,1,:);
%     ncraw{'ProfQP'}(1,1,irem:end-1,1,1,:) = ncraw{'ProfQP'}(1,1,irem+1:end,1,1,:);
%     [ee,ie]=find(rawd > -99);
%     ncraw{'Deep_Depth'}(1,:)=rawd(ie(end));
%     close(ncraw)
% end
%end of just fixing 3.7m...

% get today's date    
    c=clock;
    if length(num2str(c(3)))<2
        dd=['0' num2str(c(3))];
    else
        dd=num2str(c(3));
    end
    if length(num2str(c(2)))<2
        mm=['0' num2str(c(2))];
    else
        mm=num2str(c(2));
    end
    update=[num2str(c(1)) mm dd];

for a=1:length(stnstofix)
%turn them into directories
    raw = 1;
    stnraw=getfilename(stnstofix(a,:),raw);
    stnraw=[filen '/' stnraw];
    raw=0;
    stned=getfilename(stnstofix(a,:),raw);
    stned=[filen '/' stned]
    
    nced = netcdf(stned,'write');
    ncraw = netcdf(stnraw,'write');
    rawd = ncraw{'Depthpress'}(:);
    edd = nced{'Depthpress'}(:);

    %remove the extra data point from depth, temperature and
    %quality flags
%     irem = find(edd > 3.81 & edd < 3.83);
%     if isempty(irem)
%         irem = find(edd > 3.69 & edd < 3.71);
%         if isempty(irem)
%             b=b+1;
%             stnnotfixed(b,:)=stnstofix(a,:);
%             close(nced)
%             close(ncraw)
%             continue
%         end
%     end
%     if ~isempty(irem)
%         edd(irem:end-1) = edd(irem+1:end);
%         nced{'Profparm'}(1,1,irem:end-1,1,1) = nced{'Profparm'}(1,1,irem+1:end,1,1);
%         nced{'DepresQ'}(1,irem:end-1,:) = nced{'DepresQ'}(1,irem+1:end,1,:);
%         nced{'ProfQP'}(1,1,irem:end-1,1,1,:) = nced{'ProfQP'}(1,1,irem+1:end,1,1,:);

        [rr,ir]=find(rawd > -99);
        [ee,ie]=find(edd > -99);
%     end
% 
%     try
%         diffd = edd(ie)-rawd(ir);
%     catch
%         try
%             diffd = edd(ie)-rawd(1:length(ir)+1);
%         catch
%             try
%             diffd = edd(1:length(ie)+1)-rawd(ir);
%             catch
%                 %some other matrix problem
%                 b=b+1;
%                 notfixed(b,:) = stnstofix(a,:);
%                 close(nced);
%                 close(ncraw);
%                 continue
%             end
%         end
%     end
%     meand = nanmean(diffd)
    diffed = diff(edd(ie));
    diffraw = diff(rawd(ir));
%     clf
%     plot(diffd)
%     pause
    clf
    plot(diffed,'r-')
    hold on
    plot(diffraw,'gx')
    pause
    
    clf
    [n,xout]=hist(diffed)
    bar(xout,n)
    pause
    
    clear stded iextra imissing
    stded= std(diffed);
    tempraw=ncraw{'Profparm'}(:);
    temp=nced{'Profparm'}(:);
    [tt,it]=find(temp>-99);
    [tr,itr]=find(tempraw>-99);
    dpq=nced{'DepresQ'}(:);
    idpq=strfind(dpq,'1');
    prq =nced{'ProfQP'}(:);
    iprq = regexp(prq','[1234]');
    srfc = nced{'Act_Code'}(:);
    numhists= nced{'Num_hists'}(:);
    srfc(numhists,:)
   
    
%    iextra = find(diffed<xout(1)+3*stded & diffed > xout(1)-3*stded)+1;
%    imissing = find(diffed<xout(end)+3*stded & diffed > xout(end)-3*stded)+1;
    iextra = find(diffed<0.48);

% copy from the raw
    if ~isempty(iextra) & length(iextra) < 5
        edd(iextra:end) = rawd(iextra:end);
        temp(iextra:end)=tempraw(iextra:end);
        ['fixed extra points, ' num2str(iextra)]
    end
    
    % check for missing values
    imissing = find(diffed>0.71);
% copy from the raw
    if ~isempty(imissing) & length(imissing) < 5
        edd(imissing:end) = rawd(imissing:end);
        temp(imissing:end)=tempraw(imissing:end);
        ['fixed missing points, ' num2str(imissing)]
    end
    
    [tt,it]=find(temp>-99);
    [tr,itr]=find(tempraw>-99);
    [ee,ie]=find(edd > -99);
    diffd = edd(ie)./rawd(ir);
    meand = nanmean(diffd)
    
    %fix the depresQ, profQP
    if length(idpq) < length(ee)
        %make it longer
        ilen = length(ee) - length(idpq);
        dpq(idpq(end):idpq(end)+ilen) = '1';
    end

    %%Leave flags where they are. Might not be perfect, but close enough
    if length(iprq) < length(tt)
        %make it longer
        ilen = length(tt) - length(iprq);
        prq(iprq(end):iprq(end)+ilen) = prq(iprq(end));
    end

    [tt,it]=find(temp>-99);
    difft=temp(tt)./tempraw(tr);
    meant = mean(difft)
    
     [rr,ir]=find(rawd > -99);
    
    nced{'Depthpress'}(:) = edd(:);
     nced{'Deep_Depth'}(1,:)=edd(ie(end));
    nced{'Profparm'}(:)=temp(:);
    nced{'ProfQP'}(:)=prq(:);
    nced{'DepresQ'}(:)=dpq(:);
     ncraw{'Deep_Depth'}(1,:)=rawd(ir(end));
     ncraw{'Depthpress'}(:) = rawd(:);

    nced{'No_Depths'}(:)=length(edd(ie));
     ncraw{'No_Depths'}(:)=length(rawd(ir));
    
            close(nced)
            close(ncraw)
end


%% 18 eliminate unwanted profiles by eliminating keys from the keys.nc file


keys=keysdata
oldkeysfile=[keysdata.prefix '_keys.nc'];
starting=1;
% use this to eliminate data outside of desired region (set for tasman sea)

% kk=find(keys.obslon < 145. | keys.obslat > 0. | keys.obslon > 200.);
%kk = find(keys.year >= 2008 & keys.obslat < -42);

% eliminate data from a given year
% kk=find(keys.year==2012 & keys.month == 4 & (keys.day >11 & keys.day < 19));
kk = find(keys.stnnum>=89005729);
% use this to eliminate records from the TAO array:

%tao=load('TAO.sites');
%kk=find(tao(:,1)>0.);
%tao(kk,:)=[];
%kk=find(tao(:,2)>200.);
%tao(kk,:)=[];
% for tasman sea, eliminate stations less than 145 degrees...
%kk=find(tao(:,2)<145.);
%tao(kk,:)=[];

%set up variables for compression where necessary:

    stnnum=getnc(oldkeysfile,'stn_num');
    autoqc=getnc(oldkeysfile,'autoqc');
    obsy=getnc(oldkeysfile,'obs_y');
    obsm=getnc(oldkeysfile,'obs_m');
    obsd=getnc(oldkeysfile,'obs_d');
    obst=getnc(oldkeysfile,'obs_t');
    dflag=getnc(oldkeysfile,'d_flag');
   
%for i=1:length(tao)
 %   kk2=find(keys.obslat<=tao(i,1)+.52 & keys.obslat>=tao(i,1)-0.52 &...
 %       keys.obslon<=tao(i,2)+0.52 & keys.obslon>=tao(i,2)-0.52);

 % just get the suspect callsigns...
 % kk2=1:length(keys.obslon);
 
% check for the correct data type (we don't want to eliminate ctds) and
% callsigns (tao data has 5 character callsigns and starts with '5')
%m=0

%kk=[];
%if(~isempty(kk2))
%    kl=strmatch('V',keys.callsign(kk2,:));
%    for j=1:length(kl)
%        ss=deblank(keys.callsign(kk2(kl(j)),:));
%        if length(ss)>=5
%            m=m+1;
%            kk(m)=kk2(kl(j));
%        end
%    end
%end
lkk=length(kk)

% now eliminate the relevant records:
    if(~isempty(kk))
        keys.obslon(kk)=[];
        keys.obslat(kk)=[];
        autoqc(kk)=[];
        stnnum(kk,:)=[];
        keys.callsign(kk,:)=[];
        obsy(kk,:)=[];
        obsm(kk,:)=[];
        obsd(kk,:)=[];
        obst(kk,:)=[];
        keys.datatype(kk,:)=[];
        dflag(kk)=[];
        keys.datasource(kk,:)=[];
        keys.priority(kk)=[];
    end

%end  %note only needed if eliminating a sequence of profiles


    %now output to keysnew.nc...

        keysfile=[keysdata.prefix '_keysnew.nc'];


    %    if(isempty(newkeysdata))
    if(starting)
            %create keys file...
            createkeys
            starting=0;
    end

        % open and fill keys file:
        newkeysdata=netcdf(keysfile,'write');

        newkeysdata{'obslat'}(1:length(keys.obslat)) = keys.obslat(:);
        newkeysdata{'obslng'}(1:length(keys.obslat)) = keys.obslon(:);
        newkeysdata{'c360long'}(1:length(keys.obslat)) = keys.obslon(:);
        newkeysdata{'autoqc'}(1:length(keys.obslat)) = autoqc(:);

        newkeysdata{'stn_num'}(1:length(keys.obslat),:) = stnnum(:,:);
        newkeysdata{'callsign'}(1:length(keys.obslat),:) = keys.callsign(:,:);
        newkeysdata{'obs_y'}(1:length(keys.obslat),:) = obsy(:,:);

        newkeysdata{'obs_m'}(1:length(keys.obslat),:) = obsm(:,:);
        newkeysdata{'obs_d'}(1:length(keys.obslat),:) = obsd(:,:);

        newkeysdata{'obs_t'}(1:length(keys.obslat),:)=obst(:,:);

        newkeysdata{'data_t'}(1:length(keys.obslat),:) = keys.datatype(:,:);
        newkeysdata{'d_flag'}(1:length(keys.obslat)) = dflag(:);
        newkeysdata{'data_source'}(1:length(keys.obslat),1:10)= keys.datasource(:,:);
        newkeysdata{'priority'}(1:length(keys.obslat)) = keys.priority(:);

        close(newkeysdata);
 % end  note - only needed if eliminating keys only once.
%% this bit is to do all 'v' ships...

        newkeysdata{'obslat'}(1:length(kk)) = keys.obslat(kk);
        newkeysdata{'obslng'}(1:length(kk)) = keys.obslon(kk);
        newkeysdata{'c360long'}(1:length(kk)) = keys.obslon(kk);
        newkeysdata{'autoqc'}(1:length(kk)) = autoqc(kk);

        newkeysdata{'stn_num'}(1:length(kk),:) = stnnum(kk,:);
        newkeysdata{'callsign'}(1:length(kk),:) = keys.callsign(kk,:);
        newkeysdata{'obs_y'}(1:length(kk),:) = obsy(kk,:);

        newkeysdata{'obs_m'}(1:length(kk),:) = obsm(kk,:);
        newkeysdata{'obs_d'}(1:length(kk),:) = obsd(kk,:);

        newkeysdata{'obs_t'}(1:length(kk),:)=obst(kk,:);

        newkeysdata{'data_t'}(1:length(kk),:) = keys.datatype(kk,:);
        newkeysdata{'d_flag'}(1:length(kk)) = dflag(kk);
        newkeysdata{'data_source'}(1:length(kk),1:10)= keys.datasource(kk,:);
        newkeysdata{'priority'}(1:length(kk)) = keys.priority(kk);

   

%% 19 create new keys list of all profiles with scripps rejected data...

% the process will be to open each file, check for csiro auto QC flags and, if none
% found, read the QC flags to see if any data has been rejected.  If so,
% then write the keys to a new file for further QC checking...

%open and get ready to writ a enw keysfile
        keysfile=[keysdata.prefix '_keysscrippsQC3.nc'];
        keys=keysdata

       if(~exist(keysfile,'file'))
            %create keys file...
            createkeys
       end

       % get the data as stored (character strings...)
       oldkeysfile=[keysdata.prefix '_keys.nc'];
       stnn=getnc(oldkeysfile,'stn_num');
       obsy=getnc(oldkeysfile,'obs_y');
       obsm=getnc(oldkeysfile,'obs_m');
       obsd=getnc(oldkeysfile,'obs_d');
       obst=getnc(oldkeysfile,'obs_t');
       autoqc=getnc(oldkeysfile,'autoqc');
       dflag=getnc(oldkeysfile,'d_flag');
       % the rest of the variables are unconverted...
       
       nk=getnc(keysfile,'obslat');
       mm=length(nk);
       
       % open and get ready to fill keys file:
       newkeysdata=netcdf(keysfile,'write');

for i=1:length(keysdata.obslat)
 %   i=i
    kk=strmatch('CSIRO',keys.datasource(i,:));
    kl=strmatch('BOM',keys.datasource(i,:));
 if(isempty(kk) & isempty(kl))
    i=i
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
 
    flags=getnc(filenam,'Act_Code');     %if one of these is 'du' then skip
    idcode=getnc(filenam,'Ident_Code');  %if this is CS then check prccode...
    prccode=getnc(filenam,'PRC_Code');   %if this is auto, skip
    
    kk=strmatch('DU',flags);
    if(isempty(kk))
        kk=strmatch('AUTO',prccode);
        if(isempty(kk))
            qualflags=getnc(filenam,'ProfQP');
            [m,n]=size(qualflags);
            if(n==100)
                qf=qualflags(1,:)';
            else
                qf=qualflags(:,1);
            end
qlen=regexp(qf','[1 2 3 4 5 9]');
qf=str2num(qf(qlen));
            if(any(qf==4) | any(qf==3))
                mm=mm+1
        newkeysdata{'obslat'}(mm) = keys.obslat(i);
        newkeysdata{'obslng'}(mm) = keys.obslon(i);
        newkeysdata{'c360long'}(mm) = keys.obslon(i);
        newkeysdata{'autoqc'}(mm) = autoqc(i);

        newkeysdata{'stn_num'}(mm,:) = stnn(i,:);
        newkeysdata{'callsign'}(mm,:) = keys.callsign(i,:);

        newkeysdata{'obs_y'}(mm,:) = obsy(i,:);
        newkeysdata{'obs_m'}(mm,:) = obsm(i,:);
        newkeysdata{'obs_d'}(mm,:) = obsd(i,:);
        newkeysdata{'obs_t'}(mm,:)=obst(i,:);

        newkeysdata{'data_t'}(mm,:) = keys.datatype(i,:);
        newkeysdata{'d_flag'}(mm) = dflag(i);
        newkeysdata{'data_source'}(mm,:)= keys.datasource(i,:);
        newkeysdata{'priority'}(mm) = keys.priority(i);
            end
        end
    end
 end
end

close(newkeysdata);

%% 20: Rewrite keys without specific stations
% alternative to keys rewrite above. stnstofix contains the station numbers
% in char format
%MAKE A BACKUP OF KEYS BEFORE STARTING!!

 keysnc=netcdf('antarctic2000MQNC_keys.nc','write');
 
 keystn=keysnc{'stn_num'}(:);
 %get length of N_Casts
 lcast=length(keysnc('N_Casts'));
 [m,n]=size(stnstofix);
 
 for a=1:m
     ifix = strmatch(stnstofix(a,:),keystn(:,1:10),'exact');
     
     %move everything up to overwrite this station
     keysnc{'obslat'}(ifix:end-1)=keysnc{'obslat'}(ifix+1:end);
     keysnc{'obslng'}(ifix:end-1)=keysnc{'obslng'}(ifix+1:end);
     keysnc{'c360long'}(ifix:end-1)=keysnc{'c360long'}(ifix+1:end);
     keysnc{'autoqc'}(ifix:end-1)=keysnc{'autoqc'}(ifix+1:end);
     keysnc{'stn_num'}(ifix:end-1,1:10)=keysnc{'stn_num'}(ifix+1:end,1:10);
     keysnc{'callsign'}(ifix:end-1,1:10)=keysnc{'callsign'}(ifix+1:end,1:10);
     keysnc{'obs_y'}(ifix:end-1,1:4)=keysnc{'obs_y'}(ifix+1:end,1:4);
     keysnc{'obs_t'}(ifix:end-1,1:4)=keysnc{'obs_t'}(ifix+1:end,1:4);
     keysnc{'obs_m'}(ifix:end-1,1:2)=keysnc{'obs_m'}(ifix+1:end,1:2);
     keysnc{'obs_d'}(ifix:end-1,1:2)=keysnc{'obs_d'}(ifix+1:end,1:2);
     keysnc{'data_t'}(ifix:end-1,1:2)=keysnc{'data_t'}(ifix+1:end,1:2);
     keysnc{'d_flag'}(ifix:end-1,:)=keysnc{'d_flag'}(ifix+1:end,:);
     keysnc{'data_source'}(ifix:end-1,1:10)=keysnc{'data_source'}(ifix+1:end,1:10);
     keysnc{'priority'}(ifix:end-1)=keysnc{'priority'}(ifix+1:end);
 end     
 resize(keysnc('N_Casts'),lcast-m)
 
 close(keysnc);
      
%% 21   Create new keys from list 
% the list of stations is in a char array 'fncmstn'

%load the keys from the text file and eliminate duplicate values:
kstnno=input('enter name of text file holding station numbers: ','s')
keysn=load(kstnno);
ukeysn=unique(keysn);

okeys=input('enter the orignal keys prefix: ','s');
origkeys = netcdf([okeys '_keys.nc'],'nowrite');

kfile = input('enter the output keys prefix: ','s');
keysfile=[kfile '_keys.nc'];
createkeys;

newkeys = netcdf(keysfile,'write');
keystn=origkeys{'stn_num'}(:);
ncasts = size(newkeys('N_Casts'));
ncasts = ncasts(1);
 
 nkeystn=str2num(keystn);
 
 [c,ia,ib] = intersect(ukeysn,nkeystn);
 
%  for a=1:m
%     iwrite = strmatch(fncmstn(a,:),keystn(:,1:10),'exact');
%     iwrite = find(nkeystn==ukeysn(a));
%   if(~isempty(iwrite))
if ~isempty(c)
%     if(length(iwrite==1))
%         error(a)=0;
%     else
%         error(a)=1;
%     end
%     newkeys{'obslat'}(a)=origkeys{'obslat'}(iwrite(end));
%     newkeys{'obslng'}(a)=origkeys{'obslng'}(iwrite(end));
%     newkeys{'c360long'}(a)=origkeys{'c360long'}(iwrite(end));
%     newkeys{'autoqc'}(a)=origkeys{'autoqc'}(iwrite(end));
%     newkeys{'stn_num'}(a,1:10)=origkeys{'stn_num'}(iwrite(end),1:10);
%     newkeys{'callsign'}(a,1:10)=origkeys{'callsign'}(iwrite(end),1:10);
%     newkeys{'obs_y'}(a,1:4)=origkeys{'obs_y'}(iwrite(end),1:4);
%     newkeys{'obs_t'}(a,1:4)=origkeys{'obs_t'}(iwrite(end),1:4);
%     newkeys{'obs_m'}(a,1:2)=origkeys{'obs_m'}(iwrite(end),1:2);
%     newkeys{'obs_d'}(a,1:2)=origkeys{'obs_d'}(iwrite(end),1:2);
%     newkeys{'data_t'}(a,1:2)=origkeys{'data_t'}(iwrite(end),1:2);
%     newkeys{'d_flag'}(a,:)=origkeys{'d_flag'}(iwrite(end),:);
%     newkeys{'data_source'}(a,1:10)=origkeys{'data_source'}(iwrite(end),1:10);
%     newkeys{'priority'}(a)=origkeys{'priority'}(iwrite(end));
    aa = origkeys{'obslat'}(:);
    newkeys{'obslat'}(1:length(c))=aa(ib);
    aa = origkeys{'obslng'}(:);
    newkeys{'obslng'}(1:length(c))=aa(ib);
    aa = origkeys{'c360long'}(:);
    newkeys{'c360long'}(1:length(c))=aa(ib);
    aa = origkeys{'autoqc'}(:);
    newkeys{'autoqc'}(1:length(c))=aa(ib);
    aa = origkeys{'stn_num'}(:);
    newkeys{'stn_num'}(1:length(c),1:10)=aa(ib,:);
    aa = origkeys{'callsign'}(:);
    newkeys{'callsign'}(1:length(c),1:10)=aa(ib,:);
    aa = origkeys{'obs_y'}(:);
    newkeys{'obs_y'}(1:length(c),1:4)=aa(ib,:);
    aa = origkeys{'obs_t'}(:);
    newkeys{'obs_t'}(1:length(c),1:4)=aa(ib,:);
    aa = origkeys{'obs_m'}(:);
    newkeys{'obs_m'}(1:length(c),1:2)=aa(ib,:);
    aa = origkeys{'obs_d'}(:);
    newkeys{'obs_d'}(1:length(c),1:2)=aa(ib,:);
    aa = origkeys{'data_t'}(:);
    newkeys{'data_t'}(1:length(c),1:2)=aa(ib,:);
    aa = origkeys{'d_flag'}(:);
    newkeys{'d_flag'}(1:length(c))=aa(ib);
    aa = origkeys{'data_source'}(:);
    newkeys{'data_source'}(1:length(c),1:10)=aa(ib,:);
    aa = origkeys{'priority'}(:);
    newkeys{'priority'}(1:length(c))=aa(ib);

% else
%     error(a)=2;
end
%  end      
 close(newkeys);
%  ll=find(error);
%  if(~isempty(ll))
%      errormsg='error - some stations not written!'
%     [ll' error(ll)']
%  end


%% 23 - fix CS flags that are incorrectly identified with too severe a flag
% severity

%load reject and accept codes for comparison with flag severity:
[a,b,c]=textread('questAflags.txt','%3s %f %f');
acceptcode=a;
acceptlevel=b;
acceptplace=c;

% setup the reject menu:   The order and action of these flags can be
%changed by editing 'questRflags.txt'
clear a;
clear b;
clear c;
[a,b,c]=textread('questRflags.txt','%3s %f %f');
rejectcode=a;
rejectlevel=b;
rejectplace=c;

for i=1:length(keysdata.stnnum)
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end

  
    %fix CS severity: 
 
    actc=getnc(filenam,'Act_Code');
    flags=getnc(filenam,'Flag_severity');
    Num_Hists=getnc(filenam,'Num_Hists');
    Ident_Code=getnc(filenam,'Ident_Code'); 
    depthflag=getnc(filenam,'Aux_ID');
    profQ=getnc(filenam,'ProfQP');
    ndeps=getnc(filenam,'No_Depths');        
    depth=getnc(filenam,'Depthpress');
     
    csstr=strmatch('CS',actc);
    
    if(~isempty(csstr))
    %     if(any(find(flags(csstr)==3 | flags(csstr)==4)))
    i=i
        fix_flag_severity
%         flags(csstr)=0;
        ncid=netcdf(filenam,'write');
        ncid{'Flag_severity'}(:)=flags(:);
        close(ncid);
%         fid=fopen('profileschopsurfaceforreview.txt','a');
%         fprintf(fid,'%10i\n',(keysdata.stnnum(i)));
%         fclose(fid);
    end
    %now fix the profileQ flag to be '5'
%     changed=0;
%     for gg=1:length(csstr)
%        aux=depthflag(csstr(gg))-0.01;
%        jj=find(depth>=aux);
%        if(~isempty(jj))
%            if(profQ(jj(1))~='5')
%                changed=1;
%                profQ(jj(1))='5';
%            end
%        end
%     end
%     if(changed)
%         ncid=netcdf(filenam,'write');
%         ncid{'ProfQP'}(:)=profQ(:);
%         close(ncid);
%     end        
end   

%fix profile QC flags:    
   
    %find profiles with qc of 5 for entire profile:
    if(ndeps>0)
        if(profQ(ndeps)=='5')
            fid=fopen('profilesflag5forreview.txt','a');
            fprintf(fid,'%10i\n',(keysdata.stnnum(i)));
            fclose(fid);
        end
    end    
    %find profiles entirely bad but with no QC flag 
    if(profQ(1)=='4' | profQ(1)=='3')
        badd=find(flags==3 | flags==4);
        
        if(isempty(badd))
            fid=fopen('profilesallbadforreview.txt','a');
            fprintf(fid,'%10i\n',(keysdata.stnnum(i)));
            fclose(fid);
        else
            if(~any(find(depthflag(badd)==0 | depthflag(badd)==depth(1,1))))
                fid=fopen('profilesallbadforreview.txt','a');
                fprintf(fid,'%10i\n',(keysdata.stnnum(i)));
                fclose(fid);
            end
        end
    end
    
    %find bad data without flag:
    if(any(find(profQ=='4' | profQ=='3')))
        if(~any(find(flags==4 | flags==3)))
            fid=fopen('profilesnoflagforreview.txt','a');
            fprintf(fid,'%10i\n',(keysdata.stnnum(i)));
            fclose(fid);
        end
    end
    

%% 24 (line) = fix bad missing values - profiles padded with 99.99 instead
%       of -99.99 after max depth - use %1 to set up database

% change this to read stn nums from text file:  restore if you want to do
% entire file...

load 'xbbadtemplengths2.txt';
stnnum=xbbadtemplengths2;
filen='mastertasmanMQNC'

%filen=keysdata.prefix;
%for i=1:length(keysdata.stnnum)
    
for i=1:length(stnnum)

%    stn = keysdata.stnnum(i)
    stn = stnnum(i)
    
    raw = 1;
    stnraw=getfilename(num2str(stn),raw);
    stnraw=[filen '/' stnraw];
%     stnraw=[filen '\' stnraw];
    raw=0;
    stned=getfilename(num2str(stn),raw);
    stned=[filen '/' stned];

    depsrw=getnc(stnraw,'No_Depths');
    depsed=getnc(stned,'No_Depths');
    
    nced = netcdf(stned,'write');
    ncraw = netcdf(stnraw,'write');
    nprof=getnc(stned,'No_Prof');

    if(nprof>1)
        profrw.deps = ncraw{'Depthpress'}(:,:);
        profed.deps = nced{'Depthpress'}(:,:);
        profrw.tmp = ncraw{'Profparm'}(:,:);
        profed.tmp = nced{'Profparm'}(:,:); 
%        proft=getnc(stned,'Prof_Type');
%        tprof=strmatch('TEMP',proft);
        for ii=1:nprof
            kk=find(profrw.deps(ii,depsrw(ii)+1:end)>99)
            kl=find(isnan(profrw.deps(depsrw+1:end)));
            if(~isempty(kk) | ~isempty(kl))
                profrw.deps(ii,depsrw(ii)+1:end)=-99.99;
                ncraw{'Depthpress'}(:,:)=profrw.deps(:,:);
            end
            kk=find(profed.deps(ii,depsed(ii)+1:end)>99)
            kl=find(isnan(profrw.deps(depsrw+1:end)));
            if(~isempty(kk) | ~isempty(kl))
                profed.deps(ii,depsed(ii)+1:end)=-99.99;
                nced{'Depthpress'}(:,:)=profed.deps(:,:);
            end
            kk=find(profrw.tmp(ii,depsrw(ii)+1:end)>99)
            kl=find(isnan(profrw.deps(depsrw+1:end)));
            if(~isempty(kk) | ~isempty(kl))
                profrw.tmp(ii,depsrw(ii)+1:end)=-99.99;
                ncraw{'Profparm'}(:,:)=profrw.tmp(:,:);
            end
            kk=find(profed.tmp(ii,depsed(ii)+1:end)>99)
            kl=find(isnan(profrw.deps(depsrw+1:end)));
            if(~isempty(kk) | ~isempty(kl))
                profed.tmp(ii,depsed(ii)+1:end)=-99.99;
                nced{'Profparm'}(:,:)=profed.tmp(:,:);
            end
        end
    else
        profrw.deps = ncraw{'Depthpress'}(:);
        profed.deps = nced{'Depthpress'}(:);
        profrw.tmp = ncraw{'Profparm'}(:);
        profed.tmp = nced{'Profparm'}(:);

        kk=find(profrw.deps(depsrw+1:end)>99);
        if(~isempty(kk))
            profrw.deps(depsrw+1:end)=-99.99;
            ncraw{'Depthpress'}(:)=profrw.deps(:);
        end
        kk=find(profed.deps(depsed+1:end)>99);
        if(~isempty(kk))
            profed.deps(depsed+1:end)=-99.99;
            nced{'Depthpress'}(:)=profed.deps(:);
        end
        kk=find(profrw.tmp(depsrw+1:end)>99);
        if(~isempty(kk))
            profrw.tmp(depsrw+1:end)=-99.99;
            ncraw{'Profparm'}(:)=profrw.tmp(:);
        end
        kk=find(profed.tmp(depsed+1:end)>99);
        if(~isempty(kk))
            profed.tmp(depsed+1:end)=-99.99;
            nced{'Profparm'}(:)=profed.tmp(:);
        end
    end

    close(nced)
    close(ncraw)
end
 

%% 25 - fix julian dates of edited files which are based on the wrong start date
% use #1 to set up the data bases first, then:

filen=keysdata.prefix;
for i=1:length(keysdata.stnnum)
    
    stn = keysdata.stnnum(i)
    
    raw = 1;
    stnraw=getfilename(num2str(stn),raw);
    stnraw=[filen '/' stnraw];
%     stnraw=[filen '\' stnraw];
    raw=0;
    stned=getfilename(num2str(stn),raw);
    stned=[filen '/' stned];
    
    rawt=getnc(stnraw,'time');
    ti = datenum('1900-01-01 00:00:00')+rawt;
    t = num2str(keysdata.time(i));
    tt = '0000';
    tt(1+4-length(t):end) = t;
    if ti ~= datenum(keysdata.year(i),keysdata.month(i),...
            keysdata.day(i),str2num(tt(1:2)),str2num(tt(3:4)),0)
%     if(rawt>2400000)
        
         wd=getnc(stnraw,'woce_date');
         wtime=getnc(stnraw,'woce_time');
         wdate=num2str(wd);
         ju=julian([str2num(wdate(1:4)) str2num(wdate(5:6)) str2num(wdate(7:8)) ...
            floor(wtime/10000) rem(wtime,10000)/100 0])-2415020.5;
         ncraw = netcdf(stnraw,'write');
         ncraw{'time'}(:) = ju;
         close(ncraw);
     
    end
    
    
    edt=getnc(stned,'time');
    ti = datenum('1900-01-01 00:00:00')+edt;
    if ti ~= datenum(keysdata.year(i),keysdata.month(i),...
            keysdata.day(i),str2num(tt(1:2)),str2num(tt(3:4)),0)
%     if(edt>2400000)
        
         wd=getnc(stned,'woce_date');
         wtime=getnc(stned,'woce_time');
         wdate=num2str(wd);
         ju=julian([str2num(wdate(1:4)) str2num(wdate(5:6)) str2num(wdate(7:8)) ...
            floor(wtime/10000) rem(wtime,10000)/100 0])-2415020.5;
         nced = netcdf(stned,'write');
         nced{'time'}(:) = ju;
         close(nced);
     
    end
    
    
end
%% 26 - Condense NC files (create a shortened version of the *good.nc
% file)
% !cp /home/tethys1/iota/iotaeast/mastereastMQNCgood.nc /home/tethys1/iota/IOTAgood.nc
% filn = {'/home/tethys1/iota/iotaeast/mastereastMQNCgood.nc','/home/tethys1/iota/iotawest/masterwestMQNCgood.nc'};
% dbase = {'east      ','west      '};

% modified to take concatenated east/west file and remove unnecessary
%  variables for data exchange
clear 

% filn = {'*.nc'}; %for WMO box files
filn = {'mastertasmanMQNCgood.nc'};
dd = dir(char(filn)); %for 5m bin file
% vars = {'callsign','datat','datasource','year','month','day','mytime','lat', ...
%     'lon','stnno','tzvals'}; %for WMO box files
vars = {'callsign','data_type','probe_type','recorder_type','datasource','year','month','day','mytime','lat', ...
    'lon','stnno','tzvals'}; %for 5m bin file


for a = 1:length(dd)
    nc = netcdf(dd(a).name);
    newnc = netcdf([dd(a).name(1:end-3) '_tz.nc'] ,'clobber');
    ln = length(nc('cast'));
    lnew = size(newnc('cast'));
    
    c = 0;
    for b=1:length(vars)
        c = c+1;
        copy(nc{vars{b}},newnc);
        try
            newnc{c} < nc{vars{b}}.units ;
            newnc{c} < nc{vars{b}}.missing_value;
        end
        newnc{c}(lnew(1)+1:lnew(1)+ln,:) = nc{vars{b}}(:);
    end
    copy(nc.depthbins,newnc);  %global depthbins
%     copy(nc.title,newnc);  %global title
    %copy(nc.dbase,newnc);   %data base id for future debugging
    close(nc);
    close(newnc);
end


% %newnc{'dbase'}=ncchar('cast','c'); %create a new variable to id which dbase it comes from
% 
%  for a = 1:length(dd)
%      nc = netcdf(filn{a},'nowrite');
%      ln = length(nc('cast'));
%      lnew = size(newnc('cast'));
%      c= [1:4,6,8:14,16];
%      for b= 1:13
%          newnc{b}(lnew(1)+1:lnew(1)+ln,:) = nc{c(b)}(:)
%      end
%      newnc{14}(lnew(1)+1:lnew(1)+ln,:) = nc{29}(:)
% %     db= repmat(dbase{a},length(lnew(1)+1:lnew(1)+ln),1);
% %     newnc{'dbase'}(lnew(1)+1:lnew(1)+ln,1:10) = db;
%      close(nc)
%  end
% close(newnc)

%% 27 Get specific files from a backup copy

filn= 'dtmismatch';                     %retrieveQCedXBT.mat
filen='inddatanewMQNC';
% filen='mastereastMQNC';
filebu = 'inddataMQNC2';
fnm = [filn '.txt'];
clear stn stnall

    fid=fopen(fnm,'r')
    a=1;
    while 1
        tline=fgetl(fid);
        if ~ischar(tline),   break,   end
        try
            mx=strfind(tline,' ');
            stn(a)=str2num(tline(1:mx(1)));
        catch
            try
                stn(a)=str2num(tline(1:10));
            catch
                try
                    stn(a)=str2num(tline(1:9));
                catch
                    try
                        stn(a)=str2num(tline(1:8));
                    catch
                        try
                            stn(a)=str2num(tline(1:7));
                        catch
                            stn(a)=str2num(tline(1:6));
                        end
                    end
                end
            end
        end
        a=a+1;
    end
    fclose(fid);
    stn=stn';
    stnall=unique(stn);


for a= 1:length(stnall)
        %get the station number
        raw = 1;
        stnraw=getfilename(num2str(stnall(a)),raw);
        stnr=[filen '/' stnraw];
        raw=0;
        stned=getfilename(num2str(stnall(a)),raw);
        stne=[filen '/' stned]

        %copy it from backup to the working copy
%         try
%             eval(['!cp ' filebu '/' stned ' ' stne]);
%             eval(['!cp ' filebu '/' stnraw ' ' stnr]);
%         catch
            mkdir([stne(1:length(stne)-7)])
            eval(['!cp ' filebu '/' stned ' ' stne]);
            eval(['!cp ' filebu '/' stnraw ' ' stnr]);
%         end


end

%% 28 Find casts that have two profiles (eg BO's and XCTD'S with salinity
% and temp
filnam = 'twoprofiles.txt';
prefix=input('enter the database prefix:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);

for a=1:length(keysdata.stnnum)
    disp(a)
    %open the file
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(a)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    
    if length(nc('N_Prof')) > 1
        if nc{'No_Depths'}(1) ~= nc{'No_Depths'}(2)
%             for argo t-only floats, fix sal first depth
            nc{'Depthpress'}(2,1) = nc{'Depthpress'}(1,1);
            %write the station number out

            fid = fopen(filnam,'a');
            outp = [];
            fprintf(fid,'%i \n',keysdata.stnnum(a));
            fclose(fid);
        end
    end
    close(nc)
end

%% 29 Fix the casts with two or more profiles and missing salinity
filn= 'twoprofiles';                     %retrieveQCedXBT.mat
prefix='mastereastMQNC';
% filen='mastereastMQNC';
% filebu = '/home/ghost1/iotaonlinebu/westonlinebu/';
filebu = './holdfinished3/mastereastfinished3';

fnm = [filn '.txt'];
clear stn stnall

    fid=fopen(fnm,'r')
    a=1;
    while 1
        tline=fgetl(fid);
        if ~ischar(tline),   break,   end
        try
            mx=strfind(tline,' ');
            stn(a)=str2num(tline(1:mx(1)));
        catch
            try
                stn(a)=str2num(tline(1:10));
            catch
                try
                    stn(a)=str2num(tline(1:9));
                catch
                    try
                        stn(a)=str2num(tline(1:8));
                    catch
                        try
                            stn(a)=str2num(tline(1:7));
                        catch
                            stn(a)=str2num(tline(1:6));
                        end
                    end
                end
            end
        end
        a=a+1;
    end
    fclose(fid);
    stn=stn';
    stnall=unique(stn);
    notfixed=[];

    for a= 11:length(stnall)
        disp(a)
        %open the file
        raw=0;
        filen=getfilename(num2str(stnall(a)),raw);
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        nc=netcdf(filenam,'write');
        raw=1;
        filen=getfilename(num2str(stnall(a)),raw);
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        ncr=netcdf(filenam,'write');
        
        if ~isempty(strmatch(nc{'Prof_Type'}(2),'                '))
            raw = 1;
            %open the backup file
            filen=getfilename(num2str(stnall(a)),raw);
            if(ispc)
                filenam=[filebu '\' filen];
            else
                filenam=[filebu '/' filen];
            end
            nc2=netcdf(filenam,'nowrite');
            if nc{'No_Depths'}(1) == nc2{'No_Depths'}(2)
                nc{'Prof_Type'}(2,1:4) = nc2{'Prof_Type'}(2,:);
                nc{'No_Depths'}(2) = nc2{'No_Depths'}(2);
                nc{'Depthpress'}(2,1:length(nc2{'Depthpress'}(2,:))) = nc2{'Depthpress'}(2,:);
                nc{'Profparm'}(2,:,1:length(nc2{'Depthpress'}(2,:)),:,:) = nc2{'Profparm'}(2,:,:,:,:);
                nc{'DepresQ'}(2,1:length(nc2{'Depthpress'}(2,:)),:) = nc2{'DepresQ'}(2,:,:);
                nc{'ProfQP'}(2,:,1:length(nc2{'Depthpress'}(2,:)),:,:,:) = nc2{'ProfQP'}(2,:,:,:,:,:);
                nc{'Deep_Depth'}(1) = max(nc{'Depthpress'}(1,:));
                nc{'Deep_Depth'}(2) = max(nc{'Depthpress'}(2,:));
                ncr{'Prof_Type'}(2,1:4) = nc2{'Prof_Type'}(2,:);
                ncr{'No_Depths'}(2) = nc2{'No_Depths'}(2);
                ncr{'Depthpress'}(2,1:length(nc2{'Depthpress'}(2,:))) = nc2{'Depthpress'}(2,:);
                ncr{'Profparm'}(2,:,1:length(nc2{'Depthpress'}(2,:)),:,:) = nc2{'Profparm'}(2,:,:,:,:);
                ncr{'DepresQ'}(2,1:length(nc2{'Depthpress'}(2,:)),:) = nc2{'DepresQ'}(2,:,:);
                ncr{'ProfQP'}(2,:,1:length(nc2{'Depthpress'}(2,:)),:,:,:) = nc2{'ProfQP'}(2,:,:,:,:,:);
                ncr{'Deep_Depth'}(1) = max(ncr{'Depthpress'}(1,:));
                ncr{'Deep_Depth'}(2) = max(ncr{'Depthpress'}(2,:));
                
            else
                notfixed = [notfixed; stnall(a)];
            end
            close(nc2)
        else
            notfixed = [notfixed; stnall(a)];
        end

        close(nc)
        close(ncr)

    end
   
%% 30 Run Tim Boyer's list of DBID's that need PEQ changed from XBT to CTD
% second column is DBID
% and from T10 TO T5
filn= '../dbid_list_ctdnotxbt';                 

prefix = 'masterio';
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
peq = '830       ';

fnm = [filn '.txt'];
clear stn stnall
wehave =[];
wehave2 =[];
    fid=fopen(fnm,'r')
    a=1;
    while 1
        tline=fgetl(fid);
        if ~ischar(tline),   break,   end
            mx=strfind(tline,' ');
            stn(a)=str2num(tline(mx(end):length(tline)));
        a=a+1;
    end
    fclose(fid);
    stn=stn';
    stnall=unique(stn);
    notfixed=[];

    for a= 422158:length(keysdata.stnnum)
        disp(keysdata.stnnum(a))
        %open the file
        raw=0;
        filen=getfilename(num2str(keysdata.stnnum(a)),raw);
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        %see if the file exists
        nc=netcdf(filenam,'nowrite');
        srfcc = nc{'SRFC_Code'}(:);
        srfcp = nc{'SRFC_Parm'}(:);
        ii = strmatch('DBID',srfcc);
        if ~isempty(ii)
%             ifound = find(stnall == str2num(srfcp(ii,:)));
            dbid(a) = str2num(srfcp(ii,:));
%             if ~isempty(ifound)
%                 wehave = [wehave;keysdata.stnnum(a)];
%                 fid = fopen('BoyerDBID.txt','a');
%                 outp = [];
%                 fprintf(fid,'%i \n',keysdata.stnnum(a));
%                 fclose(fid);
%             end
        end
        close(nc);
    end
    
    %now intersect the dbid with the stnall list:
    [ia,ib,ic] = intersect(dbid,stnall);
    
    %try the other lists:
    clear stnall
fnm= '../xbt_shouldbet5.txt';                 
    fid=fopen(fnm,'r')
    a=1;
    while 1
        tline=fgetl(fid);
        if ~ischar(tline),   break,   end
            mx=strfind(tline,' ');
            stn(a)=str2num(tline(mx(end):length(tline)));
        a=a+1;
    end
    fclose(fid);
    stn=stn';
    stnall=unique(stn);
    clear stn
fnm= '../moret5s.txt';                 
    fid=fopen(fnm,'r')
    a=1;
    while 1
        tline=fgetl(fid);
        if ~ischar(tline),   break,   end
            mx=strfind(tline,' ');
            stn(a)=str2num(tline(mx(end):length(tline)));
        a=a+1;
    end
    fclose(fid);
    stn=stn';
    stnall = [stnall;unique(stn)];
    %now intersect the dbid with the stnall list:
    [c,ia,ib] = intersect(dbid,stnall);
    
    for a= 1:length(c)
        disp(keysdata.stnnum(a))
        %open the file
        raw=0;
        filen=getfilename(num2str(keysdata.stnnum(ia(a))),raw);
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        %see if the file exists
        nc=netcdf(filenam,'nowrite');
        srfcc = nc{'SRFC_Code'}(:);
        srfcp = nc{'SRFC_Parm'}(:);
        ii = strmatch('PEQ$',srfcc);
        if ~isempty(ii)
            dpc(a,1:10) = srfcp(ii,:);
        else
            dpc(a,1:10) = 'empty     ';
        end
        close(nc)
    end
        
%% 31 - check MBTs for depth problem
fid = fopen('dtmismatch.txt');
stn=[];
while 1
    d = fgetl(fid);
    if d == -1;break;end
    ii = strfind(d,' ');
    if ~isempty(ii)
    stn = [stn;str2num(d(1:ii(1)))];
    end
end
    
% ij = strmatch('MB',keysdata.datatype);
% stn =[]; %stn = load(deepmbt.txt);
for a=1:length(ij)
    disp(num2str(a));
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(ij(a))),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end

    deps = getnc(filenam,'Depthpress');
    [ii,dd] = find(deps > -90);
    
    if deps(ii(end)) > 300
            fid = fopen('deepmbt.txt','a');
            fprintf(fid,'%i \n',keysdata.stnnum(ij(a)));
            fclose(fid);
            stn = [stn;keysdata.stnnum(ij(a))];
    end
    clear deps ii dd

end

% now fix them:NOTE THAT THESE WILL NEED RUNNING THROUGH DEPTH CORRECTION!!
for a = 218:length(stn)
    disp(num2str(a));
    for b = 1:2
        raw=b-1;
        filen=getfilename(num2str(stn(a)),raw);
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        nc = netcdf(filenam,'write');

        nc{'Data_Type'}(:) = 'XB';
        nc{'Stream_Ident'}(3:4) = 'XB';
        nc{'Up_date'}(:) = datestr(datenum(date),'YYYYMMDD');
        nhists = nc{'Num_Hists'}(:);
        ii = strmatch('DT',nc{'Act_Code'}(1:nhists,:));
        if isempty(ii)
            nhists = nhists+1;
            nc{'Num_Hists'}(:) = nhists;
            nc{'Ident_Code'}(nhists,:) = DATA_QC_SOURCE;
            nc{'PRC_Code'}(nhists,:) = 'CSCB';
            nc{'Version'}(nhists,:) = '1.0 ';
            nc{'PRC_Date'}(nhists,:) = datestr(datenum(date),'YYYYMMDD');
            nc{'Act_Code'}(nhists,:) = 'DT';
            nc{'Act_Parm'}(nhists,:) = 'DTYP';
            nc{'Aux_ID'}(nhists) = 0;
            nc{'Previous_Val'}(nhists,:) = 'MB        ';
        else
            nc{'Previous_Val'}(ii(1),:) = 'MB        ';            
        end
        close(nc)
    end
end
%fix the keys datatype:
nck = netcdf([prefix '_keys.nc'],'write');
[ia,ib,ic]=intersect(keysdata.stnnum,stn);
for a = 1:length(ib)
keysdata.datatype(ib(a),:) = 'XB';
end
nck{'data_t'}(:) = keysdata.datatype;
close(nck)

% %plot
% [ia,ib,ic]=intersect(keysdata.stnnum,stn);
% yr = keysdata.year(ib);
% clear tm2 dp2
% b=0;
% for a = 1:length(stn)
%      raw=0;
%     filen=getfilename(num2str(stn(a)),raw);
%     if(ispc)
%         filenam=[prefix '\' filen];
%     else
%         filenam=[prefix '/' filen];
%     end
% 
%     deps = getnc(filenam,'Depthpress');
%     tem = getnc(filenam,'Profparm');
%     [ii,dd] = find(deps > -90);
%     if deps(ii(end)) > 300
%         b=b+1;
%         dp2(1:length(ii),b) = deps(ii);
%         tm2(1:length(ii),b) = tem(ii);
%         dp2(length(ii)+1:60,b) = NaN;
%         tm2(length(ii)+1:60,b) = NaN;
%         yr2(b) = yr(a);
%         stn2(b) = stn(a);
%     end
%     clear deps ii dd tem
% end
% figure(1); clf;hold on
% axis ij
% plot(tm2,dp2,'b-');
% title('MBTs deeper than 300m in the Indian Ocean')
% xlabel('Temperature')
% ylabel('Depth')
% save_fig('mbttmp.gif')
% %plot years > 1975 in a different color
% ind = find(yr2>1975);
% figure(1); clf;hold on
% axis ij
% plot(tm2,dp2,'b-');
% plot(tm2(:,ind),dp2(:,ind),'r-');
% title('Red profiles are post-1975')
% xlabel('Temperature')
% ylabel('Depth')
%  save_fig('mbttemp_1975_2.gif')
% for a=1:length(ind)
%     figure(1); clf;
% 
%  plot(tm2(:,ind(a)),dp2(:,ind(a)))
%    axis ij
%     pause
% end

%% 32 - extract profiles with bad/good data and tally
badd=0;
goodd=0;
for i=1:length(keysdata.stnnum)
      raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    clear dataq
    dataq=getnc(filenam,'ProfQP');
%    dataq1=str2num(dataq);
    if(any(dataq=='3') | any (dataq=='4'))
        badd=badd+1;
        stnbad(badd) = keysdata.stnnum(i);
    end
    if(any(dataq=='1') | any (dataq=='2') | any (dataq=='0'))
        goodd=goodd+1;
        stngood(goodd) = keysdata.stnnum(i);
    end
    
end
%% 33 - use a list of station numbers to flag out these as duplicates
prefix=input('enter the database prefix:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);

stnn = keysdata.stnnum;
clear keysdata
prefix=input('enter the database prefix that needs the profiles flagged as DUR:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);

[c,ia,ib] = intersect(keysdata.stnnum,stnn);

for a = 2:length(c)
      raw=0;
    filen=getfilename(num2str(c(a)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
   nc = netcdf(filenam,'write');
   nprof = nc{'No_Prof'}(:);
   ndep = nc{'No_Depths'}(1,:);
   nc{'Dup_Flag'}(:,1) = 'D';
   nc{'Ident_Code'}(1,:) = DATA_QC_SOURCE;
   nc{'PRC_Code'}(1,:) = 'DUPE';
   nc{'Version'}(1,:) = '9999';
   nc{'Act_Code'}(1,:) = 'DP';
   nc{'Act_Parm'}(1,:) = 'TEMP';
   nc{'Flag_severity'}(1) = 4;
   nc{'Previous_Val'}(1,:) = '9999.99   ';
   nc{'ProfQP'}(1,1,1:ndep,1,1,1) = '4';
   close(nc);
end

%% 34 Update the PALACE - t only floats information
%read the raw lat/lon/date/time/values for updating files:
fid=fopen(inputfile,'r');
a=0;
% a=3164;
% a=5678;
% a=8017;
while ~feof(fid)
    d=fgets(fid);
    disp(d);
    ndep=str2num(d(1:4));
    if ndep==0
        continue
    end
    da=str2num(d(31:35));
    if da<-9  % missing date, skip
        for i=1:ndep
            d=fgets(fid);
        end
        continue
    end
    a=a+1;
    if str2num(d(28:29))>10
        yy=str2num(['19' d(28:29)]);
    else
        yy=str2num(['200' d(29)]);
    end
    datey = datenum([yy 00 00 00 00 00]);
    dat = datey + da;
    mm=str2num(datestr(dat,5));
    dd=str2num(datestr(dat,7));
    hh=datestr(dat,'HH');
    MM=datestr(dat,'MM');
%     ss=datestr(dat,'SS');
    profiledata.year(a)=yy;
    profiledata.month(a)=mm;
    profiledata.day(a)=dd;
    profiledata.time(a)=str2num([hh MM]);  %woce_time

    profiledata.sn(a)=str2num(d(60:65));
    profiledata.lat(a)=str2num(d(42:47));
    profiledata.lon(a)=str2num(d(48:55));
    for i=1:ndep
        d=fgets(fid);
    end
    continue
end
fclose(fid)

save wocepfcastheader.mat profiledata
%fix longitudes:
for a = 1:length(profiledata.lon)
    if profiledata.lon(a) < 0
        profiledata.lon(a) = (180 + profiledata.lon(a)) + 180;
    end
end
save wocepfcastheader.mat profiledata
%now match up the lats and longs and replace the date/time
prefix=input('enter the database prefix:','s')
p={prefix};
m={'All'};
y={'All'};
q={'1'};
a={'1'};
tw={'1'};
sstyle={'None'};
[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
nck = netcdf([prefix '_keys.nc'],'write');
notupdated = [];
nomatch = [];
for a = 1:length(keysdata.stnnum)
    %     %change the data source in the keys
    keysdata.datasource(a,:) = 'wocePALACE';
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(a)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
   nce = netcdf(filenam,'write');
      raw=1;
    filen=getfilename(num2str(keysdata.stnnum(a)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
   ncr = netcdf(filenam,'write');
   
   nce{'SRFC_Parm'}(2,:) = 'wocePALACE';
   ncr{'SRFC_Parm'}(2,:) = 'wocePALACE';
   
   %now find the matching record in the profiledata structure and replace
   %times and dates:
   dlat = abs(profiledata.lat - keysdata.obslat(a));
   dlon = abs(profiledata.lon - keysdata.obslon(a));
   
   ii = find(dlat < .001 & dlon < .001);
   
   if length(ii) == 1; %one record found
       %check date and time are on a par:
       dy = keysdata.year(a) - profiledata.year(ii);
       ds = str2num(keysdata.callsign(a,:)) - profiledata.sn(ii);
       if (ds==0) & (dy==0)
           disp(a);
           nck{'obs_t'}(a,:) = '    ';
           nck{'obs_t'}(a,1:length(num2str(profiledata.time(ii)))) = num2str(profiledata.time(ii));
           nck{'obs_m'}(a,:) = '  ';
           nck{'obs_m'}(a,1:length(num2str(profiledata.month(ii)))) = num2str(profiledata.month(ii));
           nck{'obs_d'}(a,:) = '  ';
           nck{'obs_d'}(a,1:length(num2str(profiledata.day(ii)))) = num2str(profiledata.day(ii));
           %update the ed and raw files:
           dd =  num2str(profiledata.day(ii));
           if length(dd) == 1; dd = ['0' dd];end
           mm = num2str(profiledata.month(ii));
           if length(mm) == 1; mm = ['0' mm];end
           yy = num2str(profiledata.year(ii));
           dat = [yy mm dd];
           nce{'woce_date'}(:) = str2num(dat);
           ncr{'woce_date'}(:) = str2num(dat);
           tt = [num2str(profiledata.time(ii)) '00'];
           nce{'woce_time'}(:) = str2num(tt);
           ncr{'woce_time'}(:) = str2num(tt);
           ju=julian([profiledata.year(ii) profiledata.month(ii) profiledata.day(ii) ...
               floor(profiledata.time(ii)/10000) rem(profiledata.time(ii),100) 0])-2415020.5;
           nce{'time'}(:) = ju;
           ncr{'time'}(:) = ju;
       else
           notupdated = [notupdated;ii];
       end
   else
       nomatch = [nomatch;ii];
   end
   close(nce); close(ncr);

% % put the float serial number in the callsign field of the keys
% nc = netcdf(filenam,'nowrite');
% ii = strmatch('SER1', nc{'SRFC_Code'}(:));
% 
% sn = nc{'SRFC_Parm'}(ii,:)';
% 
% keysdata.callsign(a,1:length(sn)) = sn;
% close(nc)
% 
end
%update the keys
nck{'data_source'}(:) = keysdata.datasource;
% nck{'callsign'}(:) = keysdata.callsign;

close(nck)

%% 35 - Extract the wocePF rejected info from Bruce Ingleby
% Bec Cowley 13 May 2008

fnm = 'wocePFLbadfloats.txt';
    fid=fopen(fnm,'r')
    a=0;
    while 1
        tline=fgetl(fid);
        sn = tline(57:62);
        rej = tline(63:68);
        if ~isempty(str2num(sn))
            a=a+1;
            pfsn(a) = str2num(sn);
            cnt(a) = str2num(tline(11:16));
            num(a) = str2num(tline(70:74));
            if strmatch('RejAll',rej)
                rejj(a) = 1;
            elseif strmatch('Rej950',rej)
                rejj(a) = 2;
            else
                rejj(a) = 0;
            end
        end
    end
            
    fid(close)
    
    wsn = getnc('wocePFio_keys.nc','callsign');
    wsn = str2num(wsn);
    wsnu = unique(wsn);
    stn = getnc('wocePFio_keys.nc','stn_num');
    stn = str2num(stn);
    
    ii = find(rejj >0);
    
    pfsnr = pfsn(ii);
    [c,ia,ib] = intersect(pfsnr,wsnu);
    stnr = [];
    for a=1:length(c)
        ii = find(wsn == wsnu(ib(a)));
        stnr = [stnr; stn(ii)];
    end
        
    fid = fopen('wocepfrej.txt','w')
    fprintf(fid,'%i\n',stnr);
    fclose(fid)

%% 36 Find the woce PF that have failed the screen in more than 40% profiles

wsn = getnc('wocePFio_keys.nc','callsign');
wsn = str2num(wsn);
wsnu = unique(wsn);
stn = getnc('wocePFio_keys.nc','stn_num');
stn = str2num(stn);
whos
aut = getnc('wocePFio_keys.nc','autoqc');

ii = find(aut>1);
[n,xout]=hist(wsn(ii),[369:1:645]);
for a=1:length(xout)
    %get total number of profiles:
    ij = find(wsn == xout(a));
    xtot(a) = length(ij);
end
    
%percentage failure:
xp = n./xtot;
bar(xout,xp*100);hold on

%isolate those that fail more than 25% of their profiles:
ij=find(xp>0.4);
bar(xout(ij),xp(ij)*100,'r')

grid
stnb=[];

for a=1:length(xout(ij))
    ik = find(wsn == xout(ij(a)));
    stnb = [stnb;stn(ik)];
end

% flag float 530 as 'DOR' - all profiles
prefix = 'wocePFio';
ii = find(wsn == 530);
for a = 2:length(ii)
%     %change the data source in the keys
%     keysdata.datasource(a,:) = 'woce ALACE';
    raw=0;
    filen=getfilename(num2str(stn(ii(a))),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
nc = netcdf(filenam,'write');
tm = nc{'Profparm'}(:);
dp = nc{'Depthpress'}(:);
nd = nc{'No_Depths'}(:);
nh = nc{'Num_Hists'}(:);
nh = nh+1;
nc{'Num_Hists'}(:) = nh;

nc{'Ident_Code'}(nh,:) = DATA_QC_SOURCE;
nc{'PRC_Code'}(nh,:) = 'CSCB';
nc{'Version'}(nh,:) = '1.0 ';
nc{'PRC_Date'}(nh,:) = '20080514';
nc{'Act_Code'}(nh,:) = 'DO';
nc{'Act_Parm'}(nh,:) = 'TEMP';
nc{'Aux_ID'}(nh) = dp(1);
nc{'Flag_severity'}(nh) = 3;
nc{'Previous_Val'}(nh,1:length(num2str(tm(1)))) = num2str(tm(1));
pqp = nc{'ProfQP'}(:);
pqp(1:nd) = '3';
nc{'ProfQP'}(:) = pqp;

close(nc)
end

%% 37 Find MBTs and XBTs that are mixed up (eg, MBTs that have been
% changed to XBTs and info not updated correctly

% prefix = 'masterio';
prefix = 'mastertasmanMQNC';
st = getnc([prefix '_keys.nc'],'stn_num');
dt = getnc([prefix '_keys.nc'],'data_t');
st = str2num(st);
udt = unique(dt,'rows');
iall = []; %do the whole lot by datatype
for a = 1:length(udt)
    ii = strmatch(udt(a,:),dt);
    iall = [iall;ii];
end

for a = 1:length(iall)
    raw=0;
    filen=getfilename(num2str(st(iall(a))),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    nc = netcdf(filenam,'write');
    
    dtyp = nc{'Data_Type'}(:);
    strid = nc{'Stream_Ident'}(:);
    dtf = strmatch('DT',nc{'Act_Code'}(:));
    disp([num2str(a) '  ' dt(iall(a),:) '  ' dtyp '  ' strid]);
    if ~isempty(strmatch('  ',strid(3:4)))
        nc{'Stream_Ident'}(3:4) = dt(iall(a),:);
        strid = nc{'Stream_Ident'}(:);
    end
    if ~isempty(strmatch('TXCB',strid))
        nc{'Stream_Ident'}(:) = 'TCXB';
        strid = nc{'Stream_Ident'}(:);
    end
    if isempty(strmatch(dt(iall(a),:),dtyp)) | isempty(strmatch(dtyp,strid(3:4)))
        fid = fopen('dtmismatch.txt','a');
        try
        fprintf(fid,'%s\n',[num2str(st(iall(a))) ' ' dt(iall(a),:) ' ' dtyp ' ' strid ' ' num2str(dtf(1))]);
        catch
        fprintf(fid,'%s\n',[num2str(st(iall(a))) ' ' dt(iall(a),:) ' ' dtyp ' ' strid]);
        end            
        fclose(fid);
    end
    close(nc)
end

%open the text file and fix all the MB references. Should all be XBts
 [stn]=textread('dtmismatch.txt','%10s %*s %*s %*s %*s');
 stn = unique(str2num(char(stn)));
 
 [c,ia,ib] = intersect(st,stn);
 notfixed = [];
 for a = 2:length(ia)
     dt(ia(a),1:2) = 'XB'; %fix the keys
     raw=0;
     filen=getfilename(num2str(st(ia(a))),raw);
     if(ispc)
         filenam=[prefix '\' filen];
     else
         filenam=[prefix '/' filen];
     end
     nce = netcdf(filenam,'write');
     raw=1;
     filen=getfilename(num2str(st(ia(a))),raw);
     if(ispc)
         filenam=[prefix '\' filen];
     else
         filenam=[prefix '/' filen];
     end
     ncr = netcdf(filenam,'write');
     %fix the data file
    dtyp = nce{'Data_Type'}(:);
    if isempty(strmatch('XB',dtyp))
        notfixed = [notfixed; dtyp];
    else
        nce{'Stream_Ident'}(3:4) = 'XB';
        ncr{'Stream_Ident'}(3:4) = 'XB';
    end
    
     close(nce);close(ncr);
 end
 
 nck = netcdf([prefix '_keys.nc'],'write');
 nck{'data_t'}(1:421091,:) = dt;
 close(nck);
 %now update the PEQ$ and fix references to HANAWA!!
  [stn]=textread('xbbadcorrections.txt','%10s %*s %*s %*s %*s');
  [stn2]=textread('xbignored.txt','%10s %*s %*s %*s %*s');
stn=[stn;stn2];
 stn = unique(str2num(char(stn)));
 notfixed = [];
 for a = 2:length(stn)
     raw=0;
     filen=getfilename(num2str(stn(a)),raw);
     if(ispc)
         filenam=[prefix '\' filen];
     else
         filenam=[prefix '/' filen];
     end
     nce = netcdf(filenam,'write');
     raw=1;
     filen=getfilename(num2str(stn(a)),raw);
     if(ispc)
         filenam=[prefix '\' filen];
     else
         filenam=[prefix '/' filen];
     end
     ncr = netcdf(filenam,'write');
     %fix the data file
%     peq = nce{'SRFC_Parm'}(:);
%     peqr = ncr{'SRFC_Parm'}(:);
%     ip = strmatch('800',peq);
%     ipr = strmatch('800',peqr);
%     if isempty(ip)
%         notfixed = [notfixed; peq];
%     else
%         nce{'SRFC_Parm'}(ip,:) = '999       ';
%     end
%     if isempty(ipr)
%         notfixed = [notfixed; peq];
%     else
%         ncr{'SRFC_Parm'}(ip,:) = '999       ';
%     end
    peq = nce{'SRFC_Parm'}(:);
    peqr = ncr{'SRFC_Parm'}(:);
    ip = strmatch('HANAWA',peq);
    ipr = strmatch('HANAWA',peqr);
    if isempty(ip)
        notfixed = [notfixed; peq];
    else
        nce{'SRFC_Parm'}(ip,:) = '1.0336    ';
    end
    if isempty(ipr)
        notfixed = [notfixed; peq];
    else
        ncr{'SRFC_Parm'}(ip,:) = '1.0336    ';
    end
    
     close(nce);close(ncr);
 end
%% 38 Change time padding in keys file:

prefix = 'argotasMQNC';

nck = netcdf([prefix '_keys.nc'],'write');
t=nck{'obs_t'}(:);
for a =1:length(t)
    ii = strfind(t(a,:),' ');
    clear dummy
    if ~isempty(ii)
        ij = 4 - length(ii)-1;
        dummy = t(a,:);
        dummy(4-ij:4) = t(a,1:ij+1);
        dummy(1:length(ii)) = t(a,ii);
        t(a,:) = dummy;
    end
end
nck{'obs_t'}(:) = t;

% t = nck{'obs_m'}(:);
t = nck{'obs_d'}(:);
for a =1:length(t)
    ii = strfind(t(a,:),' ');
    clear dummy
    if ~isempty(ii)
        ij = 2 - length(ii)-1;
        dummy = t(a,:);
        dummy(2-ij:2) = t(a,1:ij+1);
        dummy(1:length(ii)) = t(a,ii);
        t(a,:) = dummy;
    end
end
% nck{'obs_m'}(:) = t;
 nck{'obs_d'}(:) = t;

%% 38 - based on 32, extract tallies of flags.  Supply the
% variable 'flag_req' and you get a tally through time from the prefix_list
% databases.
%  needs 'flag_req' as cell array, severity_req as cell array of min
%  severity, and needs prefix_list as cell array of database prefixes

flag_req = [{'IP'}
    {'LE'}]
severity_req=[{'3'} 
    {'3'}]
prefix_list=[{'antarctic92to96MQNC'}
    {'antarctic97to99MQNC'}
    {'antarctic2000MQNC'}
    {'antarctic2005MQNC'}]
 
% prefix_list=[{'GTSPPmerMQNC'}
%     {'GTSPPmer96MQNC'}
%     {'GTSPPmer99MQNC'}
%     {'GTSPPmer2003MQNC'}
%     {'GTSPPmer2005MQNC'}
%     {'GTSPPmer2006MQNC'}]

% prefix_list=[{'qcarc83to88MQNC'}
%     {'qcarc89to93MQNC'}]

tally(1:length(flag_req),1980:2008)=0;
numPyear(1980:2008)=0;

for j=1:length(prefix_list)
    p=prefix_list(j)    
    m={'All'};
    y={'All'};
    q={'1'};
    a={'1'};
    tw={'1'};
    sstyle={'None'};
    [keysdata]=getkeys(p,m,y,q,a,tw,sstyle);
    y=keysdata.year;

    for i=1:length(keysdata.stnnum)
        numPyear(y(i))=numPyear(y(i))+1;
          raw=0;
        filen=getfilename(num2str(keysdata.stnnum(i)),raw);
        if(ispc)
            filenam=[p{1} '\' filen];
        else
            filenam=[p{1} '/' filen];
        end
        clear dataq
        dataq=getnc(filenam,'Flag_severity');
    %    dataq1=str2num(dataq);
        clear dataf
        dataf=getnc(filenam,'Act_Code');

        %ignore severity for now...
        for k=1:length(flag_req)

            if(strmatch(flag_req{k},dataf)>0)
                tally(k,y(i))=tally(k,y(i))+1;
            end
        end
    end
end

% now do something with the tally - bar plot?
t(1980:2008)=0;

for i=1990:2008
    if(numPyear(i)>0)
        t(i)=(tally(1,i)/numPyear(i))*100;
    end
end
    bar(t')%,'grouped')
hold on
t=title('Insulation penetrations in colder water - CSIRO data')
set(t,'FontSize',12)
set(t,'FontWeight','bold')
axis([1990 2010 0 40])
xlabel('Year')
ylabel('Percentage')
save_fig('InsulationPenetrationsforXBTsColdWaterPercents.gif')

%% 39 - find farseasfisheries profiles in master file, match with
% re-extracted data and combine the QC into the new profiles if the data is
% the same.
clear
filen = 'masterio';
filn = 'farseasio2';
ncload([filen '_keys.nc']);
ii = strmatch('fars',data_source);

mas.y = str2num(obs_y(ii,:));
mas.m = str2num(obs_m(ii,:));
mas.d = str2num(obs_d(ii,:));
mas.t = str2num(obs_t(ii,:));
mas.lat = obslat(ii);
mas.lon = obslng(ii);
mas.stn = str2num(stn_num(ii,:));
mas.dt = data_t(ii,:);
mas.aut = autoqc(ii,:);
mas.dup = zeros(length(mas.t),1);

ncload([filn '_keys.nc']);
far.y = str2num(obs_y);
far.m = str2num(obs_m);
far.d = str2num(obs_d);
ii = strmatch('    ',obs_t);
for a = 1:length(ii)
    obs_t(ii(a),:) = '9999';
end
far.t = str2num(obs_t);
far.lat = obslat;
far.lon = obslng;
far.stn = str2num(stn_num);
far.dt = data_t;
far.aut = autoqc;
far.dup =  zeros(length(far.t),1);

%inew=[];
idiffdtn=[];
%iexact=[];
inear=[];ineartmp=[];idiffdep=[];i10=[];fixkeysdt=[];
%for each new profile
for a = 1:length(idiffdt)
    %check for dups
    mlat = abs(mas.lat - far.lat(idiffdt(a)));
    mlon = abs(mas.lon - far.lon(idiffdt(a)));
    ii = find(mlat < 0.01 & mlon < 0.01);
    if ii
        %             break
        %test date/time
        hh = num2str(far.t(idiffdt(a)));
        if length(hh)<4
            %pad it
            hn(1:4-length(hh)) = '0';
            hn(4-length(hh)+1:4) = hh;
        else
            hn = hh;
        end
        dh = str2num(hn(1:2)) + str2num(hn(3:4))/60;
        dt = julian(far.y(idiffdt(a)),far.m(idiffdt(a)),far.d(idiffdt(a)),dh);
        for b = 1:length(ii)
            hh = num2str(mas.t(ii(b)));
            if length(hh)<4
                %pad it
                hn(1:4-length(hh)) = '0';
                hn(4-length(hh)+1:4) = hh;
            else
                hn = hh;
            end
            dh = str2num(hn(1:2)) + str2num(hn(3:4))/60;
            dti = julian(mas.y(ii(b)),mas.m(ii(b)),mas.d(ii(b)),dh);
            if abs(dt - dti) < 0.0069 %less than 10 minutes apart
                %check the datatype and number of depths and that the
                %data is the same:
                raw = false;
                fin=getfilename(num2str(far.stn(idiffdt(a))),raw);
                filenamf=[filn '/' fin];
                depa = getnc(filenamf,'Depthpress');
                tempa = getnc(filenamf,'Profparm');
                if size(depa,2) >1
                    depa = depa(1,:)';
                    tempa = tempa(1,:)';
                end
                fin=getfilename(num2str(mas.stn(ii(b))),raw);
                filenam=[filen '/' fin];
                depb = getnc(filenam,'Depthpress');
                tempb = getnc(filenam,'Profparm');
                if size(depb,2) >1
                    depb = depb(1,:)';
                    tempb = tempb(1,:)';
                end
                
                if sum(~isnan(tempa)) == sum(~isnan(tempb)) %same no depths
                    %                     if ~isempty(strmatch(far.dt(idiffdt(a),:),mas.dt(ii(b),:)))
                mbdp = getnc(filenamf,'Deep_Depth');
                    if (~isempty(strmatch('DT',far.dt(idiffdt(a),:))) && ~isempty(strmatch('DB',mas.dt(ii(b),:)))) ...
                            || ~isempty(strmatch('BO',far.dt(idiffdt(a),:))) || ...
                            (~isempty(strmatch('XC',far.dt(idiffdt(a),:))) && ~isempty(strmatch('CT',mas.dt(ii(b),:)))) ...
                            || (~isempty(strmatch('MB',far.dt(idiffdt(a),:))) && ~isempty(strmatch('XB',mas.dt(ii(b),:)))...
                            && mbdp(1) >=250)
                        if abs(nansum(tempa) - nansum(tempb)) <= 0.015 && ...
                           (abs(nansum(depa) - nansum(depb)) <= 0.06 ||...
                           abs(nansum(depa) - nansum(depb/1.0336)) <= 0.4)
                            %exact match, same datatype
                            disp([num2str(a) ' ' num2str(ii(b))])
                            mas.dup(ii(b)) = 1;
                            far.dup(idiffdt(a)) = 1;
                            fid=fopen('fsexactmatch.txt','a');
                            fprintf(fid,'%10i %10i\n',(far.stn(idiffdt(a))),(mas.stn(ii(b))));
                            fclose(fid);
                            %transfer the QC data to the new file:
                            nc = netcdf(filenamf,'write');
                            if ~isempty(strmatch('MB',far.dt(idiffdt(a),:)))
                                qcn = {'Ident_Code' 'PRC_Code' 'Version' 'PRC_Date' 'Act_Code' ...
                                    'Act_Parm' 'Aux_ID' 'Previous_Val' 'Flag_severity' 'Num_Hists' ...
                                    'Dup_Flag' 'ProfQP' 'DepresQ','Depthpress','Data_Type'};
                                nc{'Stream_Ident'}(:) = 'FSXB';
                                fixkeysdt = [fixkeysdt;a];
                            else
                                qcn = {'Ident_Code' 'PRC_Code' 'Version' 'PRC_Date' 'Act_Code' ...
                                    'Act_Parm' 'Aux_ID' 'Previous_Val' 'Flag_severity' 'Num_Hists' ...
                                    'Dup_Flag' 'ProfQP' 'DepresQ'};
                            end
                            for c = 1:length(qcn)
                                parm = getnc(filenam,qcn{c});
                                try
                                    nc{qcn{c}}(:) = parm;
                                catch
                                    try
                                        nc{qcn{c}}(1,:) = parm;
                                    catch
                                        nc{qcn{c}}(:) = parm(1,:);
                                    end
                                end
                            end
                            close(nc)
                            iexact = [iexact;idiffdt(a)];
                        elseif abs(nansum(tempa) - nansum(tempb)) < sum(~isnan(tempa))*.01
                            %very close match, dame datatype
                            fid=fopen('fsnearmatch.txt','a');
                            fprintf(fid,'%10i %10i\n',(far.stn(idiffdt(a))),(mas.stn(ii(b))));
                            fclose(fid);
                            inear = [inear;idiffdt(a)];
                        else %different temps, check
                            fid=fopen('fsnearmatchdifftemp.txt','a');
                            fprintf(fid,'%10i %10i\n',(far.stn(idiffdt(a))),(mas.stn(ii(b))));
                            fclose(fid);
                            ineartmp = [ineartmp;idiffdt(a)];
                        end
                    else %different datatype, check
                        fid=fopen('fsdiffdt.txt','a');
                        fprintf(fid,'%10i %10i\n',(far.stn(idiffdt(a))),(mas.stn(ii(b))));
                        fclose(fid);
                        idiffdtn = [idiffdtn;idiffdt(a)];
                    end
                else %different #depths, same date/time
                    fid=fopen('fsdiffdep.txt','a');
                    fprintf(fid,'%10i %10i\n',(far.stn(idiffdt(a))),(mas.stn(ii(b))));
                    fclose(fid);
                    idiffdep = [idiffdep;idiffdt(a)];
                end
            else %outside 10 mins diff
                fid=fopen('fsnearmatch10.txt','a');
                fprintf(fid,'%10i %10i\n',(far.stn(idiffdt(a))),(mas.stn(ii(b))));
                fclose(fid);
                i10 = [i10;idiffdt(a)];
            end
        end
    else %this has no duplicate,write to list of 'new' stations
        fid=fopen('fsnew.txt','a');
        fprintf(fid,'%10i\n',(far.stn(idiffdt(a))));
        fclose(fid);
        inew = [inew;idiffdt(a)];
    end
end


% intersect matches to check for exact matches in remaining lists
idiffdtu = setdiff(idiffdt,iexact);
idiffdepu = setdiff(idiffdep,iexact);
i10u = setdiff(i10,iexact);
inearu = setdiff(inear,iexact);
ineartmpu = setdiff(ineartmp,iexact);
inewu = setdiff(inew,iexact);
whos i*

% more than 10mins apart, add to inew:
inewu=[inewu;i10u];
%now try and fix diffdeps
fid = fopen('fsdiffdep.txt');
diffdm = textscan(fid,'%*s %s');
fclose(fid);
diffdm1 = cell2mat(diffdm{1});
diffdm = str2num(diffdm1);
[c,ia,ib] = intersect(diffdm,mas.stn);
[far.dt(idiffdep,:) mas.dt(ib,:) num2str(far.stn(idiffdep)) num2str(mas.stn(ib))]
%not in exact, then add to inew:
inewu = [inewu;idiffdepu];
%diffdt:
fid = fopen('fsdiffdt.txt');
diffdt = textscan(fid,'%s %s');
fclose(fid);
diffdt1 = cell2mat(diffdt{2});
diffdtm = str2num(diffdt1);
diffdt1 = cell2mat(diffdt{1});
diffdtf =  str2num(diffdt1);
[c,ia,ib] = intersect(diffdtm,mas.stn);
[d,id,ic] = intersect(diffdtf,far.stn);
for a =1:length(diffdtm)
    imdt(a) = find(mas.stn == diffdtm(a));
end
[far.dt(ic,:) mas.dt(imdt,:) num2str(far.stn(ic)) num2str(mas.stn(imdt))]
%rerun it through code above

%now fix MB to XB keys and NaN's in depthpress field and deep depth
nck = netcdf('farseasio2_keys.nc','write');
stn = nck{'stn_num'}(:);
dt = nck{'data_t'}(:);
stn = str2num(stn);
[c,ia,ib] = intersect(stn,far.stn(idiffdt(fixkeysdt)));
dt(ia,:) = repmat('XB',length(ia),1);
nck{'data_t'}(:) = dt;
close(nck);
for a = 1:length(fixkeysdt)
    %now fix the nans and depthpress and raw files, all info!
    raw = false;
    fin=getfilename(num2str(far.stn(idiffdt(fixkeysdt(a)))),raw);
    filenamf=[filn '/' fin];
    nce = netcdf(filenamf,'write');
    raw = true;
    fin=getfilename(num2str(far.stn(idiffdt(fixkeysdt(a)))),raw);
    filenamf=[filn '/' fin];
    ncr = netcdf(filenamf,'write');
    dpr = nce{'Depthpress'}(:);
    dpr = change(dpr,'==',NaN,-99.99);
    nce{'Depthpress'}(:) = dpr;
    nce{'Deep_Depth'}(:) = max(dpr,[],2);
    idtyp = strmatch('DTYP',nce{'Act_Parm'}(:));
    nce{'Flag_severity'}(idtyp) = 2;
qcn = {'Ident_Code' 'PRC_Code' 'Version' 'PRC_Date' 'Act_Code' ...
        'Act_Parm' 'Aux_ID' 'Previous_Val' 'Flag_severity' 'Num_Hists' ...
        'Dup_Flag' 'ProfQP' 'DepresQ','Depthpress','Data_Type','Deep_Depth'};
    ncr{'Stream_Ident'}(:) = 'FSXB';
    for c = 1:length(qcn)
        parm = nce{qcn{c}}(:);
        ncr{qcn{c}}(:) = parm;
    end
    close(nce)
    close(ncr)
end

inewu = [inewu;idiffdtn];
% inear match is a match, has a SP chop, cp over QC:
% check what's happening with ineartmp
fid = fopen('fsnearmatchdifftemp.txt');
difftp = textscan(fid,'%s %s');
fclose(fid);
difftp1 = cell2mat(difftp{2});
difftpm = str2num(difftp1);
difftp1 = cell2mat(difftp{1});
difftpf =  str2num(difftp1);
[c,ia,ib] = intersect(difftpm,mas.stn);
[d,id,ic] = intersect(difftpf,far.stn);
imtp = ones(length(difftpm),1);
for a =1:length(difftpm)
    imtp(a) = find(mas.stn == difftpm(a));
end
[far.dt(ic,:) mas.dt(imtp,:) num2str(far.stn(ic)) num2str(mas.stn(imtp))]
%run through the following:
%inew=[];
idiffdtn=[];
%iexact=[];
inear=[];ineartmpn=[];idiffdep=[];i10=[];fixkeysdt=[];
%for each new profile
for a = 1:length(ic)
    %check for dups
    mlat = abs(mas.lat - far.lat(ic(a)));
    mlon = abs(mas.lon - far.lon(ic(a)));
    ii = find(mlat < 0.01 & mlon < 0.01);
    if ii
        %             break
        %test date/time
        hh = num2str(far.t(ic(a)));
        if length(hh)<4
            %pad it
            hn(1:4-length(hh)) = '0';
            hn(4-length(hh)+1:4) = hh;
        else
            hn = hh;
        end
        dh = str2num(hn(1:2)) + str2num(hn(3:4))/60;
        dt = julian(far.y(ic(a)),far.m(ic(a)),far.d(ic(a)),dh);
        for b = 1:length(ii)
            hh = num2str(mas.t(ii(b)));
            if length(hh)<4
                %pad it
                hn(1:4-length(hh)) = '0';
                hn(4-length(hh)+1:4) = hh;
            else
                hn = hh;
            end
            dh = str2num(hn(1:2)) + str2num(hn(3:4))/60;
            dti = julian(mas.y(ii(b)),mas.m(ii(b)),mas.d(ii(b)),dh);
            if abs(dt - dti) < 0.0069 %less than 10 minutes apart
                %check the datatype and number of depths and that the
                %data is the same:
                raw = false;
                fin=getfilename(num2str(far.stn(ic(a))),raw);
                filenamf=[filn '/' fin];
                depa = getnc(filenamf,'Depthpress');
                tempa = getnc(filenamf,'Profparm');
                if size(depa,2) >1
                    depa = depa(1,:)';
                    tempa = tempa(1,:)';
                end
                fin=getfilename(num2str(mas.stn(ii(b))),raw);
                filenam=[filen '/' fin];
                depb = getnc(filenam,'Depthpress');
                tempb = getnc(filenam,'Profparm');
                if size(depb,2) >1
                    depb = depb(1,:)';
                    tempb = tempb(1,:)';
                end
                
                if sum(~isnan(tempa)) == sum(~isnan(tempb)) %same no depths
                    %                     if ~isempty(strmatch(far.dt(ic(a),:),mas.dt(ii(b),:)))
                mbdp = getnc(filenamf,'Deep_Depth');
                    if (~isempty(strmatch('DT',far.dt(ic(a),:))) && ~isempty(strmatch('DB',mas.dt(ii(b),:)))) ...
                            || ~isempty(strmatch('BO',far.dt(ic(a),:))) || ...
                            (~isempty(strmatch('XC',far.dt(ic(a),:))) && ~isempty(strmatch('CT',mas.dt(ii(b),:)))) ...
                            || (~isempty(strmatch('MB',far.dt(ic(a),:))) && ~isempty(strmatch('XB',mas.dt(ii(b),:)))...
                            && mbdp(1) >=250) || ~isempty(strmatch(far.dt(ic(a),:),mas.dt(ii(b),:)))
                        %check for spikes:
                        mm = find(tempb < 99);
                        mf = find(tempa < 99); ma = {'mm','mf'};
                        %pick the smaller of the two:
                        [sm,im] = min([size(mm,1),size(mf,1)]);
                        sm = ma{im};
                        sm = eval(sm);
                        if abs(nansum(tempa(sm)) - nansum(tempb(sm))) <= 0.015 && ...
                           (abs(nansum(depa(sm)) - nansum(depb(sm))) <= 0.06 ||...
                           abs(nansum(depa(sm)) - nansum(depb(sm)/1.0336)) <= 0.4)
                            %exact match, same datatype
                            disp([num2str(a) ' ' num2str(ii(b))])
                            mas.dup(ii(b)) = 1;
                            far.dup(ic(a)) = 1;
                            fid=fopen('fsexactmatch.txt','a');
                            fprintf(fid,'%10i %10i\n',(far.stn(ic(a))),(mas.stn(ii(b))));
                            fclose(fid);
                            %transfer the QC data to the new file:
                            nc = netcdf(filenamf,'write');
                            if ~isempty(strmatch('MB',far.dt(ic(a),:)))
                                qcn = {'Ident_Code' 'PRC_Code' 'Version' 'PRC_Date' 'Act_Code' ...
                                    'Act_Parm' 'Aux_ID' 'Previous_Val' 'Flag_severity' 'Num_Hists' ...
                                    'Dup_Flag' 'ProfQP' 'DepresQ','Depthpress','Data_Type'};
                                nc{'Stream_Ident'}(:) = 'FSXB';
                                fixkeysdt = [fixkeysdt;a];
                            else
                                qcn = {'Ident_Code' 'PRC_Code' 'Version' 'PRC_Date' 'Act_Code' ...
                                    'Act_Parm' 'Aux_ID' 'Previous_Val' 'Flag_severity' 'Num_Hists' ...
                                    'Dup_Flag' 'ProfQP' 'DepresQ'};
                            end
                            for c = 1:length(qcn)
                                parm = getnc(filenam,qcn{c});
                                try
                                    nc{qcn{c}}(:) = parm;
                                catch
                                    try
                                        nc{qcn{c}}(1,:) = parm;
                                    catch
                                        nc{qcn{c}}(:) = parm(1,:);
                                    end
                                end
                            end
                            close(nc)
                            iexact = [iexact;ic(a)];
                        elseif abs(nansum(tempa) - nansum(tempb)) < sum(~isnan(tempa))*.01
                            %very close match, dame datatype
                            fid=fopen('fsnearmatch.txt','a');
                            fprintf(fid,'%10i %10i\n',(far.stn(ic(a))),(mas.stn(ii(b))));
                            fclose(fid);
                            inear = [inear;ic(a)];
                        else %different temps, check
                            fid=fopen('fsnearmatchdifftemp.txt','a');
                            fprintf(fid,'%10i %10i\n',(far.stn(ic(a))),(mas.stn(ii(b))));
                            fclose(fid);
                            ineartmpn = [ineartmpn;ic(a)];
                        end
                    else %different datatype, check
                        fid=fopen('fsdiffdt.txt','a');
                        fprintf(fid,'%10i %10i\n',(far.stn(ic(a))),(mas.stn(ii(b))));
                        fclose(fid);
                        idiffdtn = [idiffdtn;ic(a)];
                    end
                else %different #depths, same date/time
                    fid=fopen('fsdiffdep.txt','a');
                    fprintf(fid,'%10i %10i\n',(far.stn(ic(a))),(mas.stn(ii(b))));
                    fclose(fid);
                    idiffdep = [idiffdep;ic(a)];
                end
            else %outside 10 mins diff
                fid=fopen('fsnearmatch10.txt','a');
                fprintf(fid,'%10i %10i\n',(far.stn(ic(a))),(mas.stn(ii(b))));
                fclose(fid);
                i10 = [i10;ic(a)];
            end
        end
    else %this has no duplicate,write to list of 'new' stations
        fid=fopen('fsnew.txt','a');
        fprintf(fid,'%10i\n',(far.stn(ic(a))));
        fclose(fid);
        inew = [inew;ic(a)];
    end
end
% intersect matches to check for exact matches in remaining lists
idiffdtu = setdiff(idiffdt,iexact);
idiffdepu = setdiff(idiffdep,iexact);
i10u = setdiff(i10,iexact);
inearu = setdiff(inear,iexact);
ineartmpnu = setdiff(ineartmpn,iexact);
inewu = setdiff(inew,iexact);
whos i*
%add ineartmpn  to inew:
inew = [inew;ineartmpnu];
%overwrite masterio fs files with 'exact' matches, keep masterio stn
%numbers:
iexactu = unique(iexact);
fid = fopen('fsexactmatch.txt');
ex = textscan(fid,'%s %s');
fclose(fid);
ex1 = cell2mat(ex{2});
exm = str2num(ex1);
ex1 = cell2mat(ex{1});
exf =  str2num(ex1);
[exfu,iex] = unique(exf); %duplicates as I ran something twice.
exf = exf(iex);
exm = exm(iex);
prefix = 'farseasio2';
for a =1:length(exf)
    raw=0;
    filen=getfilename(num2str(exf(a)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    nce = netcdf(filenam,'write');
    raw=1;
    filen=getfilename(num2str(exf(a)),raw);
    if(ispc)
        filenamr=[prefix '\' filen];
    else
        filenamr=[prefix '/' filen];
    end
    ncr = netcdf(filenamr,'write');
    %change the CSID to match the master
    ii = strmatch('CSID',nce{'SRFC_Code'}(:));
    nce{'SRFC_Parm'}(ii,:) = '          ';
    nce{'SRFC_Parm'}(ii,1:length(num2str(exm(a)))) = num2str(exm(a)); 
    ii = strmatch('CSID',ncr{'SRFC_Code'}(:));
    ncr{'SRFC_Parm'}(ii,:) = '          ';
    ncr{'SRFC_Parm'}(ii,1:length(num2str(exm(a)))) = num2str(exm(a)); 
    close(ncr)
    close(nce)
    %now cp the file to the original:
    raw=0;
    filenm=getfilename(num2str(exm(a)),raw);
    filenamm=[ 'masterio/' filenm];
    eval(['!cp ' filenam ' ' filenamm])
    raw=1;
    filenm=getfilename(num2str(exm(a)),raw);
    filenamm=[ 'masterio/' filenm];
    eval(['!cp ' filenamr ' ' filenamm])
    disp(num2str(a));
end


%% 40 - Fix deep-depth value to the deepest value in the file

clear
prefix = input('enter the data prefix: ','s')   %'farseasio2';
ncload([prefix '_keys.nc']);

for a=1:length(obslat);
         raw=0;
     filen=getfilename(num2str(stn_num(a,:)),raw);
     if(ispc)
         filenam=[prefix '\' filen];
     else
         filenam=[prefix '/' filen];
     end
     nce = netcdf(filenam,'write');
     raw=1;
     filen=getfilename(num2str(stn_num(a,:)),raw);
     if(ispc)
         filenam=[prefix '\' filen];
     else
         filenam=[prefix '/' filen];
     end
     ncr = netcdf(filenam,'write');
     %fix the data file
    dd = nce{'Depthpress'}(:);
    id = find(dd>-90);
    ddp = dd(id(end));
    nce{'Deep_Depth'}(:) = ddp;
    ncr{'Deep_Depth'}(:) = ddp;
    close(nce);
    close(ncr);
    disp(num2str(a));
end

%% 41 Create a keys file from the directory structure
%for when you lose the keys....
%    keysdata = 
%           time: [#profiles x 1 double]   hhmm
%            day: [#profiles x 1 double]   
%          month: [#profiles x 1 double]   
%           year: [#profiles x 1 double]
%         obslat: [#profiles x 1 double]   latitude(+ = north)
%         obslon: [#profiles x 1 double]   longitude (+ = east)
%       callsign: [#profiles x 10 char]    ship identifier (usually the callsign)      
%         stnnum: [#profiles x 10 char]    unique identifying number for
%                                               each profile - this forms the
%                                               directory tree to allow
%                                               retrieval of a profile from the
%                                               database directory
%       priority: [#profiles x 1 double]   indication of how "good" a profile is 
%                                               (1 is best, 9 is worst) 
%     datasource: [#profiles x 10 char]    where is the data from (CSIRO,
%                                               BOM, WOCE, LEVITUS, etc.
%    masterrecno: [1 x #profiles - double] a tally of where, within the
%                                               entire database, this record came 
%                                               from - allows you to rewrite data
%                                               without searching for it's original location.
%         prefix: 'database name'          the name of the directory which holds the profiles 
%       datatype: [#profiles x 2 char]     eg. XB (xbt), CT (CTD), TE
clear
cd /home/tethys1/iota/indianocean
keysfile = '/home/tethys1/iota/indianocean/farseasio2_keys.nc';
createkeys
keysdata.prefix = 'farseasio2';
cd /home/tethys1/iota/indianocean/farseasio2
% d = dirc(pwd);
d = genpath(pwd);
ii = strfind(d,':');
pth{1} = cellstr(d(1:ii(1)-1));
for a = 2:length(ii)-1
    pth{a} = d(ii(a)+1:ii(a+1)-1);
end
ist = 0;
for a = 1:length(pth)
    dd = dir([char(pth{a}) '/*ed.nc']);
    %set up path:
    ii = strfind(char(pth{a}),'/');
    nn = char(pth{a});
    st=[];
    for c = 1:length(ii)-1
        ss = nn(ii(c)+1:ii(c+1)-1);
        if ~isempty(str2num(ss))
            st = [st ss];
        end
    end
    if ~isempty(st)
        st = [st nn(ii(end)+1:end)];
    else
        continue
    end
    for b = 1:length(dd)
        ist = ist+1;
        %include in keys:
        stn = [st dd(b).name(1:2)];
        dummy = '          ';
        dummy(1:length(stn)) =stn;
        keysdata.stnnum(ist,:) = dummy;
        filn = [nn '/' dd(b).name];
        t = num2str(getnc(filn,'woce_time'));
        da = num2str(getnc(filn,'woce_date'));
        lat = getnc(filn,'latitude');
        ln = getnc(filn,'longitude');
        ds = getnc(filn,'Stream_Ident');
        srf = getnc(filn,'SRFC_Code');
        srfp = getnc(filn,'SRFC_Parm');
        call = strmatch('GCLL',srf);
        iot = strmatch('IOTA',srf);
        
        if length(t) < 6
            %pad it
            dummy(1:6-length(t)) = '0';
            dummy(6-length(t)+1:6) = t;
            t=dummy;
        end
        keysdata.time(ist,:) = t(1:4);
        keysdata.day(ist,:) = da(7:8);
        keysdata.month(ist,:) = da(5:6);
        keysdata.year(ist,:) = da(1:4);
        keysdata.obslat(ist) = lat;
        keysdata.obslon(ist) = ln;
        if ~isempty(call)
            keysdata.callsign(ist,:) = srfp(call,:);
        else
            keysdata.callsign(ist,:) = '          ';
        end
        keysdata.priority(ist) = 7;
        if ~isempty(iot)
            keysdata.datasource(ist,:) = srfp(iot,:);
        else
            keysdata.datasource(ist,:) = '          ';
        end
        keysdata.datatype(ist,:) = ds(3:4);
    end
end
cd ../
% keysdata.time = keysdata.time';
% keysdata.day = keysdata.day';
% keysdata.month = keysdata.month';
% keysdata.year = keysdata.year';
keysdata.obslat = keysdata.obslat';
keysdata.obslon = keysdata.obslon';
keysdata.priority = keysdata.priority';

nk = netcdf(keysfile,'write');
nk{'obslat'}(1:length(keysdata.obslat))=keysdata.obslat;
nk{'obslng'}(1:length(keysdata.obslat))=keysdata.obslon;
nk{'c360long'}(1:length(keysdata.obslat))=keysdata.obslon;
nk{'autoqc'}(1:length(keysdata.obslat))=0;
nk{'stn_num'}(1:length(keysdata.obslat),:)=keysdata.stnnum;
nk{'callsign'}(1:length(keysdata.obslat),:)=keysdata.callsign;
nk{'obs_y'}(1:length(keysdata.obslat),:)=keysdata.year;
nk{'obs_d'}(1:length(keysdata.obslat),:)=keysdata.day;
nk{'obs_m'}(1:length(keysdata.obslat),:)=keysdata.month;
nk{'obs_t'}(1:length(keysdata.obslat),:)=keysdata.time;
nk{'data_t'}(1:length(keysdata.obslat),:)=keysdata.datatype;
nk{'data_source'}(1:length(keysdata.obslat),:)=keysdata.datasource;
nk{'priority'}(1:length(keysdata.obslat))=keysdata.priority;
  
close(nk)


% hold these for now...

% l=num2str(longi)
% prevv(ll,1:length(l))=l;
% prevv(ll,length(l)+1:end)=' ';
% prevv(1:10,:)
% 
% nc{'Previous_Val'}(:,:)=prevv;


%% 42 fix longitudes in sprightly data - can be adapted to any data set
% that needs wholesale changes to position  Based on #14.

%  note: kk is index to those profiles needing change in the keysdata
%  set.

% adapted to correct Sprightly longitudes (all set to 114.6833 for some
% reason) AT: 17/9/08

%kk=find(keysdata.obslon>300);
ssn=keysdata.stnnum;
kk=1:length(keysdata.obslon);
lon=keysdata.obslon;

for i=1:length(kk)
    i=i
    raw=0;
    filen=getfilename(num2str(ssn(kk(i))),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    raw=1;
    filen=getfilename(num2str(ssn(kk(i))),raw);
    if(ispc)
        filenamr=[prefix '\' filen];
    else
        filenamr=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    ncr=netcdf(filenamr,'write');
    longi=nc{'longitude'}(:);
    actc=nc{'Act_Code'}(:,:);
    prevv=nc{'Previous_Val'}(:,:);
    
    ll=strmatch('PE',actc);
    if(~isempty(ll))
        if(length(ll)>1);ll=2;end
        pv=prevv(ll,:);
        pvf=str2num(pv);
        if(abs(pvf-lon(kk(i)))>.0001)
            pvf=pvf
            lonhold=lon(kk(i))
            longi=longi
            lon(kk(i)) = pvf;
        end
    else
        lonhold=lon(kk(i))
        longi=longi
        pvf=lonhold;
    end
    longi=pvf;
    
 %   longi=longi-90.;
    if(abs(longi-lon(kk(i)))>.0001)
        pause
    end
    nc{'longitude'}(:)=longi;
    ncr{'longitude'}(:)=longi;
    
    close(nc);
    close(ncr);
end

filekeys=[prefix '_keys.nc']
nc=netcdf(filekeys,'write');
nc{'obslng'}(:)=lon(:);
nc{'c360long'}(:)=lon(:);
close(nc)

%% 43 - fix sprightly double decimal latitudes -

% the strategy is to grep the unique id from the .MA files and grab the
% correct latitude, then insert it into the raw, edited and keys files.

ssn=keysdata.stnnum;
lat=keysdata.obslat;
kk=1:length(keysdata.obslat);
fileorig='/home/tethys1/UOT/data/XBTarchaeology/sprightly_from_mers/original_data/*.MA'

for i=1:length(keysdata.obslat)
    i=i
    raw=0;
    filen=getfilename(num2str(ssn(kk((i))),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    raw=1;
    filen=getfilename(num2str(ssn(kk((i))),raw);
    if(ispc)
        filenamr=[prefix '\' filen];
    else
        filenamr=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    ncr=netcdf(filenamr,'write');
    
%    lati=nc{'latitude'}(:);
    [s,str]=system(['grep ' num2str(ssn(i)) ' '  fileorig]);

    lati=str(143:152);
    nc{'latitude'}(:)=lati(:);
    ncr{'latitude'}(:)=lati(:);
    
    close(nc);
    close(ncr);
    
    lat(i)=lati;
    
end
filekeys=[prefix '_keys.nc']
nc=netcdf(filekeys,'write');
nc{'obslat'}(:)=lat(:);
close(nc)

%% 44 - fix FHZ1 callsigns from astrolabe...

ssn=keysdata.stnnum;
holdcalls=keysdata.callsign;

for i=1:length(keysdata.obslat)
    
    if(~isempty(strmatch('FHZ1',keysdata.callsign(i,:))))
        
    i=i
        raw=0;
        filen=getfilename(num2str(ssn(i)),raw);
        if(ispc)
            filenam=[prefix '\' filen];
        else
            filenam=[prefix '/' filen];
        end
        raw=1;
        filen=getfilename(num2str(ssn(i)),raw);
        if(ispc)
            filenamr=[prefix '\' filen];
        else
            filenamr=[prefix '/' filen];
        end

        nc=netcdf(filenam,'write');
        ncr=netcdf(filenamr,'write');
        
        findc=getnc(filenam,'SRFC_Code');
        oldc=getnc(filenam,'SRFC_Parm');
        
        ll=strmatch('GCLL',findc);
        oldc(ll,:)='FHZI      ';
        nc{'SRFC_Parm'}(:,:)=oldc(:,:);

        ncr{'SRFC_Parm'}(:,:)=oldc(:,:);
        close(nc);
        close(ncr);
    
        holdcalls(i,:)='FHZI      ';
    end
end
        
        
 filekeys=[prefix '_keys.nc']
nc=netcdf(filekeys,'write');
nc{'callsign'}(:,:)=holdcalls(:,:);
close(nc)
  
%% 45 - fix scale factor in longitude
for i=1:length(keysdata.obslat)
    i=i
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    raw=1;
    filen=getfilename(num2str(keysdata.stnnum(i)),raw);
    if(ispc)
        filenamr=[prefix '\' filen];
    else
        filenamr=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    ncr=netcdf(filenamr,'write');
      if ~isempty(ncr{'longitude'}.scale_factor)
        ncr{'longitude'}.scale_factor=[];
     end
      if ~isempty(nc{'longitude'}.scale_factor)
        nc{'longitude'}.scale_factor=[];
     end
  
    
    
    close(nc);
    close(ncr);
    
    
end
%% 46 - replace lats/longs in files with those in keys
ssn=keysdata.stnnum;
for a = 1:length(ssn)
    raw=0;
    filen=getfilename(num2str(ssn(a)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    raw=1;
    filen=getfilename(num2str(ssn(a)),raw);
    if(ispc)
        filenamr=[prefix '\' filen];
    else
        filenamr=[prefix '/' filen];
    end

    nc=netcdf(filenam,'write');
    ncr=netcdf(filenamr,'write');
    nc{'longitude'}(:) = keysdata.obslon(a);
    nc{'latitude'}(:) = keysdata.obslat(a);
    ncr{'longitude'}(:) = keysdata.obslon(a);
    ncr{'latitude'}(:) = keysdata.obslat(a);
    close(nc)
    close(ncr)
end

%% 47 - Fix profiles flagged with pLA and also fix deep-depth value to the deepest value in the file

clear
prefix = input('enter the data prefix: ','s')   %'farseasio2';
ncload([prefix '_keys.nc']);

for a=1:length(obslat);
    raw=0;
    filen=getfilename(num2str(stn_num(a,:)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    nce = netcdf(filenam,'write');
    raw=1;
    filen=getfilename(num2str(stn_num(a,:)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    ncr = netcdf(filenam,'write');
    ac=getnc(filenam,'Act_Code')
    kk=strfind(ac,'PL');
    if ~isempty(kk)
        %fix the data file
        dd = nce{'Depthpress'}(:);
        id = find(dd>-90);
        ddp = dd(id(end));
        nce{'Deep_Depth'}(:) = ddp;
        ncr{'Deep_Depth'}(:) = ddp;
        ncr{'No_Depths'}(:) = id(end);
        close(nce);
        close(ncr);
        disp(num2str(a));
    end
end

%% 47 - find STA codes in the history record


file= 'STAprofiles.txt'
fid=fopen(file,'a');

 for i=1:length(keysdata.stnnum)
       raw=0;
       filen=getfilename(num2str(keysdata.stnnum(i)),raw);
       if(ispc)
          filenam=[prefix '\' filen];
       else
          filenam=[prefix '/' filen];
       end
        
               [status,result]=system(['ncdump ' filenam ' | grep ST'])
        if ~isempty(result)
            nc=netcdf(filenam);
            lat=getnc(filenam,'latitude');
            lon=nc{'longitude'}(:);
            fprintf(fid,'%s %s %s\n',num2str(lat),num2str(lon),filenam);
        end
 end

       fclose(fid);


     %% 48  find a specific QC flag
     for i=1:length(keysdata.stnnum)
       raw=0;
       filen=getfilename(num2str(keysdata.stnnum(i)),raw);
       if(ispc)
          filenam=[prefix '\' filen];
       else
          filenam=[prefix '/' filen];
       end
         ac = getnc(filenam,'Act_Code');
          kk=strmatch('PL',ac);
          if ~isempty(kk)
              ds=[keysdata.stnnum(i)]
          end
     end

     %% fix data source in keys and in files
     %assume DATA_SOURCE is set correctly by getglobals routine. If not,
     %need to set it manually!
     %note that this changes ALL the data_source fields in the keys and in
     %every file.
     nc = netcdf([prefix '_keys.nc'],'w');
     s = '          ';
     nc{'data_source'}(:) = repmat(s,length(keysdata.stnnum),1);
     s(1:length(DATA_SOURCE)) = DATA_SOURCE;
      nc{'data_source'}(:) = repmat(s,length(keysdata.stnnum),1);
      close(nc)
    
     for i = 1:length(keysdata.stnnum)
         raw=0;
         filen=getfilename(num2str(keysdata.stnnum(i,:)),raw);
         if(ispc)
             filenam=[prefix '\' filen];
         else
             filenam=[prefix '/' filen];
         end
         nce = netcdf(filenam,'write');
         raw=1;

         filen=getfilename(num2str(keysdata.stnnum(i,:)),raw);
         if(ispc)
             filenam=[prefix '\' filen];
         else
             filenam=[prefix '/' filen];
         end
         ncr = netcdf(filenam,'write');
         
         ii = strmatch('IOTA',nce{'SRFC_Code'}(:));
         if ~isempty(ii)
             s = '          ';
             nce{'SRFC_Parm'}(ii,:)=s;
             nce{'SRFC_Parm'}(ii,1:length(DATA_SOURCE)) = DATA_SOURCE';
         end
         close(nce)
         ii = strmatch('IOTA',ncr{'SRFC_Code'}(:));
         if ~isempty(ii)
             s = '          ';
             ncr{'SRFC_Parm'}(ii,:)=s;
             ncr{'SRFC_Parm'}(ii,1:length(DATA_SOURCE)) = DATA_SOURCE';
         end
         close(ncr)
         
     end
     
%% 50 Fix date formats from ddmmyyyy to yyyymmdd in histories and update
% fields, as per NOAA meds-ascii requirements
%Run this over 2014 databases only as at 29 August, 2014. Re-extract the
%meds-ascii versions of the 2014 databases for our archives at this stage.
%Bec Cowley, 29 August, 2014
%written as a function so that BOM can use it. See 'fix_dateformats.m'

%% 51 Change the RAN ship callsigns for HMAS Sydney which was decomissioned and
% the system was moved to HMAS Stuart

ii = cellfun(@isempty,(strfind(cellstr(keysdata.callsign),'VKML')));
jj = find(keysdata.month > 4);
[c,ia,ib] = intersect(ii,jj);
cid = '15046ST   ';
shp = 'HMASStuart';
cll = 'VKCK      ';

for a = 1:length(c)
    %edit each raw and ed file
    raw=0;
    filen=getfilename(num2str(keysdata.stnnum(c(a),:)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    nce = filenam;
    raw=1;
    
    filen=getfilename(num2str(keysdata.stnnum(c(a),:)),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    ncr = filenam;
    
    ncwrite(nce,'Cruise_ID',cid)
    ncwrite(ncr,'Cruise_ID',cid)
    
    srfc = ncread(nce,'SRFC_Code');
    srfcp = ncread(nce,'SRFC_Parm');
    ind = strmatch('GCLL',srfc');
    srfcp(:,ind) = cll';
    ind = strmatch('SHP#',srfc');
    srfcp(:,ind) = shp';
    
    
    ncwrite(nce,'SRFC_Parm',srfcp);
    ncwrite(ncr,'SRFC_Parm',srfcp);
end

%Now fix the callsign in the keys
for a = 1:length(c)
    keysdata.callsign(c(a),:) = cll;
end
ncwrite('RANxbt2015_keys.nc','callsign',keysdata.callsign')
