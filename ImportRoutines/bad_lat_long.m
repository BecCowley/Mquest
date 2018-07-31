function varargout = bad_lat_long(varargin)
% BAD_LAT_LONG M-file for bad_lat_long.fig
%      BAD_LAT_LONG, by itself, creates a new BAD_LAT_LONG or raises the existing
%      singleton*.
%
%      H = BAD_LAT_LONG returns the handle to a new BAD_LAT_LONG or the handle to
%      the existing singleton*.
%
%      BAD_LAT_LONG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BAD_LAT_LONG.M with the given input arguments.
%
%      BAD_LAT_LONG('Property','Value',...) creates a new BAD_LAT_LONG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bad_lat_long_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bad_lat_long_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bad_lat_long

% Last Modified by GUIDE v2.5 30-Oct-2007 10:37:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bad_lat_long_OpeningFcn, ...
                   'gui_OutputFcn',  @bad_lat_long_OutputFcn, ...
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


% --- Executes just before bad_lat_long is made visible.
function bad_lat_long_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bad_lat_long (see VARARGIN)

% Choose default command line output for bad_lat_long
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

inputdata=get(hObject,'UserData');

profiledata=inputdata{1};
inputfile=profiledata.datafile;
handles.profiledata=profiledata;
set(handles.origlat,'String',['original latitude: ' num2str(profiledata.latitude)]);
set(handles.origlong,'String',['original longitude: ' num2str(profiledata.longitude)]);

set(handles.newlat,'String',num2str(profiledata.latitude));
set(handles.newlong,'String',num2str(profiledata.longitude));
set(handles.datafile,'String',['Data file: ' inputfile]);

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end

% UIWAIT makes bad_lat_long wait for user response (see UIRESUME)
uiwait(handles.bad_lat_long);


% --- Outputs from this function are returned to the command line.
function varargout = bad_lat_long_OutputFcn(hObject, eventdata, handles) 
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

delete(handles.bad_lat_long);


function newlat_Callback(hObject, eventdata, handles)
% hObject    handle to newlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newlat as text
%        str2double(get(hObject,'String')) returns contents of newlat as a double


% --- Executes during object creation, after setting all properties.
function newlat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newlong_Callback(hObject, eventdata, handles)
% hObject    handle to newlong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newlong as text
%        str2double(get(hObject,'String')) returns contents of newlong as a double


% --- Executes during object creation, after setting all properties.
function newlong_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newlong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reject.
function reject_Callback(hObject, eventdata, handles)
% hObject    handle to reject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

profiledatan=[];
handles.output=profiledatan;
try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end

uiresume(handles.bad_lat_long)

% --- Executes on button press in returnchanges.
function returnchanges_Callback(hObject, eventdata, handles)
% hObject    handle to returnchanges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

pd=handles.profiledata;
nlong=str2num(get(handles.newlong,'String'));
nlat=str2num(get(handles.newlat,'String'));

if(nlat>90 | nlat <-90 | ...
      nlong<-360 | nlong>360)
  set(handles.errormsg,'Visible','on');
    return
end
pd.longitude=str2num(get(handles.newlong,'String'));
pd.latitude=str2num(get(handles.newlat,'String'));


profiledatan=pd;
handles.output=profiledatan;

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end
uiresume(handles.bad_lat_long)


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


