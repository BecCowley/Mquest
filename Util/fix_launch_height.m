%% replace incorrect launch heights in SRFC_PARM field with correct information
%Bec Cowley, Aug 2018

clear
prefix=input('enter the database prefix:','s')
[calls,~,ii] = unique(ncread([prefix '_keys.nc'],'callsign')','rows');
stn = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
for aa=1:size(calls,1)
    stnn = stn(ii==aa);
    height = NaN*ones(length(stnn),1);
    for bb = 1:length(stnn)
        raw=0;
        filen=getfilename(num2str(stnn(bb)),raw);
        filenam=[prefix '/' filen];
        
        %update the CSID with the new uniqueid
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        
        kk=strmatch('HTL$',srfccodes');
        if(~isempty(kk))
            if ~isempty(str2num(srfcparm(:,kk)'))
                height(bb)=str2num(srfcparm(:,kk)');
            end
        end
    end
    disp(['Callsign: ' calls(aa,:)])
    disp('Heights: ' )
    disp(num2str(unique(height)))
    
    nheight = input(['Enter the correct height for callsign ' calls(aa,:) ', return to skip: '],'s');
    if isempty(nheight)
        disp('no new height entered, continuing')
        continue
    end
    
    %now replace HTL$ with the new height:
    nheight = num2str(nheight);
    for bb = 1:length(stnn)
        for cc = 1:2
            raw=cc-1;
            filen=getfilename(num2str(stnn(bb)),raw);
            filenam=[prefix '/' filen];
            
            srfccodes=ncread(filenam,'SRFC_Code');
            srfcparm=ncread(filenam,'SRFC_Parm');
            kk=strmatch('HTL$',srfccodes');
            
            if(~isempty(kk))
                ss2='          ';
                ss2(1:length(nheight))=nheight;
                srfcparm(:,kk)=ss2';
                ncwrite(filenam,'SRFC_Parm',srfcparm);
            else
                disp('No HTL$')
            end
        end
    end

end
