
function [PRC_Date,Up_date, changed] = reformatdates_util(Num_Hists,PRC_Date,Up_date)
% function [PRC_Date,Up_date,changed] = reformatdates_util(Num_Hists,PRC_Date,Up_date)
%check the datestr in the PRC and Up_date fields are the correct format. Should be
%yyyymmdd. 
%Bec Cowley, June, 2022
% Adapted from reformatdates.m used in Mquest. This utility is independent
% of the Mquest GUI and called by fix_missingMetadata.m

narginchk(3,3)
changed = logical(zeros(2,1));

for b = 1:2 %for up_date and PRC_date fields
    changed(b) = 0;
    if b == 1
        cnt = Num_Hists;
        nds = PRC_Date';
    else
        cnt = 1;
        nds = Up_date';
    end
    for i = 1:cnt
        if b == 1
            datestring = PRC_Date(:,i)';
        else
            datestring = Up_date';
        end
        ii = datestring == ' ';
        datestring(ii) = '0';
        %let's streamline this with datetime
        try
            dat = datetime(datestring,'InputFormat','yyyyMMdd');
        catch
            dat = datetime(datestring,'InputFormat','ddMMyyyy');
            disp('Changing date format!')
            disp(['Old: ' datestring ])
            %wrong format, change it
            newdatestring = datestr(dat,'yyyymmdd');
            disp(['New: '  newdatestring ])
            if datenum(dat) > now
                %still wrong, fix:
                s = input('Enter corrected date (yyyymmdd): ','s');
                newdatestring = s;
            end
            changed(b) = 1;
            nds(i,:) = newdatestring;
        end
    end
    %output the updated datestring
    if changed(b)
        if b == 1
            PRC_Date = nds';
        else
            Up_date = nds';
        end
    end
end