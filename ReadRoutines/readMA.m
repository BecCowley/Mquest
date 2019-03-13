function profiledata=readMA(fid,uniqueid)
%this function reads a single profile from a MA file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.

CONFIG

%setup output files
clear profiledata:
profiledata.nss=num2str(uniqueid);

%Get the header data and ouput to both files:
d=fgets(fid);

profiledata.year=str2num(d(27:30));
profiledata.month=str2num(d(31:32));
profiledata.day=str2num(d(33:34));
profiledata.time=str2num(d(35:38))*100;

profiledata.lat=str2num(d(63:70));
profiledata.lon=str2num(d(71:79)); 
profiledata.latitude=profiledata.lat;
%need to multiply longitude by -1 and change to 360 degree long
%MA FORMAT IS +west and -east. Opposite to the rest of the world....
profiledata.longitude=-profiledata.lon;
if(profiledata.longitude<0)
    profiledata.longitude=360+profiledata.longitude;
end
profiledata.lon=profiledata.longitude;
        
%if this data is to be added:

profiledata.mky=d(1:8);
profiledata.onedegsq=d(9:16);
profiledata.cruiseID=d(17:26);
profiledata.datat=d(39:40);
profiledata.iumsgno=d(41:52);
profiledata.streamsource=d(53);
profiledata.uflag=d(54);
profiledata.medssta=d(55:62);
profiledata.qpos=d(80);
profiledata.qdatetime=d(81);
profiledata.qrec=d(82);
profiledata.update=d(83:90);
profiledata.bultime=d(91:102);
profiledata.bulheader=d(103:108);
profiledata.sourceID=d(109:112);
profiledata.streamident=d(113:116);
profiledata.QCversion=d(117:120);
profiledata.dataavail=d(121);

profiledata.nprof=str2num(d(122:123));
profiledata.nparms=str2num(d(124:125));
if(isempty(profiledata.nparms));profiledata.nparms=0;end
profiledata.nsurfc=str2num(d(126:127));
if(isempty(profiledata.nsurfc));profiledata.nsurfc=0;end
profiledata.nhists=str2num(d(128:130));
if(isempty(profiledata.nhists));profiledata.nhists=0;end
e=130;

profiledata.nosseg='';
profiledata.deep_depth='';
profiledata.prof_type='';
profiledata.dup_flag='';
profiledata.digit_code='';
profiledata.standard='';
profiledata.deep_depth=0;
profiledata.nosseg=0;
for i=1:profiledata.nprof
    profiledata.nosseg(i)=str2num(d(e+1:e+2));
    profiledata.prof_type(i,1:4)=d(e+3:e+6);
    profiledata.prof_type(i,5:16)='            ';
    profiledata.dup_flag(i)=d(e+7);
    profiledata.digit_code(i)=d(e+8);
    profiledata.standard(i)=d(e+9);
    profiledata.deep_depth(i)=str2num(d(e+10:e+14));
    e=e+14;
end

profiledata.profiledata.pcode='';
profiledata.profiledata.parm='';
profiledata.profiledata.qparm='';
for i=1:profiledata.nparms
    profiledata.pcode(i,1:4)=d(e+1:e+4);
    profiledata.parm(i,1:10)=d(e+5:e+14);
    profiledata.qparm(i)=d(e+15)
    e=e+15;
end

profiledata.surfpcode='';
profiledata.surfparm='';
profiledata.surfqparm='';
for i=1:profiledata.nsurfc
    profiledata.surfpcode(i,1:4)=d(e+1:e+4);
    profiledata.surfparm(i,1:10)=d(e+5:e+14);
    profiledata.surfqparm(i)=d(e+15);
    e=e+15;
end    

% profiledata.nss=[];
profiledata.unqiueid_from_file = 0;
if(profiledata.nsurfc>0)
    kk=strmatch('CSID',profiledata.surfpcode(:,:));
    if(~isempty(kk))   %csid already exists in this MA file...
        profiledata.nss=profiledata.surfparm(kk(1),:);
        uniqueid=uniqueid-1;
        profiledata.unqiueid_from_file = 1;
    end
