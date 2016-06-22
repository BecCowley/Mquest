function varargout = listboxexample(varargin)
% LISTBOXEXAMPLE M-file for listboxexample.fig
%      LISTBOXEXAMPLE, by itself, creates a new LISTBOXEXAMPLE or raises the existing
%      singleton*.
%
%      H = LISTBOXEXAMPLE returns the handle to a new LISTBOXEXAMPLE or the handle to
%      the existing singleton*.
%
%      LISTBOXEXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LISTBOXEXAMPLE.M with the given input arguments.
%
%      LISTBOXEXAMPLE('Property','Value',...) creates a new LISTBOXEXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before listboxexample_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to listboxexample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help listboxexample

% Last Modified by GUIDE v2.5 14-Sep-2006 12:48:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @listboxexample_OpeningFcn, ...
                   'gui_OutputFcn',  @listboxexample_OutputFcn, ...
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


% --- Executes just before listboxexample is made visible.
function listboxexample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to listboxexample (see VARARGIN)

% Choose default command line output for listboxexample
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes listboxexample wait for user response (see UIRESUME)
% uiwait(handles.figure1);

for i=1:20
listforbox{i}=[num2str(i)];
end

set(handles.listbox1,'String',listforbox)
set(handles.listbox1,'Value',1)

updatelinenumber


guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = listboxexample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

handles=guidata(gcbo);

cklinenumber=get(handles.listbox1,'Value')

updatelinenumber

newline=get(handles.listbox1,'Value')

guidata(gcbo,handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function linenumber_Callback(hObject, eventdata, handles)
% hObject    handle to linenumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linenumber as text
%        str2double(get(hObject,'String')) returns contents of linenumber as a double

handles=guidate(gcbo);
newline=str2num(get(handles.linenumber,'String'))
set(handles.listbox1,'Value',newline);

% --- Executes during object creation, after setting all properties.
function linenumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linenumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


