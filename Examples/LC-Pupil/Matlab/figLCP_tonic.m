function figLCP_tonic
% function figLCP_tonic
%
% Plots trial-by-trial relationship between tonic neural activity in LC/IC/SC
% (other?) and baseline PD. Columns are brain regions (LC/IC/SC).
%   Top row is mean PD per trial within an example session.
%   Next row is mean spike rate per trial within the same session.
%   Next row is spike rate versus PD for that session.
%   Bottom row is histogram of correlation coefficients from each session.
%       Black/gray are two monkeys.
%       Filled are p<0.01 (I?ll probably redo the stats using shuffled trials).
%
% NOTE: using robustfit will sometimes give a warning about "Iteration
%     limit reached" -- you can ignore this

%% Set up figure
%
wid                   = 17.6;          % total width, in cm
hts                   = [1.5 1.5 3 3]; % height of each row, in cm
cols                  = {5,5,5,1};     % number of columns per row
figureNum             = 3;
panelSeparationHeight = 2;             % in cm
panelSeparationWidth  = 0.5;           % in cm
[axs,~] = getPLOT_axes(figureNum, wid, hts, cols, ...
   panelSeparationHeight, panelSeparationWidth, [], 'Joshi et al', true);
set(axs,'Units','normalized');

%% Get the data (without rebuilding)
%
% Both trialData and siteSpecs are cell arrays
%  Rows are sites:
%  1. LC
%  2. IC
%  3. SC
%  4. ACC
%  5. PCC
%
%  Columns are monkeys per site
%
%  trialData entries are cell arrays of session data
%  each session data matrix has rows = trials, columns are pupil diameter
%     and units
%
%  siteSpecs are names of sites and monkeys
[trialData, siteSpecs] = getLCP_trialData();

% Count the number of brain regions (sites) to plot
numSites = size(siteSpecs, 1);

%% Example plotz for each site
%

% First define the example data we will use
% 
%  values are per site:
%  1. monkey index
%  2. file index
%  3. single-unit index
%  4. ylim1 (y-axis scaling in example plot)
%  5. ylim2 (y-axis scaling in example plot)
exampleData = [ ...
   1 20 1  5  3; ...
   2 24 2 10 10; ...
   2  6 2 25 12; ...
   2  3 1 30 20; ... % 1 5 1; 1 6 1; 2 2 1
   1  10 1 10 8];

% To set marker size
markerSize = 6;

