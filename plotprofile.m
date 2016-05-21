axes(handles.profile);
cla;
tt=title([ 'Database prefix: ' keysdata.prefix '(' num2str(length(keysdata.stnnum)) ' profiles)']);
    if(~isempty(handles.newfontsize))
        set(tt,'FontSize',handles.newfontsize)
    else
        set(tt,'FontSize',10);
    end
i=handles.currentprofile;
currentp=i

col=['gbyrg'];
readnetcdf;
pd = handles.pd;
handles.changed='N';
            
%plot climatology...
plot_clim;
handles.displaybuddy='N';

xlimit=[-5 35];
if(pd.ndep>0)
    handles.menudepth=min(handles.menudepth,pd.depth(pd.ndep(1)));
else
    handles.menudepth=0;
end

%plot grey line at cursor point
ylimit=[-30 1000];
if(pd.ndep>0)
    if(pd.depth(pd.ndep(1))>1000.)
        gg=find(pd.depth>1000);
        if(pd.temp(gg(1))<30.)
            ylimit=[-30 2000];
        end
    end
end
set(handles.profile,'XLim',xlimit);
set(handles.profile,'YLim',ylimit);
newblue=[0 .5 .2];
grey2=[.6 .6 .6];
g=plot(xlimit,[handles.menudepth handles.menudepth],'color',grey2,'linestyle','-');
set(g,'LineWidth',2);


%plot profile data
isn=find(~isnan(pd.temp) & pd.temp<99.);
if(~isempty(isn))
    if length(isn)==1
    hg=plot(pd.temp(isn),pd.depth(isn),'wx');
    else
    hg=plot(pd.temp(isn),pd.depth(isn),'w-');
    end
    set(hg,'ButtonDownFcn','recenterprofileplotfcn');
end
if(isfield(pd,'sal'));
    isn=find(~isnan(pd.sal) & pd.sal<99.);
    if(~isempty(isn))
        shiftsal=pd.sal-20.;
        hs=plot(shiftsal(isn),pd.depth(isn),'c');
    end
end
hold on
axis ij;
grid on;
grey=[.5 .5 .5];
black=[0 0 0];
set(gca,'Xcolor',grey);
set(gca,'YColor',grey);
%axis([-2 35 -1000 0])
xlimit=[-5 35];
%handles.menudepth=min(handles.menudepth,pd.depth(pd.ndep(1)));
            
%add QC flags to plot and plot colored line of profile quality:

printqflags