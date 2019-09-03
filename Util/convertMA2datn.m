% convertMA2datn
%Converts a MA file to datn using the Mquest read/write routines
% Bec Cowley, Feb 2016.

% dirn = '/home/UOT/archives/XBT/archiveMA/';
dirn = pwd;
filn = '07006ARtmtc.MA';

fid = fopen([dirn '/' filn]);
if fid < 1
    disp('File not found')
    return
end
i = 1;

while (~feof(fid))
    
    profiledata = readMA(fid,1);
%     if str2num(profiledata.nss) == 1
%         disp('error in read')
%         return
%     end
    
    %now write it out
    writeREFfromMA
    i = i+1;
end
fclose(fid)


  