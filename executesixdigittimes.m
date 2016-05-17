% executesixdigittimes fix - this calls a gui that lets you select the
% cruise to be changed, then reads and writes the times from all selected
% profiles to add two digits to the database.


DECLAREGLOBALS

%launch gui to output data from this file to meds-ascii or new-reformat
%(plus others if there is a demand)

%retrieveguidata

callsignstring=get(handles.callsigns,'String');
centering=1;
sixdigittimes('UserData',{centering callsignstring});