% Loop through each site
for ss = 1:size(exampleData, 1)
   
   % Get standard colors that we use for the plots based on the monkey and
   % site
   [standardColors, ~] = getLCP_colorsAndSymbol( ...
      siteSpecs{ss,2}(exampleData(ss,1)),  ...        % monkey name
      siteSpecs{ss,1});                               % site name
   
   % Get the trial data
   %  rows are trials
   %  columns are:
   %  1. time
   %  2. pupil
   %  3...n. Spike rate
   %
   % Get the data from the example session
   exampleSessionData = trialData{ss, exampleData(ss,1)}{exampleData(ss,2)};
   
   % Get only good trials, defined as finite pupil measures
   LgoodTrials = isfinite(exampleSessionData(:, 2));
   
   % Get the time axis, convert from ms to minutes
   timeAxis = exampleSessionData(LgoodTrials,1)./60000;
   
   % Get the pupil data
   pupilData = exampleSessionData(LgoodTrials,2);
   
   % Get the spike data
   spikeData = exampleSessionData(LgoodTrials,2+exampleData(ss,3));
   
   % 1: show pupil per trial vs time
   %
   axes(axs(ss)); cla reset; hold on;
   plot(timeAxis, pupilData, '.', ...
      'Color',       standardColors{1}, ...
      'MarkerSize',  markerSize);
   lsline; % show a linear fit the easy way
   axis([min(timeAxis) max(timeAxis) -3 3]);
   title(sprintf('%s', siteSpecs{ss,1}))
   
   % Compute residuals to robust linear fit of pupil vs time
   % Note that robustfit automatically adds column of ones
   pupilBetas     = robustfit(timeAxis, pupilData);
   pupilResiduals = pupilData-[ones(sum(LgoodTrials),1) timeAxis]*pupilBetas;
                           
   % 2: show spikes per trial vs time
   axes(axs(ss+numSites)); cla reset; hold on;
   plot(timeAxis, spikeData, '.', ...
      'Color',       standardColors{1}, ...
      'MarkerSize',  markerSize);
   lsline; % linear fit
   axis([min(timeAxis) max(timeAxis) 0 exampleData(ss,4)]);
   
   % Compute residuals to robust linear fit of spike rate vs time
   % Note that robustfit automatically adds column of ones
   spikeBetas     = robustfit(timeAxis, spikeData);
   spikeResiduals = spikeData-[ones(sum(LgoodTrials),1) timeAxis]*spikeBetas;

   % 3: residual pupil vs spike, per trial
   axes(axs(ss+2*numSites)); cla reset; hold on;
   plot(pupilResiduals, spikeResiduals, '.', ...
      'Color',       standardColors{1}, ...
      'MarkerSize',  markerSize);
   lsline; % linear fit
   plot([-30 30], [0 0], 'k:');
   plot([0 0], [-30 30], 'k:');
   axis([-3 3 -exampleData(ss,5) exampleData(ss,5)]);
   
   % Compute partial correlations, to add to fig
   [R,P] = corr(pupilResiduals, spikeResiduals, 'type', 'Spearman');
   disp(sprintf('site=%s, r=%.2f, p=%.5f', siteSpecs{ss,1}, R, P))
end


%% Summary scatter plotz
%

% pValue used in panel D (< this value are shown as solid)
pVal = 0.05;

% Get the axes
axes(axs(end)); cla reset; hold on;

% Show the zero line
plot([0 10], [0 0], 'k:');

