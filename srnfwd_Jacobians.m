function [Y, J] = srnfwd_Jacobians(srn_net, U, nlength)

if (nargin < 3)
    nlength = size(U, 2) / 2; % for "Addition problem" only
end

w1_in = srn_net.w1_in;
w1_rec = srn_net.w1_rec;
b1 = srn_net.b1;
w2 = srn_net.w2;
b2 = srn_net.b2;

ndata = size(U, 1);
nin = size(w1_in, 1);
nhidden = size(w1_rec, 1);

A1 = zeros(ndata, nhidden, nlength);
Z1 = zeros(ndata, nhidden, nlength);
R1 = zeros(ndata, nhidden, nlength);

r1 = zeros(ndata, nhidden);

J = zeros(nhidden, nhidden, nlength - 1);

for n = 1:nlength
    u = U(:, nin*(n-1)+1:nin*n);
    
    a1 = u*w1_in + r1*w1_rec + ones(ndata, 1)*b1;
    z1 = tanh(a1);
    
    A1(:, :, n) = a1;
    Z1(:, :, n) = z1;
    R1(:, :, n) = r1;
    
    if (n >= 2)
        epsilon = 1e-08;
        
        all_dz_dz_numeric = zeros(nhidden, nhidden, ndata);
        for k = 1:ndata
            
            curr_r1 = r1(k, :);
            temp_dz_dz_numeric = zeros(nhidden, nhidden);
            for i = 1:nhidden
                r1_plus = curr_r1;
                r1_plus(i) = curr_r1(i) + epsilon;
                r1_minus = curr_r1;
                r1_minus(i) = curr_r1(i) - epsilon;
                
                z1_plus = tanh(u(k,:)*w1_in + r1_plus*w1_rec + ones(1, 1)*b1);
                z1_minus = tanh(u(k,:)*w1_in + r1_minus*w1_rec + ones(1, 1)*b1);
                
                dz_numeric = (z1_plus - z1_minus) / (2*epsilon);
                
                temp_dz_dz_numeric(i, :) = dz_numeric;
            end
            all_dz_dz_numeric(:, :, k) = temp_dz_dz_numeric;
            
%              n
%              k
%              temp_dz_dz_numeric
%              pause
            
            curr_dz_dz_numeric = mean(all_dz_dz_numeric, 3);           
        end
        
        %         prev_z1_deriv = 1 - z1.^2;
        %         f = mean(prev_z1_deriv, 1);
        
        prev_z1_deriv = 1 - z1.^2;
        
        f = mean(prev_z1_deriv, 1);
        curr_dz_dz_analytical_os = (w1_rec)*diag(f);
        
        c = zeros(nhidden, nhidden, ndata);
        for k = 1:ndata
            curr_f = prev_z1_deriv(k, :);
            
            inst = (w1_rec)*diag(curr_f);
            
            n
            k
            inst
            pause
            
            
            c(:, :, k) = inst;
        end
        
        curr_dz_dz_analytical = mean(c, 3);
        
        all_dz_dz_numeric
        
        c
        
        
        
        
%        error A
        
        
        %prev_f = mean(1 - R1(:, :, n).^2, 1);
        %prev_dz_dz_analytical = (w1_rec)*diag(prev_f);
        
        n
        
        curr_dz_dz_numeric
        curr_dz_dz_analytical_os
        curr_dz_dz_analytical
        %prev_dz_dz_analytical
        
        diff = curr_dz_dz_numeric  ./ curr_dz_dz_analytical
        
        norm_curr_dz_dz_numeric = norm(curr_dz_dz_numeric)
        norm_curr_dz_dz_analytical = norm(curr_dz_dz_analytical)
        
        pause
        
    end
    
    
    
    
    
    r1 = z1;
end

A2 = z1*w2 + ones(ndata, 1)*b2;
Z2 = A2;
Y = Z2;
