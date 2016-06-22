% zoomprofile - a script that replots the profile window.
%       when you are massively changing the axes in getkeystroke.
%  This requires Mquest structures and will operate only in the gui
%       environment.

i=handles.currentprofile;

col=['gbyrg'];
plot_clim;
isn=find(~isnan(pd.temp) & pd.temp<99.);

hg=plot(pd.temp(isn),pd.depth(isn),'w-');
set(hg,'ButtonDownFcn','recenterprofileplotfcn');

hold on
axis ij;
grid on;
grey=[.5 .5 .5];
black=[0 0 0];
set(gca,'Xcolor',grey);
set(gca,'YColor',grey);
xlimit=get(handles.profile,'Xlim');
newblue=[0 .5 .2];
grey2=[.6 .6 .6];
g=plot(xlimit,[handles.menudepth handles.menudepth],'color',grey2,'linestyle','-');
set(g,'LineWidth',2);


