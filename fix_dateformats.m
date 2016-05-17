function fix_dateformats
% Fix date formats from ddmmyyyy to yyyymmdd in histories and update
% fields, as per NOAA meds-ascii requirements
%Run this over 2014 databases only as at 29 August, 2014. Re-extract the
%meds-ascii versions of the 2014 databases for our archives at this stage.
%Bec Cowley, 29 August, 2014

prefix = input('Enter the database prefix: ','s');

% get the station information:
stn = ncread([prefix '_keys.nc'],'stn_num')';

for a = 1:size(stn,1)
    raw=0;
    filen=getfilename(stn(a,:),raw);
    if(ispc)
        filenam=[prefix '\' filen];
    else
        filenam=[prefix '/' filen];
    end
    %get the update field:
    update = ncread(filenam,'Up_date')';
    %check it
    newdatestring = reformatdates(update);
    
    %return the change:
    ncwrite(filenam,'Up_date',newdatestring')
    
    %NOW PRC_Date
    %get the prc_date field:
    prcdate = ncread(filenam,'PRC_Date')';
    nhists = ncread(filenam,'Num_Hists');
    %check it
    for b = 1:nhists
        prcdate(b,:) = reformatdates(prcdate(b,:));
    end
    
    %return the change:
    ncwrite(filenam,'PRC_Date',prcdate')
    
end

