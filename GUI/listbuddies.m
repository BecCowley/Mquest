%     listbuddies
%
%  this script runs to subset the buddy profiles according the the already
%  defined criteria and, instead of plotting them to the profile window,
%  lists them, along with the datbase prefix, to the matlab command window.

DECLAREGLOBALS

holdb=0;  %this is the index of buddies from the same year...
pd=handles.pd;

i=handles.currentprofile;
keysdata=handles.keys;
currentlat=keysdata.obslat(i);
currentlon=keysdata.obslon(i);
singleyear=handles.singleyearbuddies;

buddyarea=handles.buddylim;
iyear=str2num(pd.year);
if(handles.buddy>3)
    bud=handles.buddies;
   
%first plot the buddies from other files:
    for jj=1:length(bud)
    findbud2=[];
        if(singleyear)
            findbud=find(bud{jj}.obslat>=currentlat-buddyarea & ...
                bud{jj}.obslat<=currentlat+buddyarea & ...
                bud{jj}.obslon>=currentlon-buddyarea & ...
                bud{jj}.obslon<=currentlon+buddyarea &...
                bud{jj}.year==iyear);
        else
            findbud1=find(bud{jj}.obslat>=currentlat-buddyarea & ...
               bud{jj}.obslat<=currentlat+buddyarea & ...
               bud{jj}.obslon>=currentlon-buddyarea & ...
               bud{jj}.obslon<=currentlon+buddyarea&...
                bud{jj}.year~=iyear);
            findbud2=find(bud{jj}.obslat>=currentlat-buddyarea & ...
               bud{jj}.obslat<=currentlat+buddyarea & ...
               bud{jj}.obslon>=currentlon-buddyarea & ...
               bud{jj}.obslon<=currentlon+buddyarea&...
                bud{jj}.year==iyear);
            findbud=[findbud1' findbud2'];
        end
               
        filenam=bud{jj}.prefix      
        sslist=bud{jj}.stnnum(findbud)
    end
    
    %now find them from the same database:
   
    if(singleyear)
    
        findbud=find(keysdata.obslat>=currentlat-buddyarea & ...
            keysdata.obslat<=currentlat+buddyarea & ...
            keysdata.obslon>=currentlon-buddyarea & ...
            keysdata.obslon<=currentlon+buddyarea &...
            keysdata.year==iyear);
    else
        findbud=find(keysdata.obslat>=currentlat-buddyarea & ...
           keysdata.obslat<=currentlat+buddyarea & ...
           keysdata.obslon>=currentlon-buddyarea & ...
           keysdata.obslon<=currentlon+buddyarea);
    end

    filenam=keysdata.prefix
    sstlist2=keysdata.stnnum(findbud)
          
else
    
    errordlg('this is only useful if you are in "area" buddies');
    
end
    
           
        
    