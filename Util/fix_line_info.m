%% replace incorrect XBT line info in SRFC_PARM field with correct information
%Bec Cowley, Feb, 2024

clear
prefix=input('enter the database prefix:','s')
[calls,~,ii] = unique(ncread([prefix '_keys.nc'],'callsign')','rows');
stn = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
for aa=1:size(calls,1)
    stnn = stn(ii==aa);
    line = [];
    for bb = 1:length(stnn)
        raw=0;
        filen=getfilename(num2str(stnn(bb)),raw);
        filenam=[prefix '/' filen];
        
        %update the CSID with the new uniqueid
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        
        kk=strmatch('TWI#',srfccodes');
        if(~isempty(kk))
            line=[line; srfcparm(:,kk)'];

        end
    end
    disp(['Callsign: ' calls(aa,:)])
    disp('Line names: ' )
    disp(unique(line,'rows'))
    
    nline = input(['Enter the correct line for callsign ' calls(aa,:) ', return to skip: '],'s');
    if isempty(nline)
        disp('no new line name entered, continuing')
        continue
    end
    
    %now replace TWI# with the new line:
    nline = pad(nline,10);
    for bb = 1:length(stnn)
        for cc = 1:2
            raw=cc-1;
            filen=getfilename(num2str(stnn(bb)),raw);
            filenam=[prefix '/' filen];
            
            srfccodes=ncread(filenam,'SRFC_Code');
            srfcparm=ncread(filenam,'SRFC_Parm');
            kk=strmatch('TWI#',srfccodes');
            
            if(~isempty(kk))
                srfcparm(:,kk)=nline';
                ncwrite(filenam,'SRFC_Parm',srfcparm);
            else
                disp('No TWI#')
            end
        end
    end

end
