function [ok,dif] = checkFREandPEQ(deps,peq)
%function to check the fall rate equation matches the probe type assigned,
%via the depths that are included in the file.
% Built to check the MQNC databases at CSIRO for the SOOP lines.
% simplified version of depthcorrV4.m which was created in 2013 to fix
% depths in XBTs in the IOTA/QuOTA projects.
% called by fix_missingMetadata.m
%Bec Cowley, June, 2022

ok = 1;

%set up some strings and probe type codes for older files
prstr = {'SIP T-04','TSK T-07','83099','T- 7','T-04','T-07 760' ...
    'WA','760m T-07','T- 5','T- 4','T-06','T-05','052','051', ...
    '041','042','212','211','252','251','011','061','T-10',...
    'SIPP T-11','///','UNK','001','002','021','031','032','071'};
dpcodes = {'001       ','221       ','830       ' ...
    '041       ','001       ','041       ','999       ','041       ', ...
    '011       ','001       ','031       ','011       ','052       ','051       ', ...
    '041       ','042       ','212       ','211       ','252       ','251       ', ...
    '011       ','061       ','061       ','071       ','999       ','999       ', ...
    '001       ','002       ','021       ','031       ','032       ','071       '};

% match the peq string (could have come from PTYP etc) with the prstr
ii = find(strcmp(peq,prstr));
if isempty(ii)
    disp('No probe type string match!')
    keyboard
end
% now we have a correct code to work with the IODE table
ptyp = str2num(dpcodes{ii});

% Generate the set of depths
% based on z = at + 10exp-3 * bt^2, where t is
% in 0.1s increments.
zpeq = [2,32,42,52,202,212,222];
zpeqold = [1,31,41,51,201,211,221];
zt5peq = [11,231];
zfdpeq = 21;
zt10peq = [61,241];
zt11peq = 71;
zts7peq = [461,462];
%set time array
t=0.1:0.1:400;
if any(zpeq == ptyp)
    a=6.691;
    b=-.00225;
elseif any(zpeqold == ptyp)
    a = 6.472;
    b = -0.00216;
elseif any(zt5peq == ptyp)
    % other probes:
    % Sippican T5, TSK T5
    a=6.828;
    b=-.00182;
elseif any(zfdpeq == ptyp)
    % Sippican Fast deep
    a=6.346;
    b=-.00182;
elseif any(zt10peq == ptyp)
    % Sippican T10, TSK T10
    a=6.301;
    b=-.00216;
elseif any(zt11peq == ptyp)
    % Sippican T11
    a=1.779;
    b=-.000255;
elseif any(zts7peq == ptyp)
    % Sparton T7
    a=6.705;
    b=-.000228;
end
z = (a.*t) + (b*t.^2);


% resolution:
diffed = diff(deps);
meanded = nanmean(diffed);
if meanded >= 1
    resolution = 1; %low
else
    resolution = 2; %high
end

%let's check the depths are what they should be. What is the acceptable
%difference? Should be very small, otherwise flag it as a problem.
dif=max(abs(deps'-z(1:length(deps))));

if dif > z(1) %greater than one depth step - will cover situations where there is a zero first point
    ok = 0;
end


