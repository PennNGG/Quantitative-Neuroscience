function mc_ = matCmds(varargin)
% function mc_ = matCmds(varargin)
%
% Constructor method for class matCmds
%   (Matlab Commands, typically controlling
%       the visual display)
%
% Input:
%   varargin ... ignored
%
% Output:
%   mc_ ... the created matCmds object 
%       to be stored in FIRA.spm.matCmds
%   Also creates:
%       FIRA.raw.matCmds = []
%       FIRA.matCmds (created by set method)     

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania

global FIRA

% make the matCmds struct
mc = struct();

if ~isempty(FIRA)

    %% make FIRA.raw.matCmds
    %  cmds is double matrix with columns:
    %       timestamp       command_index     #_arguments
    %
    %   command_indices are as follows, from mns/Matlab.h:
    %
    %       #define MAT_INIT_SCREEN_CMD			0
    %       #define MAT_ALL_OFF_CMD				1
    %       #define MAT_SET_CLUT_CMD			2
    %       #define MAT_DUMMY_WENT_CMD			3
    %       #define MAT_SET_WENT_CMD			4
    %       #define MAT_UNSET_WENT_CMD			5
    %       #define MAT_STROBE_STOP_CMD			6
    %
    %   /* TARGET COMMANDS 	100 - 199 */
    %       #define MAT_SHOW_TARGET_CMD			100
    %       #define MAT_HIDE_TARGET_CMD			101
    %       #define MAT_STROBE_TARGET_CMD		102
    %       #define MAT_CHANGE_TARGET_CMD		103
    %       #define MAT_CHANGE_TARGET_WAIT_CMD	104
    %
    %   /* DOTS COMMANDS 		200 - 299 */
    %       #define MAT_DOTS_SETUP_CMD			200
    %       #define MAT_DOTS_GO_CMD				201
    %       #define MAT_DOTS_STOP_CMD			202
    %       #define MAT_DOTS_STOP_ABORT_CMD		203
    %       
    %
    %  args is cell array, each entry is
    %       arg_#   value
    FIRA.raw.matCmds = struct( ...
        'cmds',     [], ...
        'args',     [], ...
        'ind',      1);

    % make FIRA.matCmds
    FIRA.matCmds = {};
end

% struct is empty so don't even bother checking for args
mc_ = class(mc, 'matCmds');
