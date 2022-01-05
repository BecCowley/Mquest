% check and fix problem batch dates/serial numbers on probes.
%run one cell at a time.


clear
prefix=input('enter the database prefix:','s');
stnnum = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
%serial numbers and batch dates:
serial = NaN*ones(length(stnnum),1); batch = serial;
for aa=1:length(stnnum)
    
    raw= 0;
    filen=getfilename(num2str(stnnum(aa)),raw);
    filenam=[prefix '/' filen];
    srfccodes=ncread(filenam,'SRFC_Code');
    srfcparm=ncread(filenam,'SRFC_Parm');
    crid{aa} = ncread(filenam,'Cruise_ID')';
    
    kk=strmatch('MFD#',srfccodes');
    if(~isempty(kk))
        batch(aa) = datenum(srfcparm(:,kk)','yyyymmdd');
    end
    
    kk=strmatch('SER#',srfccodes');
    if(~isempty(kk))
        try
            serial(aa) = str2num(srfcparm(:,kk)');
        catch
            serial(aa) = NaN;
        end            
    end
    
end

%% plot
plot(batch,serial,'ko')

%% 20xx dates - which cruise?
%adjust this to suit each fix

% ii = find(batch > datenum('01/02/2011','dd/mm/yyyy') & batch < datenum('01/01/2012','dd/mm/yyyy'));%serial > 1000000);% & serial < 1285000)% & b% 
ii = find(stnnum == 89013822);
stnnum(ii)
for a = 1:length(ii)
    disp(stnnum(ii(a)))
    disp(serial(ii(a)))
    disp(datestr(batch(ii(a))));
    nb = datestr(batch(ii(a)));
    ns = num2str(serial(ii(a)));
    nb = input(['Enter new batch date [' nb '],yyyymmdd:'],'s');
    if isempty(nb)
        nb = datestr(batch(ii(a)),'yyyymmdd');
    end
    ns = input(['Enter new serial number [' ns ']:'],'s');
    if isempty(ns)
        ns = num2str(serial(ii(a)));
    end
    
    batch(ii(a)) = datenum(nb,'yyyymmdd');
    serial(ii(a)) = str2num(ns);
end
%%
%write back to file:
for aa=ii:length(stnnum)
    for bb = 1:2;
        raw= bb -1;
        filen=getfilename(num2str(stnnum(aa)),raw);
        filenam=[prefix '/' filen];
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        
        kk=strmatch('MFD#',srfccodes');
        if(~isempty(kk))
            bd = datestr(batch(aa)','yyyymmdd')';
            srfcparm(1:length(bd),kk) = bd;
        end
        
        kk=strmatch('SER#',srfccodes');
        if(~isempty(kk))
            ser = num2str(serial(aa))';
            srfcparm(:,kk) = '          ';
            srfcparm(1:length(ser),kk)=ser;
        end
        ncwrite(filenam,'SRFC_Code',srfccodes)
        ncwrite(filenam,'SRFC_Parm',srfcparm)
    end
end
