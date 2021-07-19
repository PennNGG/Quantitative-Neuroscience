function parse(m)
% function parse(m)
%
% Parse method for class matCmds
% Reads FIRA.raw.matCmds and FIRA.raw.trial
%   and fills FIRA.matCmds, a cell array:
%   {<full cmd/arg string>, timestamp, cmd, #args, args}   
%
% 
% Input:
%   m ... the matCmds object
%
% Output:

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA
persistent cmdi cmds

% define cmds
if isempty(cmds)
    cmdi = [0 1 2 3 4 5 6 100 101 102 103 104 200 201 202 203]';
    cmds = { ...
        'initScreen',       ...
        'allOff',           ...
        'setCLUTIndex',     ...
        'dummyWent',        ...        
        'setWent',          ...
        'unsetWent',        ...
        'strobeStop',       ...
        'showTarget',       ...
        'hideTarget',       ...        
        'strobeTarget',     ...
        'changeTarget',     ...
        'changeTargetWait', ...
        'dots8',            ...
        'dots8',            ...
        'dots8Stop',        ...
        'dots8Abort'};
end

% get the commands (<timestamp> <command_index> <# args>)
Fc = find(FIRA.raw.matCmds.cmds(:,1)>=FIRA.raw.trial.start_time & ...
    FIRA.raw.matCmds.cmds(:,1)<=FIRA.raw.trial.end_time);

if ~isempty(Fc)
    cmdC = cell(size(Fc,1), 5);
    
    for ii = 1:size(Fc,1)
        
        % timestamp, cmd, # args, args
        cmdC{ii, 2} = FIRA.raw.matCmds.cmds(Fc(ii), 1) - FIRA.raw.trial.wrt;
        cmdC{ii, 3} = FIRA.raw.matCmds.cmds(Fc(ii), 2);
        cmdC{ii, 4} = FIRA.raw.matCmds.cmds(Fc(ii), 3);
        cmdC{ii, 5} = FIRA.raw.matCmds.args{Fc(ii)};

        % make the cmd
        cmd = cmds{cmdC{ii,3}==cmdi};
        if ~isempty(cmd)
            cmd = [cmd '('];
            for aa = 1:cmdC{ii, 4}
                La  = cmdC{ii,5}(:,1)==aa;
                if ~any(La)
                    arg = '[]';
                else
                    arg = mat2str(cmdC{ii,5}(La,2)');
                end
                cmd = [cmd arg ','];
            end
            if cmdC{ii, 4} > 0
                cmdC{ii, 1} = [cmd(1:end-1) ');'];
            else
                cmdC{ii, 1} = [cmd(1:end-1) ';'];
            end
        end
    end
end

% save the cell array    
FIRA.matCmds{FIRA.raw.trial.good_count, 1} = cmdC;
