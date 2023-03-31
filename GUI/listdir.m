%listdir - takes directory input and outputs directory listing to string

%function listdir(inputdir,handles)  - doesn't need to be function...

a=dir(filename);
% suff=a(:,1);
% handles.suff=suff;
clear directorylist

dataforms=get(handles.inputformats,'Value');

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

clear inputfiles
handles.isdir=isdir;
if(input)
    inputfiles=directorylist;
    ii=i;
end

if(~input)
    %RC, 2023: should never get here as there is no call with input == 0
    %leave here for now, it will break if something does get here
    for j=1:length(kk)
        i=i+1;
        directorylist{i}=[filename suff{kk(j)}];
        isdir(i)=0;
    end
    
    handles.isdir=isdir;
    set(handles.databaseprefix,'String',directorylist,'Value',1);
    
else
    dataforms=get(handles.inputformats,'Value');
    switch dataforms
        case 1
            
            usethis=[];
            
        case 2
            
            for i=1:length(suff)
                isinput=strfind(suff(i),'.MA');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
            
        case 3
            
            for i=1:length(suff)
                isinput=strfind(suff(i),'.sip');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
            
        case 4
            
            usethis=0;
            
        case 5
            
            for i=1:length(suff)
                isinput=strfind(suff(i),'.txt');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
        case 6 %TSK data
            usethis=0;
        case 7
            for i=1:length(suff)
                isinput=strfind(suff(i),'.nc');
                if(~isempty(isinput{1}))
                    usethis(i)=1;
                else
                    usethis(i)=0;
                end
            end
    end
    
    kkin=find(usethis==1);
    
    for j=1:length(kkin)
        ii=ii+1;
        %         inputfiles{ii}=[filename suff{kkin(j)-1}];
        inputfiles{ii}=[filename suff{kkin(j)}];
        isdir(ii) = 0;
    end
    inputfiles(1)={'   '};
    set(handles.inputdata,'String',inputfiles,'Value',1);
    handles.isdir = isdir;
    handles.directorylength=length(inputfiles);
%     %reset the inputdir too
%     cd(filename)
%     handles.inputdatadir=pwd;
    cd(handles.databasedir);
    
end

