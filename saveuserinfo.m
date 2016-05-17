%this program saves the userinfo entered in selectuser for future reference


fid=fopen('usersettings.txt','w');
spacee=' ';
for i=1:length(yy)
    i=i;
    user{i};
   
    fprintf(fid,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\r\n',user{i},spacee,prefix{i},spacee,...
       mm{i},spacee,yy{i},spacee,qc{i},spacee,auto{i},spacee,timewindow{i},spacee,sortstyle{i});
end
   fclose(fid); 

