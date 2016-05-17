function newdatestring = reformatdates(datestring)
% function newdatestring = reformatdates(datestring)
%check the datestr in the PRC and Up_date fields are the correct format. Should be
%yyyymmdd. THIS IS NOT FOOLPROOF! Will be a problem if the year is 2001 to
%2012 as these years can be day/month too. For now, just trap for this and
%deal with it when it happens:
%Bec Cowley, August, 2014

dat = datenum(datestring,'yyyymmdd');
datyr = str2num(datestring(1:4));
datyr2 = str2num(datestring(5:8));
if dat < 719529 | dat > now+1 %ie, before 1/1/1970 or after current date allowing for one day
    dat = datenum(datestring,'ddmmyyyy');
    if dat < 719529 | dat > now+1
        disp(['The update field is incorrect: ' datestring])
        datestring = input('Please enter a correct update string in the format yyyymmdd: ','s');
    else %change the format around:
        if (datyr > 2000 & datyr < 2013) & (datyr2 > 2000 & datyr2 < 2013)
            disp(['This date could be a year or day/month: ' datestring])
            keyboard
        end
        disp('Changing date format!')
        disp(['Old: ' datestring ])
        newdatestring = datestr(dat,'yyyymmdd');
        disp(['New: '  newdatestring ])
%         pause(0.5)
    end
else
%     disp(['No change required: ' datestring])
    newdatestring = datestring;
end
