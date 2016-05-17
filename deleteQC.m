function varargout = deleteQC(varargin)
% DELETEQC M-file for deleteQC.fig
%      DELETEQC, by itself, creates a new DELETEQC or raises the existing
%      singleton*.
%
%      H = DELETEQC returns the handle to a new DELETEQC or the handle to
%      the existing singleton*.
%
%      DELETEQC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DELETEQC.M with the given input arguments.
%
%      DELETEQC('Property','Value',...) creates a new DELETEQC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before deleteQC_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to deleteQC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% this displays a box of QC flags and depths so you can pick one to delete
% if necessary

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help deleteQC

% Last Modified by GUIDE v2.5 23-Mar-2006 09:07:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @deleteQC_OpeningFcn, ...
                   'gui_OutputFcn',  @deleteQC_OutputFcn, ...
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


% --- Executes just before deleteQC is made visible.
function deleteQC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to deleteQC (see VARARGIN)

inputdata=get(hObject,'UserData');
depthQCstring=inputdata(2);
set(handles.deleteQC,'String',depthQCstring{1});
centervalue=inputdata(1);
set(handles.deleteQC,'Value',centervalue{1});
minlist=centervalue{1}-16;
minlist=max(minlist,1);
set(handles.deleteQC,'ListboxTop',minlist);
if(inputdata{3})
    set(handles.returntoquest,'Visible','off')
else
    set(handles.returntoquest,'Visible','on')
end
guidata(hObject,handles);

% Choose default command line output for launchendindex
handles.output = -1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes deleteQC wait for user response (see UIRESUME)
 uiwait(handles.finddeletionpoint);


% --- Outputs from this function are returned to the command line.
function varargout = deleteQC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles = guidata(hObject);
catch
    handles=guidata(gcbo);
end

varargout{1} = handles.output;
uiresume(handles.finddeletionpoint);
delete(handles.finddeletionpoint);


% --- Executes on selection change in deleteQC.
function deleteQC_Callback(hObject, eventdata, handles)
% hObject    handle to deleteQC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns deleteQC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from deleteQC

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.output=get(handles.deleteQC,'Value');

try
    guidata(hObject,handles);
catch
    guidata(gcbo,handles);
end

% --- Executes during object creation, after setting all properties.
function deleteQC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deleteQC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in returntoquest.
function returntoquest_Callback(hObject, eventdata, handles)
% hObject    handle to returntoquest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    handles=guidata(hObject);

    varargout{1} = handles.output;
    uiresume(handles.finddeletionpoint);



% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    handles=guidata(hObject);
    handles.output=-1;
    varargout(1)=handles.output;
    guidata(gcbo,handles);
    uiresume(handles.finddeletionpoint);

  


% --- Executes when finddeletionpoint is resized.
function finddeletionpoint_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to finddeletionpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


