function parseEC_rawCodes(codes)
% function parseEC_rawCodes(codes)
%
% Reads the given ecodes matrix in which
%   each row is <timestamp> <ecode>
% and figures out which codes are acual ecodes and 
% which are spikes, dio commands, matlab commands, and
% matlab arguments
%   
% Fills in (when appropriate, depending on the existance
%   of each data type in FIRA.raw) the following:
%   FIRA.raw.ecodes  ... nx2 matrix of "general" ecodes -- that is, the ecodes
%                         normally dropped in the REX e-file
%                         columns are <timestamp> <value>
%   FIRA.raw.spikes  ... in rex, sent as codes 601:608
%   FIRA.raw.matCmds ... struct with fields "cmds", "args", and "index"
%                        cmds is nx3 matrix of "MATLAB command" ecodes, which
%                         are commands sent to ShadlenDots
%                         columns are: <timestamp> <cmd_index> <total_#_args>
%                        args is nx1 array of Cells (thus the "C")...
%                         each Cell is an mx2 matrix of arguments
%                         columns are <arg #> <arg value>
%                         Note that arguments are typically sent low priority,
%                         which means that, in principle, they can be delayed 
%                         relative to other messages... which is why we have to be
%                         careful to keep filling them in as they come
%                        index keeps track of matlab arguments
%   FIRA.raw.dios   ... nx3 matrix of "dio" ecodes, which correspond to 
%                        commands send via the dio interface to rack-mounted
%                        modules (e.g., reward system)
%                        columns are <timestamp> <port> <data>
%

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

if nargin < 1 || isempty(codes)
    return
end

% get selection arrays for type
Lp  = codes(:,2) >= 0;
L14 = bitget(abs(codes(:,2)), 14);
L15 = bitget(abs(codes(:,2)), 15);

%%%
% ecodes (& Rex spikes)
%%%
if isfield(FIRA, 'ecodes')

    % type mask is 0 0
    Li = ~L15 & ~L14;
    if(any(Li))

        % get the codes
        % message is lsb 13 bits (12 - 0)
        % EC_CODE_MASK = 8191;
        ec = codes(Li, [1 2]);

        % Spikes in Rex are sent as ecodes 601:608
        sp      = [601:608]';
        Lspikes = ismember(ec(:, 2), sp);

        % append the ecodes
        FIRA.raw.ecodes = [FIRA.raw.ecodes; ec(~Lspikes, :)];

        % append the spikes... treat Rex spike codes (601:608) as spike
        % channels (or units)
        if any(Lspikes) && isfield(FIRA.raw, 'spikes')

            Lgood = verify(FIRA.spm.spikes, ec(Lspikes, 2));
            if any(Lgood)
                inds = find(Lspikes);
                FIRA.raw.spikes = [FIRA.raw.spikes; ec(inds(Lgood),1) 1000+ec(inds(Lgood),2)];
            end
        end
    end
end


%%%
% MATLAB commands and arguments
%%%
if isfield(FIRA, 'matCmds')
    
    % command type mask is 1 0
    Li = L15 & ~L14;
    if any(Li)
        
        % get number of commands
        num_cmds = sum(Li);

        % Command is bits 12 - 3 (10 bits)
        % # Args is bits   2 - 0 (3 bits)
        EC_CMD_MASK  = 8184;
        EC_CMD_SHIFT = -3;
        EC_ARG_MASK  = 7;
        
        % store FIRA.raw.matCmds.cmds as array of 
        % [<timestamp> <command> <# arguments>]
        cmds = [codes(Li, 1) ...
            bitshift(bitand(codes(Li,2), EC_CMD_MASK), EC_CMD_SHIFT) ...
            bitand(codes(Li,2), EC_ARG_MASK)];
        FIRA.raw.matCmds.cmds = [FIRA.raw.matCmds.cmds; cmds];

        % update the argument array ... an array of cells, one
        % for each command
        if isempty(FIRA.raw.matCmds.args)
            FIRA.raw.matCmds.args = cell(num_cmds, 1);
        else
            FIRA.raw.matCmds.args{end+num_cmds} = [];
        end
        
        % mark 0-argument commands
        argIs = find(cmds(:,3)==0);
        if ~isempty(argIs)
            [FIRA.raw.matCmds.args{end-num_cmds+argIs}] = deal(0);
        end
    end

    % argument type mask is 1 1
    Li = L15 & L14;
    if sum(Li)

        % Arg number is bits 12 - 10 (3 bits)
        % Value is bits       9 - 0  (10 bits)
        % remember that arg #0 marks the end of the arguments to a given command
        EC_ARN_MASK  = 7168;
        EC_ARN_SHIFT = -10;
        EC_VAL_MASK  = 1023;
        args = [bitshift(bitand(codes(Li,2), EC_ARN_MASK), EC_ARN_SHIFT) ...
            bitand(codes(Li,2), EC_VAL_MASK)];

        % get indices of "0" entries, which mark end of argument list
        a0inds = [0 find(args(:,1) == 0)'];
        if a0inds(end) ~= size(args,1)
            a0inds = [a0inds size(args,1)];
        end
        
        % loop thru the args, adding to appropriate cells
        ai  = FIRA.raw.matCmds.ind;
        len = length(FIRA.raw.matCmds.args);
        for i = 1:length(a0inds)-1
            % find the first empty or incomplete arg Cell
            while ai <= len & ~isempty(FIRA.raw.matCmds.args{ai}) & FIRA.raw.matCmds.args{ai}(end,1) == 0
                ai = ai + 1;
            end
            FIRA.raw.matCmds.args{ai} = [FIRA.raw.matCmds.args{ai}; [args(a0inds(i)+1:a0inds(i+1), 1) ...
                twosc(args(a0inds(i)+1:a0inds(i+1), 2))]];
        end

        % update the argIndG pointer to the next empty or incomplete Arg Cell
        while ai <= len & ~isempty(FIRA.raw.matCmds.args{ai}) & FIRA.raw.matCmds.args{ai}(end,1) == 0
            ai = ai + 1;
        end
        FIRA.raw.matCmds.ind = ai;
    end
end
    
%%%
% dio commands
%%%
if isfield(FIRA, 'dio')
    
    % type mask is 0 1
    Li = ~L15 & L14;
    if any(Li)
        
        % Port is bits 12 - 8 (5 bits)
        % Data is bits  7 - 0 (8 bits)
        EC_PORT_MASK  = 7936; % 5 bits = 0x1f00
        EC_PORT_SHIFT = -8;
        EC_DATA_MASK  = 255;  % 8 bits = 0xff

        % save as <timestamp> <port> <data>
        FIRA.raw.dio = [FIRA.raw.dio; [codes(Li, 1) ...
            bitshift(bitand(codes(Li,2), EC_PORT_MASK), EC_PORT_SHIFT) ...
            bitand(codes(Li,2), EC_DATA_MASK)]];
    end
end

%%%
% SUBFUNCTION: twosc
%%%
%
% Matlab argument values are in 10-bit two's compliment
%
function new_vals_ = twosc(arg_vals)

new_vals_        = zeros(size(arg_vals));
Lpos             = bitget(arg_vals,10) == 0;
new_vals_(Lpos)  = arg_vals(Lpos);

% to get two's compliment, flip bits and add one
new_vals_(~Lpos) = -(bitxor(1023,arg_vals(~Lpos))+1);
