% FIRA directory
%
% updated by jig, 11/04
% 
% subdirectories
% -------------------
% build: routines for building FIRA (buildFIRA_*).
% 	These routines each perform a specific function
% 	and are combined in different ways to create FIRA,
% 	depending on what kind of data you're getting in
% 	and what you want FIRA to include.
% 	Subdirectories:
% 		- buildScripts ... the most useful tools if you just
% 			want to make FIRA using standard methods.
% 			These scripts invoke the buildFIRA_* tools
% 			in the appropriate order, etc., for building
% 			FIRA out of, e.g., Nex files, Rex files, etc.
% 		- dataTypes ... defines the different data types
% 			that FIRA can be composed of. Each data type
% 			(class) is defined by several methods that, for
% 			the most part, correspond to the buildFIRA_*
% 			functions; that is, calling buildFIRA_* simply
% 			calls the appropriate method(s) for the data types
% 			in the current FIRA
% 		- readers ... methods for reading different data formats.
% 			As of 3/3/05, it only includes Rex files, Nex files,
% 			and connections to the Plexon server. These
% 			are typically invoked by buildFIRA_read
% 		- spm ... user 'scripts' for defining how to set up FIRA
% 			(mostly defining which dataTypes to include,
% 			what parameters each dataType has, and
% 			the ability to modify stored data for each trial)
% 
% gui: graphical interface for converting/viewing FIRA data.
% 	run "plotGUI" to start it.
% 
% utilities: useful stuff for accessing data in FIRA}