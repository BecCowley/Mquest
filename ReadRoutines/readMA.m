function [profiledata,pd]=readMA(fid,uniqueid)
%this function reads a single profile from a MA file and creates the
%structure "profiledata" containing all the variables necessary to either
%plot or write the data into another format.
% profiledata =
%
%         woce_date: 20160426
%         woce_time: 142500
%              time: 42485
%          latitude: -25.35
%         longitude: 131.03
%         Num_Hists: 1
%           No_Prof: 1
%            Nparms: 0
%            Nsurfc: 13
%               Mky: [8x1 char]
%        One_Deg_Sq: [8x1 char]
%         Cruise_ID: [10x1 char]
%         Data_Type: [2x1 char]
%           Iumsgno: [12x1 char]
%     Stream_Source: ' '
%             Uflag: 'U'
%          MEDS_Sta: [8x1 char]
%             Q_Pos: '1'
%       Q_Date_Time: '1'
%          Q_Record: '1'
%           Up_date: [8x1 char]
%          Bul_Time: [12x1 char]
%        Bul_Header: [6x1 char]
%         Source_ID: [4x1 char]
%      Stream_Ident: [4x1 char]
%        QC_Version: [4x1 char]
%        Data_Avail: 'A'
%         Prof_Type: [16x1 char]
%          Dup_Flag: 'N'
%        Digit_Code: '7'
%          Standard: '2'
%        Deep_Depth: 198.7
%             Pcode: [30x4 char]
%              Parm: [30x10 char]
%            Q_Parm: [30x1 char]
%         SRFC_Code: [30x4 char]
%         SRFC_Parm: [30x10 char]
%       SRFC_Q_Parm: [30x1 char]
%        Ident_Code: [100x2 char]
%          PRC_Code: [100x4 char]
%           Version: [100x4 char]
%          PRC_Date: [100x8 char]
%          Act_Code: [100x2 char]
%          Act_Parm: [100x4 char]
%            Aux_ID: [100x1 single]
%      Previous_Val: [100x10 char]
%     Flag_severity: [100x1 int32]
%          D_P_Code: 'D'
%         No_Depths: 300
%        Depthpress: [400x1 double]
%          Profparm: [400x1 double]
%           DepresQ: [400x1 char]
%            ProfQP: [400x1 char]

%And a holding structure (pd) for QCd data, plotting. Returned to main
%structure at write time.
% pd =
%
%          latitude: -25.35
%         longitude: 131.03
%              year: '2016'
%             month: '04'
%              day: '26'
%              ndep: 300
%              time: '14:25'
%             depth: [400x1 double]
%                qc: [400x1 char]
%          depth_qc: [400x1 char]
%              temp: [400x1 double]
%     Flag_severity: [100x1 int32]
%          numhists: 1
%            nparms: 0
%           QC_code: [100x2 char]
%          QC_depth: [100x1 double]
%          PRC_Date: [100x8 char]
%          PRC_Code: [100x4 char]
%           Version: [100x4 char]
%          Act_Parm: [100x4 char]
%      Previous_Val: [100x10 char]
%        Ident_Code: [100x2 char]
%          surfcode: [30x4 char]
%          surfparm: [30x10 char]
%         surfqparm: [30x1 char]
%            nsurfc: 13
%               nss: some unique number
%             ptype: [16x1 char]

CONFIG

%setup output files
clear profiledata:
pd.unqiueid_from_file = 0;
pd.nss=num2str(uniqueid);

%Get the header data and ouput to both files:
d=fgets(fid);

profiledata.year=str2num(d(27:30));
profiledata.month=str2num(d(31:32));
profiledata.day=str2num(d(33:34));
profiledata.time=str2num(d(35:38))*100;

lat=str2num(d(63:70));
lon=str2num(d(71:79)); 
profiledata.latitude=lat;
%need to multiply longitude by -1 and change to 360 degree long
%MA FORMAT IS +west and -east. Opposite to the rest of the world....
profiledata.longitude=-lon;
if(profiledata.longitude<0)
    profiledata.longitude=360+profiledata.longitude;
end

%if this data is to be added:

