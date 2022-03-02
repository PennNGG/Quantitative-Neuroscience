function plotWeightData

% week min, typical, max; sat min, typical; fri min, typical
monks = { ...
    'WWD_Atticus(081H).txt', 'Male',   'June 1998',  'y', 150 275 325 300 400 400 500; ...
    'WWD_Ava(CL06).txt',     'Female', 'May  2000',  'y', 50   70 125 150 200 250 300; ...
    'WWD_Cheetah(CR5J).txt', 'Male',   'March 2001', 'y', 150 275 325 300 400 400 500; ...
    'WWD_Chewy(95E073).txt', 'Male',   'June 1995',  'n', 125 150 250 200 300 300 400; ...
    'WWD_Cyrus(109H).txt',   'Male',   'June 1998',  'y', 150 250 350 300 400 400 500; ...
    'WWD_Falco().txt',       'Male',   '2001',       'y', 150 300 350 300 400 400 500; ...
    'WWD_Oz(RQ2259).txt',    'Male',   'March 1996', 'y', 50   70 125 150 200 250 300; ...
    'WWD_Woody(95E052).txt', 'Male',   'May 1995',   'n', 175 200 300 250 400 350 500; ...
    'WWD_ZsaZsa(CL55).txt',  'Female', 'May 2000',   'n', 40   75 125 150 200 250 300};

dirname  = '/Users/jigold/GoldWorks/Mirror_lab/Data/MonkeyWeights/txt/';

for mm = 1:size(monks,1)

    % check first for file
    filename = fullfile(dirname, monks{mm,1});
    a        = FS_txtToStruct(filename);
    if isstruct(a)

        % be nice
        disp(['Making ' monks{mm,1}(5:end-4) '...'])
        
        % make the figure
        fig = figure;
        wysifig(fig);

        % add label
        axes('Units', 'inches', 'position',[1.3 8.75 6.2 1.5]); cla reset; hold on;
        set(gca, 'Visible', 'off');
        
        h = [ ...
            text(0,1,monks{mm,1}(5:end-4)); ...
            text(0,.7,sprintf('Gender: %s, DOB: %s, Updated: %s', monks{mm,2}, monks{mm,3}, datestr(floor(now)))); ...            
            ];
        set(h,    'FontSize', 14);
        set(h(1), 'FontSize', 22, 'FontWeight', 'bold');
        
        if monks{mm,4} == 'n'
            h = [ ...
                text(0,.5,'NOT ON WATER CONTROL'); ...
                text(0,-0.2,'Reviewed by:'); ...
                ];
            set(h, 'FontSize', 22);
        else
            h = [ ...
                text(0,.5,sprintf('FRIDAY:             min = %.0f, typical = %.0f', monks{mm,10}, monks{mm,11})); ...
                text(0,.3,sprintf('SATURDAY:     min = %.0f, typical = %.0f', monks{mm,8}, monks{mm,9})); ...
                text(0,.1,sprintf('SUN-THURS:   min = %.0f, typical = %.0f - %.0f', monks{mm,5}, monks{mm,6}, monks{mm,7})); ...
                text(0,-0.2,'Reviewed by:')];
            set(h(end), 'FontSize', 22);
        end
        
        % get data
        dates   = a.data{strcmp(a.name,'Date')};
        water   = a.data{strcmp(a.name,'H20 (ml)')};
        dinds   = find(~isnan(water),1,'last')+(-150:0)';
        dinds   = dinds(dinds>0);
        dates   = dates(dinds);
        water   = water(dinds);
        weights = a.data{strcmp(a.name,'Weight (kg)')}(dinds);

        % mod(datenum, 7) == 0 is Friday, etc
        dnums = datenum(dates);
        dmods = mod(dnums, 7);
        LFri  = dmods == 0 & isfinite(water);
        LSat  = dmods == 1 & isfinite(water);
        Lweek = dmods >= 2 & isfinite(water);

        %% Water
        axes('Units', 'inches', 'position',[1.3 4.75 6.2 3]); cla reset; hold on;
        set(gca,'FontSize', 14);
        plot(dnums(LFri),  water(LFri),  'ko', 'MarkerSize', 8);
        plot(dnums(LSat),  water(LSat),  'g^', 'MarkerSize', 8);
        plot(dnums(Lweek), water(Lweek), 'r*', 'MarkerSize', 8);
        datetick(gca,'x',6)
        ylim([0 1000]);
        title('Water Data');
        ylabel('Water (ml)');
        % xlabel('Date');
        grid on
        h = legend( ...
            sprintf('Friday:       %.0f [%.0f-%.0f]', median(water(LFri)),  min(water(LFri)),  max(water(LFri))), ...
            sprintf('Saturday:   %.0f [%.0f-%.0f]', median(water(LSat)),  min(water(LSat)),  max(water(LSat))), ...
            sprintf('Sun-Thurs: %.0f [%.0f-%.0f]', median(water(Lweek)), min(water(Lweek)), max(water(Lweek))), ...
            'location', 'NorthWest');
        set(h, 'FontSize', 11);

        %% Weight
        axes('Units', 'inches', 'position',[1.3 1 6.2 3]); cla reset; hold on;
        NRMSZ = 15;
        set(gca,'FontSize', 14);
        plot(dnums, weights, 'k.', 'MarkerSize', 20);
        nrm = nanrunmean(weights, NRMSZ);
        plot(dnums, nrm, 'k-', 'LineWidth', 2);
        Lp = abs(weights-nrm)./nrm>0.05;
        plot(dnums(Lp), weights(Lp), 'mx', 'MarkerSize', 12);
        datetick(gca,'x',6)
        ylim([min(weights)-2 max(weights)+3]);
        title('Weight data');
        ylabel('Weight (kg)')
        xlabel('Date');
        grid on
        h = legend( ...
            sprintf('Mean = %.1f, Median = %.1f, Min = %.1f, Max = %.1f', ...
            nanmean(weights), nanmedian(weights), min(weights), max(weights)), ...
            sprintf('%.0f-point running mean', NRMSZ*2+1), ...
            '5+% away from running mean', ...
            'location', 'Northwest');
        set(h, 'FontSize', 11);
        
        % print it
        print('-depsc', fullfile(dirname,monks{mm,1}(5:end-4)))
    end
end
