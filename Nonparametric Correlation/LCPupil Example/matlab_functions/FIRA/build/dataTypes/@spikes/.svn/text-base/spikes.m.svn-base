function sp_ = spikes(varargin)
% function sp_ = spikes(varargin)
%
% Constructor method for class spikes
%
% Input:
%   varargin ... optional property value pairs
%                also looks in FIRA.spm.spikes for
%                optional list of property/value pairs
%
% Output:
%   sp_ ... the spike object (to be stored in FIRA.spm)
%   Also creates (in set method):
%       FIRA.raw.spikes
%       FIRA.spikes

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make the spikes struct
sp = struct( ...
    'keep_spikes', 'all', ... % 'all', 'allnz', or [channel unit] x n array
    'raw',         'true');

if isempty(FIRA)
    sp_ = class(sp, 'spikes');
    return
end

% check FIRA.spm.analog, varargin for varargin
if isfield(FIRA.spm, 'spikes') && iscell(FIRA.spm.spikes)
    varargin = cat(2, FIRA.spm.spikes, varargin)
end

% loop through the varargin
for i = 1:2:size(varargin, 2)
    sp.(varargin{i}) = varargin{i+1};
end

% check spike channels
if isempty(sp.keep_spikes)

    % if no spikes given, save nothing...
    sp_ = [];

else

    % make sure keep_spikes is nx2; if just a column
    % vector, assume values are "channels" and add a column
    % of ones as "units"
    if isnumeric(sp.keep_spikes) && size(sp.keep_spikes, 2) == 1
        sp.keep_spikes = [ones(size(sp.keep_spikes)) sp.keep_spikes];
    elseif iscell(sp.keep_spikes)
        ks = [];
        for ii = 1:size(sp.keep_spikes, 1)
            these_units = [sp.keep_spikes{ii, 2} - 96]';
            ks = [ks; sp.keep_spikes{ii,1} * ones(size(these_units)), these_units, ...
                (sp.keep_spikes{ii,1}*1000+these_units(1))*ones(size(these_units))];
        end
        sp.keep_spikes = ks;
    end

    % conditionally make FIRA.raw.spikes
    if sp.raw
        FIRA.raw.spikes = [];
    end

    % make FIRA.spikes
    FIRA.spikes = struct( ...
        'channel', [], ... % 1xn array of channel #'s
        'unit',    [], ... % 1xn array of unit #'s
        'id',      [], ... % 1xn array, ID = 1000*channel+unit
        'data',    {{}});    % mxn cell array

    % make object
    sp_ = class(sp, 'spikes');
end
