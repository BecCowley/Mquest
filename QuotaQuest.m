function varargout = QuotaQuest(varargin)
% QuotaQuest M-file for QuotaQuest.fig
%
%       QuotaQuest is created by "quest('user')" which initializes the input
%       variables:  month, year, input database, version, required QC (if
%       any), whether or not you want to see only profiles that have failed
%       auto QC tests, and the buddy databases for display.
%
%       Each user name retrieves the last settings for that user which can
%       be modified within "quest".  These variables are then passed
%       to QuotaQuest.  In this way, several people can use the same
%       program but customize it for their particular needs, saving time
%       when entering QC.
%
%      QuotaQuest, by itself, creates a new QuotaQuest or raises the existing
%      singleton*.
%
%      H = QuotaQuest returns the handle to a new QuotaQuest or the handle to
%      the existing singleton*.
%
%      QuotaQuest('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QuotaQuest.M with the given input arguments.
%
%      QuotaQuest('Property','Value',...) creates a new QuotaQuest or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QuotaQuest_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QuotaQuest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help QuotaQuest

% Last Modified by GUIDE v2.5 16-Feb-2007 12:48:10

%DECLAREGLOBALS

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QuotaQuest_OpeningFcn, ...
                   'gui_OutputFcn',  @QuotaQuest_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before QuotaQuest is made visible.
function QuotaQuest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QuotaQuest (see VARARGIN)

%the first thing you need to do is establish that nothing needs to be
%changed.  Selectuser is created by the quest entry gui and contains the
%required time frame, database and buddy databases.

h=handles;

    DECLAREGLOBALS

    handles=h;
 
handles.changed=0;
   
load selectuser;
%u=u ;  %username
%p=p ;  %database prefix
%m=m ;  %month required
%y=y ;  %year required
%quotaquest=quotaquest ;  %display a profile only if certain qc codes are present?
%a=a ;  %display a profile only if it has failed an auto qc test?
%tw=tw ; %"time window" of the program - specifies the time window to be used
%sstyle=sstyle ; %sort style - by lat or ship

[keysdata]=getkeys(p,m,y,q,a,tw,sstyle);  %retrieve the keys of the subset of the data required
handles.keys=keysdata;    %set up the handles structure for communication to other functions
handles.Qkey='N';         %identifies whether or not the "q" key has been pressed - 
    %used to determine the action of other keypresses.
handles.version=tw;
handles.goodbuddy='Y';   %display only the good data when you show buddy profiles.
handles.profilefocus=500.;    %the "center" of the profile display
handles.singleyearbuddies=0;   %singleyearbuddies controls display of buddy profiles - 
                                   %plot from single year or only the year of the current profile.
handles.singlemonthbuddies=0;   %singlemonthbuddies controls display of buddy profiles - 
                                   %plot from single month or only the month of the current profile.
[buddykeys]=getbuddykeys(m,tw,u,q,keysdata.prefix);  %retrieve the keys of the buddy profiles and hold in memory.
handles.buddies=buddykeys;       %save in the handles structure.
handles.sstyle=sstyle;
handles.newfontsize=[];
handles.restrictbuddies=0;
handles.qc=str2num(q{1})-1;
handles.monthrequired=m{1};
handles.u = u;
handles.stopbuds=0;   %hopefully is used to stop buddy plotting...
%saveguidata
%guidata(hObject, handles);

%set(handles.QuotaQuest,'MenuBar','None');
plotedit('hidetoolsmenu')
try
    plotmap;    %plot the positions in the map box
end


    populatecallsignlist   %script to put the callsigns from the current data subset 
%                           into the drop down menu box.

%set up to plot the first profile

i=1;
handles.currentprofile=i;  %keeps track of where you are in the subset.

%establish the first values for these parameters:
handles.changed='N';
handles.lastprofile=i;  %keeps track of the last profile displayed - used when a 
%                           new profile is requested to save any changes before continuing
handles.buddylim=1;     %display +/-1 profile when buddies are requested.
handles.buddy=1;        %the value of the buddy selection window at startup (points to +/-1 profile)
handles.displaybuddy='N';  %don't show the buddies at startup.  Page up changes this to "Y".

%setup the accept menus:  The order and action of these flags can be
%changed by editing 'questAflags.txt'
[a,b,c]=textread('questAflags.txt','%3s %f %f');
set(handles.acceptcodes,'String',a);
handles.acceptlevel=b;
handles.acceptplace=c;

% setup the reject menu:   The order and action of these flags can be
%changed by editing 'questRflags.txt'
clear a;
clear b;
clear c;
[a,b,c]=textread('questRflags.txt','%3s %f %f');
set(handles.rejectcodes,'String',a);
handles.rejectlevel=b;
handles.rejectplace=c;
handles.updateall=1;

%setup the waterfall window:
handles.firstwaterprofile=1;
handles.menudepth=0;

%setup the key handling structure if "quotaquest" is pressed first:  The flag called
%and the action taken can be changed by editing "qflaghandling.txt"
clear a;
clear b;
[a,b]=textread('qflaghandling.txt','%13s%4s','delimiter','%','commentstyle','matlab','headerlines',1);

handles.qkeystrokes=a;
handles.qflags=b;
set(handles.speed,'visible','off');
set(handles.repeat,'visible','off');
set(handles.stopbuddies,'Value',0);
set(handles.singleyear,'Visible','off');
set(handles.singlemonth,'Visible','off');

%plot all the things that change with a new profile:

plotnewprofile;

% Choose default command line output for QuotaQuest
handles.output = hObject;

% Update handles structure
%saveguidata
%guidata(hObject, handles);

% UIWAIT makes QuotaQuest wait for user response (see UIRESUME)
 %uiwait(handles.figure1);

uicontrol(handles.profile_info);
                    

% --- Outputs from this function are returned to the command line.
function varargout = QuotaQuest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
h=handles;

DECLAREGLOBALS

%NOTE: there are no outputs from this program
varargout{1} = handles.output; 
%clear global handles

% --- Executes on selection change in depthdisplay.
function depthdisplay_Callback(hObject, eventdata)
% hObject    handle to depthdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns depthdisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from depthdisplay

DECLAREGLOBALS

%this function recentres the profile display at the selected depth from the
%depth/temp menu to the left of the profile plot.

%retrieveguidata

profiledata=handles.profile_data;
axes(handles.profile);
xlimit=[-5 35];
%get rid of the original depth line - imperfect but faster than replotting
%the entire profile window.
g=plot(xlimit,[handles.menudepth handles.menudepth],'k-');
set(g,'LineWidth',2);
ddtt=get(hObject,'String');
depthfrommenu=ddtt{get(hObject,'Value')};
handles.menudepth=str2num(depthfrommenu(1:8));

%set profilefocus to 1/2 range of plot, then centre plot on the focus
ymin=handles.menudepth-handles.profilefocus;
ymax=handles.menudepth+handles.profilefocus;

ylimit=[ymin ymax];
set(handles.profile,'YLim',ylimit);
grey2=[.6 .6 .6];
%add line at the depth chosen
g=plot(xlimit,[handles.menudepth handles.menudepth],'color',grey2,'linestyle','-');
set(g,'LineWidth',2);

%reset the depth/temp box
minlist=get(hObject,'Value')-22;
minlist=max(minlist,1);
set(handles.depthdisplay,'ListboxTop',minlist);

%saveguidata
%set(gcf, 'CurrentObject',gcf); 
%uicontrol(handles.invisiblebutton)

uicontrol(handles.profile_info);
                    

% --- Executes during object creation, after setting all properties.
function depthdisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depthdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in acceptcodes.
function acceptcodes_Callback(hObject, eventdata)
% hObject    handle to acceptcodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns acceptcodes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from acceptcodes

DECLAREGLOBALS

%adds the required QC flag to the profile:

%retrieveguidata

flagstring=get(hObject,'String');
flag=get(hObject,'Value'); 
qualf=flagstring{flag};
handles.QCflag=flagstring(flag,:);

%saveguidata

identifyflag;    %retrieves the relevant information (depth, severity, code) for the selected flag and
                    % calls routine to add the flag to the profile.

uicontrol(handles.profile_info);
                    
% --- Executes during object creation, after setting all properties.
function acceptcodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acceptcodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in rejectcodes.
function rejectcodes_Callback(hObject, eventdata)
% hObject    handle to rejectcodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns rejectcodes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rejectcodes

DECLAREGLOBALS

%adds the requird QC flag to the profile:

%retrieveguidata
flagstring=get(hObject,'String');
flag=get(hObject,'Value');  
qualf=flagstring{flag};
handles.QCflag=flagstring(flag,:);
%saveguidata
identifyflag;  %identifies the flag and calls the routine that adds it to the profile.

uicontrol(handles.profile_info);
                    
% --- Executes during object creation, after setting all properties.
function rejectcodes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rejectcodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in next_profile.
function next_profile_Callback(hObject, eventdata)
% hObject    handle to next_profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%go to the next profile:  (can use uparrow as well)

%    retrieveguidata
    
    keysdata=handles.keys;
    handles.lastprofile=handles.currentprofile;
    
    if(handles.currentprofile>=length(keysdata.stnnum))
        handles.currentprofile=length(keysdata.stnnum);
    else
        handles.currentprofile=handles.currentprofile+1;
    end
    
    handles.profilefocus=500.; %this is the default...
    
%    saveguidata
        
    plotnewprofile;

uicontrol(handles.profile_info);
                    
% --- Executes on button press in previous_profile.
function previous_profile_Callback(hObject, eventdata)
% hObject    handle to previous_profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%go to the previous profile (or can use downarrow)

%    retrieveguidata

    handles.lastprofile=handles.currentprofile;
    if(handles.currentprofile<=1)
        handles.currentprofile=1;
    else
        handles.currentprofile=handles.currentprofile-1;
    end
    
    handles.profilefocus=500.; %this is the default...
    
%    saveguidata    
    plotnewprofile;
    updatemap; 

uicontrol(handles.profile_info);
                    
% --- Executes on selection change in waterfalllist.
function waterfalllist_Callback(hObject, eventdata)
% hObject    handle to waterfalllist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns waterfalllist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from waterfalllist

%set the current profile to the porifle number for the selected line and
%display that profile after updating the present profile.

DECLAREGLOBALS

%changes the profile displayed if you change the selection in the waterfall
%list:

%retrieveguidata
profilelist=get(hObject,'String');
line=get(hObject,'Value');
sp=strfind(profilelist{line},' ');
newprofile=str2num(profilelist{line}(1:sp(1)));
handles.lastprofile=handles.currentprofile;
handles.currentprofile=newprofile;

%saveguidata

plotnewprofile;

%set(gcf, 'CurrentObject',gcf); 
%uicontrol(handles.invisiblebutton);

uicontrol(handles.profile_info);
                    
% --- Executes during object creation, after setting all properties.
function waterfalllist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waterfalllist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in goto.
function goto_Callback(hObject, eventdata)
% hObject    handle to goto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%allows you to specify the drop you want displayed - enter the number into
%the box.

%retrieveguidata

    keysdata=handles.keys;
    handles.lastprofile=handles.currentprofile;
    handles.currentprofile=str2num(get(handles.profilenumber,'String'));
    if(handles.currentprofile>length(keysdata.stnnum))
        handles.currentprofile=length(keysdata.stnnum);
    end
    handles.profilefocus=500.; %this is the default...
%saveguidata
    plotnewprofile;
    clearmapposition;
    updatemap;

uicontrol(handles.profile_info);
                    
% --- Executes on selection change in buddyselection.
function buddyselection_Callback(hObject, eventdata)
% hObject    handle to buddyselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

% Hints: contents = get(hObject,'String') returns buddyselection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from buddyselection

%changes the definition of a buddy to the selected range and then displays the buddies.

%retrieveguidata

buddylimits=get(hObject,'String');
usebuddylimits=get(hObject,'Value');
handles.displaybuddy='Y';
handles.buddy=usebuddylimits;
handles.restrictbuddies=0;
if(usebuddylimits<=3)  %these buddies are +/- 1,2 or 3 from the present profile
    handles.buddylim=usebuddylimits;
    set(handles.custombuddy,'String',num2str(usebuddylimits));
else
    if(strmatch(buddylimits(usebuddylimits),'user select')>0) 
        %get limits from edit box below buddy selection window...
        handles.buddylim=str2num(get(handles.custombuddy,'String'));
    elseif(strmatch(buddylimits(usebuddylimits),'max buddies')>0)
        handles.buddylim=str2num(get(handles.custombuddy,'String'));
    else
        %get limits from menu - displays buddies from area around present
        %profile
        handles.buddylim=str2num(buddylimits{usebuddylimits}(1:3));
        set(handles.custombuddy,'String',num2str(handles.buddylim));
    end
end

%saveguidata
axes(handles.profile);
plotbuddies

uicontrol(handles.profile_info);
                    
% --- Executes during object creation, after setting all properties.
function buddyselection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buddyselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exitbutton.
function exitbutton_Callback(hObject, eventdata,handles)
% hObject    handle to exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    h=handles;
    DECLAREGLOBALS
    handles=h;
catch
    DECLAREGLOBALS
end
%retrieveguidata
%save present profile, if it has changed, before exiting:
if(handles.changed=='Y')
    handles.lastprofile=handles.currentprofile;
%    saveguidata;
    writenetcdf
end
delete(handles.QuotaQuest);

% --- Executes on mouse press over axes background.
function map_ButtonDownFcn(hObject, eventdata)
% hObject    handle to profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%changes the depth on the profile plot and depth/temp menu so you 
%can add flags at a particular point

%retrieveguidata
zoommapwindow;

uicontrol(handles.profile_info);
                    
return

% --- Executes on mouse press over axes background.
function profile_ButtonDownFcn(hObject, eventdata)
% hObject    handle to profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%changes the depth on the profile plot and depth/temp menu so you 
%can add flags at a particular point

%retrieveguidata
recenterprofileplot;
%uicontrol(handles.invisiblebutton);

uicontrol(handles.profile_info);
                    
return


function profilenumber_Callback(hObject, eventdata)
% hObject    handle to profilenumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of profilenumber as text
%        str2double(get(hObject,'String')) returns contents of profilenumber as a double

DECLAREGLOBALS

%goes to the new profile number from the edit box:

%retrieveguidata

keysdata=handles.keys;

    handles.lastprofile=handles.currentprofile;
    handles.currentprofile=str2num(get(handles.profilenumber,'String'));
    if(handles.currentprofile>length(keysdata.stnnum))
        handles.currentprofile=length(keysdata.stnnum);
    end

    %change the callsign in the box if the new profile is from a different
    %ship:
    if(~strcmp(keysdata.callsign(handles.currentprofile,:),keysdata.callsign(handles.lastprofile,:)));
        
        requiredcallsign=keysdata.callsign(handles.currentprofile);
        callsignlist=get(handles.callsigns,'String');
        kk=strmatch(requiredcallsign,callsignlist);
        set(handles.callsigns,'Value',kk(1));
        
    end


    handles.profilefocus=500.; %this is the default...
%    saveguidata
    plotnewprofile;
    updatemap;
%set(gcf, 'CurrentObject',gcf); 
%uicontrol(handles.invisiblebutton);

uicontrol(handles.profile_info);
                    
% --- Executes during object creation, after setting all properties.
function profilenumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to profilenumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function custombuddy_Callback(hObject, eventdata)
% hObject    handle to custombuddy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

% Hints: get(hObject,'String') returns contents of custombuddy as text
%        str2double(get(hObject,'String')) returns contents of custombuddy as a double

%set the area limits for the buddy display - this is in degrees +/- the
%location of the present profile.  Then plot the buddies.

%retrieveguidata

handles.restrictbuddies=0;

budregion=get(handles.buddyselection,'String');
newbud=strmatch('user select',budregion);
set(handles.buddyselection,'Value',newbud);

handles.displaybuddy='Y';
handles.buddy=newbud;
handles.buddylim=str2num(get(handles.custombuddy,'String'));

%saveguidata;
axes(handles.profile);
plotbuddies
%set(gcf, 'CurrentObject',gcf); 
%uicontrol(handles.invisiblebutton);
uicontrol(handles.profile_info);

% --- Executes during object creation, after setting all properties.
function custombuddy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to custombuddy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in callsigns.
function callsigns_Callback(hObject, eventdata)
% hObject    handle to callsigns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns callsigns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from callsigns

DECLAREGLOBALS

%calls the script that determines the required callsign and goes to the
%first profile of that ship in the current subset.

goto_callsign
%get(gcf)
%set(gcf, 'CurrentObject',handles.profile_info); 
%uicontrol(invisiblebutton);
uicontrol(handles.profile_info);

% --- Executes during object creation, after setting all properties.
function callsigns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to callsigns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultuicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in exportbutton.
function exportbutton_Callback(hObject, eventdata)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%launch gui to output data from this file to meds-ascii or new-reformat
%(plus others if there is a demand)

%retrieveguidata

callsignstring=get(handles.callsigns,'String');
centering=1;
exportdata('UserData',{centering callsignstring});

% --- Executes on button press in importbutton.
function importbutton_Callback(hObject, eventdata)
% hObject    handle to importbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DECLAREGLOBALS

%Launches the gui to import data from a supported format (meds-ascii,
%Devil, mk12 or mk9) and add it to the current (or other, specified) database:

%retrieveguidata

keysdata=handles.keys;
dir2=pwd;
importdata('UserData',{keysdata.prefix,dir2});

load selectuser;
u=u ;
p=p ;
m=m ;
y=y ;
q=q ;
a=a ; 
tw=tw ;
ss=sstyle ;

%reload the keys to add new data:
[keysdata]=getkeys(p,m,y,q,a,tw,ss);
handles.keys=keysdata;

%reset the QuotaQuest gui to reflect additional data:
populatecallsignlist;
handles.Qkey='N';
handles.timewindow=tw;
handles.goodbuddy='Y';
handles.profilefocus=500.;

%buddies must be reloaded because the current database is part of the buddy
%database:
handles.u = u;
[buddykeys]=getbuddykeys(m,tw,u,q,keysdata.prefix);
handles.buddies=buddykeys;
jkl=keysdata;
hhh=handles;
populatecallsignlist

%plot the positions in the map box
%try
%    plotmap;
%end
%axes(handles.waterfall)
setwaterfall
drawnow
updatemap

%saveguidata
uicontrol(handles.profile_info);


% --- Executes during object creation, after setting all properties.
function waterheadings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waterheadings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%DECLAREGLOBALS

% --- Executes on button press in scroll.
function scroll_Callback(hObject, eventdata)
% hObject    handle to scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scroll

DECLAREGLOBALS
if(get(handles.scroll,'Value'))
    cp=handles.currentprofile;
    keysdata=handles.keys ;
    set(handles.scroll,'String','Stop Scroll');
    handles.updateall=0;
    while(get(handles.scroll,'Value') & handles.currentprofile ~= length(handles.keys.stnnum) )   % scrollonward=cp:length(keysdata.stnnum)
        handles.lastprofile=handles.currentprofile;
        handles.currentprofile=handles.currentprofile+1;
        handles.profilefocus=500.; %this is the default...
        plotnewprofile
        drawnow
    end
    if(handles.currentprofile==length(handles.keys.stnnum))
        handles.updateall=1;
        plotnewprofile
        drawnow
        set(handles.scroll,'String','Scroll');
        return
    end
else
    handles.updateall=1;
    plotnewprofile
    drawnow
    set(handles.scroll,'String','Scroll');
    return
end
%set(gcf, 'CurrentObject',gcf); 
%uicontrol(handles.invisiblebutton);
uicontrol(handles.profile_info);

% --- Executes on button press in singleyearbuds.
%function singleyearbuds_Callback(hObject, eventdata, handles)
% hObject    handle to singleyearbuds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of singleyearbuds

%if(get(handles.scroll,'Value'))
%        handles.singleyearbuddies=1;
%    set(handles.singleyearbuds,'String','All Years');
%else
%    handles.singleyearbuddies=0;
%    set(handles.singleyearbuds,'String','Single Year');
%end




% --- Executes during object creation, after setting all properties.
function QuotaQuest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuotaQuest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in invisiblebutton.
function invisiblebutton_Callback(hObject, eventdata, handles)
% hObject    handle to invisiblebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getkeystroke;



function uniqueid_Callback(hObject, eventdata)
% hObject    handle to uniqueid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uniqueid as text
%        str2double(get(hObject,'String')) returns contents of uniqueid as a double

DECLAREGLOBALS
keysdata=handles.keys;
uniqid=get(handles.uniqueid,'String');

kk=find(keysdata.stnnum==str2num(uniqid{1}));

if(isempty(kk))
    errordlg('this profile does not exist or is not in this database')
    return
else
    handles.lastprofile=handles.currentprofile;
    handles.currentprofile=kk(1);
    if(handles.currentprofile>length(keysdata.stnnum))
        handles.currentprofile=length(keysdata.stnnum);
    end
    handles.profilefocus=500.; %this is the default...

    plotnewprofile;
    updatemap;
end
uicontrol(handles.profile_info);

% --- Executes during object creation, after setting all properties.
function uniqueid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uniqueid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in stopbuddies.
function stopbuddies_Callback(hObject, eventdata)
% hObject    handle to stopbuddies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DECLAREGLOBALS

handles.stopbuds=1;
