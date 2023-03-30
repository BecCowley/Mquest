%get a median scale and offset value
scaledball=[];
offsetdball=[];

%for n=41:67
for n=10:60
if n<10
a=['0' int2str(n)];
else
a=int2str(n);
end

filen=['/home/mership/proc/F23014/drop' a '.nc']
nc=netcdf(filen,'nowrite');
scaledball=[scaledball sscanf(nc.Scale(:),'%f')];
offsetdball=[offsetdball sscanf(nc.Offset(:),'%f')];
close(nc)
end

median(scaledball)
median(offsetdball)

%deep blue scale and offset values
scaledb=0.9994;
offsetdb=-23;
coef1=0.12901230e-2;
coef2=0.23322529e-3;
coef3=0.45791293e-6;
coef4=0.71625593e-7;

for a=88116732:88116762
for b=68:98

%GTSPPmer data files
a=int2str(a);
filen=['GTSPPmer2005/' a(1:2) '/' a(3:4) '/' a(5:6) '/' a(7:8) 'ed.nc']
nc=netcdf(filen,'write');

%Devil data files
b=int2str(b);
filen=['/home/mership/proc/F23014/drop0' b '.nc']
nc2=netcdf(filen,'write');

     %correct the data - incorrectly recorded as Fast Deep, not deep Blue
scale=sscanf(nc2.Scale(:),'%f');
offset=sscanf(nc2.Offset(:),'%f');

d=length(nc2{'resistance'})

rawres(1:d)=(nc2{'resistance'}(1,1:d,1,1)-offset)/scale;

%replace wrong resistances with deep blue corrected values
nc2{'resistance'}(1,1:d,1,1)=rawres(1:d)*scaledb+offsetdb;

for c=1:d
res=log(nc2{'resistance'}(1,c,1,1));

%re-calculate the temperatures from corrected resistance
nc2{'temperature'}(1,c,1,1)=(1/(coef1+coef2*res+coef3*res*res+coef4*res*res*res))-273.15;
nc2{'procTemperature'}(1,c,1,1)=(1/(coef1+coef2*res+coef3*res*res+coef4*res*res*res))-273.15;
end

%fix temps in GTSPP nc files
close(nc2)

end
