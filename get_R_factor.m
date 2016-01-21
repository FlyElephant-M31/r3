function R_factor = get_R_factor(srn_net, U1, T1, nlength)

[Y, ~, Z1, R1] = srnfwd(srn_net, U1, nlength);
deltas_out = ones(size(T1));
[~,~,~,~,~,~,~,~,~,~,~,~,~,~, norm_deltas_hidden_in_time] = srnbkp(srn_net, U1, Z1, R1, deltas_out, 1, 1);

R_factor = norm_deltas_hidden_in_time(end) / norm_deltas_hidden_in_time(1);