    % write the edited data to the MQNC (Matlab-Quest-NetCdf) file
    % this contains corrected data if available,
    % if not, the uncorrected data
    % note - this only writes variables that might have changed in quest as
    % opposed to the script writeMQNCfiles which writes the entire MQNC
    % structure when importing data.
    
    %retrieveguidata
    
    %update to suit changes to pd structure vs profile_data structure.
    
    keysdata = handles.keys;
    profiledata=handles.profile_data;
    
    %pd contains the changed data
    
    ss=keysdata.stnnum(handles.lastprofile);
    clear filenam
    
    %construct the filename of the data file from the unique id and the
    %database prefix
    
    filenam=keysdata.prefix;
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
    
    %get the complete arrays from the originalfile and replace with the edited
    %values...  Only variables that are likely to have changed are
    %rewritten:
    
    checkcsid   %check that csid has not been corrupted somehow...
    
    ptype=ncread(filenam,'Prof_Type');
    pt=strmatch('TEMP',ptype);
    ps=strmatch('PSAL',ptype);
    dpcode=ncread(filenam,'D_P_Code');
    
    %clear h
    %h=ncread(filenam,'Profparm');
    
    %clear de
    %de=ncread(filenam,'Depthpress');
    %[m,n]=size(h);
    
    %data2=h(:,:);
    %depth2=de(:,:);
    
    %now save the data back to the file:
    editedncfile=netcdf(filenam,'write');
    
    editedncfile{'Num_Hists'}(:) = profiledata.numhists;
    
    %    try
    editedncfile{'Q_Pos'}(:) = profiledata.pos_qc(:);
    %    end
    %    try
    editedncfile{'Q_Date_Time'}(:) = profiledata.juld_qc(:);
    %    end
    
    editedncfile{'latitude'}(:) = single(profiledata.latitude);
    editedncfile{'longitude'}(:) = single(profiledata.longitude);
    t=profiledata.time;
    sh=strfind(t,':');
    if(~isempty(sh))
        t(sh)=[];
    end
    
    time=str2num(t)*100;
    newdate=str2num([profiledata.year profiledata.month profiledata.date]);
    
    editedncfile{'woce_time'}(:) = time;
    editedncfile{'woce_date'}(:) = newdate;
    editedncfile{'time'}(:) = julian([str2num(profiledata.year),...
        str2num(profiledata.month),  str2num(profiledata.date),...
        str2num(t(1:2)), str2num(t(3:4)), 0])-2415020.5;
    
    %     clo=datestr(clock,24);
    %     update=[clo(1:2) clo(4:5) clo(7:10)];
    %As of August, 2014, the format has been changed to yyyymmdd to agree with
    %NOAA formats. Bec Cowley
    update = datestr(now,'yyyymmdd');
    
    editedncfile{'Up_date'}(:) = update(:);
    
    editedncfile{'Deep_Depth'}(:) = profiledata.deep_depth;
    
    if(profiledata.numhists==1)
        %pad the rest of the array in case the field didn't exist:
        for fixhists=profiledata.numhists+1:100
            profiledata.QC_code(fixhists,:)='  ';
            profiledata.QC_depth(fixhists,:)=0;   %-99.;
            profiledata.Ident_Code(fixhists,:)='  ';
            profiledata.PRC_Date(fixhists,:)='        ';
            profiledata.PRC_Code(fixhists,:)='    ';
            profiledata.Version(fixhists,:)='    ';
            profiledata.Act_Parm(fixhists,:)='    ';
            profiledata.Flag_severity(fixhists)=0;
            profiledata.Previous_Val(fixhists,:)='          ';
        end
    end
    if(profiledata.numhists>100)
        elimdupehistories
    end
    if(profiledata.numhists>100)
        profiledata.numhists=75;
    end
    %if(profiledata.numhists>=1)
    % need depth data to recalc history depths if is P instead of D:
    clear data2
    clear depth2
    clear qcdata2
    data2=ncread(filenam,'Profparm');
    depth2=ncread(filenam,'Depthpress');
    qcdata2=ncread(filenam,'ProfQP');
    qcdepth2=ncread(filenam,'DepresQ');
    [m,n]=size(depth2);
    
    if(profiledata.numhists>=1)
        if dpcode=='P'
            profiledata.QC_depth(1:profiledata.numhists)=sw_pres(profiledata.QC_depth(1:profiledata.numhists),profiledata.latitude(1));
            for i=1:profiledata.numhists
                dd=abs(depth2(1,:)-profiledata.depth(1,i));
                igood = find(dd==min(dd));
                profiledata.depth(i)=depth2(1,igood);
            end
        end
    end
    
    
    editedncfile{'Act_Code'}(:,:)=profiledata.QC_code(:,:);
    editedncfile{'Aux_ID'}(:)=profiledata.QC_depth(:);
    editedncfile{'Ident_Code'}(:,:) = profiledata.Ident_Code(:,:);
    editedncfile{'PRC_Code'}(:,:) = profiledata.PRC_Code(:,:);
    editedncfile{'Version'} (:,:)=profiledata.Version(:,:);
    editedncfile{'PRC_Date'} (:,:)=profiledata.PRC_Date(:,:);
    editedncfile{'Act_Parm'}(:,:)=profiledata.Act_Parm(:,:);
    editedncfile{'Previous_Val'}(:,:)=profiledata.Previous_Val(:,:);
    
    %   try
    editedncfile{'Flag_severity'}(:)=profiledata.Flag_severity(:);
    %   end
    
    
    %save temperature profile (and salinity profile if present): These are
    %the only two that can be changed by quest:  If other parameters are
    %present, they are also saved automatically as part of the data2 array.
    
    kk=find(isnan(profiledata.temp));
    if(~isempty(kk))
        profiledata.temp(kk)=-99.99;
    end
    try
        kk=find(isnan(profiledata.sal));
        if(~isempty(kk))
            profiledata.sal(kk)=-99.99;
        end
    end
    kk=find(isnan(profiledata.depth));
    if(~isempty(kk))
        profiledata.depth(kk)=-99.99;
    end
    
    pt=strmatch('TEMP',profiledata.ptype);
    ps=strmatch('PSAL',profiledata.ptype);
    
    
    kk=find(isnan(depth2));
    if(~isempty(kk))
        depth2(kk)=-99.99;
    end
    
    if(dpcode=='P')
        % need to convert D back to P:
        profiledata.depth(1:profiledata.ndep)=sw_pres(profiledata.depth(1:profiledata.ndep),profiledata.latitude(1));
        for i=1:profiledata.ndep
            dd=abs(depth2(1,:)-profiledata.depth(1,i));
            igood = find(dd==min(dd));
            profiledata.depth(i)=depth2(1,igood);
        end
    end
    
    if(n==profiledata.nprof)
        data2(1:length(profiledata.temp),pt)=profiledata.temp;
        depth2(1:length(profiledata.depth),pt)=profiledata.depth;
        qcdata2(1:length(profiledata.qc),pt)=profiledata.qc;
        qcdepth2(1:length(profiledata.qc),pt)=profiledata.depth_qc;
        if(~isempty(ps))
            data2(1:length(profiledata.sal),ps)=profiledata.sal;
            depth2(1:length(profiledata.depth),ps)=profiledata.depth;
            qcdata2(1:length(profiledata.salqc),ps)=profiledata.salqc;
            qcdepth2(1:length(profiledata.qc),ps)=profiledata.depth_qc;
        end
    else
        data2(pt,1:length(profiledata.temp))=profiledata.temp';
        depth2(pt,1:length(profiledata.depth))=profiledata.depth';
        qcdata2(pt,1:length(profiledata.qc))=profiledata.qc';
        qcdepth2(pt,1:length(profiledata.qc))=profiledata.depth_qc';
        if(~isempty(ps))
            data2(ps,1:length(profiledata.sal))=profiledata.sal';
            depth2(ps,1:length(profiledata.depth))=profiledata.depth';
            qcdata2(ps,1:length(profiledata.salqc))=profiledata.salqc';
            qcdepth2(ps,1:length(profiledata.qc))=profiledata.depth_qc';
        end
    end
    
    editedncfile{'Profparm'}(:,:)=data2(:,:);
    editedncfile{'Depthpress'}(:,:)=depth2(:,:);
    editedncfile{'ProfQP'}(:,:)=qcdata2(:,:);
    editedncfile{'DepresQ'}(:,:)=qcdepth2(:,:);
    editedncfile{'No_Depths'}(:)=profiledata.ndep(:);
    
    % close the files
    close(editedncfile);
    %save the structure - shouldn't be necessary...
    %guidata(gcbo,handles);
    
