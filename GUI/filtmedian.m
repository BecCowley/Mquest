% FILTMEDIAN: for each point, replace with median of all points within some
%    radius. Probably written for noisy SST data?
%
% INPUTS:
% dd   - is on regular grid.
% rm   - is source radius in units of grid points eg 
%
% USAGE: oo = filtmedian(dd,rm);

function oo = filtmedian(dd,rm)

if nargin<2 | isempty(rm)
   rm = sqrt(2) + .01;
end

% Instead of taking root to get distances, just square the distance limit.   
rm = rm.^2;

ii = find(~isnan(dd));

oo = repmat(nan,size(dd));

[x,y] = meshgrid(1:size(dd,2),1:size(dd,1));

for kk=1:prod(size(dd))
   r = (x-x(kk)).^2 + (y-y(kk)).^2;
   jj = ii(find(r(ii)<rm));
   if length(jj)>1
      oo(kk) = median(dd(jj));
   end
end
