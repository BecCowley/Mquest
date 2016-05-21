clear profileinfo
i=handles.currentprofile;
profileinfo{1}=[' '];
profileinfo{2}=sprintf('Latitude : %6.2f',pd.latitude);
%profileinfo{3}=[' ' ];
profileinfo{3}=sprintf('Longitude : %6.2f',pd.longitude);
profileinfo{4}=[' ' ];

profileinfo{5}=[pd.date '/' pd.month '/' ...
    pd.year '   ' pd.time];

profileinfo{6}=[' '];
profileinfo{7}=['Prof No :  ' num2str(i)];

profileinfo{8}=[' '];
profileinfo{9}=['Station Number : ' num2str(keysdata.stnnum(i))];

%profileinfo{10}=[' '];
profileinfo{10}=['  Ship ID : ' keysdata.callsign(i,:)];

%profileinfo{13}=[' '];
profileinfo{11}=['Data Type : ' keysdata.datatype(i,:)];

%profileinfo{13}=[' '];
profileinfo{12}=['Data Source : ' keysdata.datasource(i,:) ];
profileinfo{13}=['Priority : ' num2str(keysdata.priority(i)) ]; 

%put in probe type and serial numbers if available
ij = strmatch('PEQ$',pd.surfcode);
if ~isempty(ij)
    profileinfo{end+1}=['Probe type : ' pd.surfparm(ij,:) ];
end
ij = strmatch('SER#',pd.surfcode);
if ~isempty(ij)
    profileinfo{end+1}=['Serial number : ' pd.surfparm(ij,:) ];
end

%put in comments if available;
if isfield(pd,'comments_pre')
    comm = deblank(pd.comments_pre);
    if ~isempty(comm)
        profileinfo{end+1}='Comments pre: ';
        profileinfo{end+1} = comm';
    end
end
if isfield(pd,'comments_post')
    comm = deblank(pd.comments_post);
    if ~isempty(comm)
        profileinfo{end+1}='Comments post: ';
        profileinfo{end+1} = comm';
    end
end
%add the time since fix for fish tag info:
ij = strmatch('FTT#',pd.surfcode);
ik = strmatch('FTD#',pd.surfcode);
if ~isempty(ij)
    profileinfo{end+1} =['Time since fix (hrs) : ' pd.surfparm(ij,:)];
end
if ~isempty(ik)
    profileinfo{end+1} =['Deployment serial# : ' pd.surfparm(ik,:)];
    il = strmatch('SER1',pd.surfcode);
    if ~isempty(il)
        profileinfo{end+1} =['Tag serial# : ' pd.surfparm(il,:)];
    end        
end


set (handles.profile_info,'String',profileinfo);
