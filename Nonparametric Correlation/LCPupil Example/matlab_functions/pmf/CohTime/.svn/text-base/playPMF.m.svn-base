% play PMF

% get monkeys, colors
monks = getBIAS_monks('FEF');
monkn = length(monks);

fun   = @logist2;

mdat = cell(monkn, 2);

for mm = 1:monkn

    dat          = getBIAS_data(monks{mm});
    Lgood        = dat(:,2) <= 2 & sum(isfinite(dat(:,[3 5 6 8 9])),2)==5;
    Lcor         = dat(:,3) == 1;
    Llong        = dat(:,6) > 0.2;
    Lstim        = [dat(:,17)==0 dat(:,17)==2];
    sessions     = unique(dat(:,1));
    num_sessions = length(sessions);

    % make signed coh
    dat(:,5) = dat(:,5).*dat(:,8);

    % dummy data for computing threshold
    ddat = (-1:0.001:1)';
    ddat = [ddat ones(size(ddat))];
    
    sdat = nans(num_sessions, 2, 2); % lapse/thresh, stim/nostim
    hdat = nans(num_sessions, 3, 2); % avg coh/time/diff, stim/nostim
    
    % loop through the sessions
    for ss = 1:num_sessions

        for tt = 1:2
            
            Lses = Lgood & dat(:,1) == sessions(ss) & Lstim(:,tt);
            disp([ss sessions(ss) sum(Lses)])
            
            if sum(Lses) > 100

                % compute lapse
                Llapse = Lses & Llong & dat(:,5)== max(dat(Lses,5));
                if sum(Llapse) > 5
                    lapse = 1-sum(Llapse&Lcor)/sum(Llapse);
                end
                
                % fit to simple model
                [f,s,t] = ctPsych_fit(fun, dat(Lses,[5 6]), (dat(Lses, 9)+1)/2, [], [], [], [], lapse);
                
                % compute threshold
                t1 = (log(.75/.25)-f(1))/f(2);
                t2 = (log(.25/.75)-f(1))/f(2);
                
                sdat(ss,:,tt) = [t1-t2, lapse];
            
                % diff
                hdat(ss,:
            end
        end
    end
    mdat{mm} = sdat;
end

clf
sy = {'ko' 'k.'};
for pp = 1:2
    for mm = 1:2
        subplot(2,2,(pp-1)*2+mm); cla reset; hold on;
        for tt = 1:2
            plot(mdat{mm}(:,pp,tt), sy{tt});
        end
        if pp == 1
            set(gca, 'YScale', 'log');
        end
    end
end


