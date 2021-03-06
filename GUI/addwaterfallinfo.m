%addwaterfallinfo - this script adds information on the profiles 
%  in the waterfall window to the listbox below waterfall plot 
%  so you can choose another plot from this list.  Keysdata (from "getkeys") 
%  must already exist and this can only be run in a gui environment
%  with a handles structure.
%
%  You must also have one variable:
%
%       twater - the profilenumber list of the profiles in the waterfall
%                   window.  These point to the position within the keysdata 
%                       structure that holds infomation about these profiles.  

%retrieveguidata

keysdata=handles.keys;

j=0;
waterstring{1}='#      callsign       lat        long           date            time';

    twater=handles.firstwaterprofile:min(length(keysdata.year),handles.firstwaterprofile+25);

for jk=1:length(twater)
%    waterstring{jk}='                                                  ';   
    j=j+1;
    dd=sprintf('%4.4i',keysdata.time(twater(jk)));
    cc='          ';
    kk=find(keysdata.callsign(twater(jk),:)==char(0));
    keysdata.callsign(twater(jk),kk)=' ';
    cc(1:length(keysdata.callsign(twater(jk),:)))=keysdata.callsign(twater(jk),:);
    lla=sprintf('%6.2f',keysdata.obslat(twater(jk)));
    llo=sprintf('%7.2f',keysdata.obslon(twater(jk)));
    waterdate=[' ' sprintf('%2.2i',keysdata.day(twater(jk))) '/' ...
        sprintf('%2.2i',keysdata.month(twater(jk))) '/' ...
        sprintf('%4.4i',keysdata.year(twater(jk))) '    ' dd];
    waterstring{jk+1}=[sprintf('%i',twater(jk)) '      ' cc(1:10) ' ' ...
        lla '   ' llo '   ' waterdate ' '];
   
end

set(handles.waterfalllist,'String',waterstring);
set(handles.waterfalllist,'fontname','courier')