end
if(isempty(profiledata.nss))
  if(profiledata.nsurfc>0)
    kk=strmatch('DBID',profiledata.surfpcode(:,:));
    if(~isempty(kk))   %csid already exists in this MA file...
        profiledata.nss=profiledata.surfparm(kk(1),:);
        uniqueid=uniqueid-1;
        profiledata.unqiueid_from_file = 1;
    end
  end
end

profiledata.identcode='';
profiledata.PRCcode='';
profiledata.Version='';
profiledata.PRCdate='';
profiledata.Actcode='';
profiledata.Actparm='';
profiledata.AuxID=0;
profiledata.PreviousVal='';
profiledata.flagseverity=0;
for i=1:profiledata.nhists
    profiledata.identcode(i,1:2)=d(e+1:e+2);
    profiledata.PRCcode(i,1:4)=d(e+3:e+6);
    profiledata.Version(i,1:4)=d(e+7:e+10);
    profiledata.PRCdate(i,1:8)=d(e+11:e+18);
    profiledata.Actcode(i,1:2)=d(e+19:e+20);
    profiledata.Actparm(i,1:4)=d(e+21:e+24);
    profiledata.AuxID(i)=str2num(d(e+25:e+32));
    profiledata.PreviousVal(i,1:10)=d(e+33:e+42);
    profiledata.flagseverity(i)=0;
    e=e+42;
end

profiledata.D_P_Code='';
profiledata.profile_type='';

profiledata.depth(1,1,1)=0;
profiledata.depresQ(1,1,1)=0;
profiledata.profParm(1,1,1)=0;
profiledata.profQparm(1,1,1)=0;
profiledata.nodepths=0;

for k=1:profiledata.nprof
    for i=1:profiledata.nosseg(k)
        d=fgets(fid);
        %get the depth temp pairs etc out of the file, 
        %then read the next segment if relevant:
        profiledata.nodepths(k,i)=str2num(d(59:62));
        profiledata.D_P_Code(k)=d(63);
        % Profileseg(k,i)=str2num(d(57:58));
        profiledata.profile_type(k,i,1:4)=d(53:56);
        e=64;
        for dd=1:profiledata.nodepths(k,i)
            profiledata.depth(k,i,dd)=str2num(d(e:e+5));
            profiledata.depresQ(k,i,dd)=d(e+6);
            profiledata.profparm(k,i,dd)=str2num(d(e+7:e+15));
            profiledata.profQparm(k,i,dd)=d(e+16);
            e=e+17;
        end
    end
    
end

no_depths='';
profiledata.ndep=sum(profiledata.nodepths,2);

profiledata.autoqc=0;

%%%%%%%%%%%%%%%%% COMBINE SEGMENTS %%%%%%%%%%%%%%%%%

%CS: Combine segments into complete profiles
%CS: Taken from writeMQNCfiles.m
prof=[];

for j=1:profiledata.nprof
    i=0;
    gg=strmatch(profiledata.prof_type(j),profiledata.profile_type);
    for k=1:profiledata.nosseg(j)
        for l=1:profiledata.nodepths(gg(1),k)
            i=i+1;
            prof(j,i)=profiledata.profparm(gg(1),k,l);
            profQ(j,i)=profiledata.profQparm(gg(1),k,l);
            dep(j,i)=profiledata.depth(gg(1),k,l);
            depQ(j,i)=profiledata.depresQ(gg(1),k,l);
        end
    end
end
 
if(isempty(prof))
    prof=0;
    profQ=0;
    dep=0;
    depQ=0;
end   
    
%CS Update profiledata for complete profiles
profiledata.profparm = prof;
profiledata.profQparm = profQ;
profiledata.depth = dep;
profiledata.depresQ = depQ;
profiledata.nossegs = 0;

return
