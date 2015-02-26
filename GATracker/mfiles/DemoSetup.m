% Add folders to path and move to relevant place
w = which(mfilename);
Here = fileparts(w);
DemoDir = fileparts(Here);
cd([DemoDir,'\mfiles']);
addpath(DemoDir,...
    [DemoDir,'\gaDemo'],...
    [DemoDir,'\CointegrationTracker'],...
    [DemoDir,'\mfiles'],...
    [DemoDir,'\Objects'],...
    [DemoDir,'\Data']);

% Open scripts and presentation

% edit('demoGA');
% edit('GA_TrackerDemo');
% edit('BankAccount');
% edit('AccountManager');
% edit('Index_Tracker_Short');
% edit('Batch_Run_Results');

%winopen([DemoDir,'\Building an Index Tracker in MATLAB.ppt']);

% Clean up session
clear all
close all
clc
warning off
