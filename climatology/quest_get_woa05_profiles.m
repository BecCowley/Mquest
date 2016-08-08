% GET_WOA05_PROFILES:  Extract WOA05 profiles at given place and day-of-year
%     
% Note: Does NOT do temporal interpolation - just takes nearest month value.
%       Interpolates to any specified depths which are not WOA depth levels.
%
% INPUT
%   prop       Single char:  t  s  o  p  n  i(=silicate)
%                  O(=% oxygen saturation)  A(=Apparent oxygen saturation)
%   lons,lats  vectors of locations
%   deps       Vector of depths(m) [same for all locations]. Faster if
%              all are WOA depth levels (CSL v1)
%   doy        OPTIONAL: vector of day-of-year. If absent, get annual mean.
%   vartyp     1=mean/monthly values  2=Standard Deviation  [def 1]
%
% OUTPUT: vv:  [ndep,nlocs] profiles from WOA05
%
% Jeff Dunn CSIRO CMAR May 2008
%
% USAGE: vv = get_woa05_profiles(prop,lons,lats,deps,doy,vartyp);

function vv = get_woa05_profiles(prop,lons,lats,deps,doy,vartyp)


if(~ispc)
    % configuration bits for UNIX/LINUX:
    global UNIQUE_ID_PATH_UNIX LAND_MASK_FILE_UNIX MAP_FILE_UNIX  TOPO_FILE_UNIX 
    global CLIMATOLOGY_PATH_UNIX LEVITUSDATA_PATH_UNIX MQUEST_DIRECTORY_UNIX
else
% configuration bits for PC:
    global UNIQUE_ID_PATH_PC LAND_MASK_FILE_PC MAP_FILE_PC  TOPO_FILE_PC 
    global CLIMATOLOGY_PATH_PC LEVITUSDATA_PATH_PC MQUEST_DIRECTORY_PC
end

if ~isa(lons,'double')
   lons = double(lons);
   lats = double(lats);
end
if nargin<6 || isempty(vartyp)
   vartyp = 1;
end

% Only have monthly maps to level 24 (1500m), so if these are required we
% must access them and then add on any deeper layers from the annual-mean maps.

lons = lons(:)'; lats = lats(:)'; deps = deps(:)'; doy = doy(:)';

ndeps = length(deps);
vv = repmat(nan,ndeps,length(lons));
if (~ispc)
    pth = LEVITUSDATA_PATH_UNIX;
else 
    pth = LEVITUSDATA_PATH_PC;
end
if vartyp==1
   avar = [prop '00an1'];
   mvar = [prop '0112an1'];
   mfnm = [pth 'monthly/' mvar '.nc'];
else
   avar = [prop '00sd1'];
   doy = [];
end

afnm = [pth 'annual/' avar '.nc'];

lon = ncread(afnm,'lon');
lat = ncread(afnm,'lat');

% Quite excusable cheat
if any(lats>89.5)
   lats(lats>89.5) = 89.4;
end
% Not so excusable cheats
if any(lons<=.5)
   lons(lons<=.5) = .51;
end
if any(lons>=359.5)
   lons(lons>=359.5) = 359.49;
end


adeps = ncread(afnm,'depth');
nadps = length(adeps);  

ldeps = dep_csl(deps,1);
% Determine which depths adequately match the climatology levels, and which
% need to be interpolated
noint = 1:ndeps;
intp = find(rem(ldeps,1)>.05 | rem(ldeps,1)<.95);
noint(intp) = [];
if ~isempty(noint)
   ldeps(noint) = round(ldeps(noint));
end

% Remove index to any depths requested deeper than climatology 
if any(ldeps(intp)>nadps)
   intp(ldeps(intp)>nadps) = [];
end
 

if nargin>=5 & ~isempty(doy)
   mdeps = ncread(mfnm,'depth');
   nmdps = length(mdeps);

   if max(ceil(ldeps)) > nmdps
      % Want beyond depth range of monthly fields, so get annual
      ndp = nmdps;
      nadp = max(ceil(ldeps));
      Z = adeps(1:nadp);      
   else
      ndp = max(ceil(ldeps));
      nadp = 0;
      Z = mdeps(1:ndp);
   end   

   mon = ceil(doy/30.5);
   mon(mon==0) = 1; 
   mon(mon>12) = 12; 
   
   for month = unique(mon)
      kk = find(mon==month);
   
      ix = round(lons(kk));
      ix = [min(ix) max(ix)+1];
      iy = round(lats(kk)+90);
      iy = [min(iy) max(iy)+1];
      dat = ncread(mfnm,mvar,[ix(1) iy(1) 1 month],[ix(2)-ix(1)+1 iy(2)-iy(1)+1 ndp 1]);

      X = 1 + lons(kk) - lon(ix(1));
      Y = 1 + lats(kk) - lat(iy(1));

      if nadp>0
	 dat2 = ncread(afnm,avar,[ix(1) iy(1) ndp+1 1],[ix(2)-ix(1)+1 iy(2)-iy(1)+1 nadp-ndp 1]);
	 dat = [dat; dat2];
      end
      dat = permute(dat,[2,1,3]);
      
      for ii = noint
	 vv(ii,kk) = interp2(squeeze(dat(:,:,ldeps(ii))),X,Y,'*linear');
      end

      if ~isempty(intp)
	 ni = length(intp);
	 X = repmat(X,[ni 1]);
	 Y = repmat(Y,[ni 1]);
	 Z = ldeps(intp);
	 Z = repmat(Z(:),[1 length(kk)]);
	 vv(intp,kk) = interp3(dat,X,Y,Z,'*linear');
      end
   end

else
   nadp = max(ceil(ldeps));

   ix = round(lons);
   ix = [min(ix) max(ix)+1];
   iy = round(lats+90);
   iy = [min(iy) max(iy)+1];
   dat = ncread(afnm,avar,[ix(1) iy(1) 1 1],[ix(2)-ix(1)+1 iy(2)-iy(1)+1 nadp 1]);

   X = 1 + lons - lon(ix(1));
   Y = 1 + lats - lat(iy(1));

      dat = permute(dat,[2,1,3]);
      
   for ii = noint
      vv(ii,:) = interp2(squeeze(dat(:,:,ldeps(ii))),X,Y,'*linear');
   end

   if ~isempty(intp)
      ni = length(intp);
      X = repmat(X,[ni 1]);
      Y = repmat(Y,[ni 1]);
      Z = ldeps(intp);
      Z = repmat(Z(:),[1 length(lons)]);
      vv(intp,:) = interp3(dat,X,Y,Z,'*linear');
   end
end

return

% ------------ End of get_woa05_profiles.m --------------------
