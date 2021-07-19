function connectPLX_loop
% function connectPLX_loop
%
% adds data from the Plexon connection to FIRA.raw
% Note: still must call buildFIRA_parse to add the raw data
% to FIRA.(dataTypes)
%
% Arguments:
%   force_flag  ... if 1, force a verify of new spike channel/units

% Copyright 2005 by Joshua I. Gold
%   University of Pennsylvania
%
% history:
% created 11/05/04 by jig

global FIRA

%if isempty(FIRA) || ~strcmp(FIRA.header.filetype, 'connect')
%    return
%end

if nargin < 1
    force_flag = false;
end

% get the latest timestamp data from Plexon
[nt, tt] = PL_GetTS(FIRA.header.filename);

if nt

    % put timestamps in ms
    tt(:,4) = tt(:,4)*1000;
    
    % parse the ecode data, filling the global raw data struct
    % we're not dealing with plexon spikes, but remember that the ecodes from
    % rex may contain rex (601:608) spikes
    parseEC_rawCodes(tt(tt(:,1)==4, [4 3]));

    % now parse the plexon spikes
    if isfield(FIRA, 'spikes')
        
        % get all the Plexon spike data & verify valid units
        Fsp = find(tt(:,1) == 1);
        Lsp = verify(FIRA.spm.spikes, tt(Fsp,2:3));
        
        % if there are any new spikes
        if any(Lsp)
            
            % concatenate all the new spike data to what we already have
            %   <timestamp> <id>, where id = 1000*channel+unit
            inds = Fsp(Lsp);
            FIRA.raw.spikes = [FIRA.raw.spikes; ...
                [tt(inds,4) tt(inds,2)*1000+tt(inds,3)]];
        end
    end
end

% Analog data
if isfield(FIRA, 'analog')
    
    % get data from Plexon
    [na, ta, da] = PL_GetAD(FIRA.header.filename);
    
    % parse the data
    if na && ~isempty(ta) && ~isempty(da)
                
        % make sure the raw data are listed in the appropriate order
        % expected by FIRA.analog
        if isempty(FIRA.analog.name) || isempty(FIRA.analog.store_rate)

            % get user-defined channel parameters
            ks = buildFIRA_get('analog', 'keep_sigs');   % 'all' or [<list>]          
            so = buildFIRA_get('analog', 'channel_order'); % [<list>] or []
            
            % get sort order, which by default includes
            % the highest-numbered channels (i.e., eye position)
            num_channels = size(da, 2);            
            if length(so) > num_channels
                so = so(end-num_channels+1:end);
            elseif length(so) < num_channels
                so = 17-num_channels:16; % trust me
            end
            
            % convert keep sigs to indices of sort order
            if isnumeric(ks)
                [tmp, ks] = ismember(ks, so);
            else
                ks = 1:length(so);
            end

            % save the result
            FIRA.raw.analog.params.ks = ks;
            
            % set up FIRA.analog
            if isempty(FIRA.analog.acquire_rate)
                
                % connection params gives the store rate
                pl_params                = PL_GetPars(FIRA.header.filename);
                FIRA.analog.acquire_rate = ones(1,length(ks))*pl_params(8);
                FIRA.analog.store_rate   = FIRA.analog.acquire_rate;
            end

            if isempty(FIRA.analog.name)
                
                % set to the default channel names
                FIRA.analog.name = getPLX_analogNames(so(ks));
            end
            
            % possibly override store rates
            resample = get(FIRA.spm.analog, 'resample');
            if ~isempty(resample)
                for rr = 1:size(resample, 1)
                    Lr = strcmp(resample{rr,1}, FIRA.analog.name);
                    if sum(Lr) == 1 && isfinite(resample{rr,2})
                        FIRA.analog.store_rate(Lr) = resample{rr,2};
                    end
                end
            end
        end
        
        % NOTE -- for now we're assuming all channels have the same acquire rate
        sf = 1/FIRA.analog.acquire_rate(1);

        % get the data
        FIRA.raw.analog.data = ...
            [FIRA.raw.analog.data; [1000*[ta:sf:(ta+sf*(na-1))]' ...
            da(:, FIRA.raw.analog.params.ks)./40]];

        % save size of data, just 'cuz
        FIRA.raw.analog.params.asz = size(FIRA.raw.analog.data, 1);
    end
end
