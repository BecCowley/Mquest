%% fix callsign in SRFC_PARM field & keys file
%Bec Cowley, Jun 2020
%set up to fix Investigator callsigns

clear
prefix=input('enter the database prefix:','s')
stn = str2num(ncread([prefix '_keys.nc'],'stn_num')');
calls = ncread([prefix '_keys.nc'],'callsign')';

%%
str10 = '          ';
for aa=1:size(stn,1)
    if isempty(strmatch('VLHJ',calls(aa,:)))
        continue
    end
    stnn = stn(aa);
    for bb = 1:2
        raw=bb-1;
        filen=getfilename(num2str(stnn),raw);
        filenam=[prefix '/' filen];
        
        %update the CSID with the new line
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        nsrfc = ncread(filenam,'Nsurfc');
        
        kk=strmatch('GCLL',srfccodes');
        if isempty(kk)
            srfccodes(1:4,nsrfc+1) = 'GCLL';
            srfcparm(:,nsrfc+1) = str10;
            srfcparm(1:4,nsrfc+1) = 'VLMJ';
            ncwrite(filenam,'SRFC_Parm',srfcparm);
            ncwrite(filenam,'SRFC_Code',srfccodes);
            ncwrite(filenam,'Nsurfc',nsrfc+1);
        else
            srfcparm(1:4,kk) = 'VLMJ';
            ncwrite(filenam,'SRFC_Parm',srfcparm);            
        end
    end
    calls(aa,:) = 'VLMJ      ';
end

ncwrite([prefix '_keys.nc'],'callsign',calls')