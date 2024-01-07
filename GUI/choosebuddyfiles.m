function varargout = CHOOSEBUDDYFILES(varargin)
% CHOOSEBUDDYFILES Application M-file for choosebuddyfiles.fig
%   CHOOSEBUDDYFILES, by itself, creates a new CHOOSEBUDDYFILES or raises the existing
%   singleton*.
%
%   H = CHOOSEBUDDYFILES returns the handle to a new CHOOSEBUDDYFILES or the handle to
%   the existing singleton*.
%
%   CHOOSEBUDDYFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in CHOOSEBUDDYFILES.M with the given input arguments.
%
%   CHOOSEBUDDYFILES('Property','Value',...) creates a new CHOOSEBUDDYFILES or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before choosebuddyfiles_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to choosebuddyfiles_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2000-2002 The MathWorks, Inc.

% Edit the above text to modify the response to help choosebuddyfiles

% Last Modified by GUIDE v2.5 05-Jun-2006 14:05:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @choosebuddyfiles_OpeningFcn, ...
                   'gui_OutputFcn',     @choosebuddyfiles_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before choosebuddyfiles is made visible.
function choosebuddyfiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choosebuddyfiles (see VARARGIN)

% Choose default command line output for choosebuddyfiles
h=handles;
retrieveguidata
buddypath=handles.buddypath;
handles=h;
handles.buddypath=buddypath;

handles.output = 'error';

% Update handles structure
guidata(handles.editbuddyfiles,handles);

% Populate the listbox
handles.currentdir=pwd;
a = dir(handles.buddypath);
handles.databasedir=handles.currentdir;

loadbuddylist

guidata(handles.editbuddyfiles,handles);

%set(handles.choosebuddies,'String',inputfiles,'Value',1);

%load_listbox(initial_dir,handles)
% Return figure handle as first output argument
    
% UIWAIT makes choosebuddyfiles wait for user response (see UIRESUME)
 uiwait(handles.editbuddyfiles);


% --- Outputs from this function are returned to the command line.
function varargout = choosebuddyfiles_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%varargout{1} = handles.output

% ------------------------------------------------------------
% Callback for list box - open .fig with guide, otherwise use open
% ------------------------------------------------------------

function varargout = choosebuddies_Callback(h, eventdata, handles)
% hObject    handle to choosebuddies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns choosebuddies contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choosebuddies

   handles=guidata(handles.editbuddyfiles);

%get(handles.editbuddyfiles,'SelectionType');
%if strcmp(get(handles.editbuddyfiles,'SelectionType'),'open')
%if strcmp(get(handles.editbuddyfiles,'SelectionType'),'open') % If double click
index_selected = get(handles.choosebuddies,'Value');
file_list = get(handles.choosebuddies,'String');
filename = [file_list{index_selected}];

if  handles.isdir(index_selected)
    
    loadbuddylist
else
    s=strfind(filename,'_')-1;
    if(isempty(s))
        s=length(filename-1);
    end
    %       if(ispc)
    newbuddy=filename(1:s);
    save addedbuddy.mat newbuddy;
    handles.output=newbuddy;
    %       else
    %           newbuddy=[relpath '/' name(1:s)];
    %           save addedbuddy.mat newbuddy;
    %           handles.output=newbuddy;
    %       end
    guidata(handles.editbuddyfiles,handles)  ;
    uiresume;
    varargout{1} = handles.output;
    close(handles.editbuddyfiles);
    return
end
guidata(handles.editbuddyfiles,handles)  ;
return
%end

% --- Executes during object creation, after setting all properties.
function choosebuddies_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choosebuddies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function editbuddyfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editbuddyfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Add the current directory to the path, as the pwd might change thru' the
% gui. Remove the directory from the path when gui is closed 
% (See editbuddyfiles_DeleteFcn)
setappdata(hObject, 'StartPath', pwd);
addpath(pwd);


% --- Executes during object deletion, before destroying properties.
function editbuddyfiles_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to editbuddyfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove the directory added to the path in the editbuddyfiles_CreateFcn.
if isappdata(hObject, 'StartPath')
    rmpath(getappdata(hObject, 'StartPath'));
end



% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=[];

guidata(handles.editbuddyfiles,handles)  ;
   
newbuddy=[];
save addedbuddy.mat newbuddy;
close(handles.editbuddyfiles);


function relativeprefix_Callback(hObject, eventdata, handles)
% hObject    handle to relativeprefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relativeprefix as text
%        str2double(get(hObject,'String')) returns contents of relativeprefix as a double

newb=get(handles.relativeprefix,'String');
newbuddy=newb{1};
save addedbuddy.mat newbuddy;
close(handles.editbuddyfiles);


% --- Executes during object creation, after setting all properties.
function relativeprefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relativeprefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


