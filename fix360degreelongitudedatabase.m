%% fix360degreelongitudedatabase
% this opens the database and changes the longitudes in both edited and raw
% files to 360 degrees - it also saves the old longitude in the surface
% codes section of the record.


for i=1:length(d)
    spa=strfind(d(i).name,'_');
    prefix=d(i).name(1:spa(1)-1);
    stnnum=getnc(d(i).name,'stn_num');
    c360l=getnc(d(i).name,'c360long');
    c=clock;
    update=[num2str(c(1)) num2str(c(2)) num2str(c(3))];
    
  for j=1:length(stnnum)
      raw=1;
      clear filen
      filen=getfilename(stnnum(j,:),raw);
      if(ispc)
       ncraw=netcdf([prefix '\' filen],'write');
      else
       ncraw=netcdf([prefix '/' filen],'write');
      end
      
      raw=0;
      clear filen
      filen=getfilename(stnnum(j,:),raw);
      if(ispc)
       nced=netcdf([prefix '\' filen],'write');
      else
       nced=netcdf([prefix '/' filen],'write');
      end
      
      %%increment the number of histories:
      ncraw{'Num_Hists'}(1)=ncraw{'Num_Hists'}(1)+1
      nced{'Num_Hists'}(1)=nced{'Num_Hists'}(1)+1
      if(nced{'Num_Hists'}(1)>100)
          nced{'Num_Hists'}(1)=100;
      end
      nrh=ncraw{'Num_Hists'}(1);
      neh=nced{'Num_Hists'}(1);
     
      clear hist*
      %%change the history section, one bit at a time..
      %first change the ident code...
      histrawIC=ncraw{'Ident_Code'};
      histedIC=nced{'Ident_Code'};
      histrawIC(nrh,:)='CS';
      histedIC(neh,:)='CS';
      ncraw{'Ident_Code'}(:,:)=histrawIC(:,:);
      nced{'Ident_Code'}(:,:)=histedIC(:,:);
      
      %%now change the PRC_Code
      histrawPRC=ncraw{'PRC_Code'};
      histedPRC=nced{'PRC_Code'};
      histrawPRC(nrh,:)='CSCB';
      histedPRC(neh,:)='CSCB';
      ncraw{'PRC_Code'}(:,:)=histrawPRC(:,:);
      nced{'PRC_Code'}(:,:)=histedPRC(:,:);
      
      %%now change the version:
      histrawV=ncraw{'Version'};
      histedV=nced{'Version'};
      histrawV(nrh,:)='1.0 ';
      histedV(neh,:)='1.0 ';
      ncraw{'Version'}(:,:)=histrawV(:,:);
      nced{'Version'}(:,:)=histedV(:,:);

      %%now change the PRC_Date
      histrawD=ncraw{'PRC_Date'};
      histedD=nced{'PRC_Date'};
      histrawD(nrh,:)=update;
      histedD(neh,:)=update;
      ncraw{'PRC_Date'}(:,:)=histrawD(:,:);
      nced{'PRC_Date'}(:,:)=histedD(:,:);
      
      %%now change the Act_Code
      histrawAC=ncraw{'Act_Code'};
      histedAC=nced{'Act_Code'};
      histrawAC(nrh,:)='PE';
      histedAC(neh,:)='PE';
      ncraw{'Act_Code'}(:,:)=histrawAC(:,:);
      nced{'Act_Code'}(:,:)=histedAC(:,:);

      %%now change the Act_Parm
      histrawAP=ncraw{'Act_Parm'};
      histedAP=nced{'Act_Parm'};
      histrawAP(nrh,:)='LONG';
      histedAP(neh,:)='LONG';
      ncraw{'Act_Parm'}(:,:)=histrawAP(:,:);
      nced{'Act_Parm'}(:,:)=histedAP(:,:);

      %%now change the Aux_ID
      histrawAID=ncraw{'Aux_ID'};
      histedAID=nced{'Aux_ID'};
      histrawAID(nrh)=0.;
      histedAID(neh)=0.;
      ncraw{'Aux_ID'}(:)=histrawAID(:);
      nced{'Aux_ID'}(:)=histedAID(:);
      
      %%now change the Flag_Severity
      histrawFS=ncraw{'Flag_severity'};
      histedFS=nced{'Flag_severity'};
      histrawFS(nrh)=0;
      histedFS(neh)=0;
      ncraw{'Flag_severity'}(:)=histrawFS(:);
      nced{'Flag_severity'}(:)=histedFS(:);
      
      %%now change the Previous_Val
      histrawPV=ncraw{'Previous_Val'};
      histedPV=nced{'Previous_Val'};
      l=num2str(ncraw{'longitude'}(1));
      ls='          ';
      ls(1:min(10,length(l)))=l(1:min(10,length(l)));
      histrawPV(nrh,1:10)=ls;
      histedPV(neh,1:10)=ls;
      ncraw{'Previous_Val'}(:,:)=histrawPV(:,:);
      nced{'Previous_Val'}(:,:)=histedPV(:,:);

      %%finally, change the longitude in both these files:
      ncraw{'longitude'}(1)=c360l(j);
      nced{'longitude'}(1)=c360l(j);
      
  close(nced)
  close(ncraw)

  end
 
end