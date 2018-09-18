function filenames = gimme_a_file(varargin)
% --- gimme_a_file ---
%
% Provides a list of filenames that are fit a desired set of inputs.
% 
% -----------------------------------------------------------------------
% Usage:
%   filenames = gimme_a_file(name/value pair)
%
% Inputs are given as a name/value pair, where the name will relate to the
% field you're wanting to search (ie monkey, task etc) and the value will
% be the corresponding search term. This should be a valid value for the
% corresponding search field. Use as many or as few as you want.
%
% -----------------------------------------------------------------------
% Valid Search Fields:
%*   numRes                Maximum number of files to return. [default:20]
%*   monkey_name           Name of the monkey. This must be a string.
%*   ccm_id                CCM ID. This is a string
%*   task_name             Name of the task. This must be a string. 
%*   task_description      Task description. If you're not sure about the
%                             exact name that was used, or want a general
%                             type of task instead of just one task.
%*   implant_location      Location of the implant (ie rightM1), can input 
%                             just a part of the implant location (ie M1)
%                             and it'll return everything that matches
%                             that.
%*   array_type            Array type (typically going to be Utah)
%*   rec_date              Date of the recording. A range of dates can be
%                             input using a pair of dates such as 
%                             [06/15/2018 06/18/2018]
%*   behavior_quality      'Good','ok','bad'; this if for an individual
%                             session
%*   behavior_quality_day  'Good','ok','bad';this is for the day as a whole
%*   lab_num               Lab number
%*   duration              length of the recording in seconds. You can also
%                             input a range ie [600 900]. If you want a
%                             minimum length enter [600 NaN], if you want a
%                             maximum length enter [Nan 900].
%*   numChannels           number of recorded channels. You can also input
%                             a range in the same format as duration.
%*   hasTriggers           True/False
%*   hasChaoticLoad        True/False
%*   hasBumps              True/False
%*   numTrials             number of trials performed. You can also use an
%                             input range of the same format as duration
%*   numReward             number of successful trials. Can be a value range
%*   numAbort              number of aborted trials. Can be a value range
%*   numFail               number of failed trials. Can be a value range
%*   numIncomplete         number of incomplete trials. can be a range
%*   



%% Data input checking, formatting to sqlQuery
if mod(nargin,2)
    error('Inputs must be a name/value pair. See documentation for more info');
elseif nargin == 0
    error('You need to enter something to search for')
end



sqlQuery = ['SELECT m.monkey_name AS name, m.ccm_id, d.rec_date AS date, ',...
    'd.day_key, ];

for ii = 1:2:nargin
    if ~any(strcmpi(varargin(ii),validFields)
        error(['Invalid search field: ', varargin(ii)
    




%% connection to the database









%% send the sqlQuery, check for errors







%% return the filenames








end