% plotbathy adds the bathymetry to the map plot window...

col=jet(100);

if(~exist('xb'))
    if(~ispc)
        fname=MAP_FILE_UNIX;
        tt='error if you get here?';
    else
        pwd
        fname=MAP_FILE_PC;
    end
    xb = ncread(fname,'lon');
    yb = ncread(fname,'lat');
end

v=[xlimit ylimit];

if(handles.keys.map180)
%    gg=find(xb<=180);
%    xb180(end+1:)=xb(gg);

    ixw=find((xb > 360+v(1) & xb <= 360));
    ixe=find(xb >= 0 & xb<v(2));
    iy = find(yb > v(3) & yb < v(4));
    hbe = -1*ncread(fname,'height',[min(ixe) min(iy)],[ max(ixe)-min(ixe)+1 max(iy)]);
    hbw = -1*ncread(fname,'height',[min(ixw) min(iy)],[ max(ixw)-min(ixw)+1 max(iy)]);

    hb=[hbw hbe];
    xbw=-(360-xb(ixw));
    xb2=[xbw' xb(ixe)']';
    yb2 = yb(iy);

else    
    ix = find(xb > v(1) & xb < v(2));
    iy = find(yb > v(3) & yb < v(4));
    hbe = -1*ncread(fname,'height',[min(ix) min(iy)],[max(ix)-min(ix)+1 max(iy)-min(iy)+1]);
    
    hb = hbe;
    xb2 = xb(ix);
    yb2 = yb(iy);
end
contourf(xb2(1:4:end),yb2(1:4:end),hb(1:4:end,1:4:end)',[0:100:2000],'k');
%contourf(xb2,yb2,hb,[0:100:2000],'k')
caxis([0,2000]);
%colorbar

hold on