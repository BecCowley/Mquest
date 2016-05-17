%separate out the data by cruise for writing to individual MA files.
ext = {'a','b','c','d','e','f','g'};
kk2=find(realdate<=targetend & realdate>=targetstart);

dnum = datenum(keysdata2.year,keysdata2.month,keysdata2.day);

if ~isempty(kk2)    
    %get unique cruises:
    [b,mm,nn]=unique(keysdata2.callsign,'rows');

    for jj = 1:length(b) %for each ship
        %first get individual ship
        ii = find(nn == jj);
        [sdnum,is] = sort(dnum(ii));

        ijk = 0;
        kk4 = kk2(ii(is));
        idif = diff(sdnum);
        holdcid = [];
        for iii=1:length(kk4) %for each profile
            ss=keysdata2.stnnum(subsetkeys(kk4(iii)),:);

            readnetcdfforexport
            cid = deblank(profiledata.Cruise_ID');
            cid = cid(~isspace(cid));
            %if the cruiseID isn't the right format
            if ~isempty(str2double(cid(1)))
                %concatenate the callsign with the cruiseID
                cid = [deblank(b(jj,:)) '_' cid];
            end
            if ~isempty(strmatch(cid,holdcid))
                %check the difference in days
                if idif(iii-1) > 2
                    ijk = ijk+1;
                    cid = [cid ext{ijk}];
                    holdcid = cid;
                else
                    try
                        cid = [cid ext{ijk}];
                    catch
                    end
                end
            else
                holdcid = cid;
                ijk = 0;
            end

            %reset the output filename:
            handles.outputfile = [cid num2str(profiledata.year)];
            writeMA;
            if(handles.first)
                handles.first=0;
                try
                    guidata(gcbo,handles);
                catch
                    guidata(hObject,handles);
                end
            end
        end
    end
end

