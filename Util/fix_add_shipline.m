%% add ship line in SRFC_PARM field
%Bec Cowley, Oct 2018
% check before running

clear
prefix=input('enter the database prefix:','s')
stn = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
str10 = '          ';
for aa=1:size(stn,1)
    stnn = stn(aa);
    for bb = 1:2
        raw=bb-1;
        filen=getfilename(num2str(stnn),raw);
        filenam=[prefix '/' filen];
        
        %update the CSID with the new line
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        nsrfc = ncread(filenam,'Nsurfc');
        crid = ncread(filenam,'Cruise_ID')';
        
        kk=strmatch('TWI#',srfccodes');
        if length(kk) > 1
            disp([crid ' removing blank TWI#'])
            srfcparm(:,kk(2)) = str10';
            srfccodes(:,kk(2)) = '    ';
            ncwrite(filenam,'Nsurfc',nsrfc-1);
        end
        kk=strmatch('TWI#',srfccodes');
            
        if contains('TTIDE',strtrim(crid))
            %remove the empty one
%             line = strtrim(srfcparm(:,kk)');
            srfcparm(:,kk) = 'Tasman-sea';
            ncwrite(filenam,'SRFC_Parm',srfcparm);
            ncwrite(filenam,'SRFC_Code',srfccodes);
            
%             disp([crid ' fixing TWI#'])
%             srfccodes(1:4,nsrfc+1) = 'TWI#';
%             srfcparm(:,nsrfc+1) = str10;
%             srfcparm(:,kk) = 'Tasman-sea';
%             ncwrite(filenam,'SRFC_Parm',srfcparm);
%             ncwrite(filenam,'SRFC_Code',srfccodes);
%             ncwrite(filenam,'Nsurfc',nsrfc+1);
        end
    end
end
