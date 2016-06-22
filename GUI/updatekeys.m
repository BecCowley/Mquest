%updatekeys = this is used when metadata is changed (position or date/time) 
%   to insert the new values into the keys nc file. 

function updatekeys(field,recno,newval,prefix)

%field is the variable name that is to have values changed (usually
%obs_lat, obs_lng, and the various date/time fields) in the keys file...

%recno is the record number within the keys file to be replaced

%newval is the replacement value

%prefix is the database prefix you are currently using.
DECLAREGLOBALS

clear variable

filen=[prefix '_keys.nc'];

if(strcmp(field,'obslat')|strcmp(field,'obslng')|strcmp(field,'c360long')...
        |strcmp(field,'autoqc') | strcmp(field,'priority'))
    ncwrite(filen,field,newval,recno);
else
    ncwrite(filen,field,newval',[1,recno]);
end


if(handles.qc)

    filen=[prefix '_keysQC.nc'];
    stnlist=str2num(ncread(filen,'stn_num'));
    stn=handles.keys.stnnum(handles.currentprofile);
    [icomm,ia,ib]=intersect(stn,stnlist,'rows');
    recno=ib;
    
    if(strcmp(field,'obslat')|strcmp(field,'obslng')|strcmp(field,'c360long')...
            |strcmp(field,'autoqc') | strcmp(field,'priority'))
        ncwrite(filen,field,newval,recno);
    else
        ncwrite(filen,field,newval',[1,recno]);
    end

end

return
