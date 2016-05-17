%select the data in a box and write out to DATN format

%FOR EXTRACTING ix1 DATA FOR KEN AND MING.
kk2=find((realdate<=targetend & realdate>=targetstart) & ...
    (keysdata2.obslat <= -5 & keysdata2.obslat >= -35) & ...
    (keysdata2.obslon >=102 & keysdata2.obslon <= 116));
% kk2=find(realdate<=targetend & realdate>=targetstart);
subsetkeys = subsetkeys(kk2);
realdate = realdate(kk2);
if ~isempty(kk2)
    
    ipnum = 0;
    fnum = 1;
    disp([num2str(length(kk2)) ' profiles found'])
    for iii=1:length(kk2) %for each profile
        ipnum = ipnum +1;
        if ipnum > 999
            ipnum = 1;
            fnum = fnum +1;
            idot = findstr('.',handles.outputfile);
            handles.outputfile = [handles.outputfile(1:idot-1) '_' num2str(fnum) '.datn'];
        end            
        ss=keysdata2.stnnum(subsetkeys(iii),:);
        
        readnetcdfforexport
        %reset the output filename:
        if ~isfield(handles,'outputfile')
            handles.outputfile = [num2str(profiledata.year) '.datn'];
        end
        i = ipnum;
        writeREF
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

