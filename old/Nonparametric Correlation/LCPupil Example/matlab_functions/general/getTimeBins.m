function tbins_ = getTimeBins(num_bins, min_time, max_time, times, fix_flag)
% function tbins_ = getTimeBins(num_bins, min_time, max_time, times, fix_flag)
%
% Make time bins

% check box "Fix bin" determines whether we bin
%   time by viewing times or number of trials
if fix_flag
    
    % get fixed bins between time min and time max
    tbins_ = linspace(min_time, max_time, num_bins+1);
else

    % get bins based on prctiles of data
    tbins_ = prctile(times, linspace(0, 100, num_bins+1));
end

% extend the last one to avoid < errors
tbins_(end) = tbins_(end) + 0.0001;
tbins_ = [tbins_(1:end-1)' tbins_(2:end)'];
