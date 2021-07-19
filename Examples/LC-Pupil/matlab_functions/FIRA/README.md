# FIRA
# Utilities for making FIRA, a standard data structure

How to generate FIRA using your spm 
-----------------------------------

The FIRA structure is a standardized struct used by the Gold lab in Matlab to extract and analyze behavioral and physiological data acquired on the Plexon-MAP data acquisition system. The data acquired by the Plexon-MAP system can be used in 2 ways, either it can be stored in a .plx data file or it can be transmitted to Matlab in real time for online analysis. 

In either scenario (either store data in plx file or online analysis), there has to be method to convert the data from the Plexon-MAP system into a form that can be used in Matlab. This is done by using a Matlab 'spm' file that contains all the information needed by Matlab to interpret the data from the Plexon-MAP system into the standardized FIRA.

A typical experiment contains a number of streams of data and the spm tells Matlab how all these streams of data are to be interpreted and sorted to build a FIRA struct:
  - Analog eye position data from the eye tracker
  - Strobed words from QNX-Rex
  -	Unfiltered analog data (field potentials) from the recording electrodes
  -	Signal-processed spike data from the MAP box
  -	And possibly many many more...

A single standard FIRA struct makes it easier to analyze experimental data from a range of experiments using the same set of tools that are built around FIRA.

**Stored data file**

If the data is stored in a plx file, the data has to be processed or sorted into an intermediate .nex before it can be read into Matlab. The nex files are read and interpreted in Matlab by a collection of routines in the FIRA\build directory. In a nutshell, a number of necessary arguments, along with the filename and path of the nex file are passed to these routines (see make**_FIRA.m, bNex.m and bFile.m) which build FIRA from the nex file.

**Online Analysis**

For online analysis, Matlab needs to connect to the plexon MAP server, which streams data to Matlab. This is done using plotGUI, which connects to the MAP server, and using the spm specified, interprets the data it receives into FIRA. plotGUI also enables real-time plots and analysis of relevant parameters. (see plotGUI.m for more details).

How to write a spm in Matlab to generate FIRA
---------------------------------------------

**Introduction**

A spm is a Matlab m-file that provides a description for interpreting the contents of a nex file into a 'FIRA' structure in Matlab. The FIRA structure is a 'standardized' structure the Gold lab uses to extract, use and analyze data. The spm can either be used to either analyze the data within Matlab to make '.mat' files that contain the relevant data from that session OR can be used online while the subject doing an experiment for task relevant real-time analysis.

All examples used in this document will refer to spm760 and its strongly suggested that you have this or any other spm file open in matlab while going through the howto.

The spm file contains 3 sections, each referring to a different mode in which the spm can be used, and the input argument 'func' is used to switch mode. Each mode or 'func' does something different as described below.
  'init'         : fills FIRA.spm?
  'trial'        : parses current trial (in FIRA.trial)
  'cleanup'   : does whatever you need to do at the end of making FIRA
  
  NOTE: the commands from the spm will always be in italics and the docs will be in regular type.

**Header**

global FIRA
[declare FIRA to be a global structure that is accessible to all functions and scripts, including the spm.]

declareEC_ecodes
[declares all the ecodes that are being used in your experiment. If you are making a new spm, you should make sure that the ecodes that rex drops in your paradigm are declared in this file.]

**func 'init'**

The first mode/func is called when the argument 'init' is passed to the spm. The 'init' func is usually called from buildFIRA_init and it returns to buildFIRA_init descriptors or arguments that are then converted by buildFIRA_init into actual dataType objects used to build FIRA.spm and parse data into it. All the hard/dirty work is done by buildFIRA_init, which uses the arguments passed to it from the spm to fill in all the fields of FIRA corresponding to "dataTypes". The "dataTypes" specified by spm760 are described in more detail below.

The init section starts with a declaration of some useful markers that are used to interpret ecodes pairs:
cb = 7000;
cm = 6000;
cx = 7999;

cb is the base number that is subtracted from the second part of an ecode pair
cm is the minimum value that the second part of that ecode pair can take
cx is the maximum value that the second part of that ecode pair can take

The next section describes how the FIRA.datatype substructures are setup. As mentioned earlier, each "dataType" described corresponds to a FIRA.datatype substructure and the arguments listed for each "dataType" are converted by buildFIRA_init into actual dataType objects used to build that FIRA.datatype

FIRA.spm = struct( ...
    'trial',  {{ ...
    'startcd', 1005,                             ...
    'anycd',   [EC.CORRECTCD EC.WRONGCD EC.NOCHCD EC.FIX1CD], ...
    'allcd',   [] ...
    }}, ...
    'ecodes', {{  ...
    'extract', {   ...  % values to extract & save in FIRA{2}: <name> <type> <method> <args>
      'trg_on'    'time'     @getEC_time      {EC.TARGONCD 1}; ...
      'dot_coh'   'id'        @getEC_tagged    {EC.I_COHCD     cb    cb    cx  0.1};  ...
    }, ...
    'compute', { ...            % names/types of fields to compute & save later in FIRA{2}
      'cor_targ'      'id'; ...  % which target is correct t1(1) or t2(2)
    }, ...
    'tmp', { ...  % values to extract & use temporarily: <name> <type> <method> <args>
    }}}, ...
    'spikes',  [], ...
    'analog',  []);
  
  The code above sets up 4 "dataTypes": trial, ecodes, spikes and analog (i.e. FIRA.ecodes etc.).
  
