function indicator = get_indicator_G_dG(D_array, W, dW, mean_deltas_hidden_last)

nlength = size(D_array, 3);
N = size(W, 1);

%% 01. Calculate G

DW_array = zeros(N, N, nlength-1);
for i = 1:nlength-1
    DW_array(:, :, i) = D_array(:, :, i)*W;
end

G = eye(N);

for i = 1:nlength-1
    G = G*DW_array(:, :, i);        
end

G = G*(mean_deltas_hidden_last');

%% 02. Calcualte dG

L_array = zeros(N, N, nlength-1);
R_array = zeros(N, N, nlength-1);

L_array(:, :, 1) = eye(N);
R_array(:, :, end) = eye(N);

for i = 2:size(L_array, 3)
    L_array(:, :, i) = L_array(:, :, i-1)*DW_array(:, :, i-1);    
end

for i = size(R_array, 3)-1:-1:1
    R_array(:, :, i) = DW_array(:, :, i+1)*R_array(:, :, i+1);
end

dG = zeros(N, N);
for i = 1:nlength-1
    curr_dG = L_array(:, :, i)*D_array(:, :, i)*dW*R_array(:, :, i);
    dG = dG + curr_dG;    
end

dG = dG*(mean_deltas_hidden_last');

%% 03. Calculate indicator

C1 = G(:);
C2 = dG(:);

indicator = sum(C1.*C2);