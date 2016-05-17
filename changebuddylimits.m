%changebuddylimits
%when you want to readjust the buddy limits, this routine does all the
%necessary bookkeeping.
%
%you must first have set newbud to the new limit required:

        budregion=get(handles.buddyselection,'String');
        usebuddylimits=strmatch('user select',budregion);
        set(handles.buddyselection,'Value',usebuddylimits);
        set(handles.custombuddy,'String',num2str(newbud));
 