function varargout = selectuser(varargin)
% SELECTUSER M-file for selectuser.fig
%      SELECTUSER, by itself, creates a new SELECTUSER or raises the existing
%      singleton*.
%
%      H = SELECTUSER returns the handle to a new SELECTUSER or the handle to
%      the existing singleton*.
%
%      SELECTUSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTUSER.M with the given input arguments.
%
%      SELECTUSER('Property','Value',...) creates a new SELECTUSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectuser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectuser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help selectuser

% Last Modified by GUIDE v2.5 30-Aug-2006 11:46:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selectuser_OpeningFcn, ...
                   'gui_OutputFcn',  @selectuser_OutputFcn, ...
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


% --- Executes just before selectuser is made visible.
function selectuser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectuser (see VARARGIN)

% Choose default command line output for selectuser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectuser wait for user response (see UIRESUME)
% uiwait(handles.selectuser);

%get the user information and preferences here and allow editing if
%required.


%set up month and time menus:
twstring{1}='all months';
twstring{2}='single month';
twstring{3}='month +/1 15 days';

set(handles.timewindow,'String',twstring);

ms='JanFebMarAprMayJunJulAugSepOctNovDecAll';
j=1;
for i=1:13
    month{i}=ms(j:j+2);
    j=j+3;
end
set(handles.Month,'String',month);   

if nargin<6
    errordlg('too few input arguments - rerun');
    quit;
else
    userno=varargin{2};
    users=varargin{4};
    users;
    a=varargin{14};
    b=varargin{16};
    c=varargin{6};
    set(handles.user_name,'String',users);
    set(handles.user_name,'Value',userno);
    set(handles.database_prefix,'String',c{userno});
    set(handles.Month,'Value',strmatch(varargin{8}{userno},month,'exact'));
    set(handles.Year,'String',varargin{10}{userno});
    set(handles.subsetbyQC,'Value',str2num(varargin{12}{userno}));
    set(handles.AutoQConly,'Value',str2num(a{userno}));
    set(handles.timewindow,'Value',str2num(b{userno}));
    sstyle=varargin{18};
    showauto=varargin{20};
    if(strmatch(sstyle{userno},'lat','exact'));
        set(handles.sortstylelatitude,'Value',1);
    elseif(strmatch(sstyle{userno},'ship','exact'));
        set(handles.sortstyleship,'Value',1);
    end
    if(showauto)
        set(handles.text6,'Visible','on');
        set(handles.text5,'Visible','on');
        set(handles.subsetbyQC,'Visible','on');
        set(handles.AutoQConly,'Visible','on');
    end
end

clear u
    userno=get(handles.user_name,'Value');
    user=get(handles.user_name,'String');
    u=user(userno);
buddydata=[u{1} 'buddies.txt'];

clear buddyd
try
    [buddydatalist]=textread(buddydata,'%s');
catch
    buddydatalist=[];
end

for i=1:length(buddydatalist)
    buddyd{i+2}=buddydatalist{i};
