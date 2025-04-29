%getclimatology - this loads the cars database and makes it available to
%plot in the profile window.

if(ispc)
    clim_fname=[CLIMATOLOGY_PATH_PC 'temperature_Argo_2006_Feb2025.nc'];
    clim_fname2=[CLIMATOLOGY_PATH_PC 'temperature_Argo_2006_Feb2025.nc'];
else
    clim_fname=[CLIMATOLOGY_PATH_UNIX 'temperature_Argo_2006_Feb2025.nc'];
    clim_fname2=[CLIMATOLOGY_PATH_UNIX 'temperature_Argo_2006_Feb2025.nc'];
end

clim.temp=getnc(clim_fname,'mean');
clim.std=getnc(clim_fname2,'std_dev');
clim.resid=getnc(clim_fname2,'RMSresid');
acos=getnc(clim_fname,'an_cos');
asin=getnc(clim_fname,'an_sin');
clim.anominput=acos + (sqrt(-1)*asin);
clim.lat=getnc(clim_fname,'lat');
clim.lon=getnc(clim_fname,'lon');

   handles.clim=clim;

%saveguidata