profiledata.Mky=d(1:8);
profiledata.One_Deg_Sq=d(9:16);
profiledata.Cruise_ID=d(17:26);
profiledata.Data_Type=d(39:40);
profiledata.Iumsgno=d(41:52);
profiledata.Stream_Source=d(53);
profiledata.Uflag=d(54);
profiledata.MEDS_Sta=d(55:62);
profiledata.Q_Pos=d(80);
profiledata.Q_Date_Time=d(81);
profiledata.Q_Record=d(82);
profiledata.Up_date=d(83:90);
profiledata.Bul_Time=d(91:102);
profiledata.Bul_Header=d(103:108);
profiledata.Source_ID=d(109:112);
profiledata.Stream_Ident=d(113:116);
profiledata.QC_Version=d(117:120);
profiledata.Data_Avail=d(121);

profiledata.No_Prof=str2num(d(122:123));
profiledata.Nparms=str2num(d(124:125));
if(isempty(profiledata.Nparms));profiledata.Nparms=0;end
profiledata.Nsurfc=str2num(d(126:127));
if(isempty(profiledata.Nsurfc));profiledata.Nsurfc=0;end
profiledata.Num_Hists=str2num(d(128:130));
if(isempty(profiledata.Num_Hists));profiledata.Num_Hists=0;end
e=130;

profiledata.Prof_Type='';
profiledata.Dup_Flag='';
profiledata.Digit_Code='';
profiledata.Standard='';
profiledata.Deep_Depth=0;
nosseg=0;

for i=1:profiledata.No_Prof
    nosseg = str2num(d(e+1:e+2));
    profiledata.Prof_Type(i,1:4)=d(e+3:e+6);
    profiledata.Prof_Type(i,5:16)='            ';
    profiledata.Dup_Flag(i)=d(e+7);
    profiledata.Digit_Code(i)=d(e+8);
    profiledata.Standard(i)=d(e+9);
    profiledata.Deep_Depth(i)=str2num(d(e+10:e+14));
    e=e+14;
end

profiledata.Pcode='';
profiledata.Parm='';
profiledata.Q_parm='';
for i=1:profiledata.Nparms
    profiledata.Pcode(i,1:4)=d(e+1:e+4);
    profiledata.Parm(i,1:10)=d(e+5:e+14);
    profiledata.Q_Parm(i)=d(e+15)
    e=e+15;
end

profiledata.SRFC_Code='';
profiledata.SRFC_Parm='';
profiledata.SRFC_Q_Parm='';
for i=1:profiledata.Nsurfc
    profiledata.SRFC_Code(i,1:4)=d(e+1:e+4);
    profiledata.SRFC_Parm(i,1:10)=d(e+5:e+14);
    profiledata.SRFC_Q_Parm(i)=d(e+15);
    e=e+15;
end    

if(profiledata.Nsurfc>0)
    kk=strmatch('CSID',profiledata.SRFC_Code(:,:));
    if(~isempty(kk))   %csid already exists in this MA file...
        pd.nss=profiledata.SRFC_Parm(kk(1),:);
        uniqueid=uniqueid-1;
        pd.unqiueid_from_file = 1;
    end
    kk=strmatch('DBID',profiledata.SRFC_Code(:,:));
    if(~isempty(kk))   %csid already exists in this MA file...
        pd.nss=profiledata.SRFC_Parm(kk(1),:);
        uniqueid=uniqueid-1;
        pd.unqiueid_from_file = 1;
    end
end

profiledata.Ident_Code='';
profiledata.PRC_Code='';
profiledata.Version='';
profiledata.PRC_Date='';
profiledata.Act_Code='';
profiledata.Act_Parm='';
profiledata.Aux_ID=0;
profiledata.Previous_Val='';
profiledata.Flag_severity=0;
for i=1:profiledata.Num_Hists
    profiledata.Ident_Code(i,1:2)=d(e+1:e+2);
    profiledata.PRC_Code(i,1:4)=d(e+3:e+6);
    profiledata.Version(i,1:4)=d(e+7:e+10);
    profiledata.PRC_Date(i,1:8)=d(e+11:e+18);
    profiledata.Act_Code(i,1:2)=d(e+19:e+20);
    profiledata.Act_Parm(i,1:4)=d(e+21:e+24);
    profiledata.Aux_ID(i)=str2num(d(e+25:e+32));
    profiledata.Previous_Val(i,1:10)=d(e+33:e+42);
    profiledata.Flag_severity(i)=0;
    e=e+42;
end

profiledata.D_P_Code='';
profiledata.Depthpress=0;
profiledata.DepresQ='0';
profiledata.Profparm=0;
profiledata.ProfQP='0';
profiledata.No_Depths=0;

