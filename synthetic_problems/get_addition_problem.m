function [U, T] = get_addition_problem(nlength, ndata)

nin = 2;
nlength = nlength;
T_period_tilda = ceil((11/10)*nlength);

U = rand(ndata, nin*nlength)*2 - 1;

zeros_idx = 2:2:nlength*2;

U(:, zeros_idx) = 0;

I = get_random_int(ndata, 1, 1, T_period_tilda / 10);
J = get_random_int(ndata, 1, (T_period_tilda / 10) + 1, T_period_tilda / 2);

% I = get_random_int(ndata, 1, 0+1, 0+7);
% J = get_random_int(ndata, 1, 0+8, 0+15);

D = (1:ndata)';

I_idx_marker = D + (I*nin - 1)*ndata;
J_idx_marker = D + (J*nin - 1)*ndata;

I_idx_value = I_idx_marker - ndata;
J_idx_value = J_idx_marker - ndata;


U(I_idx_marker) = 1;
U(J_idx_marker) = 1;

T = 0.5 + (U(I_idx_value) + U(J_idx_value)) / 4;