function changeMquestfonts(newfontsize,newfontname)
%  this is designed to change the Mquest fonts from their originals so they
%  are more easily read
% usage changeMquestfonts(newfontsize,[newfontname]) where
%       newfontsize is an integer, and
%       newfontname is an optional character string containing a valid font name

DECLAREGLOBALS

set(handles.callsigns,'FontSize',newfontsize);
set(handles.profilenumber,'FontSize',newfontsize);
set(handles.text7,'FontSize',newfontsize);
set(handles.uniqueid,'FontSize',newfontsize);
set(handles.text8,'FontSize',newfontsize);
set(handles.callsignsidentifier,'FontSize',newfontsize);
set(handles.scroll,'FontSize',newfontsize);
set(handles.repeat,'FontSize',newfontsize);
set(handles.importbutton,'FontSize',newfontsize);
set(handles.exportbutton,'FontSize',newfontsize);
%set(handles.waterheadings,'FontSize',newfontsize);
set(handles.custombuddy,'FontSize',newfontsize);
set(handles.exitbutton,'FontSize',newfontsize);
set(handles.buddyselection,'FontSize',newfontsize);
set(handles.goto,'FontSize',newfontsize);
set(handles.profile_info,'FontSize',newfontsize);
set(handles.waterfalllist,'FontSize',newfontsize);
set(handles.previous_profile,'FontSize',newfontsize);
set(handles.next_profile,'FontSize',newfontsize);
set(handles.rejectcodes,'FontSize',newfontsize);
set(handles.acceptcodes,'FontSize',newfontsize);
set(handles.depthdisplay,'FontSize',newfontsize);
handles.newfontsize=newfontsize;

if(nargin==2)
    set(handles.callsigns,'FontName',newfontname);
    set(handles.profilenumber,'FontName',newfontname);
    set(handles.text7,'FontName',newfontname);
    set(handles.callsignsidentifier,'FontName',newfontname); 
    set(handles.scroll,'FontName',newfontname);
    set(handles.repeat,'FontName',newfontname);
    set(handles.importbutton,'FontName',newfontname);
    set(handles.exportbutton,'FontName',newfontname);
    set(handles.waterheadings,'FontName',newfontname);
    set(handles.custombuddy,'FontName',newfontname);
    set(handles.exitbutton,'FontName',newfontname);
    set(handles.buddyselection,'FontName',newfontname);
    set(handles.goto,'FontName',newfontname);
    set(handles.profile_info,'FontName',newfontname);
    set(handles.waterfalllist,'FontName',newfontname);
    set(handles.previous_profile,'FontName',newfontname);
    set(handles.next_profile,'FontName',newfontname);
    set(handles.rejectcodes,'FontName',newfontname);
    set(handles.acceptcodes,'FontName',newfontname);
    set(handles.depthdisplay,'FontName',newfontname);
end  