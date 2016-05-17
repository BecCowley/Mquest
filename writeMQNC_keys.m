function writeMQNC_keys(keysdata)
%function writeMQNC_keys(keysdata)
%appends new profile to the keys file
%keysdata structure:
%keysdata.outputfile
% keysdata.nss
% keysdata.year
% keysdata.month
% keysdata.day
% keysdata.time
% keysdata.datat
% keysdata.surfpcode
% keysdata.surfparm
% keysdata.lat
% keysdata.lon
% keysdata.autoqc
% keysdata.source
% keysdata.priority

keysfile=[keysdata.outputfile '_keys.nc'];
    try
        newkeysdata=netcdf(keysfile,'write');
        d1 = newkeysdata{'stn_num'};
    catch
        newkeysdata = [];
    end
    if(isempty(newkeysdata)) || isempty(d1)
        %create keys file...
        createkeys
        newkeysdata=netcdf(keysfile,'write');
    end

    %fill keys file:
    nc=netcdf(keysfile);
    holdthis=nc{'priority'}(:);
    if(length(holdthis)==1)
        if(isempty(holdthis(1)))
            holdthis=[];
        end
    end
    dimkeys=length(holdthis)+1;
        close(nc)

    ss=num2str(keysdata.nss);
    ssn='          ';
    ssn(1:length(ss))=ss;
    calls='          ';
    kk=strmatch('GCLL',keysdata.surfpcode);
    if(~isempty(kk))
        calls=keysdata.surfparm(kk,:);
    end
    newkeysdata{'obslat'}(dimkeys) = keysdata.lat;
    newkeysdata{'obslng'}(dimkeys) = keysdata.lon;
    newkeysdata{'c360long'}(dimkeys) = keysdata.lon;
    newkeysdata{'autoqc'}(dimkeys) = keysdata.autoqc;

    newkeysdata{'stn_num'}(dimkeys,1:10) = ssn;
    newkeysdata{'callsign'}(dimkeys,1:10) = calls;
    newkeysdata{'obs_y'}(dimkeys,1:4) = num2str(keysdata.year);

    mm=sprintf('%2i',keysdata.month);
    dd=sprintf('%2i',keysdata.day);
    newkeysdata{'obs_m'}(dimkeys,1:2) = mm;
    newkeysdata{'obs_d'}(dimkeys,1:2) = dd;

    tt=sprintf('%6i',keysdata.time);
    newkeysdata{'obs_t'}(dimkeys,1:4)=tt(1:4);

    newkeysdata{'data_t'}(dimkeys,1:2) = keysdata.datat;
    newkeysdata{'d_flag'}(dimkeys) = 'N';
    newkeysdata{'data_source'}(dimkeys,1:10)= keysdata.source;
    newkeysdata{'priority'}(dimkeys) = keysdata.priority;

    close(newkeysdata);
end