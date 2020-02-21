  clear all

dirn = '/home/UOT-data/quest/';
  pref = {'mer/GTSPPmer2017MQNC/','antarctic/CSIROXBT2019ant/','BOM/BOM2018/'};
  
  dbpref = 'QCworkshop';
  prefix=[dirn dbpref];
  p={prefix};
  m={'All'};
  y={'All'};
  q={'1'};
  a={'1'};
  tw={'1'};
  sstyle={'None'};
  [keysdata]=getkeys(p,m,y,q,a,tw,sstyle);

  for a = 1:length(keysdata.stnnum)
      raw = 1;
      filen=getfilename(num2str(keysdata.stnnum(a)),raw);
      raw = 0;
      filene=getfilename(num2str(keysdata.stnnum(a)),raw);
      for b = 1:length(pref)
          fn = [dirn pref{b} filen];
          if exist(fn,'file') == 2
              disp(['cp ' fn ' ' prefix '/' filen])
              %copy it to the raw file
              system(['cp ' fn ' ' prefix '/' filen])
%               and repeat for the ed file:
              system(['cp ' fn ' ' prefix '/' filene])
              disp(['cp ' fn ' ' prefix '/' filene])
          end
      end
  end