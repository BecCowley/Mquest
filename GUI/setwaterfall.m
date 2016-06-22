%setwaterfall - 
%
%setwaterfall determines whether the entire waterfall needs to be adjusted
%   as you move through the database and then calls the relevant routines to
%   update all waterfall windows.
%

%retrieveguidata
  
%
hfp=handles.firstwaterprofile;
hcp=handles.currentprofile;
if(abs(hcp-hfp)>24 | hcp==1 | hcp<handles.firstwaterprofile)
  
    clear twater
    axes(handles.waterfall);
    cla;
    
    k=max(1,hcp-5);
    handles.firstwaterprofile=k;
%saveguidata
twater=handles.firstwaterprofile:min(length(keysdata.year),handles.firstwaterprofile+25);
    
    if(k+24>length(keysdata.stnnum));
        kk=length(keysdata.stnnum);
        twater=handles.firstwaterprofile:kk;
    else
        kk=k+25;
    end

    addwaterfallinfo
 
    for wprof=1:length(twater)
        ss=keysdata.stnnum(twater(wprof));  
        plotwaterfall;
    end

%saveguidata 
else

  if(handles.updateall)
    twater=handles.firstwaterprofile:handles.firstwaterprofile+25;

        hold on
    wprof=find(twater==handles.lastprofile);
    if(~isempty(wprof))
        ss=keysdata.stnnum(handles.lastprofile);   %keysdata.stnnum(handles.nextprofile)
        plotwaterfall;
    end
    wprof=find(twater==handles.currentprofile);
    if(~isempty(wprof))
        ss=keysdata.stnnum(twater(wprof));   %keysdata.stnnum(handles.nextprofile)
        plotwaterfall;
    else
        
    end
  end
end
try
    wlim=(ceil(profiledata.depth(profiledata.ndep)/100)*100)+100;
    set(handles.waterfall,'Ylim',[0 wlim(1)]);
catch
    set(handles.waterfall,'Ylim',[1 1000]);
end
%saveguidata