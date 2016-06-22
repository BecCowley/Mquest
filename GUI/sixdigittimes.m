function varargout = sixdigittimes(varargin)
% SIXDIGITTIMES M-file for sixdigittimes.fig
%      SIXDIGITTIMES, by itself, creates a new SIXDIGITTIMES or raises the existing
%      singleton*.
%
%      H = SIXDIGITTIMES returns the handle to a new SIXDIGITTIMES or the handle to
%      the existing singleton*.
%
%      SIXDIGITTIMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIXDIGITTIMES.M with the given input arguments.
%       
%       Example:
%        callsignstring=get(handles.callsigns,'String'); - a list of the
%                   callsigns in the database
%   or: callsignstring='FHZI';
%       centering=1;
%       
%       sixdigittimes('UserData',{centering callsignstring});
%
%       it reads "selectuser.mat" to get all other variables...
%
%      SIXDIGITTIMES('Property','Value',...) creates a new SIXDIGITTIMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sixdigittimes_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sixdigittimes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help sixdigittimes

% Last Modified by GUIDE v2.5 20-Nov-2006 15:23:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sixdigittimes_OpeningFcn, ...
                   'gui_OutputFcn',  @sixdigittimes_OutputFcn, ...
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


% --- Executes just before sixdigittimes is made visible.
function sixdigittimes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sixdigittimes (see VARARGIN)

inputdata=get(hObject,'UserData');
callsignstring=inputdata(2);
set(handles.callsigns,'String',callsignstring);
centervalue=inputdata(1);
set(handles.callsigns,'Value',centervalue{1});
set(handles.callsigns,'ListboxTop',1);
set(handles.startdate,'String','00000000');
set(handles.enddate,'String','99999999');
handles.startdate='00000000';
handles.enddate='99999999';

load selectuser;
u=u ;
p=p ;
m={'All'} ;
y={'All'} ;
q=q ;
a=a; 
tw={1};
sstyle={'ship'};
handles.first=1;

[keysdata2]=getkeys(p,m,y,q,a,tw,sstyle);
handles.keys2=keysdata2;

% Choose default command line output for sixdigittimes
handles.output = -1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sixdigittimes wait for user response (see UIRESUME)
% uiwait(gcf);


% --- Outputs from this function are returned to the command line.
function varargout = sixdigittimes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in callsigns.
function callsigns_Callback(hObject, eventdata, handles)
% hObject    handle to callsigns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns callsigns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from callsigns

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

callslist=get(handles.callsigns,'String');
callsselected=get(handles.callsigns,'Value');
handles.selectedcallsign=callslist(callsselected);

try
    guidata(hObject, handles);
catch
    guidata(gcbo, handles);
end

% --- Executes during object creation, after setting all properties.
function callsigns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to callsigns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startdate_Callback(hObject, eventdata, handles)
% hObject    handle to startdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startdate as text
%        str2double(get(hObject,'String')) returns contents of startdate as a double

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.startdate=get(hObject,'String');
if(length(handles.startdate)<8)
    errordlg(['error = you must enter 8 characters for the start date'])
end
try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function startdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enddate_Callback(hObject, eventdata, handles)
% hObject    handle to enddate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enddate as text
%        str2double(get(hObject,'String')) returns contents of enddate as a double

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

handles.enddate=get(hObject,'String');
if(length(handles.enddate)<8)
    errordlg(['error = you must enter 8 characters for the end date'])
end

try
    guidata(gcbo,handles);
catch
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function enddate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enddate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in beginfix.
function beginfix_Callback(hObject, eventdata, handles)
% hObject    handle to beginfix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%here is where the hard work is done...
%try to get all thevalues here and not in the individual callbacks:


try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

keysdata2=handles.keys2;
%setup date structure for the callsignsubset required:
handles.keys=handles.keys2;
callslist=get(handles.callsigns,'String');
callsselected=get(handles.callsigns,'Value');
selectedcallsign=callslist(callsselected);

subsetkeys=strmatch(selectedcallsign,keysdata2.callsign);
if(~isempty(subsetkeys))
    %create data structure:
    %for i=1:length(subsetkeys)
realdate=(keysdata2.year(subsetkeys)*10000)+(keysdata2.month(subsetkeys)*100)+(keysdata2.day(subsetkeys));
   
end
reversestartdate=reorderdate(handles.startdate);
   targetstart=str2num(reversestartdate);
   reverseenddate=reorderdate(handles.enddate);
   targetend=str2num(reverseenddate);
  
   kk2=find(realdate<=targetend & realdate>=targetstart);
   if(~isempty(kk2))
       for i=1:length(kk2)
         ss=keysdata2.stnnum(subsetkeys(kk2(i)),:);
         writekeys=0;
        rawfile=0;
         readnetcdf
    tt=getnc(filenam,'woce_time');
    tt=tt*100;
    nc=netcdf(filenam,'write');
    nc{'woce_time'}(:)=tt;
    close(nc)
    rawfile=1;
    readnetcdf
    nc=netcdf(filenam,'write');
    nc{'woce_time'}(:)=tt;
    close(nc)
         if(handles.first)
             handles.first=0;
             try
                 guidata(gcbo,handles);
             catch
                 guidata(hObject,handles);
             end
         end
       end
   end
   
delete(handles.sixdigittimes);
return


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


delete(handles.sixdigittimes);
return


% --- Executes on key press over beginfix with no controls selected.
function beginfix_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to beginfix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


