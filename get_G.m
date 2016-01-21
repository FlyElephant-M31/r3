function G = get_G(D_array, W, deltas_out)

nlength = size(D_array, 3);
N = size(W, 1);

if (nargin < 3)
    max_n = nlength;
end

mean_deltas_out = mean(deltas_out, 1);

% G = eye(N).*mean_deltas_out;
% for n = nlength:-1:1
%     curr_D = D_array(:, :, n);    
%     G = G*curr_D*W;    
% end

G = eye(N);

for i = 1:nlength
    G = G*D_array(:, :, i)*W;
end

G = G*mean_deltas_out;