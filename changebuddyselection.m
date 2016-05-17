% take the usebuddylimits provided by getkeystroke and set the selection as
% required, then plot the new buddy window.

buddylimits=get(handles.buddyselection,'String');
handles.displaybuddy='Y';
handles.buddy=usebuddylimits;
if(usebuddylimits<=3)
    handles.buddylim=usebuddylimits;
else
    if(strmatch(buddylimits(usebuddylimits),'user select')>0)
        %get limits from edit box below buddy selection window...
        handles.buddylim=str2num(get(handles.custombuddy,'String'));
    elseif(strmatch(buddylimits(usebuddylimits),'max buddies')>0)
        %get limits from edit box below buddy selection window...
%do nothing - use the original buddy limits
        %        handles.buddylim=handles.nbds;
    else
        handles.buddylim=str2num(buddylimits{usebuddylimits}(1:3));
    end
 end
%try
%    guidata(hObject,handles);
%catch
%    guidata(gcbo,handles);
%end
%axes(handles.profile);
plotbuddies
