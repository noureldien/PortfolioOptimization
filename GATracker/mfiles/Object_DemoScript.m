%% Object Demostration script
% Simple script to run through some properties of MATLAB objects that we
% use in the Index tracker demostration.
clear classes; clc
%% Pass by reference
% DemoObject inherits from the handle class, so we can now do pass by
% reference
edit  DemoObject;

%%
obj = DemoObject

obj.Value = 2

%% Events
% Add a listener to the object and then send the event
L = addlistener(obj,'Catastrophe',@(src,evt) disp('Disaster Detected'));

%%
notify(obj,'Catastrophe');

%% 
% Objects can listen to events in other objects. Also events can carry data
% with them.
edit DemoObject2

%%
obj2 = DemoObject2;
ListenFor(obj2,obj,'Catastrophe');

%%
SendEvent(obj);