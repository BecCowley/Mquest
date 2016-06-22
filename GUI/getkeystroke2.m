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

%whatisthis=gcbo
try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

set(gcbo,'Userdata',get(gcbo,'Currentkey')) ; 


% Set up the figure

    ch = get(gcbo,'Userdata') ;

%set (handles.keypressed,'String',ch);
%whatisthis2=gcbo
guidata(gcbo,handles);

qualf='   ';
% now manage keystrokes so they do what you need done:
%whatisthis3=gcbo
%handles
if(handles.Qkey=='Y')
     qualf='NON' ;  
  switch ch
      
        case '1'    %SPA - chop only one point!
            qualf='SPA';
        case 'w'
            qualf='WSA';
        case 'e'
            qualf='EFA';
        case 'r'
            qualf='REA';
        case 't'
            qualf='TPR';
        case 'y'
            qualf='BBA';
        case 'u'
            qualf='URA';
        case 'i'
            qualf='IVA';
        case 'o'
            qualf='OPR';
        case 'p'
            qualf='PEA';
        case 'leftbracket'
            qualf='CTA';
        case 'rightbracket'
            qualf='STA';
       case 'backslash'
%            qualf='QCR';
%            AR='R';
%            placement=     ;   
        case 'a'
%            qualf='QC';
%            AR='R';
%            placement=     ;   
        case 's'
            qualf='SFA';
        case 'd'
            qualf='DUR';
        case 'f'
            qualf='FSA';
        case 'g'
%            qualf='QC'
%            AR='R';
%            placement=;
        case 'h'
            qualf='HFA';
        case 'j'
            qualf='PSA';
        case 'k'
            qualf='LER';
        case 'l'
            qualf='LEA';
        case 'semicolon'
%            qualf='QC';
%            AR='R';
%            placement=;
        case 'z'
            qualf='HBR';
        case 'x'
            qualf='NGR';
        case 'c'
            qualf='CSA';
        case 'v'
            qualf='IPR';
        case 'b'
            qualf='WBR';
        case 'n'
            qualf='NUA';
        case 'm'
%            qualf='';
%            placement=;
        case 'comma'
            qualf='IPA';
        case 'period'
            qualf='SPA';
  end

  identifyflag

else    

switch ch
    case 'q'
    %here, we need to get another keystroke....
    %activate the key input window but still invisible - then this will get
    %the next key pressed
    
handles;
handles.Qkey='Y';
try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end
    return

%deal with single keystroke commands:
            
    ch = get(gcbo,'Userdata') ;

    case 'escape'  %nicely exit the program, saving the current profile

       
    case 'f1'   %add QCA flag
        qualf='QCA';
        addqualityflag(qualf,0,1);
    case 'f2'   %show QC (in list box)
        
    case 'f3'   %delete QC (from list)
        
    case 'f4'   %kill drop (replace with raw data)
        
    case 'f5'   %buddies +/-1
        
    case 'f6'   %buddies +/-2
        
    case 'f7'   %buddies 0.5 deg
        
    case 'f8'   %buddies 1.0 deg
        
    case 'f9'   %buddies 2.0
        
    case 'f10'  %goto specified drop
        
    case 'f11'  %display good buddies only
        handles.goodbuddy='Y';
        guidata(gcbo,handles);
        
    case 'f12'  %display all buddies
        handles.goodbuddy='N';
        guidata(gcbo,handles);
    case '1'    %URA (under resolved profile)
        
    case '2'    %switch MA for XB and vice versa - DTA code
        
    case '3'    %HBA
        
    case '4'    %DEA for JDRD  - don't implement unless needed
        
    case '5'    %get rid of duplicate history records...
        
    case '6'    %BOA for bathy system bowing
        
    case '7'    %restore surface values for CSA's in inflection data
        
    case '8'    %depth correct!!
        
    case '9'    %nothing at the moment...

    case '0'    %remove ALL QC flags
        
    case 'hyphen'    %display bottom of the trace
        
    case 'equal'    %goto a specific drop, selecting ALL ships.
        
    case 'backspace'  %nothing at the moment...
        
