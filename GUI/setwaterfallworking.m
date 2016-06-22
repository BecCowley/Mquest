axes(handles.waterfall)

k=max(1,i-25);
if(k+25>length(keysdata.stnnum));
    kk=length(keysdata.stnnum)
else
    kk=k+25;
end
for wprof=k:kk
    ss=keysdata.stnnum(wprof);   %keysdata.stnnum(handles.nextprofile)
    plotwaterfall
end