for k=1:profiledata.No_Prof
    for i=1:nosseg(k)
        d=fgets(fid);
        %get the depth temp pairs etc out of the file, 
        %then read the next segment if relevant:
        profiledata.No_Depths(k,i)=str2num(d(59:62));
        profiledata.D_P_Code(k)=d(63);
        e=64;
        for dd=1:profiledata.No_Depths(k,i)
            profiledata.Depthpress(k,i,dd)=str2num(d(e:e+5));
            profiledata.DepresQ(k,i,dd)=d(e+6);
            profiledata.Profparm(k,i,dd)=str2num(d(e+7:e+15));
            profiledata.ProfQP(k,i,dd)=d(e+16);
            e=e+17;
        end
    end
    
end


%%%%%%%%%%%%%%%%% COMBINE SEGMENTS %%%%%%%%%%%%%%%%%

%CS: Combine segments into complete profiles
%CS: Taken from writeMQNCfiles.m
prof=0;
profQ='0';
dep=0;
depQ='0';

for j=1:profiledata.No_Prof
    i=0;
    for k=1:nosseg(j)
        for l=1:profiledata.No_Depths(j(1),k)
            i=i+1;
            prof(j,1,i)=profiledata.Profparm(j(1),k,l);
            profQ(j,1,1,i)=profiledata.ProfQP(j(1),k,l);
            dep(j,i)=profiledata.Depthpress(j(1),k,l);
            depQ(j,i)=profiledata.DepresQ(j(1),k,l);
        end
    end
end
profiledata.No_Depths=sum(profiledata.No_Depths,2);
     
%CS Update profiledata for complete profiles
profiledata.Profparm = prof;
profiledata.ProfQP = profQ;
profiledata.Depthpress = dep;
profiledata.DepresQ = depQ;

%add in some more stuff to profiledata
wd=[num2str(profiledata.year) num2str(profiledata.month,'%02i') num2str(profiledata.day,'%02i')];
wtime = num2str(profiledata.time,'%06i');
profiledata.woce_time = int32(str2double(wtime));
profiledata.woce_date = int32(str2double(wd));
wt=profiledata.woce_time;
wt=floor(wt/100);
wt2=sprintf('%04i',wt);

%clean up some extra bits of profiledata:
profiledata.year = [];profiledata.month = []; profiledata.day = [];

%make the pd structure for plotting and adding QC
pd.latitude=profiledata.latitude;
pd.longitude=profiledata.longitude;
pd.year=wd(1:4);
pd.month=wd(5:6);
pd.day=wd(7:8);
pd.ndep=profiledata.No_Depths;
pd.time=[wt2(1:2) ':' wt2(3:4)];
pd.depth = profiledata.Depthpress;
pd.deep_depth = profiledata.Deep_Depth;
pd.qc = squeeze(profiledata.ProfQP);
pd.depth_qc = profiledata.DepresQ;
pd.temp = squeeze(profiledata.Profparm);
pd.Flag_severity = profiledata.Flag_severity;
pd.numhists = profiledata.Num_Hists;
pd.nparms = profiledata.Nparms;
pd.QC_code = profiledata.Act_Code;
pd.QC_depth = profiledata.Aux_ID;
pd.PRC_Date = profiledata.PRC_Date;
pd.PRC_Code = profiledata.PRC_Code;
pd.Version = profiledata.Version;
pd.Act_Parm = profiledata.Act_Parm;
pd.Previous_Val = profiledata.Previous_Val;
pd.Ident_Code = profiledata.Ident_Code;
pd.surfcode = profiledata.SRFC_Code;
pd.surfparm = profiledata.SRFC_Parm;
pd.surfqparm = profiledata.SRFC_Q_Parm';
pd.nsurfc = profiledata.Nsurfc;
pd.ptype = profiledata.Prof_Type;

%put some profile data arrays the other way:
profiledata.SRFC_Code=profiledata.SRFC_Code';
profiledata.SRFC_Parm=profiledata.SRFC_Parm';
profiledata.PRC_Date = profiledata.PRC_Date';
profiledata.PRC_Code = profiledata.PRC_Code';
profiledata.Version = profiledata.Version';
profiledata.Act_Code = profiledata.Act_Code';
profiledata.Prof_Type = profiledata.Prof_Type';
profiledata.Ident_Code = profiledata.Ident_Code';
profiledata.Act_Parm = profiledata.Act_Parm';
profiledata.Previous_Val = profiledata.Previous_Val';
profiledata.Depthpress = profiledata.Depthpress';
profiledata.Data_Type = profiledata.Data_Type';
return
