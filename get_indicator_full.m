function [indicator, gw] = get_indicator_full(srn_net, sample_U, sample_T, nlength, nhidden, v_w1_rec, mu, lr)

flag_make_pak = 1;
flag_calculate_norm = 0;

[mb_Y, ~, mb_Z1, mb_R1, ~, ~] = srnfwd(srn_net, sample_U, nlength);

deltas_out = -(sample_T - mb_Y);
[gw, ~, gw1_rec, ~, ~, ~, ~, Z1_deriv, ~, ~, ~, ~, ~, ~, ~, deltas_hidden_last] = srnbkp(srn_net, sample_U, mb_Z1, mb_R1, deltas_out, flag_make_pak, flag_calculate_norm);

mean_deltas_hidden_last = mean(deltas_hidden_last, 1);

mean_Z1_deriv = mean(Z1_deriv(:, :, 1:end-1), 1);
mean_Z1_deriv = shiftdim(mean_Z1_deriv, 1);

D_array = zeros(nhidden, nhidden, nlength-1);
for j = 1:size(mean_Z1_deriv, 2)
    curr_f = mean_Z1_deriv(:, j);
    curr_D = diag(curr_f);
    D_array(:, :, j) = curr_D;
end

v_w1_rec = mu*v_w1_rec - lr*gw1_rec;

indicator = get_indicator_G_dG(D_array, srn_net.w1_rec, v_w1_rec, mean_deltas_hidden_last);