*'trial'*

The 'trial' datatype is an exception as it doesnt result in a FIRA.trial, this datatype is used to setup how a 'good trial' is limited. The arguments here are used to modify the arguments specified in trial.m which are used to detect a good-trial.

'startcd',  1005, ...                                     % startcd, delimits trial
'anycd',    [EC.CORRECTCD EC.WRONGCD EC.NOCHCD], ...      % need to find ANY of these for a good trial
'allcd',    [], ...                                       % need to find ALL of these for a good trial

More details on this are found in FIRA\build\dataTypes\@trial\trial.m

*'ecodes'*

The 'ecodes' datatype sets up FIRA.ecodes which typically contains 3 structs: name (name of the ecode), type (type of ecode data) and data (the actual values for all ecodes for all trials). To make sure that your ecodes have been declared within matlab, open declareEC_ecodes.m. To see raw ecodes in a nex file, open the sample.nex file in NeuroExplorer and look at the 'markers' tab in the file.??Ecodes can contain data of 3 types (time, value and id) and what kind of data it contains has to be specified. The ecodes section has 3 parts - extract, compute and tmp.

'ecodes', {{  ...
  'extract', {   ...             % values to extract & save in FIRA{2}: <name> <type> <method> <args>
    'trg_on'    'time'     @getEC_time      {EC.TARGONCD 1}; ...
    'dot_coh'   'id'       @getEC_tagged    {EC.I_COHCD     cb    cb    cx  0.1};  ...
  }, ...
  'compute', { ...             % names/types of fields to compute & save later in FIRA{2}
    'cor_targ'      'id'; ...  
  }, ...
  'tmp', { ...                    % values to extract & use temporarily: <name> <type> <method> <args>
  }}},
  
*'extract'*

The arguments on the 'extract' section contains name (what this ecode will be called in FIRA), type, method (constructor method used to extract that ecodes data) and arguments that are passed to that method.

  'trg_on'    'time'     @getEC_time      {EC.TARGONCD 1};
  
Here the ecode name is 'trg_on', its type is 'time', the method is @getEC_time and the last cell contains the args passed to getEC_time. Briefly, EC.TARGONCD is the ecode to find, and getEC_time returns the time at which that ecode was dropped. Look at getEC_time.m for more details.

  'dot_coh'   'id'       @getEC_tagged    {EC.I_COHCD     cb    cb    cx  0.1};  ...
  
This ecode is similar, but its type is now 'id' and the method is @getEC_tagged and the last cell contains the args passed to getEC_tagged. Briefly, 'EC.I_COHCD' is the ecode to find, 'cb' is the base value to be subtracted from the second part of the ecode pair, cm & cx are the minimum and maximum values that the data corresponding to that ecode can take and 0.1 is the scale factor. ?e.g. A coherence of 99.9% would correspond to a ecode pair of 8011, 7999. 

Look at getEC_tagged.m for more full details.

*'compute'*

This section has ecodes that are setup here but the data for these ecodes is only filled when the 'trial' mode/func of the spm is called.

**func 'trial'**

This func/mode is where data corresponding to ecodes in the 'compute' section of the spm are filled in. The code in this section reads data from FIRA, computes the ecode data and fills the computed data into corresponding FIRA.ecodes.data??In the example below, the correct target is computed and filled into the column for cor_targ in FIRA.ecodes.data

dot_val = getFIRA_ec(tti, {'dot_dir'}); % dot_val = value of ecode 'dot_dir' for trial #tti

if dot_val==0
  setFIRA_ec(tti, {'cor_targ'}, 2); % if the condition is true, then set value of ecode 'cor_targ' for trial #tti to 2
elseif dot_val==180
  setFIRA_ec(tti, {'cor_targ'}, 1); % elseif the condition is true, then set value of ecode 'cor_targ' for trial #tti to 1
end

This mode/func is used to compute any ecodes that are not obvious; i.e., are not contained in the nex file, but have to be computed for every trial. If the data for an ecode is already present in the nex file, then the ecode should not be computed here, instead used the extract section of the 'init' func. If the computation for an ecode is general and can be done for an entire session at once, it should be computed in the 'cleanup' func/mode.

**func 'cleanup'**

The 'cleanup' func/mode is for anything you need to do at the end of building a FIRA. Typically data that donot have to be computed individually for each trial are computed in the this mode.
e.g. the code below collapses angles into a 0 to 360 range for all trials for ecode 'dot_dir'

if ~isempty(FIRA.ecodes.data)
  col = getFIRA_ecc('dot_dir');
  FIRA.ecodes.data(:, col) = mod(FIRA.ecodes.data(:, col), 360);
end

