%the script to draw the map window with positions of all profiles in the
%current database subset:

% try
    axes(handles.map);
    cla
keysdata=handles.keys;
if(keysdata.map180)
    lat=keysdata.obslat;
    lon=keysdata.lon180;
else
    lat=keysdata.obslat;
    lon=keysdata.obslon;
end
lla=range(lat);
llo=range(lon);
xlimit=[llo(1)-5 llo(2)+5];
ylimit=[lla(1)-5 lla(2)+5];
set(handles.map,'XLim',xlimit);
set(handles.map,'YLim',ylimit);
axis xy

%call the script to add the bathymerty to the map window
plotbathy;

gg=plot(lon,lat,'bs');
set(gg,'MarkerSize',6);
hold on
latc=keysdata.obslat(handles.currentprofile);
if(keysdata.map180)
    lonc=keysdata.lon180(handles.currentprofile);
else
    lonc=keysdata.obslon(handles.currentprofile);
end
gg=plot(lonc,latc,'bs');
set(gg,'MarkerSize',6);
gg=plot(lonc,latc,'gx');
set(gg,'MarkerSize',14);
set(gg,'LineWidth',2);

%gebco
%coast
% end
