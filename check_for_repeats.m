% check_for_repeats
% 
%   "check_for_repeats"  examines the previous and next profiles 
%   to determine if they are within 15 minutes of the current profile. 
%   If so, it displays and alert at the bottom of the profile window.
%
%   it also checks speed if the ship callsigns are identical AND 
%   they have been sorted by callsign/date/time and displays
%   alert if the speed is faster than 25 knots.
%
%   The script requires the keysdata structure

set(handles.speed,'visible','off');

            t1=sprintf('%4.4i',keysdata.time(handles.currentprofile));
            if(handles.currentprofile>1)
                t3=sprintf('%4.4i',keysdata.time(handles.currentprofile-1));
                d3=julian([keysdata.year(handles.currentprofile-1) keysdata.month(handles.currentprofile-1) ...
                  keysdata.day(handles.currentprofile-1)  str2num(t3(1:2)) str2num(t3(3:4)) 0]);
            else
                d3=0;
            end
            if(handles.currentprofile<length(keysdata.stnnum))
                t2=sprintf('%4.4i',keysdata.time(handles.currentprofile+1));
                d2=julian([keysdata.year(handles.currentprofile+1) keysdata.month(handles.currentprofile+1) ...
                  keysdata.day(handles.currentprofile+1)  str2num(t2(1:2)) str2num(t2(3:4)) 0]);
            else
                d2=0;
            end
            d1=julian([keysdata.year(handles.currentprofile) keysdata.month(handles.currentprofile) ...
               keysdata.day(handles.currentprofile)  str2num(t1(1:2)) str2num(t1(3:4)) 0]);
            
            if(abs(d1-d2)<=.0104167 | abs(d1-d3)<=.0104167);
%CS: using sound loses connection & quest run SLOW 
%CS: soundsc(-1:0.1:1,8000)  
%CS: make a warning visible when the profile is a repeat 
               set(handles.repeat,'visible','on');
            else
                set(handles.repeat,'visible','off');
            end


%now check speed if relevant:

if(strmatch(handles.sstyle,'ship','exact'))          
    if(handles.currentprofile>1 & ...
keysdata.callsign(handles.currentprofile)==keysdata.callsign(handles.currentprofile-1))
      ii=handles.currentprofile;
      jj=ii-1;
        kti=fix(keysdata.time(ii)/100)+(mod(keysdata.time(ii),100)/60);
        ktj=fix(keysdata.time(jj)/100)+(mod(keysdata.time(jj),100)/60);

[dist,ang]=sw_dist([keysdata.obslat(ii),keysdata.obslat(jj)],[keysdata.obslon(ii),keysdata.obslon(jj)]);
      jii=julian(keysdata.year(ii),keysdata.month(ii),keysdata.day(ii),kti );
      jjj=julian(keysdata.year(jj),keysdata.month(jj),keysdata.day(jj),ktj );
 speed=dist/(abs(jii-jjj)*24);
       if(speed>25.)
           set(handles.speed,'visible','on');
            set(handles.speed,'String',['EXCESSIVE SPEED!  ' num2str(speed)]);
       else
           set(handles.speed,'visible','off');
       end
    end
end