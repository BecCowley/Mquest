function [time,timezone]=cdfdate2num(units,calendar,time)
% Convert netcdf times to datenums
%
% USAGE: time = cdfdate2num(units,calendar,time)
%
% Warning: strange calendars like 360_day are simply stretched by 365.24237/360
% This means datevec will no longer return the right hour and minutes etc.
%
%
%
% Example:
%  [time,timezone]= cdfdate2num('hours since 1856-01-03 -07:00 UTC','julian',5)
%  datestr(time)
%  datestr(time+timezone)
%
% Here the -07:00 UTC is returned in timezone. timezone is also 
%
% Aslak Grinsted 2013
%inspired by reference: http://netcdf4-python.googlecode.com/svn/trunk/docs/netcdftime.netcdftime-pysrc.html#utime.num2date
% units=n.vars.time.atts.units.value;
% calendar=n.vars.time.atts.calendar.value;
%pat='(?<resolution>\w+)\s+since\s+(?<offsetdate>\d+-\d+-\d+)\s*(?<offsethoursign>[-+\s]*)(?<offsethour>[\d:]+)';
pat='(?<resolution>\w+)\s+since\s+(?<yyyy>\d+)-(?<mm>\d+)-(?<dd>\d+)(?<hours>[\s\d:-+]*)';
units=regexpi(units,pat,'names','once');
if isempty(units)
    error('Unknown time units.')
end
switch lower(units.resolution)
    case 'days'
    case 'hours'
        time=time/24;
    case 'minutes'
        time=time/(24*60);
    case 'seconds'
        time=time/(24*60*60);
    otherwise
        error('unsupported units');
end
yyyy=str2double(units.yyyy);
mm=str2double(units.mm);
dd=str2double(units.dd);
offset=datenum(yyyy,mm,dd);
hhmmss=[0 0 0];
units.hours=deblank(units.hours);
if ~isempty(units.hours)
    hhmmss=str2double(regexp(units.hours,'-?\d+','match'));
    hhmmss(2:end)=hhmmss(2:end)*sign(hhmmss(1));
    if length(hhmmss)<3,hhmmss(3)=0;end;
end    
timezone=datenum(0,0,0,hhmmss(1),hhmmss(2),hhmmss(3));
yearlen=365.24237;
switch lower(calendar)
    case {'julian','standard','gregorian','proleptic_gregorian'}
        time=offset+time;
    case {'noleap','365_day'}
        time=offset+time*yearlen/365;
    case {'all_leap','366_day'}
        time=offset+time*yearlen/366;
    case '360_day'
        time=offset+time*yearlen/360;
    otherwise
        error('unsupported calendar');
end
