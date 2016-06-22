function saveuserinfo(user)
%this program saves the userinfo entered in selectuser for future reference

fid=fopen('usersettings.txt','w');
spacee=' ';
for i=1:length(user.yy)
    
    fprintf(fid,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\r\n',user.user{i},spacee,...
        user.prefix{i},spacee,user.mm{i},spacee,user.yy{i},spacee,user.qc{i},...
        spacee,user.auto{i},spacee,user.timewindow{i},spacee,user.sstyle{i});
end
fclose(fid);
end

