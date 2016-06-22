%Reads the selected callsign from the pulldown menu and displays the first
%profile from the new ship. It resets all the associated windows to reflect
%the new profile.

%retrieveguidata

keysdata=handles.keys;
        
handles.lastprofile=handles.currentprofile;

callsignlist=get(handles.callsigns,'String');
callsignselection=get(handles.callsigns,'Value');

requiredcallsign=callsignlist(callsignselection,:);

kk=strmatch(requiredcallsign,keysdata.callsign);

if(isempty(kk));return;end

handles.currentprofile=kk(1);
           
handles.profilefocus=500.; %this is the default...
            
%check to see if is repeat and display alert if true:
check_for_repeats

plotnewprofile
            
updatemap;
