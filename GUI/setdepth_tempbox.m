clear depthtemp

%retrieveguidata

pd=handles.pd;
depthtemp=[];

for j=1:length(pd.depth) 
%    p1=profiledata.temp(j);
%    p2=profiledata.depth(j);
if(isnan(pd.depth(j)))

else
   depthtemp{j}=sprintf('%7.2f ', pd.depth(j), pd.temp(j));
end
end
if(~isempty(depthtemp))
    set (handles.depthdisplay,'String',depthtemp);
    findmd=find(pd.depth>=handles.menudepth);
    if(isempty(findmd))
        if(~isnan(pd.depth(pd.ndep)))
            set(handles.depthdisplay,'Value',pd.ndep);
            findmd=pd.ndep;
        else
            set(handles.depthdisplay,'Value',pd.ndep-1);
            findmd=pd.ndep-1;
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
