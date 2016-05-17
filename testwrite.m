
% write the argo data to the edited WNC file
    % this contains corrected data if available,
    % if not, the uncorrected data
    
    %handles=guidata(gcbo);
    %keysdata = handles.keys;
    %profiledata=handles.profile_data;

    testqf   %go and assign the correct quality flags to each depth level...

    %ss=keysdata.stnnum(handles.currentprofile)   ;
%filenam=keysdata.prefix;
clear filenam
filenam='.\chinese2'

nss=num2str(ss);
for j=1:2:length(num2str(ss));

	if(j+1>length(nss))
        if(ispc)
filenam=[filenam '\' nss(j)];
        else
filenam=[filenam '/' nss(j)]; 
        end
    else	
        if(ispc)
filenam=[filenam '\' nss(j:j+1)];
        else
filenam=[filenam '/' nss(j:j+1)];
        end
	end
end

filenam=[filenam 'ed.nc']; 

%get the complete arrays from the originalfile and replace with hteedited
%values...

ptype=getnc(filenam,'Prof_Type');
pt=strmatch('TEMP',ptype);
ps=strmatch('PS',ptype);
h=getnc(filenam,'Profparm');

de=getnc(filenam,'Depthpress');
[m,n]=size(h);

temp2=h(:,:);
depth2=de(:,:);

%now save the data back to the file:

editedncfile=netcdf(filenam,'write');

    editedncfile{'Num_Hists'}(1) = profiledata.numhists;
    editedncfile{'No_Prof'}(1) = profiledata.nprof;
    try
      editedncfile{'Q_pos'}(:) = profiledata.pos_qc(:);
    end
    try
      editedncfile{'Q_Date_Time'}(:) = profiledata.juld_qc(:);
    end

    clo=datestr(clock,24)
    update=[clo(1:2) clo(4:5) clo(7:10)]

    editedncfile{'Up_date'}(:) = update(:);
    
if(profiledata.numhists==1)
   
    for fixhists=profiledata.numhists+1:100
       profiledata.QC_code(fixhists,:)='  ';
       profiledata.QC_depth(fixhists,:)='        ';
       profiledata.Ident_Code(fixhists,:)='  ';
       profiledata.PRC_Date(fixhists,:)='        ';
       profiledata.PRC_Code(fixhists,:)='    ';
       profiledata.Version(fixhists,:)='    ';
       profiledata.Act_Parm(fixhists,:)='    ';
       profiledata.Flag_severity(fixhists)=0;
       profiledata.Previous_Val(fixhists,:)='          ';
    end
end

if(profiledata.numhists>=1)
    editedncfile{'Act_Code'}(:)=profiledata.QC_code(:);
    editedncfile{'Aux_ID'}(:)=profiledata.QC_depth(:);
    editedncfile{'Ident_Code'}(:) = profiledata.Ident_Code(:);
    editedncfile{'PRC_Code'}(:) = profiledata.PRC_Code(:);
    editedncfile{'Version'} (:)=profiledata.Version(:);
    editedncfile{'PRC_Date'} (:)=profiledata.PRC_Date(:);
    editedncfile{'Act_Parm'}(:)=profiledata.Act_Parm(:);
    editedncfile{'Previous_Val'}(:)=profiledata.Previous_Val(:);
    try
      editedncfile{'Flag_severity'}(:)=profiledata.Flag_severity(:);
    catch
%        nc = netcdf([filenam],'noclobber');
%nc{'Flag_severity'}=ncfloat('Num_hists');
%close(nc);
%       editedncfile{'Flag_severity'}(:)=profiledata.Flag_severity(:);
    end
end
   
    a=0;
%save temperature profile and salinity profile if necessary:

    kk=find(isnan(profiledata.temp));
    if(~isempty(kk))
        profiledata.temp(kk)=99.99;
    end
    try
        kk=find(isnan(profiledata.sal));
        if(~isempty(kk))
            profiledata.sal(kk)=99.99;
        end
    end
    pt=strmatch('TEMP',profiledata.ptype);
    ps=strmatch('PSAL',profiledata.ptype);

if(n==profiledata.nprof)
    temp2(1:length(profiledata.temp),pt)=profiledata.temp;  
    depth2(1:length(profiledata.depth),pt)=profiledata.depth;   
    if(~isempty(ps))
        sal2(1:length(profiledata.sal),ps)=profiledata.sal;   
    end
else
    temp2(pt,1:length(profiledata.temp))=profiledata.temp;
    depth2(pt,1:length(profiledata.depth))=profiledata.depth;  
    if(~isempty(ps))
       sal2(ps,1:length(profiledata.sal))=profiledata.sal;  
    end
end

    editedncfile{'Profparm'}(pt,:)=temp2(:,:);
    editedncfile{'Depthpress'}(pt,:)=depth2(:,:);

    if(~isempty(ps))
      editedncfile{'Profparm'}(ps,:)=sal2(:,:);        
    end
    
    editedncfile{'ProfQP'}(:,:)=profiledata.qc(:,:);
    
    % close the files
    close(editedncfile);
    
    
