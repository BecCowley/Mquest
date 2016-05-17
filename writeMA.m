%writeMA - this program takes input from the identified netcdf file 
% and outputs it in the data exchange format meds-ascii.

%retrieveguidata
profiledata=handles.profile_data;

if i == 1
    clear recwritten
end
if(strmatch('TP',profiledata.QC_code(:,:)))
    return
end
if(strmatch('DU',profiledata.QC_code(:,:)))
    return
end
prefix=[handles.outputfile '.MA'];

if(handles.first==0)
    fid=fopen(prefix,'at');
else
    fid=fopen(prefix,'wt')

end
if (fid==-1)
    return
end

if exist('recwritten','var') == 0 %for the sort key in MA files
    mkstart = '00000100'
    profiledata.Mky = mkstart;
    mky = profiledata.Mky(1:6);
else
    mkstart = num2str(str2num(mkstart) + 100,'%08.0f');
    profiledata.Mky = mkstart;
    mky = profiledata.Mky(1:6);
end

clear a

% Changes to format as discussed with Norm Hall, NOAA. Implemented by Bec
% Cowley, August, 2014
% put in a 'U' for update in the Update field if it is empty. 'S' is used
% for skip when sending updates to NOAA. For our purposes, use 'U' with all
% new files. 
if ~isempty(strmatch(' ',profiledata.Uflag))
    profiledata.Uflag = 'U';
