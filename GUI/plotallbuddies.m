function plotallbuddies
% plot all months when using single month option in Mquest
% for use when you need more buddies from all months


%declare handles as global:
global handles
persistent allbuddies

%put the existing buddies into a dummy variable:
budhold = handles.buddies;

%reload the buddies for all years, keep the variable for later use:
qc = {num2str(handles.qc)};
if isempty(allbuddies)    [allbuddies]=getbuddykeys({'All'},{'All'},handles.u,qc,handles.keys.prefix);  %retrieve the keys of the buddy profiles and hold in memory.
end
handles.buddies=allbuddies;       %save in the handles structure.

%replot:
axes(handles.profile);
cla(gca);
plotbuddies;
drawnow

%return the original buddies to the buddy structure:
handles.buddies=budhold;

%return to the main program:
return
end