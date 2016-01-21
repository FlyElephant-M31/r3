clc
clear

addpath('synthetic_problems');

nlength = 10;

ntrain = 20000;
ntest = 1000;
nvalidation = 500;

%[U1, T1] = get_addition_problem(nlength, ntrain);
[U2, T2] = get_addition_problem(nlength, ntest);
[U3, T3] = get_addition_problem(nlength, nvalidation);

%% Create net

nin = 2;
nhidden = 100;
nout = 1;
srn_net = srnnew(nin, nhidden, nout);

%% Make train

nminibatch = 100;
niterations = 50;

lr = 1e-04;
mu = 0.90;

[U1, T1] = get_addition_problem(nlength, ntrain);

best_mse_val = 100500;

C = {};

for k = 1:1000
    tic
    srn_net = train_SGD_pak(srn_net, U1, T1, nlength, nminibatch, niterations, lr, mu);
    
    [Y2, ~, Z1_2, R1_2] = srnfwd(srn_net, U2, nlength);
    
    esr_train = 0;
    esr_val = error_success_rate(T2, Y2);
    mse_train = 0;
    mse_val = mse(T2 - Y2);
    
    if (mse_val < best_mse_val)
        best_mse_val = mse_val;
        best_esr_val = esr_val;
        best_srn_net = srn_net;
    end
    
    c.esr_train = esr_train;
    c.esr_val = esr_val;
    c.mse_train = mse_train;
    c.mse_val = mse_val;
    
    if (esr_val > 99)
        break;
    end
    
    C{k} = c;
    
    t=toc;
    
    disp(sprintf('k = %d, esr_val = %1.1f%%, mse_val = %f, t = %1.2f sec', k, esr_val, mse_val, t));
    
    %fprintf('k = %d, esr_val = %1.1f%%, mse_val = %f, t = %1.2f sec\n', k, esr_val, mse_val, t);
end

max_k = k - 1;

Y3 = srnfwd(best_srn_net, U3, nlength);
esr_test = error_success_rate(T3, Y3);
esr_test