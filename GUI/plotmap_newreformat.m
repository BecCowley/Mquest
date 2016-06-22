% plotmap_newreformat - plots the map required for the high density cruise
% processing - script.

figure
mapplot=1;
%longi=-longi;
h=plot(longi,lati,'b.')
hold on
coast

axis([min(longi)-10 max(longi)+10 min(lati)-10 max(lati)+10])
xlabel('latitude')
ylabel('longitude')
orient landscape

title([callsign,'  ',cruiseID,'  ',mon{str2num(month)},'',num2str(year)])

gif_str = [callsign,'_',cruiseID,'_',mon{str2num(month)},'',num2str(year),'_map.gif']
% screen2jpg(jpg_str)
 
save_fig([gif_str])
% 
% eps_str = [callsign,'_',cruiseID,'_',mon{str2num(month)},'',num2str(year),'_map.eps']
%             
% screen2eps(eps_str,mapplot)
% 
%             