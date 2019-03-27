% Main Script
% This script uses the other m files to run the simulation


%% Prepare Workspace

clc, clear, close all;
import classes.*

%% Initialize Simulation

num_links = 100;
link_array(num_links) = Link;
for idx = num_links:-1:1
    link_array(idx) = Link;
end

link_array
