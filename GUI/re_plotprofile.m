%re_plot profile - 
%
% re_plotprofile is used to reset the profile window after a change -
% either to reset to original boundaries after "zoom" or after a flag has
% been added.
%
% it does not re-read the profile data but uses the structure in the
% handles structure.  Nor does it write changed data at this point.


%retrieveguidata

pd=handles.pd;
i=handles.currentprofile;

ylimit=get(handles.profile,'Ylim');
xlimit=get(handles.profile,'Xlim');

col=['gbyrb'];
% remove this because otherwise resetting from zoom leaves the zoomed
% quality bar at the side - caution this might slow it down...
%if(handles.displaybuddy~='Y')
%    if(handles.displaybuddy=='Y')
%        plotbuddies
%        return
%    end
%       axes(handles.profile);
cla
plot_clim;
%end
isn=find(~isnan(pd.temp) & pd.temp<99.);

plot(pd.temp(isn),pd.depth(isn),'w-');

if(isfield(pd,'sal'));
    isn=find(~isnan(pd.sal) & pd.sal<99.);
    if(~isempty(isn))
        shiftsal=pd.sal-20.;
        hs=plot(shiftsal(isn),pd.depth(isn),'c');
    end
end

hold on
axis ij
grid on
grey=[.5 .5 .5];
black=[0 0 0];
set(gca,'Xcolor',grey);
set(gca,'YColor',grey);
%axis([-2 35 -1000 0]);
%xlimit=[-5 35];
if(pd.ndep==0)
    handles.menudepth=0;
else
    handles.menudepth=min(handles.menudepth,pd.depth(pd.ndep(1)));
end
%saveguidata

%ymin=handles.menudepth-handles.profilefocus;
%ymax=handles.menudepth+handles.profilefocus;
%if(ymin<=5)
%    ymin=-30;
%end
%ylimit=[ymin ymax];
%ylimit=[0 1000];
set(handles.profile,'XLim',xlimit);
set(handles.profile,'YLim',ylimit);

grey2=[.6 .6 .6];
g=plot(xlimit,[handles.menudepth handles.menudepth],'color',grey2,'linestyle','-');
set(g,'LineWidth',2);

%add QC flags to plot and plot colored line of profile quality:

printqflags
