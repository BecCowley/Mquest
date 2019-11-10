%read in some MA files to check the lat/long conversions we have been using
% fid = fopen('/home/UOT/archives/XBT/archiveMA/nwe3404h2005.MA','r');
clear
latall=[];lonall=[];datall = [];
figure(1);clf;hold on
% fn = dir('/home/UOT/archives/XBT/archiveMA/a3e031985.MA');
fn = dir('/home/UOT-data/quest/RANdata/RAN2007data/*.MA');
for b = 1:length(fn)
%     fid = fopen(['/home/UOT/archives/XBT/archiveMA/' fn(b).name],'r');
    fid = fopen(['/home/UOT-data/quest/RANdata/RAN2007data/' fn(b).name],'r');
    [data] = textscan(fid,'%s','Delimiter','|','whitespace','');
    fclose(fid);
    
%     ii = find(cellfun(@isempty,strfind(data{:},'CSID'))==0);
ii = find(cellfun(@isempty,strfind(data{:},'U'))==0);
lat = []; lon = [];dat = [];
    for a = 1:length(ii)
        %     profiledata = readMA(fid,uniqueid);
        str = data{1}{ii(a)};
        lt=str2num(str(63:70));
        ln=str2num(str(71:79));
        ln=-ln;
        if(ln<0)
            ln=360+ln;
        end
        lat = [lat, lt];
        lon = [lon, ln];
        profiledata.year=str2num(str(27:30));
        profiledata.month=str2num(str(31:32));
        profiledata.day=str2num(str(33:34));
        profiledata.time=str2num(str(35:38))*100;
        wd=[num2str(profiledata.year) num2str(profiledata.month,'%02i') num2str(profiledata.day,'%02i')];
        wtime = num2str(profiledata.time,'%06i');
        dat = [dat, datenum([wd wtime],'yyyymmddHHMMSS')];
    end
    latall = [latall,lat];
    lonall = [lonall, lon];
    datall = [datall,dat];
end
    coast
    plot(lonall,latall,'k.')
    grid
%% now read in the equivalent datn version:
% fid = fopen('/home/UOT/archives/XBT/archive2m/VLMQ2007.datn','r');
data = [];latdall = [];londall = [];datdall = [];
% % fn = dir('/home/UOT/archives/XBT/archive2m/ike160s2000.datn');
fn = dir('/home/UOT-data/quest/RANdata/RAN2007data/V*.datn');
% fn = dir('/home/UOT/archives/XBT/archive2m/a3e031985.datn');
for b = 1:length(fn)
fid = fopen(['/home/UOT-data/quest/RANdata/RAN2007data/' fn(b).name],'r');
% fid = fopen(['/home/UOT/archives/XBT/archive2m/' fn(b).name],'r');
    [data] = textscan(fid,'%s','Delimiter','|');
    fclose(fid);

%find all the header lines
ii = find(cellfun(@isempty,strfind(data{:},'TEMP'))==0);
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
    if ln <= 180
        %only do this if the longitude is within the +/-180,
        %else assume the value is in 360 degress long
        dec = abs(ln - fix(ln));
        dec = dec*100/60;
        ln = fix(ln) + dec;
        if sigl == 1
            ln = 360-ln;
        end
    else
        disp('Longitude >180')
    end
    
    
    latd = [latd,lt];    
    lond = [lond,ln];
    
end
    latdall = [latdall,latd];
    londall = [londall, lond];
    datdall = [datdall,datd];


end
figure(1)
plot(londall,latdall,'ro')
%% match up using date/time information
[C,ia,ib] = intersect(dat,datd);
figure(3);clf
plot(lat(ia),lat(ia) - latd(ib))
hold on
plot(lat(ia),lon(ia)-lond(ib))
grid

%% find any that are out by > 0.01 degrees
ibad = find(abs(lat(ia)-latd(ib)) > 0.01);

[lat(ia(ibad))' latd(ib(ibad))']
[lon(ia(ibad))' lond(ib(ibad))']

    