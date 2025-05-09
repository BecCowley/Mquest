% plot_clim - this adds the climatology to the profile plot if required


%retrieveguidata

keysdata=handles.keys;

try
    clima=handles.clim;
end
if(~exist('clima'))
    
    base=[floor(range(keysdata.obslon)) floor(max(keysdata.obslon+1))];
    lo=min(base):max(base);
    base=[floor(range(keysdata.obslat)) floor(max(keysdata.obslat+1))];
    la=min(base):max(base);
    
    deps=[0 5 10 20 30 40 50 60 70 75 80 90 100 110 120 125 130 140 150 160 170 175 180 190 ...
        200 210 220 225 230 240 250 260 270 275 280 290 300 325 350 375 400 425 450 475 500 ...
        550 600 650 700 750 800 850 900 950 1000 1100];
    
    pd=handles.pd;
    
    [laty,lonx]=meshgrid(la,lo);
    [m,n]=size(laty);
    
    lat=reshape(laty,[m*n,1]);
    lon=reshape(lonx,[m*n,1]);
%     [aa,days,midd]=names_of_months(str2num(pd.month));
    
    %c360lon=rem(720-lon,360.);
    %get every month
    [meant,std] = deal(NaN*ones(length(deps),length(lon),12));
    for jj = 1:12
        [aa,days,midd]=names_of_months(jj);
        meant(:,:,jj)=quest_get_clim_casts('t',lon,lat,deps,midd,'Argo_2006_Feb2025',1,1);
        std(:,:,jj)=quest_get_clim_casts('t',lon,lat,deps,midd,'Argo_2006_Feb2025',1,9);
    end
    
    clima.mean=meant;
    clima.std=std;
    clima.lat=lat;
    clima.lon=lon;
    clima.deps=deps;
    
    handles.clim=clima;
    
    %saveguidata
    
    
    %    getclimatology;
end

clima=handles.clim;

clear lat
clear lon
deps=clima.deps;
lat=pd.latitude;
lon=pd.longitude;
if(pd.longitude<0)
    lon=rem(720-pd.longitude,360);
end
%dd=clim.lat-lat;
dd=clima.lat-floor(lat);
latindex=find(dd==min(abs(dd)));

%dd=clim.lon-lon;
dd=clima.lon-floor(lon);
lonindex=find(dd==min(abs(dd)));

meanprofile=intersect(latindex,lonindex);

%which month?
timeindex = str2num(pd.month);

if(~isempty(meanprofile))
    %    mn=atday(pd.month)
    %    [mo,days,midday]=names_of_months(mn);
    %    meant=atday(midday,clim.temp(1:56,latindex,lonindex),clim.anominput(1:56,latindex,lonindex);
    
    meantp=clima.mean(:,meanprofile,timeindex);
    std=clima.std(:,meanprofile,timeindex);
    
    leftline=meantp-(3*std);
    rightline=meantp+(3*std);
    
    x=leftline(find(~isnan(leftline)));
    y=rightline(find(~isnan(rightline)));
    filldeps=deps(find(~isnan(rightline)));
    grey=[.5 .5 .5];
    xx=[y;flipud(x)];
    %    xx=[rightline;flipud(leftline)];
    yy=[filldeps';flipud(filldeps')];
    
    fill(xx,yy,grey);
    hold on
    plot(leftline,deps,'b-');
    plot(rightline,deps,'b-');

end
