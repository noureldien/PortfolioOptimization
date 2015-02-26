function fpos = InitialiseSession

% Prepare the MATLAB session - clear it and create a figure size we
% use throughout
evalin('base',['close all;',...
    'clear all;',...
    'clear classes',...
    'clc;']);
S = get(0,'screensize'); 


fpos = [100 100 S(3)-200 S(4)-200];

end
