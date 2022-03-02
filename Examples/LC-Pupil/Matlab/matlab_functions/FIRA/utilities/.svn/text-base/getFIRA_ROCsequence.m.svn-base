function [rocs_, bins_] = getFIRA_ROCsequence( ...
    Ltrials, units, bin_size, bin_offset, num_pts, ...
    start_event, start_offset, end_event, end_offset, ...
    wrt_event, wrt_offset)
%function [rocs_, bins_] = getFIRA_ROCsequence( ...
%    Ltrials, units, bin_size, bin_offset, num_pts, ...
%    start_event, start_offset, end_event, end_offset, ...
%    wrt_event, wrt_offset)

global FIRA

% check args
if isempty(Ltrials) || size(Ltrials, 2) ~= 2
    error('Ltrials is nx2 selection arrays')
end

if isempty(units) || strcmp(units, 'all')
    uids = 1:size(FIRA.spikes.id, 2);
else
    [tf, uids] = ismember(units, FIRA.spikes.id);
end

if isempty(bin_size)
    bin_size = 50; % msec
end

if isempty(bin_offset)
    bin_offset = bin_size/2;
end

if isempty(num_pts)
    num_pts = 100; % for rocN
end

if isempty(start_event)
    start_event = 'ins_on';
end

if isempty(start_offset)
    start_offset = 0;
end

if isempty(end_event)
    end_event = 'ins_off';
end

if isempty(end_offset)
    end_offset = 0;
end

if nargin < 10 || (isempty(wrt_event) & isempty(wrt_offset))
    wrt_event  = start_event;
    wrt_offset = start_offset;
elseif isempty(wrt_event)
    wrt_event  = start_event;
elseif isempty(wrt_offset)
    wrt_offset = 0;
end

% make data matrix, cols are (start, end, wrt) times, rows are trials
times = [getFIRA_ec([], start_event) - start_offset, ...
    getFIRA_ec([], end_event) - end_offset, ...
    getFIRA_ec([], wrt_event) - wrt_offset];

% s1(2)_times columns are:
%   trial index
%   real start time
%   real end time
%   wrt start time
%   wrt end time
%   wrt
s1_times = [find(Ltrials(:,1)) times(Ltrials(:,1),1) times(Ltrials(:,1),2) ...
    times(Ltrials(:,1),1)-times(Ltrials(:,1),3) ...
    times(Ltrials(:,1),2)-times(Ltrials(:,1),3) times(Ltrials(:,1),3)];

s2_times = [find(Ltrials(:,2)) times(Ltrials(:,2),1) times(Ltrials(:,2),2) ...
    times(Ltrials(:,2),1)-times(Ltrials(:,2),3) ...
    times(Ltrials(:,2),2)-times(Ltrials(:,2),3) times(Ltrials(:,2),3)];

bins_ = [min([s1_times(:,4); s2_times(:,4)]):bin_offset:...
    max([s1_times(:,5); s2_times(:,5)])-bin_size]';

% rocs_ rows are (time) bins, columns are:
%   s1 n
%   s2 n
%   roc
%   sem
% 3D is per unit
rocs_ = nans(size(bins_, 1), 4, length(uids));
s1c   = zeros(size(s1_times, 1), 1);
s2c   = zeros(size(s2_times, 1), 1);

for bb = 1:length(bins_)
    
    % disp(bb)
    
    % s1 trials
    s1tr = find(s1_times(:,4) <= bins_(bb) & ...
        s1_times(:,5) >= bins_(bb)+bin_size);
    if size(s1tr, 1) < 3
        s1tr = [];
    end
    
    % s2 trials
    s2tr = find(s2_times(:,4) <= bins_(bb) & ...
        s2_times(:,5) >= bins_(bb)+bin_size);
    if size(s2tr, 1) < 3
        s2tr = [];
    end
    
    % loop through the units
    for uu = 1:length(uids)
        
        % collect counts, group 1
        for ii = 1:size(s1tr, 1)
            
            sp1 = FIRA.spikes.data{s1_times(s1tr(ii), 1), uids(uu)};
            if isempty(sp1)
                s1c(ii) = nan;
            else
                ss = sp1>=(bins_(bb)+s1_times(s1tr(ii), 6)) & ...
                    sp1<(bins_(bb)+bin_size+s1_times(s1tr(ii), 6));                
                s1c(ii) = sum(ss);
                
                % subplot(2,1,1);
                % hold on
                % plot(sp1(ss)-s1_times(s1tr(ii), 6), ii*ones(sum(ss),1), 'k+');
                
            end
        end
        
        % collect counts, group 2
        for ii = 1:size(s2tr, 1)

            sp2 = FIRA.spikes.data{s2_times(s2tr(ii), 1), uids(uu)};
            if isempty(sp2)
                s2c(ii) = nan;
            else
                ss = sp2>=(bins_(bb)+s2_times(s2tr(ii), 6)) & ...
                    sp2<(bins_(bb)+bin_size+s2_times(s2tr(ii), 6));
                s2c(ii) = sum(ss);
                
                % subplot(2,1,2);
                % hold on
                % plot(sp2(ss)-s2_times(s2tr(ii), 6), ii*ones(sum(ss),1), 'k+');
                
            end
        end
        
        % clear nans
        Fs1 = find(~isnan(s1c(1:size(s1tr, 1))));
        Fs2 = find(~isnan(s2c(1:size(s2tr, 1))));
        
        % conditionally compute roc
        if length(Fs1) > 3 && length(Fs2) > 3
            
            % compute it
            rr = rocN(s1c(Fs1), s2c(Fs2), num_pts);
    
            % save it
            rocs_(bb, 1:3, uu) = [length(Fs1) length(Fs2) rr];
        else
             
            rocs_(bb, 1:3, uu) = [0 0 nan];
        end
    end
end
