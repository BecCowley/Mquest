% check_profile_qc - runs the jjvv profiles from the devil system through
% and checks whether they are OK to send to the GTS.
%
% Input: lat, lon, temp array (t), depth array (d) and date array (Pdate=[yy mm dd hh mmm])

function ok=check_profile_qc(lat,lon,t,d,Pdate)

ok=1;
%Test 1: impossible or too old date test:

today=datestr(now,31);
jpdate=datenum([Pdate 00]);
if(now-jpdate > 45);   %too late for GTS submission
    ok=0;
    ['data too old for submission to GTS']
    return
end
%check for impossible bits:
if((Pdate(1)<str2num(today(1:4)) | (Pdate(1)==str2num(today(1:4))-1 & Pdate(2)~=12)) | Pdate(2)<1 | Pdate(2)>12 | Pdate(3)<1 | Pdate(3)>31 ...
        | Pdate(4)<0 | Pdate(4)>24 | Pdate(5)<0 | Pdate(5)>59)
    ok=0;
    ['impossible date - Pdate=' num2str(Pdate)]
    return
end

%Test 2:  impossible location:
calc_depths_SBD;
if(max(depth_range_near_topo)==0)
    ok=0;
    ['position on land - lat=' num2str(lat) ', lon=' num2str(lon)]
    return
end

if(lat<-90 | lat > 90 | lon<0 | lon > 360)
    ok=0;
    ['position impossible - ' num2str(lat) ', lon=' num2str(lon)]
    return
end


%Test 4: Spike test:
bdt = findspike(t,d,'t');
if ~isempty(bdt)
%remove the spike point from the profile:
     t(bdt)=[];
     d(bdt)=[];
end


%Test 6: Global range test:
jj = find(t<=-2.5 | t>40.);
if ~isempty(jj)
% remove data from profile:
     t(jj)=[];
     d(jj)=[];
end

%Test 3 - data integrity - moved to end
if(length(t)<1 | length(d)<1)  %no data to send...
    ok=0;
    ['no data ']
    return
end
   
return

