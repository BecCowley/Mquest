clear depthtemp

%retrieveguidata

profiledata=handles.profile_data;
depthtemp=[];

for j=1:length(profiledata.depth) 
%    p1=profiledata.temp(j);
%    p2=profiledata.depth(j);
if(isnan(profiledata.depth(j)))

else
   depthtemp{j}=sprintf('%7.2f ', profiledata.depth(j), profiledata.temp(j));
end
end
if(~isempty(depthtemp))
    set (handles.depthdisplay,'String',depthtemp);
    findmd=find(profiledata.depth>=handles.menudepth);
    if(isempty(findmd))
        if(~isnan(profiledata.depth(profiledata.ndep)))
            set(handles.depthdisplay,'Value',profiledata.ndep);
            findmd=profiledata.ndep;
        else
            set(handles.depthdisplay,'Value',profiledata.ndep-1);
            findmd=profiledata.ndep-1;
        end
    else
        set(handles.depthdisplay,'Value',findmd(1));
    end
    %gg=get(handles.depthdisplay,'ListboxTop');
    minlist=findmd(1)-22;
    minlist=max(minlist,1);
    set(handles.depthdisplay,'ListboxTop',minlist);
else
    depthtemp{1}='empty array';
    set(handles.depthdisplay,'String',depthtemp);
    set (handles.depthdisplay,'Value',1);
end
