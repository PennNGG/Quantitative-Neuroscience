function bConnect_loop
% function bConnect_loop
%
% Convenience function for building FIRA from 
% a connection to the Plexon server.
% Assumes bConnect has been called already to set
%  up FIRA; grabs data and fills FIRA

% Get connection data
connectPLX_loop;

% alloc mem in fira
buildFIRA_alloc;

% parse data
buildFIRA_parse;

% cleanup 
buildFIRA_cleanup(true);
