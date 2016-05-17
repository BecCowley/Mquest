function screen2jpg(filename,fignum,quality)

% SCREEN2JPG: Generate a JPG file of the current figure with dimensions
% consistent with the figure's screen dimensions.
%
% SCREEN2JPG('filename') svaes the current figure to the 
% JPEG file 'Filename'.
%
% Sean P. McCarthy
% Copyright (c) 1984-98 by The Mathworks, Inc. All Rights Reserved
%
% Modified by B. Robson (CWR), Nov 1999
% Supplied by C. Spillman (BOM), May 2006
%
% Additional optional arguments:
%   fignum: which figure to print (default: current figure)
%   quality: quality of the jpeg file (default: 75)

if nargin < 1
    error('Not enough input arguments!')
end

if nargin < 2
    fignum = gcf;
end

if nargin < 3
    quality = 100;
end

oldscreenunits = get(gcf,'Units');
oldpaperunits = get(gcf,'PaperUnits');
oldpaperpos = get(gcf,'PaperPosition');
set(gcf,'Units','Pixels');
scrpos = get(gcf,'Position');
newpos = scrpos/100;
set(gcf,'Paperunits','inches',...
        'PaperPosition',newpos)
eval(['print -f' num2str(fignum) ' -djpeg' num2str(quality) ' ' filename ' -r100'])
drawnow
set(gcf,'Units',oldscreenunits,...
        'PaperUnits',oldpaperunits,...
        'PaperPosition',oldpaperpos);
    
return        

