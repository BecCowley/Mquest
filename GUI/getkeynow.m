function ch = getkeynow(cmd)
% GETKEYNOW - Get the current key
%   CH = GETKEYNOW returns the currently pressed key in the main matlab window.
%   If no key is pressed at that moment CH is empty.
%
%   Before using getkey, initialize it with GETKEYNOW('init').
%   When you're finished using GETKEYNOW use GETKEYNOW('exit').
%
%   Example 1
%     % use to break a loop
%     getkeynow('init') ;
%     t0 = cputime ;
%     fprintf('\n\n%8.3f',cputime-t0) ;
%     ch = [] ;
%     while ~isequal(ch,'q'),
%        ch = getkeynow ;
%        if ~isempty(ch),
%            fprintf('\n%c',ch) ;
%        else
%            fprintf(repmat('%c',1,8),repmat(8,1,8)) ;
%        end                
%        fprintf('%8.3f',cputime-t0) ;
%     end
%     getkeynow('exit') ;
%
%   Code snippets:      
%      while ~isempty(getkeynow) end ; % Wait till no keys are pressed
%      kbhit = ~isempty(getkeynow) ; % as in C
%
%   The main keyboard buffer is not emptied. Characters that you type during
%   the calls to GETKEYNOW are finally returned in the main window so ...
%
%      USE WITH CARE !
%
%   (See what happens if you type the following sequence in the
%   first example above: "a = 1 : 10 <enter> q"). 
%
%   This works on a (aka my) PC running Windows XP and Matlab 6.5 + Java
%
%   See also INPUT, GETKEY (File Exchange).
%
%   C-language keywords: KBHIT, KEYPRESS, GETKEY, GETCH 

% Still no solution for the buffer problem ...
 
% 2005 Jos van der Geest

persistent rootframe
ch = [] ;
pause(0.000000001) ; % !! Otherwise no input is registered 

if nargin==0,
    cmd = 'get' ;
end

if isequal(cmd,'exit'),
    % EXIT GETKEYNOW
    if ~isempty(rootframe),
        set(rootframe,'keytypedcallback','') ;
        set(rootframe,'keyreleasedcallback','') ;
        set(rootframe,'userdata',[]) ; 
        clear rootframe
    end
elseif isequal(cmd,'init'),    
    % INIT GETKEYNOW
    % Look for the Matlab Main window
    frms = java.awt.Frame.getFrames;
    mainframetitle65 = 'com.mathworks.ide.desktop.MLMainFrame' ;
    rootframe = [] ;
    for m = 1:length(frms),
        if strcmpi(get(frms(m),'Type'),mainframetitle65),
            rootframe = frms(m);
            break;
        end
    end
    if isempty(rootframe),
        error('Cannot find root Java frame.') ;
    else    
        set(rootframe,'keytypedcallback','ch = get(gcbo,''keytypedcallbackdata'') ; set(gcbo,''userdata'',ch.keyChar)') ;
        set(rootframe,'keyreleasedcallback','set(gcbo,''userdata'',[]) ; ') ;
    end 
elseif isequal (cmd,'get'),
    if isempty(rootframe),
        warning('GETKEY not initialized ...') ;
    else
        ch = get(rootframe,'userdata') ;
    end
end






