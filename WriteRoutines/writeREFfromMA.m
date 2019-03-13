%write newreformat data - this script takes data from readMA, converts it to 2m,
%then outputs a data to the datn archive format
%  this must only write GOOD data!!!
% Called by convertMA2datn.m
%Bec Cowley, Feb, 2016

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

prefix=filn(1:end-3);

%create depth/temp arrays to 2m...
pno=strmatch('TEMP',profiledata.prof_type);
if(~isempty(pno))
    temp=profiledata.profparm(pno,:);
    ndep = profiledata.ndep;
else
    return
end

g=find(profiledata.profQparm(pno,1:ndep)=='0' | profiledata.profQparm(pno,1:ndep)=='1' ...
    | profiledata.profQparm(pno,1:ndep)=='2' | profiledata.profQparm(pno,1:ndep)=='5');
if isempty(g)
    return
end
gg = find(~isnan(temp(g)'.*profiledata.depth(pno,g)'));

g = g(gg);

d=fix(profiledata.depth(pno,max(g)));
temp=temp(g);
depth=profiledata.depth(pno,g);
kktmp=find(temp>99 & depth<5);

if length(kktmp) == length(temp)
    return
end

if ~isempty(kktmp)
    temp(kktmp)=temp(kktmp(end)+1);
end
clear depth2m
clear temp2m

if(length(temp)>4)
    
    depth2m=0:2:d;
    
    temp2m(2:length(depth2m))=interp1(depth,temp,depth2m(2:end));
    if(length(depth2m)>=2)
        temp2m(1)=temp2m(2);
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
    disp([pn ': ' profiledata.nss])
        
    if profiledata.latitude < 0
        latdir = 'S';
    else
        latdir = 'N';
    end
    lat1 = '00';lat2 = '00';
    llt = num2str(fix(abs(profiledata.latitude)));
    dec = num2str(round(rem(abs(profiledata.latitude),1)*60));
    lat1(3-length(llt):end) = llt;
    lat2(3-length(dec):end) = dec;
    lat = [lat1 lat2];;
    
    %convert 360 degrees to E/W longitude
    if profiledata.longitude < 180
        ln = profiledata.longitude;
        londir = 'E';
    else %west
        ln = 360-profiledata.longitude;
        londir = 'W';
    end
    lon1 = '000';lon2 = '00';
    llt = num2str(fix(abs(profiledata.longitude)));
    dec = num2str(round(rem(abs(profiledata.longitude),1)*60));
    lon1(4-length(llt):end) = llt;
    lon2(3-length(dec):end) = dec;
    lon = [lon1 lon2];

    %get maximum depth (refpres in fortran code).
    rp = '0000';
    refpres = num2str(length(depth2m));
    rp(5-length(refpres):end) = refpres;
    
    %did it hit the bottom?
    ihb = strmatch('HB',profiledata.Actcode);
    if ~isempty(ihb)
        hbr = 'HB';
    else
        hbr = '  ';
    end
    
    %get probe type and recorder type information:
    irct = strmatch('RCT$',profiledata.surfpcode);
    if ~isempty(irct)
        rct = '     ';
        rc = strtrim(profiledata.surfparm(irct,:));
        rct(1:length(rc)) = rc;
        rct = ['RCT$ ' rct];
    else
        rct = 'RCT$ unkno';
    end
    iprt = strmatch('PEQ$',profiledata.surfpcode);
    if ~isempty(iprt)
        peq = '     ';
        pq = strtrim(profiledata.surfparm(iprt,:));
        peq(1:length(pq)) = pq;
        peq = ['PEQ$ ' peq];
    else
        peq = 'PEQ$ unkno';
    end
    
    %build the header. Note that we are just using the first 5 characters
    %of the Cruise ID, which is dependant upon the entry made by the
    %operator. We could adapt the ships.txt file to identify the ship and
    %make a nice string as was done with ships.inc in fortran.
    crid = strtrim(profiledata.cruiseID);
    crid = [crid(1:5)];
    yy = num2str(profiledata.year);
    mm=num2str(profiledata.month);
    if length(mm)<2
        mm = ['0' mm];
    end
    dd = num2str(profiledata.day);
    if length(dd) < 2
        dd = ['0' dd];
    end
    tt = num2str(profiledata.time);
    if length(tt) < 6
        tt = [repmat('0',1,6 - length(tt)) tt];
    end
    
    headerstring=[crid pn ' ' yy mm dd  ...
          tt(1:2) tt(4:5) 'Z' ...
        lat latdir  ...
        lon londir rp '  ' hbr '  ' ...
        rct peq 'TEMP ' profiledata.datat];
    
    %now write it all out
    if i == 1
        fid2=fopen(prefix,'wt');
    else
        fid2 = fopen(prefix,'at');
    end
    if (fid2==-1)
        error=1;
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

    t2m = fix(temp2m*10);
    nlines = ceil(endkk/20);
    mmm = 1;
    for ilines=1:nlines
        tempstr = '          ';
        for jtem = mmm:mmm+19
            if jtem>endkk
                break
            end
            tmp = '   ';
            tp = num2str(t2m(jtem));
            tmp(4-length(tp):end) = tp;
            tempstr = [tempstr tmp];
        end
        fprintf(fid2,'%s\n',tempstr);
        mmm = mmm + 20;
    end
    
fclose(fid2);
end
endkk=0;



return
