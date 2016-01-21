function srn_net_out = train_SGD_pak(srn_net, U, T, nlength, nminibatch, niterations, lr, mu, GR_ON)

% if (nargin < 3)
%     nlength = size(U, 2) / 2; % for "Addition problem" only
% end

flag_make_pak = 1;
flag_calculate_norm = 0;
ndata = size(U, 1);
nhidden = srn_net.nhidden;

w = srnpak(srn_net);
v = zeros(size(w));
v_w1_rec = zeros(size(srn_net.w1_rec));
mark1 =  srn_net.nw1_in;
mark2 = mark1 +  srn_net.nw1_rec;

pp = 0;
ave = 0;
for i = 1:niterations
    mb_idx = randi(ndata, nminibatch*20, 1);
    mb_U = U(mb_idx, :);
    mb_T = T(mb_idx, :);
    [mb_Y, ~, mb_Z1, mb_R1, ~, ~] = srnfwd(srn_net, mb_U, nlength);
    deltas_out = -(mb_T - mb_Y);
    [gw, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, norm_deltas_hidden_in_time]  = srnbkp(srn_net, mb_U, mb_Z1, mb_R1, deltas_out, flag_make_pak, flag_calculate_norm);
    norm_deltas_start_log10 = log10(norm_deltas_hidden_in_time(1));
    norm_deltas_end_log10 = log10(norm_deltas_hidden_in_time(end));
    
    Q_factor = log10(norm_deltas_hidden_in_time(1)/norm_deltas_hidden_in_time(end));
    
    %%fprintf('i = %d, norm_deltas_start_log10 = %f', i, norm_deltas_start_log10);
    
    %[curr_indicator, ~] = get_indicator_full(srn_net, mb_U, mb_T, nlength, nhidden, v_w1_rec, mu, lr);
    [curr_indicator_ST, ~] = get_indicator_STRAIGHTFORWARD(srn_net, mb_U, mb_T, nlength, v, mu, lr);
    
    if (GR_ON == 0)
        %fprintf('i = %d, start = %f, end = %f, Q = %f\n', i, norm_deltas_start_log10, norm_deltas_end_log10, Q_factor);
    else        
        if (abs(curr_indicator_ST) > 1)
            %fprintf(' continue, curr_indicator_ST = %f\n', curr_indicator_ST);
            continue;
        end
        
        if ((Q_factor < -1) && (curr_indicator_ST > 0))
            %fprintf(' make UP, start = %f, end = %f, Q = %f, curr_indicator_ST = %f\n', norm_deltas_start_log10, norm_deltas_end_log10, Q_factor, curr_indicator_ST);
            continue;
        end
        
        if ((Q_factor > 1) && (curr_indicator_ST < 0))
            %fprintf(' make DOWN, start = %f, end = %f, Q = %f, curr_indicator_ST = %f\n', norm_deltas_start_log10, norm_deltas_end_log10, Q_factor, curr_indicator_ST);
            continue;
        end
        
        ave = ave + curr_indicator_ST;        
        %fprintf('i = %d, start = %f, end = %f, Q = %f, curr_indicator_ST = %f, ave = %f\n', i, norm_deltas_start_log10, norm_deltas_end_log10, Q_factor, curr_indicator_ST, ave);        
    end
    
    gw1_rec = reshape(gw(mark1 + 1:mark2), nhidden, nhidden);
    v = mu*v - lr*gw;
    v_w1_rec = mu*v_w1_rec - lr*gw1_rec;
    
    w = w + v;
    srn_net = srnunpak(srn_net, w);    
end

srn_net_out =  srn_net;