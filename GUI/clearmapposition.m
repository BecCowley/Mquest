

% axes(handles.map);

clear lat
clear lon
keysdata=handles.keys;
if(keysdata.map180)
    lat=keysdata.obslat(handles.lastprofile);
    lon=keysdata.lon180(handles.lastprofile);    
else
    lat=keysdata.obslat(handles.lastprofile);
    lon=keysdata.obslon(handles.lastprofile);
end
gg=plot(handles.map,lon,lat,'kx');
set(gg,'MarkerSize',14);
set(gg,'LineWidth',2);
gg=plot(handles.map,lon,lat,'ys');
set(gg,'MarkerSize',6);
