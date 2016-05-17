%  loadbuddylist  - takes a new directory and populates the buddylist for
%  the gui.

%handles.currentdir=pwd;
%currdir=handles.currentdir;
a=dirc(handles.buddypath);

suff=a(:,1);
[m,n]=size(a);
for i=1:m
    ll(i)=a{i,6};
    isdatabase=strfind(suff(i),'keys.nc');
    if(~isempty(isdatabase{1}))
        isdatabase2(i)=1;
    else
        isdatabase2(i)=0;
    end
end

kk=find(isdatabase2==1);

jkk=find(ll==1);
for i=1:length(jkk)
    if(ispc)
        a2=[suff{jkk(i)} '\'];
    else
        a2=[suff{jkk(i)} '/'];
    end
    suff{jkk(i)}=a2;
    directorylist(i)=suff(jkk(i));
    isdir(i)=1;
end

inputfiles=directorylist;
handles.directorylength=length(directorylist);

ii=i;
for j=1:length(kk)
    i=i+1;
    directorylist(i)=suff(kk(j));
    isdir(i)=0;
end

handles.isdir=isdir;
set(handles.choosebuddies,'String',directorylist,'Value',1);
handles.suff=suff;

