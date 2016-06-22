function user = readUserInfotxt
%reads the user information text file and returns a structure:'user'
%MQuest function. 
% Bec Cowley, May, 2016

fid = fopen('usersettings.txt');
if fid<1
    error('usersettings.txt not found. Please check paths')
end
c=textscan(fid,'%s%s%s%s%s%s%s%s');
fclose(fid);
[user.user,user.prefix,user.mm,user.yy,user.qc,...
    user.auto,user.timewindow,user.sstyle] = deal(c{1:8});
end