%  loadbuddylist  - takes a new directory and populates the buddylist for
%  the gui.

%handles.currentdir=pwd;
%currdir=handles.currentdir;
a=dir(handles.buddypath);

%grab the keys files and directories in this current directory
ii = 1;
for i=1:size(a,1)
    %keys files
    isdatabase=strfind(a(i).name,'keys.nc');
    if(~isempty(isdatabase)) 
        directorylist{ii} = a(i).name;
        isdir(ii) = 0;
        ii = ii+1;
    elseif a(i).isdir
        if(ispc)
            directorylist{ii}=[a(i).name '\'];
        else
            directorylist{ii}=[a(i).name '/'];
        end
        isdir(ii)=1;
        ii = ii+1;
    end
end

directorylist = sort(directorylist);
handles.directorylength=length(directorylist);

handles.isdir=isdir;
set(handles.choosebuddies,'String',directorylist,'Value',1);

