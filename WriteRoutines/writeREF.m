%write newreformat data - this script takes the netcdf data and converts it to 2m,
%then outputs a data to the datn archive format
%  this must only write GOOD data!!!
%Bec Cowley, Jan, 2014

% A891 001 201306100402Z3540S17458E0082  HB  RCT$ 06   PEQ$ 52   TEMP XB
%           169169169169169169169169169169169169169169169169169169169169
%           169169169169169169169169169169169169169169169169169169168168
%           166165165164162160159159158157157156156156156156156155155154
%           154153152152152151150149148148148147147147147147147146146146
%           146146

if i == 1
    %set start number of profiles to be written: 
    pnum = 0;
end
if(strmatch('TP',pd.QC_code(:,:)))
    return
end
if(strmatch('DU',pd.QC_code(:,:)))
    return
end

prefix=[handles.outputfile];

%create depth/temp arrays to 2m...
pno = 1; %if more than one variable, the first will be associated with temp.
if(~isempty(pd.temp))
    temp=pd.temp;
    ndep = pd.ndep(:,pno);
else
    return
end

%good data
g=find(pd.qc(1:ndep,pno)=='0' | pd.qc(1:ndep,pno)=='1' ...
    | pd.qc(1:ndep,pno)=='2' | pd.qc(1:ndep,pno)=='5');
if isempty(g) %no good temp data in the profile, don't write it into datn file
    return
end

%now handle the surface data. For these datn files, we don't keep the
%surface data. Three versions of how the data is QC'd:
%1. the temperature data is replaced with 99.99 and flag of 5
%2. the temperature data is left with a flag of 3
%3. the data comes from somewhere else and is flag 1 (eg Scripps)
%We need to treat all the data the same for these datn files only. So,
%let's remove all the data and interp to the surface.

%should not have any nans, but sometimes there are some in the data
gg = find(~isnan(temp(g).*pd.depth(g,pno)));

g = g(gg); %just the good data, excludes the surface flagged 3 or 5

d=fix(pd.depth(max(g),pno)); %why fix?
temp=temp(g);
depth=pd.depth(g,pno);
% kktmp=find(temp>99 & depth<5);
% let's remove all the surface data less than 5m
kktmp=find(depth<5);

if length(kktmp) == length(temp) %short record
    return
end

%set the surface to the reliable temperature below
if ~isempty(kktmp)
    temp(kktmp)=temp(kktmp(end)+1);
end
clear depth2m
clear temp2m

