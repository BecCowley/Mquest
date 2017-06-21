%separate out the data by cruise ID for writing to individual MA files.
ext = {'a','b','c','d','e','f','g'};

kk2=find(realdate<=targetend & realdate>=targetstart);
subsetkeys = subsetkeys(kk2);
realdate = realdate(kk2);
if ~isempty(kk2)    
    cn = double(callsselected);
    [b,mm,nn]=unique(keysdata2.callsign(subsetkeys,:),'rows');
    

    for jj = 1:length(mm) %for each ship
        %first get individual ship
        ii = find(nn == jj);
%         kk3 = ii(kk2);
        [sdnum,is] = sort(realdate(ii));

        ijk = 0;
        kk4 = ii(is);
        holdcid = [];
        ipnum = 0;handles.first = 1;
        for iii=1:length(kk4) %for each profile
            ipnum = ipnum +1;;
            ss=keysdata2.stnnum(subsetkeys(kk4(iii)),:);
            [profiledata,pd] = readnetcdf(ss);
            %get some time fields
            wd=num2str(profiledata.woce_date);
            profiledata.year=wd(1:4);
            profiledata.month=wd(5:6);
            profiledata.day=wd(7:8);
            wt = profiledata.woce_time;
            wt=floor(wt/100);
            wt2=sprintf('%4i',wt);
            jk=strfind(wt2,' ');
            if(~isempty(jk))
                wt2(jk)='0';
            end
            profiledata.wt=[wt2(1:2) ':' wt2(3:4)];

%             readnetcdfforexport
            %get rid of blanks and '/'
            ic = strfind(profiledata.Cruise_ID','/');
            if ~isempty(ic)
                profiledata.Cruise_ID(ic) = '_';
            end
            cid = deblank(profiledata.Cruise_ID');
            switch exform
                case 3
                    cid = cid(~isspace(cid));
                    %if the cruiseID isn't the right format
                    if ~isempty(str2double(cid(1)))
                        %concatenate the callsign with the cruiseID
                        cid = [deblank(b(jj,:)) '_' cid];
                    end
                case 4
                    iblank = find(isspace(cid) == 1);
                    if ~isempty(iblank)
                        cid = cid(1:iblank(1)-1);
                    end
            end
            if ~isempty(strmatch(cid,holdcid))
                    try
                        cid = [cid ext{ijk}];
                    catch
                    end
            else
                holdcid = cid;
                ijk = 0;
                ipnum = 1;
            end
            
            switch exform
                case 3
                    %reset the output filename:
                    handles.outputfile = [cid num2str(profiledata.year)];
                    i = ipnum;
                    writeMA;
                case 4
                    %reset the output filename:
                    handles.outputfile = [cid num2str(profiledata.year) '.datn'];
                    i = ipnum;
                    writeREF
            end
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

