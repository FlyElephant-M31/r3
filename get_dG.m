function dG = get_dG(D_array, W, dW, deltas_out)

nlength = size(D_array, 3);
N = size(W, 1);

dG = zeros(N, N);

if (nargin < 3)
    max_n = nlength;
end

mean_deltas_out = mean(deltas_out, 1);

if (1 == 1) % straightforward calculation
    tic
    for i = 1:nlength
        add_value = eye(N).*mean_deltas_out;
        for j = nlength:-1:1
            curr_D = D_array(:, :, j);
            
            if (i == j)
                add_value = add_value*curr_D*dW;
            else
                add_value = add_value*curr_D*W;
            end
        end
        dG = dG + add_value;
    end
    t1 = toc;
end

if (2 == 1) % FAST calculation    
    %tic
    DW_array = zeros(N, N, nlength);
    for j = 1:nlength
        DW_array(:, :, j) = D_array(:, :, j)*W;
    end
    
    L_array = zeros(N, N, nlength);
    L_array(:, :, 1) = eye(N);
    for j = 2:nlength
        L_array(:, :, j) = L_array(:, :, j-1)*DW_array(:, :, j-1);
    end
    
    R_array = zeros(N, N, nlength);
    R_array(:, :, end) = eye(N).*mean_deltas_out;
    for j = nlength-1:-1:1
        R_array(:, :, j) = DW_array(:, :, j+1)*R_array(:, :, j+1);
    end
    
    dY_2 = zeros(N, N);
    for j = 1:nlength
        add_value_2 = L_array(:, :, j)*D_array(:, :, j)*dW*R_array(:, :, j);
        dY_2 = dY_2 + add_value_2;
    end
    %t2 = toc;
end

% 
% % TT = t1 / t2
% 
%  dY(1:5, 1:5)
%  dY_2(1:5, 1:5)
%  dY(1:5, 1:5)./dY_2(1:5, 1:5)
% 
% 
% MMSE =  mse(dY_2(:) - dY(:))
% pause

%dY = dY_2;