% Loop through the sites
for ss = 1:numSites
   
   % Loop through the monkeys
   for mm = 1:size(siteSpecs{ss,2},2)
      
      % Get standard colors that we use for the plots based on the monkey and
      % site
      [standardColors, standardSymbol] = getLCP_colorsAndSymbol( ...
         siteSpecs{ss,2}(exampleData(ss,1)),  ...        % monkey name
         siteSpecs{ss,1});                               % site name
      
      % Compute the partial correlations
      %
      % Count the number of sessions
      numSessions = size(trialData{ss, mm}, 1);
      
      % Pre-allocate a matrix with:
      %  dim1 (rows)   : sessions
      %  dim2          : units
      %  dim3 (columns): R,P
      partialCorrelations = nan.*zeros(numSessions, ...
         max(cellfun('size', trialData{ss,mm}, 2))-2, 2);
      
      % Loop through the sessions
      for tt = 1:numSessions
         
         % Get the data from the example session
         sessionData = trialData{ss, mm}{tt};

         % Only if we have data
         if ~isempty(sessionData)            
   
            % Get only good trials, defined as finite pupil measures
            LgoodTrials = isfinite(sessionData(:, 2));
            
            % Get the time axis
            timeAxis = sessionData(LgoodTrials,1);
            
            % Add ones column for fits
            X = [ones(sum(LgoodTrials),1) timeAxis];
            
            % Get the pupil data
            pupilData = sessionData(LgoodTrials,2);
            
            % Loop through the units. Remember that for each session we
            % store the time, pupil, and units in the columns, so the number
            % of units is the number of columns - 2;
            for uu = 1:size(trialData{ss, mm}{tt}, 2) - 2
            
               % Get the spike data
               spikeData = sessionData(LgoodTrials, 2+uu);
               
               if ss==1 && mm==1 && tt==32
                  disp([ss mm tt uu])
               end
               
               % Compute residuals to robust linear fit of pupil vs time
               % Note that robustfit automatically adds column of ones
               pupilBetas     = robustfit(timeAxis, pupilData);
               pupilResiduals = pupilData-X*pupilBetas;
         
               % Compute residuals to robust linear fit of spike rate vs time
               % Note that robustfit automatically adds column of ones
               spikeBetas     = robustfit(timeAxis, spikeData);
               spikeResiduals = spikeData-X*spikeBetas;

               % Compute partial correlation, p-value using corr, and store
               % in our matrix
               [partialCorrelations(tt,uu,1), partialCorrelations(tt,uu,2)] = ...
                  corr(pupilResiduals, spikeResiduals, 'type', 'Spearman');
            end
         end
      end
      
      % Get R, P values
      Lgood     = isfinite(partialCorrelations(:,:,1));
      Rs        = partialCorrelations(:,:,1);
      Rs        = Rs(Lgood);
      Ps        = partialCorrelations(:,:,2);
      Ps        = Ps(Lgood);      
      numPoints = length(Rs);
      
      % X value is based on site and monkey, then randomize points
      xCenter    = ss+0.3*(mm-1);
      xPositions = xCenter+rand(numPoints,1)*0.2-0.1;
      
      % Plot separately for positive/negative
      LrSign = [Rs>=0 Rs<0];
      
      % r is positive/negative
      for pp = 1:2
         
         % Plot the points
         plot(xPositions(LrSign(:,pp)), Rs(LrSign(:,pp)), ...
            standardSymbol, 'Color', standardColors{pp});
         plot(xPositions(LrSign(:,pp)&Ps<pVal), Rs(LrSign(:,pp)&Ps<pVal), ...
                        standardSymbol, 'Color', standardColors{pp}, ...
                        'MarkerFaceColor', standardColors{pp});
      end
      
      % Display median, sig test -- if true, draw thick line
      h  = plot(xCenter+[-0.1 0.1], median(Rs).*[1 1], 'k-');
      sr = signrank(Rs);
      if sr<pVal
         set(h, 'LineWidth', 3);
      end
      
      % Display counts
      nSigPos = sum(Rs>0&Ps<pVal);
      nSigNeg = sum(Rs<0&Ps<pVal);
      nTotal  = sum(isfinite(Rs));
      text(xCenter-0.15,0.55,sprintf('%d/%d=%d', ...
         nSigPos, nTotal, round(nSigPos/nTotal*100)));
      text(xCenter-0.15,-0.55,sprintf('%d/%d=%d',...
         nSigNeg, nTotal, round(nSigNeg/nTotal*100)));
      
      % print stats
      disp(sprintf('site=%3s, monk=%7s, medp=%.3f, tot=%2d, +=%2d, -=%2d', ...
         siteSpecs{ss,1}, siteSpecs{ss,2}{mm}, sr, ...
         nTotal, nSigPos, nSigNeg))
      
      % Label example session
      if mm == exampleData(ss,1)
         
         % Funny way of finding the example session by using the 
         %  partialCorrelations matrix as above
         pCorExample = nan.*ones(size(partialCorrelations,1), size(partialCorrelations,2));
         pCorExample(exampleData(ss,2), exampleData(ss,3)) = 1;
         pCorIndex   = find(isfinite(pCorExample(Lgood)));
         
         % Plot it in black
         plot(xPositions(pCorIndex), Rs(pCorIndex), standardSymbol, 'Color', 'k');
      end
      
   end
end
axis([0.7 5.3 -0.6 0.6]);

%% Add labels
%
axs_pl = 1:ss:length(axs);
for xx = 1:length(axs_pl)
   setPLOT_panelLabel(axs(axs_pl(xx)), xx);
end
axes(axs(1));
ylabel('Pupil diameter (z-score)');
axes(axs(1+numSites));
ylabel('Spike rate (sp/s)');
xlabel('Time from session onset (min)');
axes(axs(1+numSites*2));
ylabel('Spike rate (sp/s)');
xlabel('Pupil diameter (z-score)');
axes(axs(1+numSites*3));
ylabel('Partial Spearman''s correlation')
xlabel('Monkey')
