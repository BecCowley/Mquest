%  medianfilter
%
%takes a temperature profile exhibiting high frequency noise nad filters it
%using a median filter of 25 points to smooth the data.  Note: original
%values are not retained and can only be retrieved by "kill"!!!

filttemp=pd.temp;
temptemp=filttemp;
s1=min(startpoint,endpoint);
s2=max(startpoint,endpoint);

for kk=s1:s2
    if(kk-25<1)
        start=1;
    else
        start=kk-25;
    end
    if(kk+25>pd.ndep)
        endjj=pd.ndep;
    else
        endjj=kk+25;
    end
    tt=filttemp(start:endjj);
    llk=find(tt<99);
    if(~isempty(llk))
        temptemp(kk)=median(tt(llk));
    else
        %retain original value
    end
end
%assign qc values to temp here as this is where the start and endpoints
%exist
pd.qc(s1:s2) = '5';
pd.qc(s2+1:end) = '2';
pd.temp=temptemp;
handles.pd=pd;
%saveguidata
