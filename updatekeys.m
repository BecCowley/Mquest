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

variable=getnc(filen,field);

keysfile=netcdf(filen,'w');

if(strcmp(field,'obslat')|strcmp(field,'obslng')|strcmp(field,'c360long')...
        |strcmp(field,'autoqc'))
    variable(recno)=newval;
    keysfile{field}(:)=variable;
else
    variable(recno,:)=newval;
    keysfile{field}(:,:)=variable;
end


close(keysfile);

if(handles.qc)
    clear variable

    filen=[prefix '_keysQC.nc'];
    stnlist=str2num(getnc(filen,'stn_num'));
    stn=handles.keys.stnnum(handles.currentprofile);
    [icomm,ia,ib]=intersect(stn,stnlist,'rows');
    recno=ib;
    
    variable=getnc(filen,field);

    keysfile=netcdf(filen,'w');

    if(strcmp(field,'obslat')|strcmp(field,'obslng')|strcmp(field,'c360long')...
            |strcmp(field,'autoqc'))
        variable(recno)=newval;
        keysfile{field}(:)=variable;
    else
        variable(recno,:)=newval;
        keysfile{field}(:,:)=variable;
    end

end

return
