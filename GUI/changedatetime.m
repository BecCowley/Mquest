function varargout = changedatetime(varargin)
% CHANGEDATETIME M-file for changedatetime.fig
%      CHANGEDATETIME, by itself, creates a new CHANGEDATETIME or raises the existing
%      singleton*.
%
%      H = CHANGEDATETIME returns the handle to a new CHANGEDATETIME or the handle to
%      the existing singleton*.
%
%      CHANGEDATETIME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANGEDATETIME.M with the given input arguments.
%
%      CHANGEDATETIME('Property','Value',...) creates a new CHANGEDATETIME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before changedatetime_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to changedatetime_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help changedatetime

% Last Modified by GUIDE v2.5 26-May-2006 12:23:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @changedatetime_OpeningFcn, ...
                   'gui_OutputFcn',  @changedatetime_OutputFcn, ...
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


% --- Executes just before changedatetime is made visible.
function changedatetime_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to changedatetime (see VARARGIN)

% Choose default command line output for changedatetime
handles.output = hObject;
inputdata=get(hObject,'UserData');
handles.origtime=inputdata(9:end);
handles.origdate=inputdata(7:8);
handles.origmonth=inputdata(5:6);
handles.origyear=inputdata(1:4);

set(handles.year,'String',handles.origyear);
set(handles.month,'String',handles.origmonth);
set(handles.day,'String',handles.origdate);
set(handles.time,'String',handles.origtime);
set(handles.titleyear,'String',['Year:' handles.origyear]);
set(handles.titlemonth,'String',['Month:' handles.origmonth]);
set(handles.titleday,'String',['Day:' handles.origdate]);
set(handles.titletime,'String',['time:' handles.origtime]);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes changedatetime wait for user response (see UIRESUME)
 uiwait(handles.changedatetime);


% --- Outputs from this function are returned to the command line.
function varargout = changedatetime_OutputFcn(hObject, eventdata, handles) 
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

delete(handles.changedatetime);

function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time as text
%        str2double(get(hObject,'String')) returns contents of time as a double


% --- Executes during object creation, after setting all properties.
function time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function month_Callback(hObject, eventdata, handles)
% hObject    handle to month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of month as text
%        str2double(get(hObject,'String')) returns contents of month as a double


% --- Executes during object creation, after setting all properties.
function month_CreateFcn(hObject, eventdata, handles)
% hObject    handle to month (see GCBO)
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

newdate=get(handles.day,'String');
if(length(newdate)<2)
    newdate(2)=newdate(1);
    newdate(1)='0';
end

newmonth=get(handles.month,'String');
if(length(newmonth)<2)
    newmonth(2)=newmonth(1);
    newmonth(1)='0';
end
newyear=get(handles.year,'String');
newtime=get(handles.time,'String');
blk = '0';
nblk = 5-length(newtime);
for j = 1:nblk; newtime=[blk newtime]; end

h=[];

    output.origyear=handles.origyear;
    output.newyear=newyear;

    output.origmonth=handles.origmonth;
    output.newmonth=newmonth; 
    
    output.origdate=handles.origdate;
    output.newdate=newdate; 

    output.origtime=handles.origtime;
    output.newtime=newtime; 

handles.output=output;

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end
uiresume(handles.changedatetime);


function year_Callback(hObject, eventdata, handles)
% hObject    handle to year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of year as text
%        str2double(get(hObject,'String')) returns contents of year as a double


% --- Executes during object creation, after setting all properties.
function year_CreateFcn(hObject, eventdata, handles)
% hObject    handle to year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function day_Callback(hObject, eventdata, handles)
% hObject    handle to year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of year as text
%        str2double(get(hObject,'String')) returns contents of year as a double


% --- Executes during object creation, after setting all properties.
function day_CreateFcn(hObject, eventdata, handles)
% hObject    handle to day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