if(length(temp)>4)
    
    depth2m=0:2:d;
    %interpolate entire profile, will end up with NaNs at surface
    temp2m=interp1(depth,temp,depth2m);
    %set zero value to same temp as first depth if there is a zero
    if temp2m(1) == 0
        temp2m(1) = temp2m(2);
    end

    %replace surface NaNs with next good temperature
    inan = find(isnan(temp2m(depth2m<6)));
    if ~isempty(inan)
        temp2m(inan) = temp2m(inan(end)+1);
    end

    endkk=length(depth2m);
    headerstring=[];
    %construct the header:
    %A891 001 201306100402Z3540S17458E0082  HB  RCT$ 06   PEQ$ 52   TEMP XB
    %nb24N003 200001031811Z2846S11332E0384  HB  RCT$ 03   PEQ$ 052  TEMP
    %no942001 200001052048Z1200N51483E0766  HB  RCT$ 03   PEQ$ 052  TEMP XB
    pn = '000';
    pnum = pnum +1;
    pnn = num2str(pnum);
    pn(4-length(pnn):end) = pnn;
    disp([pn ': ' num2str(ss)])
        
    if pd.latitude < 0
        latdir = 'S';
    else
        latdir = 'N';
    end
    lat1 = '00';lat2 = '00';
    llt = num2str(fix(abs(pd.latitude)));
    dec = num2str(round(rem(abs(pd.latitude),1)*60));
    lat1(3-length(llt):end) = llt;
    lat2(3-length(dec):end) = dec;
    lat = [lat1 lat2];;
    
    %convert 360 degrees to E/W longitude
    if pd.longitude <= 180
        ln = pd.longitude;
        londir = 'E';
    else
        ln = 360-pd.longitude;
        londir = 'W';
    end
    lon1 = '000';lon2 = '00';
    llt = num2str(fix(abs(ln)));
    dec = num2str(round(rem(abs(ln),1)*60));
    lon1(4-length(llt):end) = llt;
    lon2(3-length(dec):end) = dec;
    lon = [lon1 lon2];

    %get maximum depth (refpres in fortran code).
    rp = '0000';
    refpres = num2str(length(depth2m));
    rp(5-length(refpres):end) = refpres;
    
    %did it hit the bottom?
    ihb = strmatch('HB',pd.QC_code);
    if ~isempty(ihb)
        hbr = 'HB';
    else
        hbr = '  ';
    end
    
    %get probe type and recorder type information:
    irct = strmatch('RCT$',pd.surfcode);
    if ~isempty(irct)
        rct = '     ';
        rc = strtrim(pd.surfparm(irct,:));
        rct(1:length(rc)) = rc;
        rct = ['RCT$ ' rct];
    else
        rct = 'RCT$ unkno';
    end
    iprt = strmatch('PEQ$',pd.surfcode);
    if ~isempty(iprt)
        peq = '     ';
        pq = strtrim(pd.surfparm(iprt,:));
        peq(1:length(pq)) = pq;
        peq = ['PEQ$ ' peq];
    else
        peq = 'PEQ$ unkno';
    end
    
    %build the header. Note that we are just using the first 5 characters
    %of the Cruise ID, which is dependant upon the entry made by the
    %operator. We could adapt the ships.txt file to identify the ship and
    %make a nice string as was done with ships.inc in fortran.
    crid = strtrim(profiledata.Cruise_ID');
    try
        crid = [crid(1:2) crid(5:7)];
    catch
        if length(crid) >=5 
            crid = [crid(1:2) crid(end-2:end)];
        else
            str = '     ';
            str(1:length(crid)) = crid;
            crid = str;
        end
    end
    headerstring=[crid pn ' ' pd.year pd.month ...
        pd.day  pd.time(1:2) pd.time(4:5) 'Z' ...
        lat latdir  ...
        lon londir rp '  ' hbr '  ' ...
        rct peq 'TEMP ' profiledata.Data_Type'];
    
    %now write it all out
    
    if(handles.first==0)
        fid2=fopen(prefix,'at');
    else
        fid2=fopen(prefix,'wt');
    end
    if (fid2==-1)
        error=1
        return
    end
    fprintf(fid2,'%s\n',headerstring);
    %temperature format three chars for each temp after 10 spaces. 60
    %characters for each line. 20 temperatures on each line.
    % no26S001 200001052048Z1200N05129E0383  HB  RCT$ 03   PEQ$ 052  TEMP XB
    %           254254254254254254254254254254254254254253252251250250249249
    %           249249248246245243239238237237235231228226227223220219216213
%           211205201200200199198196194193194194194193193193193193192192
%           192192192192191191190189189189189188187187187186185184183183
%           182182182179176175175174173166163162161161159159158157156154
%           154154153152151151150149149149148147147147146145145146146146
%           146146146146146146146146146146145145145145145145145145144144
%           143143142141140140139139139139139138138138137137135135134134
%           133132132132132132131132132132132132132132132132133133133134
%           134134134133131130130131130130129128128127126126126126126126
%           126125125127128128128128127125124124123121120120119119119119
%           119119119119119119119119119119119119119118118118118118118118
%           118118118118119119119120120119119119121122123123122121121120
%           120119119118119119119118118118118119119119118118119119119119
%           119119119119119119119119118117118116115116114114115115115115
%           115115114114114113114115115115115116115116116117117118119119
%           119121121121121121121121121121121121121121121121120120120119
%           119119118118118118118118118118118118118118118118118118118117
%           117117117117117117117116116116116116116116116116116116116116
%           116116116

%     t2m = round(temp2m*10);
    nlines = ceil(endkk/20);
    tmp = num2str(temp2m*10,'%3.0f');
    mmm = 1;
    for ilines=1:nlines
        tempstr = '          ';
        if mmm+59 <= length(tmp)
            tempstr = [tempstr tmp(mmm:mmm+59)];
        else
            tempstr = [tempstr tmp(mmm:end)];
        end
        fprintf(fid2,'%s\n',tempstr);
        mmm = mmm + 60;
    end
    
fclose(fid2);
end
endkk=0;



return
