
%retrieveguidata

%axes(handles.map);

%clearmapposition;

lat=keysdata.obslat(handles.currentprofile);

if(keysdata.map180)
    lon=keysdata.lon180(handles.currentprofile);    
else
    lon=keysdata.obslon(handles.currentprofile);
end
gg=plot(handles.map,lon,lat,'bs');
set(gg,'MarkerSize',6);
gg=plot(handles.map,lon,lat,'gx');
set(gg,'MarkerSize',14);
set(gg,'LineWidth',2);
hold on

