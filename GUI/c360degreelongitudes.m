%c360degreelongitudes - replaces old longitudes held in obslng with those
%held in c360long (these hold the 360 degree globe, not the !/= verson of
%most databases).


d=dir('*keys.nc')
for i=1:length(d)
filen=d(i).name;
nc=netcdf(filen,'write');
nc{'obslng'}=nc{'c360long'};
close(nc)
end
