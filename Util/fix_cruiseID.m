% check and fix problem cruise IDs.
%run one cell at a time.


clear
prefix=input('enter the database prefix:','s');
stnnum = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
% get cruise id, date and call sign information:

for aa=1:length(stnnum)
    
    raw= 0;
    filen=getfilename(num2str(stnnum(aa)),raw);
    filenam=[prefix '/' filen];
    srfccodes=ncread(filenam,'SRFC_Code');
    srfcparm=ncread(filenam,'SRFC_Parm');
    crid{aa} = ncread(filenam,'Cruise_ID')';
    ti(aa) = datenum(num2str(ncread(filenam, 'woce_date')),'yyyymmdd');
    
    kk=strmatch('GCLL',srfccodes');
    if(~isempty(kk))
        calls(aa,:) = srfcparm(:,kk)';
    end
        
end


%% adjust this to suit each fix
% callsign VRDE7, 18/2/22 - 20/2/22, 16 profiles, voyage 176N should be 176S
% callsign VRDE7, 14/3/22 - 16/3/22, 18 profiles, voyage 177N should be 176N
% note there is a correct 177N in April, 2022

% fix first issue:
ii = contains(crid, '176N') & ti < datenum(2022,3,1); 
crid(ii) = {'176S      '};

% fix second issue:
ij = contains(crid, '177N') & ti < datenum(2022,4,1); 
crid(ij) = {'176N      '};

%%
%write back to file:
stns = [stnnum(ii); stnnum(ij)];
crids = [crid(ii), crid(ij)];
for aa=1:length(stns)
    for bb = 1:2
        raw= bb -1;
        filen=getfilename(num2str(stns(aa)),raw);
        filenam=[prefix '/' filen];
        ncwrite(filenam,'Cruise_ID',crids{aa});
    end
end

