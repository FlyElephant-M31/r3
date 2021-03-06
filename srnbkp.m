function [g, gw1_in, gw1_rec, gb1, gw2, gb2, deltas_hidden_bptt, Z1_deriv, norm_gw1_in_in_time, norm_gw1_rec_in_time, norm_u_in_time, norm_r_in_time, norm_dz_curr_dz_prev, norm_instant_dz_dz, norm_deltas_hidden_in_time, deltas_hidden_last]  = srnbkp(srn_net, U, Z1, R1, deltas_out, flag_make_pak, flag_calculate_norm)

if (nargin < 6)
    flag_make_pak = false;
end

if (nargin < 7)
    flag_calculate_norm = false;
end

nin = srn_net.nin;
nhidden = srn_net.nhidden;

%nlength = size(U, 2) / 2; % addition, mult
nlength = size(U, 2) / 6; % temporder
ndata = size(U, 1);

w1_rec = srn_net.w1_rec;
w2 = srn_net.w2;

beta = srn_net.beta;

Z1_deriv = beta*(1 - Z1.*Z1); % for tanh
%Z1_deriv = sigm_deriv(Z1, beta);

% 1a) Propagate deltas through the last layer

z1_last = Z1(:, :, nlength);

deltas_hidden = deltas_out*w2';
deltas_hidden = deltas_hidden.*Z1_deriv(:, :, nlength);
deltas_hidden_last = deltas_hidden;

%deltas_hidden = deltas_hidden./ norm(deltas_hidden) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1b) Calculate derivatives
gw2 = z1_last'*deltas_out;
gb2 = sum(deltas_out, 1);

% 2a) Propagate deltas through the recurrence

deltas_hidden_bptt = zeros(ndata, nhidden, nlength);
deltas_hidden_bptt(:, :, nlength) = deltas_hidden;

% J = (w1_rec')*eye(nhidden);

for n = nlength-1:-1:1
    deltas_hidden = deltas_hidden*w1_rec';
    deltas_hidden = deltas_hidden.*Z1_deriv(:, :, n);
    
    deltas_hidden_bptt(:, :, n) = deltas_hidden;
end

% 2b) Calculate derivatives
gw1_in_bptt = zeros(nin, nhidden, nlength);
gw1_rec_bptt = zeros(nhidden, nhidden, nlength);
gb1_bptt = zeros(1, nhidden, nlength);

norm_gw1_rec_in_time = zeros(1, nlength);
norm_gw1_in_in_time = zeros(1, nlength);
norm_u_in_time = zeros(1, nlength);
norm_r_in_time = zeros(1, nlength);

norm_instant_dz_dz = zeros(1, nlength - 1);
norm_dz_curr_dz_prev = zeros(1, nlength - 1);
norm_deltas_hidden_in_time = zeros(1, nlength);

for n = 1:nlength
    u = U(:, nin*(n-1)+1:nin*n);
    r = R1(:, nhidden*(n-1)+1:nhidden*n);
    
    deltas_hidden = deltas_hidden_bptt(:, :, n);
    
    gw1_in_instant = u'*deltas_hidden;
    gw1_rec_instant = r'*deltas_hidden;
    gb1_instant = sum(deltas_hidden , 1);
    gw1_rec_bptt(:, :, n) = gw1_rec_instant;
    gw1_in_bptt(:, :, n) = gw1_in_instant;
    gb1_bptt(:, :, n) = gb1_instant;
    
    % calculate norms
    
    if (1 == 1)
        norm_deltas_hidden_in_time(n) = norm(deltas_hidden_bptt(:, :, n));
    end
    
    if (flag_calculate_norm)
        norm_gw1_in_in_time(n) = norm(gw1_in_instant);
        norm_gw1_rec_in_time(n) = norm(gw1_rec_instant);
        norm_u_in_time(n) = norm(u);
        norm_r_in_time(n) = norm(r);
        norm_deltas_hidden_in_time(n) = norm(deltas_hidden_bptt(:, :, n));
        
        norm_instant_dz_dz(n) = norm(w1_rec'*diag(Z1_deriv(:, :, n)));
    end
end

gw1_in = sum(gw1_in_bptt, 3);
gw1_rec = sum(gw1_rec_bptt, 3);
gb1 = sum(gb1_bptt, 3);

if (flag_make_pak)
    g = [gw1_in(:);gw1_rec(:);gb1(:);gw2(:);gb2(:)];
else
    g = 0;
end