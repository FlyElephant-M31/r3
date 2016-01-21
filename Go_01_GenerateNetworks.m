clc
clear

addpath('synthetic_problems');

%% Prepare data

nlength = 100;
ntrain = 500;

[U1, T1] = get_temporder_problem(nlength, ntrain);

nin = 6;
nhidden = 100;
nout = 4;

%% Create net

srn_pure_array = {};

tic
for i = 1:10
    srn_net = srnnew(nin, nhidden, nout);
    srn_pure_array{i} = srn_net;       
end
toc

save(sprintf('SRN_%d_WS', nlength), 'srn_pure_array');