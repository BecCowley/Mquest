function screen2eps(filename,mapplot)

% SCREEN2EPS: Generate a colour encapsulated Postscript
% level 2 file of the current figure with dimensions
% consistent with the figure's screen dimensions.
%
% SCREEN2EPS('filename') svaes the current figure to the 
% EPS file 'Filename'.
%
% Supplied by C. Spillman (BOM), May 2006

if nargin < 1
    error('Not enough input arguments!')
end

if nargin < 3
    fignum = gcf;
end
if nargin < 2
    mapplot = 0;
    fignum = gcf;
end
    
oldscreenunits = get(gcf,'Units');
oldpaperunits = get(gcf,'PaperUnits');
oldpaperpos = get(gcf,'PaperPosition');
set(gcf,'Units','Pixels');
scrpos = get(gcf,'Position');
newpos = scrpos/100;
if(mapplot)
else
    set(gcf,'Paperunits','inches',...
        'PaperPosition',newpos)  
end
eval(['print -f' num2str(fignum) ' -depsc2 ' filename ' -r100'])
drawnow
set(gcf,'Units',oldscreenunits,...
        'PaperUnits',oldpaperunits,...
        'PaperPosition',oldpaperpos);
    
return        

