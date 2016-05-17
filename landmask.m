function [mask,lon,lat] = landmask(lonin,latin,N,land,sea,hbase)
% [mask,lon,lat] = landmask(lonin,latin,N,land,sea,hbase)
% defines the height above sea level, or a land/sea mask, within the 
% ranges of inputs LONIN,LATIN and decimated to N/12 degrees lat/lon.  
%
% If LONIN,LATIN are vectors of length greater than 2, the height
% is interpolated to the rectilinear grid they define (bypassing the 
% decimation step).
%
% N is allowed to be empty, [].
%
% The mask is computed from the etopo5 data smoothed with a 
% nine point 0.25*[.5 1 .5]'*[.5 1 .5] filter.
% 
% Optional inputs 4 and 5 control what to do with land and sea points.
% Typical usage is to set LAND and SEA to either NaN, 0, or 1 to produce
% a mask with the desired properties.  
%
% The default is LAND = NaN and SEA = 1.
%
% If LAND or SEA is empty, [], no conversion is made and the true
% height above sea level is returned.
% 
% Optional input HBASE sets the land/sea discriminating altitude in metres
% above sea level, and of course defaults to 0. 
% eg height = -200  masks above the 200m isobath.

% Examples:
%
% Create a 1/4 degree resolution mask suitable for using with a contour
% plot to mask the land:
%
%   contour(.....)
%   hold on;
%   [mask,lon,lat] = landmask([140 180],[-40 -10],3,1,NaN);
%   han=surface(lon,lat,mask);
%   set(han,'edgecolor','none','facecolor',0.8*[1 1 1])
%   hold off
%
% Create a mask on the grid defined by lon,lat and use this to set
% land points of the matrix DATA to NaN, without changing the sea points.
%
%   [mask,lon,lat] = landmask(lon,lat,[],NaN,1);
%   DATA = mask.*DATA;
%
% John Wilkin 29 Oct 96

% HBASE added 4/11/96  J Dunn

if nargin <= 3
  land = NaN;
  sea = 1;
end

if nargin < 3 | isempty(N)
  % decimate 1/12 degree resolution etopo5 data to N/12 degree resolution
  N = 4;
end

if nargin < 6
  hbase = 0;
end

if nargin == 0
  % default is to make an eez region landmask
  latlim = [-60 5];
  lonlim = [90 200];
  interp2grid = 'no';
else
  if length(lonin)==2
    % simple mask on etopo5 grid points
    lonlim = lonin;
    latlim = latin;
    interp2grid = 'no';
  else
    % mask on input lon/lat vectors
    lonlim = [lonin(1) lonin(length(lonin))];
    latlim = [latin(1) latin(length(latin))];
    interp2grid = 'yes';
    N = 1;
  end
end

if lonlim(1) > 90 & lonlim(2) < 200 & latlim(1) > -60 & latlim(2) < 5
  load LAND_MASK_FILE_UNIX          % Retrieves lat, lon, h
  ilon = find(lon>=lonlim(1) & lon<=lonlim(2));
  ilat = find(lat>=latlim(1) & lat<=latlim(2));
  lon = lon(ilon);
  lat = lat(ilat);
  h = h(ilat,ilon);
else

  % get all etopo5 lat/lon first
  lat = getcdf('etopo5','lat');
  lon = getcdf('etopo5','lon');

  % find the lat/lon in the users range of interest
  beginlon = min(find(lon>=lonlim(1)));
  endlon = max(find(lon<=lonlim(2)));
  beginlat = min(find(lat>=latlim(1)));
  endlat = max(find(lat<=latlim(2)));

  % get h/lat/lon in range of interest
  h = getcdf('etopo5','height',[beginlat beginlon],[endlat endlon],[1 1],2,2,0);
  lon = getcdf('etopo5','lon',beginlon,endlon,[1],1,2,0);
  lat = getcdf('etopo5','lat',beginlat,endlat,[1],1,2,0);

  % smooth with 9-pt filter  JRD Nov 96
  [m,n]=size(h);

  h=[h(:,1) h h(:,n)];
  h=[h(1,:); h; h(m,:)];
  
  x1=1:n; x2=2:n+1; x3=3:n+2;
  y1=1:m; y2=2:m+1; y3=3:m+2;
  c1 = 1/16; c2=2/16; c3=4/16;

  h=(c1*(h(y1,x1)+h(y1,x3)+h(y3,x1)+h(y3,x3)) + ...
      c2*(h(y1,x2)+h(y2,x1)+h(y2,x3)+h(y3,x2)) + c3*h(y2,x2));
end

% decimate, taking every N'th point
% default is to take every 4'th point, i.e. reduce to 1/3 degree resolution

N0 = ceil(N/2);
[nlat nlon] = size(h);
lon = lon(N0:N:nlon);
lat = lat(N0:N:nlat);
h = h(N0:N:nlat,N0:N:nlon);
 

% interpolate to input lon/lat vectors
if strcmp(interp2grid,'yes')
  h = interp2(lon,lat,h,lonin,latin);
  % switch output lon/lat to input vectors
  lon = lonin;
  lat = latin;
end

% convert land and sea requested values
wet = find(h<hbase);
dry = find(h>=hbase);

if ~isempty(land)
  h(dry) = land*ones(size(dry));
end
if ~isempty(sea)
  h(wet) = sea*ones(size(wet));
end

mask = h;