%    case 'w'   
%        qualf='WSR'
%        addqualityflag(qualf,1,2)        
    case 'e'    %not active
%        qualf='EF';
%        addqualityflag(qualf);
    case 'r'    %not active
%        qualf='QC';
%        addqualityflag(qualf)  ;      
    case 't'   
        qualf='TEA';
        addqualityflag(qualf,0,2);
    case 'y'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'u'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'i'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'o'    %tor entire profile
        qualf='TOR';
        addqualityflag(qualf,0,3);
        return
    case 'p'    %not active
        qualf='PEA';
        addqualityflag(qualf,0,2);
    case 'leftbracket'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'rightbracket'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'backslash'    %not active
%        qualf='QC';
%        addqualityflag(qualf)   ;     
    case 'a'    %not active
%        qualf='QC';
%        addqualityflag(qualf)    ;    
    case 's'    %not active
%        qualf='QC';
%        addqualityflag(qualf)     ;   
    case 'd'    %DUR profile, save, and send to the next profile
        qualf='DUR';
        addqualityflag(qualf,0,4);
        saveprofile;
                  %goto the next profile...
        %????          
        return
    case 'f'    %add FSA, CSA and QCA all together and put in buddy mode
        qualf='QCA';
        addqualityflag(qualf,0,1);
        qualf='CSA';
        addqualityflag(qualf,0,1);
        qualf='FSA';
        addqualityflag(qualf,0,2);
        %put into buddy mode
          plotbuddies

            return
    case 'g'    %not active
%        qualf='QC'
%        addqualityflag(qualf)
    case 'h'    %not active
%        qualf='QC'
%        addqualityflag(qualf)
    case 'j'    %add PSA, CSA and QCA all together and put in buddy mode
        qualf='QCA';
        addqualityflag(qualf,0,1);
        qualf='CSA';
        addqualityflag(qualf,0,0);
        qualf='PSA';
        addqualityflag(qualf,0,2);
        return
        %put into buddy mode
         plotbuddies

     case 'k'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'l'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case ';'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'z'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'x'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'c'    %add CSA and QCA, then put into buddy mode
        qualf='QCA';
        addqualityflag(qualf,0,1);
        qualf='CSA';
        addqualityflag(qualf,0,0);
        %put into buddy mode
       plotbuddies

            return
    case 'v'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'b'
        qualf='WBR';
        addqualityflag(qualf,3,4);
        return
    case 'v'
%        qualf='QC';
%        addqualityflag(qualf);
    case 'n'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'm'    %not active
%        qualf='QC';
%        addqualityflag(qualf);
    case 'comma'    %not active
%        qualf='IPA';
%        addqualityflag(qualf,2,2);        
    case 'period'    %not active
%        qualf='SPA';
%        addqualityflag(qualf,2,2);
    case 'scrolllock'  %(pause key) - not necessary in matlab
        
    case 'insert'    %now used to return map to original axes
        
        axes(handles.map);
        keysdata=handles.keys;
        lat=keysdata.obslat;
        lon=keysdata.obslon;

        lla=range(lat);
        llo=range(lon);
        xlimit=[llo(1)-5 llo(2)+5];
        ylimit=[lla(1)-5 lla(2)+5];
        set(handles.map,'XLim',xlimit);
        set(handles.map,'YLim',ylimit);

        
%        cla
%        plotmap
%        updatemap
        return
        
    case 'slash'    
        
    case 'numpad1'    %set buddies for only one year
        
    case 'numpad2'    %set buddies for all years
        
    case 'numpad3'    %set buddies to +/- 0.2 deg
        
    case 'numpad4'    %set buddies to +/- specified range
        
    case 'numpad5'    %set buddies to +/- 1 deg
        
    case 'numpad6'    %set buddies to +/- 4 deg
        
    case 'numpad7'    %not used....
         
    case 'numpad8'    %set buddies to +/- 0.25 deg
        
    case 'numpad9'    %set buddies to +/- 3 deg
        
    case 'numpad0'    %remove all QC flags - keep inactive!!!!

    case 'add'
        
    case 'subtract'
        
    case 'decimal'    %not used...
        
    case 'home'       %goto drop 1
        handles.lastprofile=handles.currentprofile;
        handles.currentprofile=1;
        handles.profilefocus=500.; %this is the default...
        i=1;
        guidata(gcbo,handles);
        plotnewprofile;
        updatemap;
        return
    case 'delete'    %change display region to focus on current profile
        
        axes(handles.map);
        keysdata=handles.keys;
        lat=keysdata.obslat(handles.currentprofile);
        lon=keysdata.obslon(handles.currentprofile);

        xlimit=[lon-2 lon+2];
        ylimit=[lat-2 lat+2];
