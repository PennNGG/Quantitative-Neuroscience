
%% Plot RT distribution
%
%
% Open a figure
figure

% Get the data
[data, labels] = later_getData();
data = [data{:}];
data = data(data>0.18);


%% Plot RT

% Binning for RT plots
rtBins  = 0:0.016:1.2;

cla reset;%  hold on;
v = VideoWriter("rt_histogram.avi");
axis([0 1.2 0 235]);
xlabel('Reaction time (s)')
ylabel('Count')
set(gca, 'FontSize', 20)
open(v);
frame = getframe(gcf);
writeVideo(v,frame);

for dd = 1:20:length(data)
    histogram(data(1:dd), rtBins);
    axis([0 1.2 0 235]);
    xlabel('Reaction time (s)')
    ylabel('Count')
    set(gca, 'FontSize', 20)
    frame = getframe(gcf);
    pause(0.001);
    writeVideo(v,frame);
end

% pause
for dd = 1:100
    writeVideo(v,frame);
end

% normalize, show inverse gaussian
histogram(data, rtBins, 'Normalization', 'pdf');
axis([0 1.2 0 4.5]);
xlabel('Reaction time (s)')
ylabel('Probability density')
set(gca, 'FontSize', 20, 'YTick', [0 2 4])
hold on
ig = fitdist(data', 'InverseGaussian');
plot(rtBins, ig.pdf(rtBins), 'r-', 'LineWidth', 3)
frame = getframe(gcf);
writeVideo(v,frame);

% pause
for dd = 1:100
    writeVideo(v,frame);
end


%% Plot reciprocal

% Binning for 1/RT plots
rrtBins = 0:0.17:10.0; % cutting off long tail of express saccades
rdata = 1./data;
cla reset;%  hold on;
% for dd = 1:20:length(rdata)
%     histogram(rdata(1:dd), rrtBins);
%     axis([0 6 0 300]);
%     xlabel('1/Reaction Time (s^-^1)')
%     ylabel('Count')
%     set(gca, 'FontSize', 20)
%     frame = getframe(gcf);
%     pause(0.001);
%     writeVideo(v,frame);
% end
% close(v);

% normalize, show gaussian
histogram(1./data, rrtBins, 'Normalization', 'pdf');
axis([0 6 0 0.6]);
xlabel('1/Reaction time (s^-^1)')
ylabel('Probability density')
set(gca, 'FontSize', 20, 'YTick', [0 0.4]);
hold on
ig = makedist('Normal', 'mu', mean(1./data), 'sigma', 0.9); %std(1./data));
plot(rrtBins, ig.pdf(rrtBins), 'r-', 'LineWidth', 3)
frame = getframe(gcf);
writeVideo(v,frame);

% pause
for dd = 1:100
    writeVideo(v,frame);
end

close(v)
