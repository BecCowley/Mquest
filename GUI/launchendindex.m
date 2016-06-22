function varargout = launchendindex(varargin)
% LAUNCHENDINDEX M-file for launchendindex.fig
%      LAUNCHENDINDEX, by itself, creates a new LAUNCHENDINDEX or raises the existing
%      singleton*.
%
%      H = LAUNCHENDINDEX returns the handle to a new LAUNCHENDINDEX or the handle to
%      the existing singleton*.
%
%      LAUNCHENDINDEX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAUNCHENDINDEX.M with the given input arguments.
%
%      LAUNCHENDINDEX('Property','Value',...) creates a new LAUNCHENDINDEX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before launchendindex_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to launchendindex_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help launchendindex

% Last Modified by GUIDE v2.5 14-Aug-2006 13:28:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @launchendindex_OpeningFcn, ...
                   'gui_OutputFcn',  @launchendindex_OutputFcn, ...
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


% --- Executes just before launchendindex is made visible.
function launchendindex_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to launchendindex (see VARARGIN)


%depthtempstring=load('selstring.mat');

inputdata=get(hObject,'UserData');
depthtempstring=inputdata(2);
set(handles.depthselection,'String',depthtempstring{1});
centervalue=inputdata(1);
set(handles.depthselection,'Value',centervalue{1});
minlist=centervalue{1}-16;
minlist=max(minlist,1);
set(handles.depthselection,'ListboxTop',minlist);
qflag=inputdata(3);
set(handles.flagselected,'String',qflag);
guidata(hObject,handles);


% Choose default command line output for launchendindex
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes launchendindex wait for user response (see UIRESUME)
 uiwait(handles.endindex);
 
% --- Outputs from this function are returned to the command line.
function varargout = launchendindex_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% Update handles structure
try
    handles = guidata(hObject);
catch
    handles=guidata(gcbo);
end

varargout{1} = handles.output;
uiresume(handles.endindex);
delete(handles.endindex);

% --- Executes on selection change in depthselection.
function depthselection_Callback(hObject, eventdata, handles)
% hObject    handle to depthselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns depthselection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from depthselection

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.output=get(handles.depthselection,'Value');

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end

% --- Executes during object creation, after setting all properties.
function depthselection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depthselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles=guidata(hObject);

    varargout{1} = handles.output;
    uiresume(handles.endindex);
%delete(handles.endindex)
 

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.output=-1;

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end

varargout{1} = handles.output;
    
uiresume(handles.endindex);

