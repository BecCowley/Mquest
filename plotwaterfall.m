%plotwaterfall - updates the waterfal plot and waterfall information
%
%plotwaterfall updates or plots only one profile in the waterfall window 
% (ss must be set to the profile you wish to update).  Call repeatedly to plot
% the entire waterfall window.  The current profile is plotted in
% red, profiles you have already examined are plotted in green and profiles
% not yet examined are blue.

%axes(handles.waterfall);

%saveguidata
            
clear filenam 
                
filenam=keysdata.prefix;

readbuddynetcdf

clear pp
jj=wprof;
pp=btemp+((jj-1)*3);  
                
isn=find(~isnan(btemp));

kkk=find(bqc(isn)<=2 | bqc(isn)==5);

if(twater(wprof)==handles.currentprofile)
    if(length(kkk)==1)
        wx=plot(handles.waterfall,pp(isn(kkk)),bdepth(isn(kkk)),'rx');
            set(wx,'LineWidth',12)
    end
   plot(handles.waterfall,pp(isn(kkk)),bdepth(isn(kkk)),'r-');
   set(handles.waterfalllist,'Value',wprof+1);
else
    if(twater(wprof)==handles.lastprofile)
    if(length(kkk)==1)
        wx=plot(handles.waterfall,pp(isn(kkk)),bdepth(isn(kkk)),'gx');
            set(wx,'LineWidth',12)
    end
       plot(handles.waterfall,pp(isn(kkk)),bdepth(isn(kkk)),'g-');
    else
    if(length(kkk)==1)
        wx=plot(pp(isn(kkk)),bdepth(isn(kkk)),'bx');
            set(wx,'LineWidth',12)
    end
       plot(handles.waterfall,pp(isn(kkk)),bdepth(isn(kkk)),'b-');
    end
end
   
hold on
axis ij
grid on
%drawnow

%axis([-2 35 -1000 0])
%set(handles.profile,'XLim',[-2 35]);
%set(handles.profile,'YLim',[0 1000]);
