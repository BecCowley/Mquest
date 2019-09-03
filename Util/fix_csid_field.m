%% replace missing CSID values in SRFC_PARM field with correct information
% Occured with bug in MK21 Ran data.
%Bec Cowley, Feb 2018

clear
prefix=input('enter the database prefix:','s')
stnnum = str2num(ncread([prefix '_keys.nc'],'stn_num')');

%%
for aa=1:length(stnnum)
    for bb = 1:2 %ed and raw files
        
        raw=bb -1;
        filen=getfilename(num2str(stnnum(aa)),raw);
        filenam=[prefix '/' filen];
        
        %update the CSID with the new uniqueid
        srfccodes=ncread(filenam,'SRFC_Code');
        srfcparm=ncread(filenam,'SRFC_Parm');
        
        kk=strmatch('CSID',srfccodes');
        if(~isempty(kk))
            csid=num2str(stnnum(aa));
            ss2='          ';
            ss2(1:length(csid))=csid;
            srfcparm(:,kk)=ss2';
            ncwrite(filenam,'SRFC_Parm',srfcparm);
        else
            errmsg('error - no csid')
        end
    end
end


