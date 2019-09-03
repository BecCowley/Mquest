function [latd,lond,datd] = read2m_metadata(fn)
%% now read in the equivalent datn version:
% fid = fopen('/home/UOT/archives/XBT/archive2m/VLMQ2007.datn','r');
fid = fopen(fn,'r');
[data] = textscan(fid,'%s','Delimiter','|');
fclose(fid);

%find all the header lines
ii = find(cellfun(@isempty,strfind(data{1},'TEMP'))==0);
latd = [];lond=[];datd = [];
for a = 1:length(ii)
    str = data{1}{ii(a)};
    iz = findstr('Z',str);
    %datetime
    dt = str(iz-12:iz-1);
    %fill in any blanks with zeros
    ibl = dt == ' ';
    dt(ibl) = '0';
    datd = [datd datenum(dt,'yyyymmddHHMM')];

    %lat
    is = findstr('S',str(iz:iz+11));
    sig = -1;
    if isempty(is)
        is = findstr('N',str(iz:iz+11));
        sig = 1;
    end
    is = is+iz-1;
    lt = str2num(str(iz+1:is-1))/100*sig;
    dec = abs(lt - fix(lt));
    dec = dec*100/60;
    lt = sig*(abs(fix(lt)) + dec);
    
    %long
    ie = findstr('E',str(iz:iz+11));
    sigl = -1;
    if isempty(ie)
        ie = findstr('W',str(iz:iz+11));
        sigl = 1;
    end
    ie = ie+iz-1;
    ln = str2num(str(is+1:ie-1))/100;
    dec = abs(ln - fix(ln));
    dec = dec*100/60;
    ln = fix(ln) + dec;
    if sigl == 1
        ln = 360-ln;
    end
    
    latd = [latd,lt];    
    lond = [lond,ln];
    
end


    
    