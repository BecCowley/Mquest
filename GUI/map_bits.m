if(ispc) 
    fname = TOPO_FILE_PC;
else
    fname = TOPO_FILE_UNIX ;
end
 v= axis;

if ~exist('hb')
%addpath /home/dunn/matlab;
xb = getnc(MAP_FILE_UNIX,'lon');
yb = getnc(MAP_FILE_UNIX,'lat');
ix = find(xb > v(1) & xb < v(2));

ix = [1:length(xb)];
iy = find(yb > v(3) & yb < v(4));

hb = -1*getnc(MAP_FILE_UNIX,'height',[min(iy) min(ix)],[max(iy) max(ix)]);
xb = xb(ix);
yb = yb(iy);
end

%%%%

v=axis;
xb = getnc(fname,'lon');
yb = getnc(fname,'lat');
ix = find(xb > v(1) & xb < v(2));
iy = find(yb > v(3) & yb < v(4));
hb = -1*getnc(fname,'height',[min(iy) min(ix)],[max(iy) max(ix)]);
xb = xb(ix);
yb = yb(iy);
cc=jet(45);
colormap(flipud(cc));
contourf(xb,yb,hb,[0:conts:bottomdepth],'k');
caxis([0,bottomdepth]);
xlabel('Longitude');
ylabel('Latitude');
colorbar ;
axis(v);
%