end
%check the datestr in the PRC and Up_date fields are the correct format. Should be
%yyyymmdd. THIS IS NOT FOOLPROOF! Will be a problem if the year is 2001 to
%2012 as these years can be day/month too. For now, just trap for this and
%deal with it when it happens:
profiledata.Up_date = reformatdates(profiledata.Up_date')';
%Now PRC
for i = 1:profiledata.numhists
    profiledata.PRC_Date(i,:) = reformatdates(profiledata.PRC_Date(i,:))';
end
% start the sort key (Mky) at 1. Format is ssssssrr where ssssss is the sequential
% station number in the MA file, and rr is the parameter record number. If
% more the 1500 records, we add another record #. 00 is the first, header,
% record. Then increment 1 for each parameter and segment.
a=profiledata.Mky;
if(~isempty(strfind(profiledata.time,':')))
    a=[a profiledata.One_Deg_Sq' profiledata.Cruise_ID' profiledata.year profiledata.month ...
    profiledata.date profiledata.time(1:2) profiledata.time(4:5)]
else
    a=[a profiledata.One_Deg_Sq' profiledata.Cruise_ID' profiledata.year profiledata.month ...
    profiledata.date profiledata.time]
end

a=[a profiledata.Data_Type' profiledata.Iumsgno' profiledata.Stream_Source' profiledata.Uflag' profiledata.MEDS_Sta'];

%need to convert longitude backto +/-180 degrees:

plong=profiledata.longitude;
if(plong<180);plong=-plong;end
if(plong>=180);plong=-plong+360;end

alat=sprintf('%8.4f',profiledata.latitude);
alon=sprintf('%9.4f',plong);

a=[a alat alon profiledata.Q_Pos profiledata.Q_Date_Time profiledata.Q_Record];

a=[a profiledata.Up_date' profiledata.Bul_Time' profiledata.Bul_Header' profiledata.Source_ID' profiledata.Stream_Ident'];

a=[a profiledata.QC_Version' profiledata.Data_Avail];

nprofs=sprintf('%2i',profiledata.nprof);
if(profiledata.Nparms==0)
    nparms=' 0';
else
    nparms=sprintf('%2i',profiledata.Nparms);
end
if(profiledata.Nsurfc==0)
    nsurfc=' 0';
else
    nsurfc=sprintf('%2i',profiledata.Nsurfc);
end
if(profiledata.numhists==0)
    numhists='  0';
else
    numhists=sprintf('%3i',profiledata.numhists);
end
a=[a nprofs nparms nsurfc numhists];

clear noseg

for i=1:profiledata.nprof
    %need to replace the dup_flag with 'Y' or 'N'. We don't pass dups through,
    %but do this anyway:
    if ~isempty(strmatch('D',profiledata.Dup_Flag(i)))
        profiledata.Dup_Flag(i) = 'Y';
    else
        profiledata.Dup_Flag(i) = 'N';
    end
    noseg(i)=floor(profiledata.ndep(i)./1500)+1;
    if noseg(i) < 0
        noseg(i) = 1;
    end
    anoseg=sprintf('%2i',noseg(i));
    a=[a anoseg ];
    a=[a profiledata.ptype(i,1:4) profiledata.Dup_Flag(i) profiledata.Digit_Code(i) profiledata.Standard(i)];

    clear adeepdepth
    adeepdepth=sprintf('%5.1f',profiledata.Deep_Depth(i));
    a=[a adeepdepth(1:5)];
end

if(profiledata.Nparms>0)
    for i=1:profiledata.Nparms
        a=[a profiledata.Pcode(i,:) profiledata.Parm(i,:) profiledata.Q_Parm(i,:)];
    end
end

if(profiledata.Nsurfc>0)
    for i=1:profiledata.Nsurfc
        a=[a profiledata.SRFC_Code(i,:) profiledata.SRFC_Parm(i,:) profiledata.SRFC_Q_Parm(i,:)];
    end
end

if(profiledata.numhists>0)
    if(profiledata.numhists>100);profiledata.numhists=100;end
    for i=1:profiledata.numhists
        aauxid=sprintf('%8.2f',profiledata.QC_depth(i));
        prevv=str2num(profiledata.Previous_Val(i,:));
        if ~isempty(prevv)
            aprevv=sprintf('%10.3f',prevv);
        else
            aprevv=profiledata.Previous_Val(i,:);
        end
        a=[a profiledata.Ident_Code(i,:) profiledata.PRC_Code(i,:) profiledata.Version(i,:) ...
            profiledata.PRC_Date(i,:) profiledata.QC_code(i,:) profiledata.Act_Parm(i,:) ...
            aauxid(1:8) aprevv(1:10)];
    end
end

% now write this bit to the file, then construct the profile data bits...
%first, find any nulls in the "a" string and replace them with ''
I = find(a == char(0));
if(~isempty(I))
   a(I) = ' ';
end

%write to the data file:

count=fprintf(fid,'%s',a);
count2=fprintf(fid,'\n');

% construct the depth/temp/quality section:
% setup header info:
mkyrec=str2num(profiledata.Mky(end-1:end));

for j=1:profiledata.nprof

    ij=0;
    for k=1:noseg(j)
        
    clear a

    mkyrec = mkyrec + 1;
    a = [mky num2str(mkyrec,'%02.0f')];
    
    if(~isempty(strfind(profiledata.time,':')))
        a=[a profiledata.One_Deg_Sq' profiledata.Cruise_ID' profiledata.year profiledata.month ...
        profiledata.date profiledata.time(1:2) profiledata.time(4:5)];
    else
        a=[a profiledata.One_Deg_Sq' profiledata.Cruise_ID' profiledata.year profiledata.month ...
        profiledata.date profiledata.time];
    end

    if(k==noseg)
        ndepths=rem(profiledata.ndep(j),1500);
    else
        ndepths=1500;
    end
    ndp=sprintf('%4i',ndepths);
    nseg=sprintf('%2i',k);
    a=[a profiledata.Data_Type' profiledata.Iumsgno' profiledata.ptype(j,1:4) nseg ndp profiledata.D_P_Code(j)];

    for i=1:ndepths
        ij=ij+1;
        clear d t qd qc
        if(strfind(a,'0191902122200'))
                j=j;
                ij=ij;
                profiledata;
                ndepths
        end
        d=sprintf('%6.2f',profiledata.depth(j,ij));
        t=sprintf('%9.3f',profiledata.data(j,ij));
           
        try
            a=[a d(1:6) profiledata.depthqc(j,ij) t(1:9) profiledata.qc(j,ij)];
        catch
            ij=ij
            j=j
            profiledata.depthqc;
            profiledata.qc;
        end
    end
    
%prepare to write it to the file:
    I = find(a == char(0));
    if(~isempty(I))
        a(I) = ' '; 
    end

%write to the data file:

count=fprintf(fid,'%s',a);
count2=fprintf(fid,'\n');

    end
end

fclose(fid);
recwritten = 1;



return
