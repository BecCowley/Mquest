%listdir - takes directory input and outputs directory listing to string

%function listdir(inputdir,handles)  - doesn't need to be function...

a=dirc(filename);
suff=a(:,1);
handles.suff=suff;
clear directorylist
[m,n]=size(a);
dataforms=get(handles.inputformats,'Value');
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
directorylist(1)={'new'};
for i=2:length(jkk)
    if(ispc)
        a2=[suff{jkk(i)} '\'];
    else
        a2=[suff{jkk(i)} '/'];
    end
    suff{jkk(i-1)}=a2;
    directorylist{i}=[ filename suff{jkk(i-1)}];
    isdir(i)=1;
end
clear inputfiles
handles.isdir=isdir;
if(input)
    inputfiles=directorylist;
    ii=i;
end

if(~input)
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

