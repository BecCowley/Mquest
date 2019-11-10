
function newdatestring = reformatdates(datestring,pd)
% function newdatestring = reformatdates(datestring)
%check the datestr in the PRC and Up_date fields are the correct format. Should be
%yyyymmdd. 
%Bec Cowley, August, 2014
%Updated Nov, 2019 to write the correct update value to the file.

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
    %write out the correct datestring to the file so we don't have to do
    %this over and over when re-exporting:
    fn = getfilename(pd.nss,0);
    fn = [pd.outputfile '/' fn];
    ncwrite(fn,'Up_date',newdatestring')
else
%     disp(['No change required: ' datestring])
    newdatestring = datestring;
end
