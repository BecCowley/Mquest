
function [profiledata, pd] = reformatdates(profiledata,pd)
% function profiledata,pd = reformatdates(profiledata,pd)
%check the datestr in the PRC and Up_date fields are the correct format. Should be
%yyyymmdd. 
%Bec Cowley, August, 2014
%Updated Nov, 2019 to write the correct update value to the file.
%Updated Jan, 2022 to fix bug where pd was not passed in for PRC_date, move
%entire handling to this routine from writeMA

for b = 1:2 %for up_date and PRC_date fields
    changed = 0;
    if b == 1
        cnt = profiledata.Num_Hists;
        nds = profiledata.PRC_Date';
    else
        cnt = 1;
        nds = profiledata.Up_date';
    end
    for i = 1:cnt
        if b == 1
            datestring = profiledata.PRC_Date(:,i)';
        else
            datestring = profiledata.Up_date';
        end
        ii = datestring == ' ';
        datestring(ii) = '0';
        dat = datenum(datestring,'yyyymmdd');
        datyr = str2num(datestring(1:4));
        datyr2 = str2num(datestring(5:8));
        if dat < 719529 | dat > now+1 %ie, before 1/1/1970 or after current date allowing for one day
            dat = datenum(datestring,'ddmmyyyy');
            if dat < 719529 | dat > now+1
                disp(['The update field is incorrect: ' datestring])
                newdatestring = input('Please enter a correct update string in the format yyyymmdd: ','s');
                changed = 1;
            else %change the format around:
                if (datyr > 2000 & datyr < 2013) & (datyr2 > 2000 & datyr2 < 2013)
                    disp(['This date could be a year or day/month: ' datestring])
                    keyboard
                end
                disp('Changing date format!')
                disp(['Old: ' datestring ])
                newdatestring = datestr(dat,'yyyymmdd');
                disp(['New: '  newdatestring ])
                changed = 1;
                nds(i,:) = newdatestring;
                %         pause(0.5)
            end
        else
            %     disp(['No change required: ' datestring])
        end
    end
    %write out the correct datestring to the file so we don't have to do
    %this over and over when re-exporting:
    if changed
        fn = getfilename(pd.nss,0);
        fn = [pd.outputfile '/' fn];
        if b == 2
            ncwrite(fn,'Up_date',nds');
        elseif b == 1
            ncwrite(fn,'PRC_Date',nds');
        end
        if b == 1
            profiledata.PRC_Date = nds';
        else
            profiledata.Up_date = nds';
        end
    end
end