end
%:length(buddydata)+2}=buddydatalist
buddyd{1}=get(handles.buddydata,'String');
bp=get(handles.database_prefix,'String');
%whos b*;
buddyd{2}=bp;
set (handles.buddydata,'String',buddyd);

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = selectuser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function User_Callback(hObject, eventdata, handles)
% hObject    handle to User (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of User as text
%        str2double(get(hObject,'String')) returns contents of User as a double


% --- Executes during object creation, after setting all properties.
function User_CreateFcn(hObject, eventdata, handles)
% hObject    handle to User (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function database_prefix_Callback(hObject, eventdata, handles)
% hObject    handle to database_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of database_prefix as text
%        str2double(get(hObject,'String')) returns contents of database_prefix as a double

try
    handles=guidata(gcbo);
catch
    handles=guidata(hObject);
end

        bd=get(handles.buddydata,'String');
        whos bd;
        bd{2}=get(handles.database_prefix,'String');
        set(handles.buddydata,'String',bd);
        guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function database_prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to database_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Month_Callback(hObject, eventdata, handles)
% hObject    handle to Month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Month as text
%        str2double(get(hObject,'String')) returns contents of Month as a double

if(get(handles.Month,'Value')==13)
    set(handles.timewindow,'Value',1);
elseif(get(handles.timewindow,'Value')==1)
    set(handles.timewindow,'Value',2)
end

% --- Executes during object creation, after setting all properties.
function Month_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Month (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Year_Callback(hObject, eventdata, handles)
% hObject    handle to Year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Year as text
%        str2double(get(hObject,'String')) returns contents of Year as a double


% --- Executes during object creation, after setting all properties.
function Year_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Year (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in user_name.
function user_name_Callback(hObject, eventdata, handles)
% hObject    handle to user_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns user_name contents as cell array
%        contents{get(hObject,'Value')} returns selected item from user_name


u=get(handles.user_name,'String');
uval=get(handles.user_name,'Value');
username=u(uval);
[user,prefix,mm,yy,qc,auto,timewindow,sstyle]=textread('usersettings.txt','%s%s%s%s%s%s%s%s');

getuser=strmatch(username,user,'exact');
newuser=0;
if(isempty(getuser))
    newuser=length(user)+1;
end

if(newuser==length(user)+1)
    
    user{newuser}=username
    prefix{newuser}='unknown';
    mm{newuser}='All';
    yy{newuser}='All';
    qc{newuser}='1';
    auto{newuser}='1';
    timewindow{newuser}='1';
    sstyle{newuser}='ship';
end    

getuser=strmatch(username,user,'exact');
uval=getuser;

    set(handles.database_prefix,'String',prefix{uval});
    mstr=get(handles.Month,'String');
%    vstr=strmatch(mstr,mm{uval});
    set(handles.Month,'Value',strmatch(mm{uval},mstr,'exact'));
%    set(handles.Month,'Value',vstr);
    set(handles.Year,'String',yy{uval});
    set(handles.subsetbyQC,'Value',str2num(qc{uval}));
    set(handles.AutoQConly,'Value',str2num(auto{uval}));
    set(handles.timewindow,'Value',str2num(timewindow{uval}));
    if(strmatch(sstyle{uval},'lat','exact'));
        set(handles.sortstylelatitude,'Value',1);
    elseif(strmatch(sstyle{uval},'ship','exact'));
        set(handles.sortstyleship,'Value',1);
    end
clear tw
tw=get(handles.timewindow,'Value');

buddydata=[username{1} 'buddies.txt'];

try
    [buddydatalist]=textread(buddydata,'%s');
catch
    buddydatalist=[];
end

for i=1:length(buddydatalist)
    buddyd{i+2}=buddydatalist{i};
end

b=get(handles.buddydata,'String');
bp=get(handles.database_prefix,'String');
whos b*;
buddyd{2}=bp;
set (handles.buddydata,'String',buddyd);
buddyd{1}=b{1};


% --- Executes during object creation, after setting all properties.
function user_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to user_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AutoQConly.
function AutoQConly_Callback(hObject, eventdata, handles)
% hObject    handle to AutoQConly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoQConly


% --- Executes during object creation, after setting all properties.
function AutoQConly_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AutoQConly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function database_directory_Callback(hObject, eventdata, handles)
% hObject    handle to database_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of database_directory as text
%        str2double(get(hObject,'String')) returns contents of database_directory as a double


% --- Executes during object creation, after setting all properties.
function database_directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to database_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in launch_quest.
function launch_quest_Callback(hObject, eventdata, handles)
% hObject    handle to launch_quest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[user,prefix,mm,yy,qc,auto,timewindow,sortstyle]=textread('usersettings.txt','%s%s%s%s%s%s%s%s');

    userno=get(handles.user_name,'Value');
    user=get(handles.user_name,'String');
    prefix{userno}=get(handles.database_prefix,'String');
    if(strmatch(prefix{userno},'unknown'))
        errordlg('please specify database')
        return
    end
    mmm=get(handles.Month,'String');
    m1=get(handles.Month,'Value');
    mm{userno}=mmm{m1};
    yy{userno}=get(handles.Year,'String');
    qc{userno}=num2str(get(handles.subsetbyQC,'Value'));
    auto{userno}=num2str(get(handles.AutoQConly,'Value'));
%    t=get(handles.timewindow,'String');
    timewindow{userno}=num2str(get(handles.timewindow,'Value'));
    if(get(handles.sortstylelatitude,'Value'));
        sortstyle{userno}='lat';
    elseif(get(handles.sortstyleship,'Value'));
        sortstyle{userno}='ship';
    else
        sortstyle{userno}='none';
    end
%getkeys and then call QuotaQuest...

u=user(userno);
p=prefix(userno);
m=mm(userno);
y=yy(userno);
q=qc(userno);
a=auto(userno);
tw=timewindow(userno);
sstyle=sortstyle(userno);
save selectuser.mat userno u p m y q a tw sstyle;

saveuserinfo;

delete(handles.selectuser);

QuotaQuest;

function timewindow_Callback(hObject, eventdata, handles)
% hObject    handle to timewindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timewindow as text
%        str2double(get(hObject,'String')) returns contents of timewindow as a double

if(get(handles.timewindow,'Value')==1)
    set(handles.Month,'Value',13);
end

% --- Executes during object creation, after setting all properties.
function timewindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timewindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%    set(hObject,'BackgroundColor','white');
%end



function buddydata_Callback(hObject, eventdata, handles)
% hObject    handle to buddydata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of buddydata as text
%        str2double(get(hObject,'String')) returns contents of buddydata as a double

if(get(hObject,'Value')==1)

    clear newbuddy;
    handles.buddypath=pwd;
saveguidata
    choosebuddyfiles;
    load addedbuddy.mat;
    newbuddy2=newbuddy;
    if(~isempty(newbuddy))
      ll=strmatch(newbuddy,' ');
      if(~isempty(ll));
        newbuddy(ll)='_';
      end
        bd=get(handles.buddydata,'String');
        whos bd;
        whos newbuddy;
        bd{length(bd)+1}=newbuddy;
        set(handles.buddydata,'String',bd);
        guidata(hObject,handles);

%use the user name to get the buddies now...
    userno=get(handles.user_name,'Value');
    user=get(handles.user_name,'String');
    u=user(userno);

        fid=fopen([u{1} 'buddies.txt'],'w');

        bd=get(handles.buddydata,'String');
        whos bd;
        for i=3:length(bd)
            fprintf(fid,'%s \r\n',bd{i});
        end
        fclose(fid); 
    end

else
    
    tobedel=get(hObject,'Value');
    if(tobedel<3)
        errordlg('error - you must not delete the current database')
        return
    end
    bd=get(handles.buddydata,'String');

% Get the current position of the GUI from the handles structure
% to pass to the modal dialog.
    pos_size = get(handles.selectuser,'Position');
% Call modaldlg with the argument 'Position'.

    user_response = modaldlg('unused','nonsense','Title',...
        'Confirm removal of this buddy','String',bd{tobedel});
    switch user_response
    case {'No'}
        % take no action
    case 'Yes'
        
    for i=1:tobedel-1
        bdnew{i}=bd{i};
    end
    for i=tobedel:length(bd)-1;
        bdnew{i}=bd{i+1};
    end
    
    set(handles.buddydata,'String',bdnew);
    set(handles.buddydata,'Value',tobedel-1);
    guidata(hObject,handles);
    
%save the new buddy list for this version
%        bdata=get(handles.user,'String');
    userno=get(handles.user_name,'Value');
    user=get(handles.user_name,'String');
    u=user(userno);
        fid=fopen([u{1} 'buddies.txt'],'w');

        bd=get(handles.buddydata,'String');
        whos bd;
        for i=3:length(bd)
            fprintf(fid,'%s \r\n',bd{i});
        end
        fclose(fid); 
     
    end
end
% --- Executes during object creation, after setting all properties.
function buddydata_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buddydata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exit_no_changes.
function exit_no_changes_Callback(hObject, eventdata, handles)
% hObject    handle to exit_no_changes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current position of the GUI from the handles structure
% to pass to the modal dialog.
pos_size = get(handles.selectuser,'Position');
% Call modaldlg with the argument 'Position'.
user_response = modaldlg('Title','Confirm Close');
switch user_response
case {'No'}
    % take no action
case 'Yes'
    % Prepare to close GUI application window
    %                  .
    %                  .
    %                  .
    delete(handles.selectuser);
end


% --- Executes on key press over launch_quest with no controls selected.
function launch_quest_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to launch_quest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in sortstyleship.
function sortstyleship_Callback(hObject, eventdata, handles)
% hObject    handle to sortstyleship (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sortstyleship

sortstyle=get(hObject,'Value');
if(sortstyle)
    handles.sortstyle='ship';
    set(handles.sortstylelatitude,'Value',0);
else
    handles.sortstyle='none';
end
saveguidata



% --- Executes on button press in sortstylelatitude.
function sortstylelatitude_Callback(hObject, eventdata, handles)
% hObject    handle to sortstylelatitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sortstylelatitude

sortstyle=get(hObject,'Value');
if(sortstyle)
    handles.sortstyle='lat';
    set(handles.sortstyleship,'Value',0);
else
    handles.sortstyle='none';
end
saveguidata



% --- Executes on selection change in subsetbyQC.
function subsetbyQC_Callback(hObject, eventdata, handles)
% hObject    handle to subsetbyQC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns subsetbyQC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subsetbyQC




% --- Executes during object creation, after setting all properties.
function subsetbyQC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subsetbyQC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


