clc
clear

addpath('synthetic_problems');

GR_ON = 1;
nlength = 10;

if (GR_ON == 0)
    status_str = 'OFF';
else
    status_str = 'ON';
end

%[U, T] = get_temporder_problem(10, 3);

parfor NN_No = 1:4
    %% Prepare data
    
    ntrain = 20000;
    %ntrain = 2000;
    ntest = 1000;
    nvalidation = 500;
    
    %[U1, T1] = get_temporder_problem(nlength, ntrain);
    [U2, T2] = get_temporder_problem(nlength, ntest);
    [U3, T3] = get_temporder_problem(nlength, nvalidation);
    
    
    %% Create net
    
    %nin = 6;
    %nhidden = 100;
    %nout = 4;    
    %srn_net = srnnew(nin, nhidden, nout);
    
    %load(sprintf('SRN_%d_v01_WS', nlength));
    %load(sprintf('SRN_%d_v02_010_WS', nlength));
    %load(sprintf('SRN_%d_v03_smart_WS', nlength));    
    
    load(sprintf('nets_temporder\\SRN_%d_WS_v01.mat', nlength));       
    srn_net = srn_pure_array{NN_No};
    
    out_path = sprintf('out_n%d_%s\\srn_%03d', nlength, status_str, NN_No);
    mkdir(out_path);
    
  % [Y2, ~, Z1_2, R1_2] = srnfwd(srn_net, U2, nlength);    
	% [f, norm_gw1_in_in_time, norm_gw1_rec_in_time, norm_deltas_hidden_in_time] = make_plot_gradients(srn_net, Y2, U2, Z1_2, R1_2, T2, nlength, 'off', '');
	% saveas(f, sprintf('%s\\Gradients_%03d.jpg', out_path, 0));    
  % save(sprintf('%s\\net_init_WS', out_path), 'srn_net');   

    %% Make train
    
    nminibatch = 1;
    niterations = 50;
    
    lr = 5e-06;
    mu = 0.90;
    %mu = 0;
    
    [U1, T1] = get_temporder_problem(nlength, ntrain);
    
    best_mse_val = 100500;
    
    C = {};
        
    for k = 1:5%000
        tic
        srn_net = train_SGD_pak(srn_net, U1, T1, nlength, nminibatch, niterations, lr, mu, GR_ON);                
        
        [Y2, ~, Z1_2, R1_2] = srnfwd(srn_net, U2, nlength);
        
        esr_train = 0;
        esr_val = error_classification(T2, Y2);
        mse_train = 0;
        mse_val = mse(T2 - Y2);
        
        if (mse_val < best_mse_val)
            best_mse_val = mse_val;
            best_esr_val = esr_val;
            best_srn_net = srn_net;
        end
        
        t = toc;
        fprintf('<strong>NN_No=%d k = %d, esr_val = %1.1f%%, mse_val = %f, t = %1.2f</strong>\n', NN_No, k, esr_val, mse_val, t);
        
        c.esr_train = esr_train;
        c.esr_val = esr_val;
        c.mse_train = mse_train;
        c.mse_val = mse_val;
        
        if (mod(k, 1) == 0)
            %s = sprintf('mse=%f/%f, esr=%1.2f%%/%1.2f%%', mse_train, mse_val, esr_train, esr_val);            
            %[f, norm_gw1_in_in_time, norm_gw1_rec_in_time, norm_deltas_hidden_in_time] = make_plot_gradients(srn_net, Y2, U2, Z1_2, R1_2, T2, nlength, 'off', s);
            %saveas(f, sprintf('%s\\Gradients_%04d.jpg', out_path, k));
            %save(sprintf('%s\\srn_net_%04d_WS', out_path, k), 'srn_net');
            
            %fprintf('k = %d, esr_train = %1.1f%%, esr_val = %1.1f%%, mse_train = %f, mse_val = %f\n', k, esr_train, esr_val, mse_train, mse_val);
            
            %c.norm_gw1_in_in_time = norm_gw1_in_in_time;
            %c.norm_gw1_rec_in_time = norm_gw1_rec_in_time;
            %c.norm_deltas_hidden_in_time = norm_deltas_hidden_in_time;
        end
        
        if (esr_val > 99)
            break;
        end
        
        C{k} = c;
        
        %save(sprintf('%s\\_curr_best_%1.2f', out_path, best_esr_val), 'best_esr_val');
        
    end
    
    max_k = k - 1;
    
    Y3 = srnfwd(best_srn_net, U3, nlength);
    esr_test = error_classification(T3, Y3);
    esr_test
    
    %save(sprintf('%s\\data_WS', out_path), 'C', 'esr_test', 'max_k');
    %save(sprintf('%s\\_accuracy_%1.2f', out_path, esr_test), 'esr_test');
    
    if (exist('out.txt'))
      out = dlmread('out.txt');
    else
      out = [];
    end
    
    out = [out;[nlength, NN_No, esr_test]];
    
    dlmwrite('out.txt', out);
endparfor

% close all;
% plot(log10(e_array));
% title('Error Train, log scale');
% xlabel('Epoch');
% ylabel('MSE');
