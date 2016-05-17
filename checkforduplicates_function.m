function [profiledata,uniqueid]=checkforduplicates(keysdata,profiledata,uniqueid,whattodo,alreadychecked)

%check for duplicates to existing database:
%CS: turned script into a function
%CS: called by inputMA.m and inputDEVIL.m

kk=find(keysdata.time==profiledata.time & keysdata.year==profiledata.year &...
        keysdata.day==profiledata.day & keysdata.month==profiledata.month...
        & keysdata.obslat==single(profiledata.lat) & keysdata.obslon==single(profiledata.lon));

format long g
    
if(~isempty(kk))
        %this might be a duplicate profile -
        %ask what you want to do with it...
    if(~alreadychecked)
        alreadychecked=1;
        keysd=[keysdata.year(kk) keysdata.month(kk) keysdata.day(kk) keysdata.time(kk) keysdata.obslat(kk)]
        newd=[profiledata.year profiledata.month profiledata.day profiledata.time profiledata.lat]
        whattodo=input('these two profiles look identical - replace(r),add(a),or skip(s)?')
    end
    if(whattodo=='r')
        %replace the old data with the new
        profiledata.nss=num2str(keysdata.stnnum(kk(1)));
        uniqueid=uniqueid-1;
    elseif(whattodo=='s')
        %skip this profile - 
        %in practice, this means aborting the conversion
        return
    elseif(whattodo=='a')
        %continue without change
    end
end
    
return
        
