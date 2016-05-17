function varargout = changeposition(varargin)
% CHANGEPOSITION M-file for changeposition.fig
%      CHANGEPOSITION, by itself, creates a new CHANGEPOSITION or raises the existing
%      singleton*.
%
%      H = CHANGEPOSITION returns the handle to a new CHANGEPOSITION or the handle to
%      the existing singleton*.
%
%      CHANGEPOSITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANGEPOSITION.M with the given input arguments.
%
%      CHANGEPOSITION('Property','Value',...) creates a new CHANGEPOSITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before changeposition_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to changeposition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help changeposition

% Last Modified by GUIDE v2.5 25-May-2006 10:12:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @changeposition_OpeningFcn, ...
                   'gui_OutputFcn',  @changeposition_OutputFcn, ...
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


% --- Executes just before changeposition is made visible.
function changeposition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to changeposition (see VARARGIN)

% Choose default command line output for changeposition
handles.output = hObject;

inputdata=get(hObject,'UserData');
handles.origlat=inputdata(1);
handles.origlon=inputdata(2);

set(handles.latitude,'String',num2str(handles.origlat));
set(handles.longitude,'String',num2str(handles.origlon));
set(handles.titlelat,'String',['Latitude:' num2str(handles.origlat)]);
set(handles.titlelong,'String',['Longitude:' num2str(handles.origlon)]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes changeposition wait for user response (see UIRESUME)
uiwait(handles.changeposition);


% --- Outputs from this function are returned to the command line.
function varargout = changeposition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

try
    handles=guidata(hObject);
catch
    handles=guidata(gcbo);
end

varargout{1} = handles.output;


delete(handles.changeposition);

function latitude_Callback(hObject, eventdata, handles)
% hObject    handle to latitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of latitude as text
%        str2double(get(hObject,'String')) returns contents of latitude as a double


% --- Executes during object creation, after setting all properties.
function latitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in finished.
function finished_Callback(hObject, eventdata, handles)
% hObject    handle to finished (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    handles=guidata(hObject);
catch
    handles=guidata(gcbo);
end

newlat=str2num(get(handles.latitude,'String'));
newlon=str2num(get(handles.longitude,'String'));

h=[];
%if(newlat~=handles.origlat)
    output.origlat=handles.origlat;
    output.newlat=newlat;
    output.parmlat='LATI';
%end

%if(newlon~=handles.origlon)
    output.origlon=handles.origlon;
    output.newlon=newlon; 
    output.parmlon='LONG';
%end

handles.output=output;

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end
uiresume(handles.changeposition);

function longitude_Callback(hObject, eventdata, handles)
% hObject    handle to longitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of longitude as text
%        str2double(get(hObject,'String')) returns contents of longitude as a double


% --- Executes during object creation, after setting all properties.
function longitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to longitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


