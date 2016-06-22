%recenterprofileplot

%this gets the current pointer position and resets both the plot and the 
%depth/temp box for further qc input...

%retrieveguidata

try
    newdepthpt=get(hg,'CurrentPoint');
catch
  newdepthpt=get(handles.profile,'CurrentPoint');  
end

pd=handles.pd;
axes(handles.profile);
xlimit=get(handles.profile,'Xlim');            %[-5 35];
g=plot(xlimit,[handles.menudepth handles.menudepth],'k-');
set(g,'LineWidth',2);

kk=find(pd.depth>=newdepthpt(1,2));
if(~isempty(kk))
    newdepthindex=kk(1);
else
    newdepthindex=pd.ndep(1);
end
    handles.menudepth=pd.depth(newdepthindex);
    set(handles.depthdisplay,'Value',newdepthindex);
    minlist=newdepthindex-22;
    minlist=max(minlist,1);
    set(handles.depthdisplay,'ListboxTop',minlist);


%set profilefocus to 1/2 range of plot, then centre plot on the focus
    ymin=handles.menudepth-handles.profilefocus;
    ymax=handles.menudepth+handles.profilefocus;
    ylimit=[ymin ymax];
%set(handles.profile,'XLim',xlimit);
    set(handles.profile,'YLim',ylimit);
    grey2=[.6 .6 .6];
    g=plot(xlimit,[handles.menudepth handles.menudepth],'color',grey2,'LineStyle','-');
    set(g,'LineWidth',2);
    
% now re-plot profile so it's on top

isn=find(~isnan(pd.temp) & pd.temp<99.);

hg=plot(pd.temp(isn),pd.depth(isn),'w-');


%    saveguidata

printqflags
