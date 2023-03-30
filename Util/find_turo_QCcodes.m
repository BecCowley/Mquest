% Read in some Turo files and look at the QC flags used.

% di = '~/ocean_obs/XBTdata/PX30/';
di = '~/ocean_obs/XBTdata/IX28_29/';
yrs = dir(di);
turoqc = [];

for a = 1:length(yrs)
   if strmatch('.',yrs(a).name)
       continue
   end
   turof = dir(fullfile([di yrs(a).name '/raw/'],'/**/drop*.nc'));
   
   if isempty(turof)
       continue
   end
   
   %read each file in the folders
   for b = 1:length(turof)
      qc = squeeze(ncread([turof(b).folder '/' turof(b).name],'sampleQC'));
      %record unique numbers
      uqc = unique(qc);
      ii = ismember(uqc,turoqc);
      if any(ii == 0)
          turoqc = [turoqc;uqc(ii==0)];
      end
   end
end