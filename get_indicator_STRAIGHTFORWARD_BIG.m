function [indicator, gw] = get_indicator_STRAIGHTFORWARD_BIG(srn_net, U, T, nlength, v, mu, lr, nminibatch)

flag_make_pak = 1;
flag_calculate_norm = 0;

ndata = size(U, 1);

sample_idx = randi(ndata, nminibatch*20, 1);
sample_U = U(sample_idx, :);
sample_T = T(sample_idx, :);

[mb_Y, ~, mb_Z1, mb_R1, ~, ~] = srnfwd(srn_net, sample_U, nlength);
deltas_out = -(sample_T - mb_Y);
[gw, ~, gw1_rec, ~, ~, ~, ~, Z1_deriv, ~, ~, ~, ~, ~, ~, norm_deltas_hidden_in_time, deltas_hidden_last] = srnbkp(srn_net, sample_U, mb_Z1, mb_R1, deltas_out, flag_make_pak, flag_calculate_norm);
BEFORE = log10(norm_deltas_hidden_in_time(1));

w = srnpak(srn_net);
v = mu*v - lr*gw;
w = w + v;
srn_net = srnunpak(srn_net, w);

[mb_Y, ~, mb_Z1, mb_R1, ~, ~] = srnfwd(srn_net, sample_U, nlength);
deltas_out = -(sample_T - mb_Y);
[gw1, ~, gw1_rec, ~, ~, ~, ~, Z1_deriv, ~, ~, ~, ~, ~, ~, norm_deltas_hidden_in_time, deltas_hidden_last] = srnbkp(srn_net, sample_U, mb_Z1, mb_R1, deltas_out, flag_make_pak, flag_calculate_norm);
AFTER = log10(norm_deltas_hidden_in_time(1));

indicator = (BEFORE - AFTER);

%fprintf('\nBEFORE = %f, AFTER = %f, indicator = %f\n', BEFORE, AFTER, indicator);