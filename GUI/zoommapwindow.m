%  zoom map window
%   This function activates the map window (handles.map), figures out
%   where you clicked, the zooms the window on that poitn so you can
%   find, for example, profiles on land...


        xlimit=[x-5 x+5];
        ylimit=[y-5 y+5];
        set(handles.map,'XLim',xlimit);
        set(handles.map,'YLim',ylimit);