set(handles.map,'XLim',xlimit);
set(handles.map,'YLim',ylimit);
        return
        
    case 'end'       %continue scrolling through the profiles.
        
handles.stopscroll=0;
try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end

        for scrollthrough=handles.currentprofile+1:length(handles.keys.stnnum)  
try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end
 stopscroll=handles.stopscroll;

            if(stopscroll)
                return
            end
            
            handles.lastprofile=handles.currentprofile;
            handles.currentprofile=scrollthrough;
            handles.profilefocus=500.; %this is the default...
            i=scrollthrough
            guidata(gcbo,handles);
            plotnewprofile;
            updatemap;

%set(gcbo,'Userdata',get(gcbo,'Currentkey')) ; 
%ch=get(gcbo,'Userdata')
%            if (isempty(strmatch('end',ch,'exact')))
%                return
%            end
            pause(.5);        handles.lastprofile=handles.currentprofile;

            handles.profilefocus=500.; %this is the default...
        end
        return
        
    case 'pageup'    %display buddy profiles
       plotbuddies
       return
    case 'pagedown'  %display only current profile
        keysdata=handles.keys;
        axis=handles.profile;
        cla
        ss=keysdata.stnnum(handles.currentprofile);  %keysdata.stnnum(i);   %
        plotprofile;
        return
        
    case 'uparrow'    %save current profile if necessary and go to the next
            handles.lastprofile=handles.currentprofile;
            handles.currentprofile=handles.currentprofile+1;
            handles.profilefocus=500.; %this is the default...
            guidata(gcbo,handles);
dsource=getnc(keysfile,'data_source');
            plotnewprofile;
            updatemap;
            return
            
    case 'downarrow'  %save current profile if necessary and to back to the previous
            handles.lastprofile=handles.currentprofile;
            handles.currentprofile=handles.currentprofile-1;
            handles.profilefocus=500.; %this is the default...
            guidata(gcbo,handles);
            plotnewprofile;
            updatemap;
            return
            
    case 'leftarrow'   %reset zoom
        axes(handles.profile);
        handles.profilefocus=500.; %this is the default...
        guidata(gcbo,handles);
        set(handles.profile,'YLim',[0 1000]);
        set(handles.profile,'XLim',[-2.5 35]);
        return
        
    case 'rightarrow'   %zoom on the profile at the cursor - +/-100m
        axes(handles.profile);
        focusdepth=handles.menudepth;
        handles.profilefocus=100.;
        guidata(gcbo,handles);
        set(handles.profile,'YLim',[focusdepth-100 focusdepth+100]);
        return
       
end
        
    if(qualf(3)=='A')
        cc=get(handles.acceptcodes,'String');
    else
        cc=get(handles.rejectcodes,'String');
    end
    cc2=strmatch(qualf,cc,'exact');
    if(isempty(cc2))
        erro=qualf;
        cc=cc;
        errordlg([ 'This flag is invalid!!!' erro]) 
        return
    end
    if(strmatch(qualf,'NON'))
        erro=qualf;
        errordlg([ 'This flag is invalid!!!' erro]) 
        return
    end

    if(qualf(3)=='A')
        placement=handles.acceptplace(cc2);
        severity=handles.acceptlevel(cc2);
    else
        placement=handles.rejectplace(cc2);
        severity=handles.rejectlevel(cc2);
    end       
    addqualityflag(qualf,placement,severity);
    handles.Qkey='N';
try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end
   
        
      
end     
     
        