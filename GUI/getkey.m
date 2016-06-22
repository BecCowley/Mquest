function ch = getkey(m) 

% GETKEY - get a key 
%   CH = GETKEY waits for a keypress, returns the ASCII code. Accepts
%   all ascii characters, including backspace (8), space (32), enter (13),
%   etc. CH is a double.
%
%   CH = GETKEY('non-ascii') uses non-documented matlab 6.5 features to
%   return a string describing the key pressed so keys like ctrl, alt, tab
%   etc. can also be used. CH is a string.
%
%   This function is kind of a workaround for getch in C. It uses a modal, but
%   non-visible window, which does show up in the taskbar.
%   C-language keywords: KBHIT, KEYPRESS, GETKEY, GETCH
%
%   Examples:
%
%    fprintf('\nPress any key: ') ;
%    ch = getkey ;
%    fprintf('%c\n',ch) ;
%
%    fprintf('\nPress the Ctrl-key: ') ;
%    if strcmp(getkey('non-ascii'),'control'),
%      fprintf('OK\n') ;
%    else
%      fprintf(' ... wrong key ...\n') ;
%    end
%
%  See also INPUT, INPUTDLG

% 2005 Jos
% Feel free to (ab)use, modify or change this contribution

% Determine the callback string to use
get(gcbo,'CurrentKey')
