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
    
% modified LD 2009-05-13
%     % get data from Plexon
%     [na, ta, da] = PL_GetAD(FIRA.header.filename);
    [na, ta, da] = PL_GetADV(FIRA.header.filename);
    temp_gains = PL_GetADGains(FIRA.header.filename);
    plx_params = PL_GetPars(FIRA.header.filename); 
    ind_gains = plx_params([1:plx_params(7)]+269);
    plx_gains = temp_gains(ind_gains);
    % parse the data
    if na && ~isempty(ta) && ~isempty(da) 
        
        % make sure the raw data structs are set up
        if isempty(FIRA.analog.name)
            
            % useful variables
            num_channels = size(da, 2);
            pl_params    = PL_GetPars(FIRA.header.filename);

            if ~verify(FIRA.spm.analog, 1:num_channels, pl_params(8))
                return
            end
        end
        
        % NOTE -- for now we're assuming all channels have the same acquire rate
        sf = 1/FIRA.analog.acquire_rate(1);

% modified LD 2009-05-13 currently the gain setup is not quite right
        % get the data
%         FIRA.raw.analog.data = ...
%             [FIRA.raw.analog.data; [1000*[ta:sf:(ta+sf*(na-1))]' ...
%             [FIRA.raw.analog.data; [1000*[ta:sf:(ta+sf*(na-1))]' ...
%             da(:, FIRA.raw.analog.params.kept_sigs).*...
%             repmat(FIRA.analog.gain,size(da,1),1)+repmat(FIRA.analog.offset,size(da,1),1)]];
%         FIRA.raw.analog.data = ...
%             [FIRA.raw.analog.data; [1000*[ta:sf:(ta+sf*(na-1))]' ...
%             da(:, FIRA.raw.analog.params.ks)./40]];
        gains = 1000.*FIRA.analog.gain;
%         gains = 1000./plx_gains(FIRA.raw.analog.params.kept_sigs).*FIRA.analog.gain;
        FIRA.raw.analog.data = ...
            [FIRA.raw.analog.data; [1000*[ta:sf:(ta+sf*(na-1))]' ...
            da(:, FIRA.raw.analog.params.kept_sigs).*...
            repmat(gains,size(da,1),1)] ];
% max(FIRA.raw.analog.data(:,2))
%                 FIRA.raw.analog.data = [FIRA.raw.analog.data allad{i}/adgains(ind_ads(i))*FIRA.analog.gain(i)*1000]; 

        % save size of data, just 'cuz
        FIRA.raw.analog.params.asz = size(FIRA.raw.analog.data, 1);
    end
end
