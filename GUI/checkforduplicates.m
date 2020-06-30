%check for duplicates to existing database:
%scripts slots into inputDEVIL.m and inputMA.m
%NB: checkforduplicates_function.m is this script as a function
%(keysdata.time==pd.time & 

d=0;kk=[];
if(~isempty(keysdata.year))
    obslat=single(keysdata.obslat);
    obslng=single(keysdata.obslon);
    kk=find(keysdata.year==str2double(pd.year) &...
        keysdata.day==str2double(pd.day) & keysdata.month==str2double(pd.month)...
        & obslat==single(pd.latitude) & obslng==single(pd.longitude));
    
    format long g
    
    if(~isempty(kk))
        %this might be a duplicate profile - ask what you want to do with it...
        if(~alreadychecked)
            alreadychecked=1;
            keysd=[keysdata.year(kk) keysdata.month(kk) keysdata.day(kk) keysdata.time(kk) keysdata.obslat(kk)]
            newd=[str2double(pd.year) str2double(pd.month) str2double(pd.day) profiledata.woce_time/100 pd.latitude]
            whattodo=input('these two profiles look identical - replace(r),add(a),or skip(s)?','s')
        end
        if(whattodo=='r')
            %replace the old data with the new
            pd.nss=num2str(keysdata.stnnum(kk(1)));
            uniqueid=uniqueid-1;
        elseif(whattodo=='s')
            %skip this profile -
            % in practice, this means aborting the conversion
            d=1;
            return
        elseif(whattodo=='a')
            %continue without change
        end
        d=1;
    end
    
end