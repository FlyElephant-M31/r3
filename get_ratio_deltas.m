function [ratio_deltas, norm_deltas_hidden_in_time] = get_ratio_deltas(srn_net, mb_U, mb_T, nlength)

flag_make_pak = 1;
flag_calculate_norm = 0;

[mb_Y, ~, mb_Z1, mb_R1, ~, ~] = srnfwd(srn_net, mb_U, nlength);
deltas_out = -(mb_T - mb_Y);
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, norm_deltas_hidden_in_time]  = srnbkp(srn_net, mb_U, mb_Z1, mb_R1, deltas_out, flag_make_pak, flag_calculate_norm);

ratio_deltas = norm_deltas_hidden_in_time(end) / norm_deltas_hidden_in_time(1);



