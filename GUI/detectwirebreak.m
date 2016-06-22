%detect and flag wire breaks at the end of the valid data:  
%
%profiledata is a structure that holds the data - profiledata.temp is the
%   temperature variable, profiledata.depth is the depth variable.  The
%       histdepth is equal to Aux_ID in the history section of the meds-ascii format.  
%           oldt is equivalent to the Previous_Val variable. 

switch qflag  %this holds the current flag being appllied to the data -
        %WBR indicates you want to put on a wire break:
    case 'WBR'
         histdepth=[];
         d=diff(profiledata.temp);
         d=[0 d(1:end)'];
        % d(end+1)=d(end);
         
         jj=find(profiledata.temp>-2.4 & profiledata.temp < 32. & d'<=0.1);
         if(~isempty(jj) & ~isnan(profiledata.temp(jj(end)+1)))
             histdepth=profiledata.depth(jj(end)+1);
             oldt=num2str(profiledata.temp(jj(end)+1));
         else
             %no appropriate point found:
             return
         end
end