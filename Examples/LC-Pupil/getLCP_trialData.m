function [trialData, siteSpecs] = getLCP_trialData(rebuildDataFile)
% function [trialData, siteSpecs] = getLCP_trialData(rebuildDataFile)
%
% Gets the data needed for figLCP_tonic.m. If collectData flag is true,
% rebuild the data file.
%
% INPUT DATA
% -----------
%
%  Uses siteData cell arrays from each site, which contain:
%
%  siteData{1}: trialsxcols matrix, cols are:
%   1 ... fix start time wrt fixation on
%   2 ... fix end time wrt fix start time (fix duration)
%   3 ... reported correcdt
%   4 ... beep on time, wrt to fix start time
%   5 ... trial begin time, wrt to fix start time
%   6 ... trial end time, wrt to fix start time
%   7 ... trial wrt time (cpu clock)
%   8 ... LFP index corresponding to fix start time (coded above)
%   9 ... ELESTM on time (when appropriate), wrt fix start time
%
%  siteData{2}: Analog:
%   dim1: trial
%   dim2: sample
%   dim3: 1=x, 2=y, 3=z-pupil, 4=corrected z-pupil, 5=slope
%   [remember first sample is considered time=0 (i.e., wrt fix start time)]
%     = eyedat(Lgood,:,:);
%
%  siteData{3}: spikes, re-coded wrt fix start time
%       first is multi-unit
%       rest are single-unit
%
%  siteData{4}: LFP, re-coded wrt fix start time
%
%  siteData{5}: pupil events... rows are events, columns are:
%   1. trial number
%   2. start time of event (wrt fix start time)
%   3. end time of event (wrt fix start time)
%   4. magnitude at start of event (raw z-score)
%   5. magnitude at end of event (raw z-score)
%   6. magnitude at start of event (corrected z-score)
%   7. magnitude at end of event (corrected z-score)
%   8. time of subsequent max slope
%   9. magnitude of subsequent max slope (corrected z/sample)
%
% OUTPUT DATA
% -----------
%
% trialData (defined below)
% siteSpecs (defined below)
%

%% Define the data we will use. Column are:
%  1. site
%  2. monkeys
siteSpecs = {...
   'LC',  {'Oz' 'Cicero'};       ...
   'IC',  {'Oz' 'Cicero'};       ...
   'SC',  {'Oz' 'Cicero'};       ...
   'ACC', {'Sprout' 'Atticus'}; ... % 1 5 1; 1 6 1; 2 2 1
   'PCC', {'Sprout' 'Cheetah'}};
numSites = size(siteSpecs, 1);

%% Rebuild data file
%
if nargin >= 1 && rebuildDataFile
   
   % Set up the tonicData cell array
   % Rows are sites
   % Columns are monkeys
   %
   % Cell entries are cell arrays of sessionData matrices, which are
   %  per-session data with rows=trials, columns=
   %  1. trial onset time
   %  2. mean pupil diameter
   %  3..n. Single-unit spike rates per isolated unit
   trialData = cell(numSites, 2);
   
   % Indices of data columns in siteData{2}
   PUPIL_DATA_INDEX = 4; % z-scored pupil
   
   % Indices of data columns in siteData{3}
   BEEP_INDEX = 4;
   STIM_INDEX = 9;
   
   % Other useful constants
   TRIAL_TIME_CUTOFF = 200; % collect data until 200 ms before end of trial
   
   % Loop through each brain region
   for ss = 1:numSites
      
      % Loop through each monkey
      for mm = 1:size(siteSpecs{ss,2},2)
         
         % Get data directory and list of data file names
         [base_dir, fnames] = getLCP_cleanDataDir(siteSpecs{ss,2}{mm}, siteSpecs{ss,1});
         
         % Check that data files exist
         if ~isempty(fnames)
            
            % Set up the site/monkey data cell array
            trialData{ss, mm} = cell(length(fnames), 1);
            
            % Loop through each file
            for ff = 1:length(fnames)
               
               % Give a status message
               disp(sprintf('monkey = %s, site = %s, %d/%d files', ...
                  siteSpecs{ss,2}{mm}, siteSpecs{ss,1}, ff, length(fnames)))
               
               % Load the data
               load(fullfile(base_dir, fnames{ff}));
               
               % Use only single units, which are columns 2:n in
               % siteData{3}
               numUnits = size(siteData{3}, 2)-1;
               
               % Check that there is at least one single unit
               if numUnits > 0
                  
                  % Use only no-beep, no-stim trials
                  trialIndices = find( ...
                     ~isfinite(siteData{1}(:,BEEP_INDEX)) & ...
                     ~isfinite(siteData{1}(:,STIM_INDEX)));
                  
                  % Count the number of good trials
                  numTrials = length(trialIndices);
                  
                  % Get trial end times, minus cutoff
                  trialEndTimes = siteData{1}(trialIndices,6)-TRIAL_TIME_CUTOFF;
                  
                  % Set up temporary data matrix, rows are trials, columns
                  % are trial start time, pupil diameter, followed by single units
                  sessionData = nan.*zeros(numTrials, numUnits + 2);
                  
                  % Loop through the trials
                  for tt = 1:numTrials
                     
                     % Get start/end indices into pupil data array (inde=4
                     % in third dimension nof siteData{2} -- the z-scored
                     %
                     % Start index is first non-nan index after at least
                     % 500 samples
                     pupilStartIndex = max(500, find(isfinite( ...
                        siteData{2}(trialIndices(tt), :, PUPIL_DATA_INDEX)), 1));
                     
                     % End index is last non-nan index
                     pupilEndIndex = find(isfinite(siteData{2} ...
                        (trialIndices(tt), :, PUPIL_DATA_INDEX)), 1, 'last');
                     
                     % Check that we have at least one sec worth of data
                     % (sample rate = 1000 Hz)
                     if pupilEndIndex > pupilStartIndex + 1000
                        
                        % Get time of fpon (the "with respect to" or wrt 
                        %  time) for the given trial
                        sessionData(tt, 1) = siteData{1}(trialIndices(tt), 7);
                        
                        % Get mean PD during trial
                        sessionData(tt, 2) = mean(siteData{2}(trialIndices(tt), ...
                           pupilStartIndex:pupilEndIndex, PUPIL_DATA_INDEX));
                        
                        % Loop through the single units
                        for uu = 1:numUnits
                           
                           % Get the spike data
                           sp = siteData{3}{trialIndices(tt), uu+1};
                           
                           % Store the spike rate, in spikes/sec
                           sessionData(tt, 2+uu) = sum( ...
                              sp >= TRIAL_TIME_CUTOFF & sp <= trialEndTimes(tt))./...
                              (trialEndTimes(tt)-TRIAL_TIME_CUTOFF).*1000;
                        end
                     end
                     
                     % Make trial times wrt the first good trial
                     firstGoodSessionIndex = find(isfinite(sessionData(:,1)),1);
                     if ~isempty(firstGoodSessionIndex)
                        sessionData(:,1) = sessionData(:,1) - ...
                           sessionData(firstGoodSessionIndex,1);
                     end
                  end
                  
                  % Save the temporary data
                  trialData{ss, mm}{ff} = sessionData;
               end
            end
         end
      end
   end
   
   % Save data to file
   save(fullfile(getLCP_collectedDataDir, 'trialData'), 'trialData', 'siteSpecs');
   
else
   
   % Load data from file
   dat = load('trialData');
   trialData = dat.trialData;
   siteSpecs = dat.siteSpecs;
end
