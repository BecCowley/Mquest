%printqflags - puts the quality flags at the correct depths and adds the 
%   quality line (colored green/blue/yellow/red) at the side


%plot grey line to show menu depth point...
pd = handles.pd;
xlimit=get(handles.profile,'Xlim');

ymin=handles.menudepth-handles.profilefocus;
ymax=handles.menudepth+handles.profilefocus;
ylimit=[ymin ymax];
%xlimit=[-5 35];
%ylimit=[0 1000];
%set(handles.profile,'XLim',xlimit);
%set(handles.profile,'YLim',ylimit);
newblue=[0 .5 .2];
grey=[0.6 0.6 0.6];
%axes(handles.profile);
g=plot(xlimit,[handles.menudepth handles.menudepth],'color',grey,'linestyle','-');
set(g,'LineWidth',2);



col=['gbyrg'];

%plot colored line of profile quality
clear xc
if(pd.ndep>0)
    pqc=pd.qc(1:pd.ndep);
    xc=zeros(size(pqc));
    xc(length(xc)+1)=0.;
    vx=get(handles.profile,'Xlim');
    xc=xc+min(vx);
    pdep=pd.depth(1:pd.ndep);
    pdep(length(pdep)+1)=max(pd.depth(pd.ndep))+1000.;
    
    for j=1:5
    kk=find(pqc==num2str(j));

     if(~isempty(kk))
        kk(length(kk)+1)=kk(length(kk))+1;
        xc2=xc*NaN;
        xc2(kk)=xc(kk);
    %    if(kk(end)>length(pd.depth));kk(end)=[];end;
        hhp= plot(xc2,pdep,'color',col(j));
        hold on
        set(hhp,'Linewidth',12.0);
     end
    end
end

% add quality flags at the correct depth:

cs=0;
spot=xlimit(1)-1.5;
for j=1:pd.numhists
    
    %    if(strmatch('CS',profiledata.Ident_Code(j,:)))
    %|...
    %            strmatch('SI',profiledata.Ident_Code(j,:)))
    if(strmatch('CS',pd.QC_code(j,:)))
        if(~cs)
            cs=1;
            if(j>1 & pd.QC_depth(j)~= pd.QC_depth(j-1))
                spot=xlimit(1)+2;
            else
                spot=spot+3.5;
            end
            hht=text(spot,pd.QC_depth(j),pd.QC_code(j,:));
            set(hht,'Color','y');
            set(hht,'VerticalAlignment','baseline');
            if(~isempty(handles.newfontsize))
                set(hht,'FontSize',handles.newfontsize)
            end
        end
    else
        if(j>1 & pd.QC_depth(j)~= pd.QC_depth(j-1))
            spot=xlimit(1)+2;
        else
            spot=spot+3.5;
        end
        hht=text(spot,pd.QC_depth(j),pd.QC_code(j,:));
        set(hht,'Color','y');
        set(hht,'VerticalAlignment','baseline')
        if(~isempty(handles.newfontsize))
            set(hht,'FontSize',handles.newfontsize)
        end
    end
    % end
end
