function [temperature, depth] = change_probetype(ptype_incorrect, ptype_correct, temp_in, resistance,...
    scale_incorrect, offset_incorrect, scale_correct, offset_correct)
% For TURO profiles where resistance, scale and offset values are available.
% change the probe type when incorrect type is selected at deployment
% the resistance needs to be back-calculated out, then the temperatures
% recalculated. Depth also has to be recalculated.
% Inputs: 
%           correct probe type (required)
%   from the profile file, retrieve:
%           resistance values ([] if unavailable)
%           sample time in milliseconds ([] if unavailable)
%           incorrect probe type (required)
%           original temperatures (required)
%           scale for incorrect probe type ([] if unavailable)
%           offset for incorrect probe type ([] if unavailable)
%   from either a previous correctly assigned profile that used the probe
%       type or maybe from a pre-set list:
%           scale from a previous drop that used correct probe type ([] if unavailable)
%           offset from a previous drop that used correct probe type ([] if unavailable)
%
% A review of offset and scale values from Investigator records show that
% there is <0.02degC difference when we use adjacent scale and offset
% values from the same voyage to correct temperatures. I recommend
% accepting the extra uncertainty in temperature and simply doing the depth
% recalculation (ie, use empty variables in the call to the function, just
% supply the old and new probe type). Downgrade the quality of temperature
% values to GTSPP flag 2 and increase the uncertainty in the results by +/-
% 0.05degC (as per Devil Probe Correction.pdf document).
%
% Author: Bec Cowley, January 2024
% Derived from Devil Probe Correction.pdf, Turo, 21 Feb 2012 v3

% check we have all inputs, if the values are unknown, they should be empty
if nargin < 7
    disp('All arguments are required, include as an empty varible [] if unknown')
    return
end
% essential inputs are required, or return
if isempty(ptype_incorrect) | isempty(ptype_incorrect) | isempty(temp_in)
    disp('Values for ptype_correct, ptyp_incorrect and temp_in are required')
    return
end

%% set up 
% depth coefficients
%     t4, t5, t6, t7, db, fd, t10, t11
prt = [2, 11, 32, 42, 52, 21, 61,  71];
a = [0.00225
    0.00182
    0.00225
    0.00225
    0.00225
    0.00182
    0.00216
    0.0002557];
b = [6.691
    6.828
    6.691
    6.691
    6.691
    6.346
    1.7779];

% set up some default scale and offset coefficients in cases of no
% correctly designated profiles to refer to. This is a backup option,
% preference is to use a known scale/offset from a probe that was deployed
% on the same system close in time to the incorrect profile.
scale = [];
offset = [];

%% are there correct scale and offset values available?
icorrect = find(prt == ptype_correct);
iincorrect = find(prt == ptype_incorrect);
% set up time array in 0.1 second increments
sample_time = 0.1:0.1:0.1*(length(temp_in));
%% recalculate temperatures if we choose to, otherwise use existing temperatures
if ~isempty(resistance)
    if isempty(scale_correct)
        scale_correct = scale(icorrect);
    end
    if isempty(offset_correct)
        offset_correct= offset(icorrect);
    end
    if isempty(scale_incorrect)
        scale_incorrect = scale(iincorrect);
    end
    if isempty(offset_incorrect)
        offset_incorrect= offset(iincorrect);
    end

    % remove the coefficients applied to the resistance in original file and
    % re-create the raw resistance
    raw_resistance = (resistance - offset_incorrect)/scale_incorrect;

    % recalculate resistance for the correct probe type using correct scale and
    % offset values:
    corrected_resistance = raw_resistance* scale_correct + offset_correct;

    % apply the standard resistance to temperature conversion equation:
    coef1 = 0.12901230e-2;
    coef2 = 0.23322529e-3;
    coef3 = 0.45701293e-6;
    coef4 = 0.71625593e-7;

    % where the corrected_resistance is negative, the data is invalid with
    % these scale and offset values, so make negative values == Nan
    corrected_resistance(corrected_resistance<0) = NaN;
    log_resistance = log(corrected_resistance);

    temperature = (1./(coef1 + coef2*log_resistance + coef3*log_resistance.^2 ...
        + coef4*log_resistance.^3))-273.15;
    % remove invalid temperatures
    temperature(isnan(corrected_resistance)) = NaN;
else
    % return original temperatures
    temperature = temp_in;
end

%% now get correct depths for this probe type
depth = b(icorrect) * sample_time - a(icorrect)*sample_time.^2;

