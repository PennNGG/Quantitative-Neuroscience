function parsePLX_aData
% function parsePLX_aData
%
% uses FIRA.raw.analog.data
%      FIRA.raw.analog.params
%      FIRA.raw.trial.index
%      FIRA.raw.trial.start
%      FIRA.raw.trial.wrt
%      FIRA.raw.trial.end
%      FIRA.raw.trial.ecodes
% to find the appropriate analog data for the given trial
%
% fills in the array of structures in FIRA.analog.data associated
%   with the current trial (FIRA.tria.index). These structures
%   have already been created with the following fields:
%       start_time
%       values
%
% FIRA.raw.analog.data is in the form of:
%   <timestamp> <ch> <ch> etc.
%   where <ch> are channels ALREADY IN THE APPROPRIATE ORDER
%   for FIRA.analog.name

% 10/29/04 updated by jig
% 11/25/02 jd fixed problem with accessing non-existing adata

global FIRA

% check that the data we want exists
if isempty(FIRA.raw.analog.data) || ...
        FIRA.raw.analog.params.aind > size(FIRA.raw.analog.data, 1) || ...
        FIRA.raw.analog.data(FIRA.raw.analog.params.aind,1) > FIRA.raw.trial.end_time || ...
        FIRA.raw.analog.data(end,1) < FIRA.raw.trial.start_time
    FIRA.analog.error{FIRA.raw.trial.good_count,1} = 'no analog data';
    return
end

% check that all the data we want really exists
% if not, update 
if size(FIRA.raw.analog.data, 2) <= size(FIRA.analog.name, 2)
    ks = 1:size(FIRA.raw.analog.data, 2)-1;
    FIRA.analog.name         = FIRA.analog.name(ks);
    FIRA.analog.acquire_rate = FIRA.analog.acquire_rate(ks);
    FIRA.analog.store_rate   = FIRA.analog.store_rate(ks);
end
    
% get a chunk of values that (we hope) contains the values
% we want .. this speeds things up A LOT

% first look for the beginning of the chunk
cs = 1000;
while ((FIRA.raw.analog.params.aind + cs) < FIRA.raw.analog.params.asz) && ...
        (FIRA.raw.analog.data(FIRA.raw.analog.params.aind+cs,1) < FIRA.raw.trial.start_time)
    FIRA.raw.analog.params.aind = FIRA.raw.analog.params.aind + cs;
end

% get the chunk. mmm. chunk.
chunk = floor(max(FIRA.analog.acquire_rate) * (FIRA.raw.trial.end_time - ...
    FIRA.raw.analog.data(FIRA.raw.analog.params.aind))/1000)+10;
if FIRA.raw.analog.params.aind + chunk > FIRA.raw.analog.params.asz
    ad = FIRA.raw.analog.data(FIRA.raw.analog.params.aind:end,:);
else
    ad = FIRA.raw.analog.data(FIRA.raw.analog.params.aind:FIRA.raw.analog.params.aind+chunk,:);
end

% get the indices of records between begin and end
inds = find( ...
    ad(:,1) >= FIRA.raw.trial.start_time & ...
    ad(:,1) <= FIRA.raw.trial.end_time);

% check for data
if isempty(inds)
    disp('Missing analog data')
    FIRA.analog.error{FIRA.raw.trial.startcd_index,1} = 'no analog data';
    return
end

% save start_time for each record, with respect to the trial's wrt
[FIRA.analog.data(FIRA.raw.trial.good_count,:).start_time] = ...
    deal(ad(inds(1),1)-FIRA.raw.trial.wrt);

% save the length of each data segment
[FIRA.analog.data(FIRA.raw.trial.good_count,:).length] = deal(length(inds));

% save the data for each channel
for i = 1:length(FIRA.analog.name)
    FIRA.analog.data(FIRA.raw.trial.good_count, i).values = ad(inds, i+1);
end

FIRA.raw.analog.params.aind = FIRA.raw.analog.params.aind + inds(end);
