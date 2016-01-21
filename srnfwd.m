function [Y, A1, Z1, R1, A2, Z2] = srnfwd(srn_net, U, nlength)

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

beta = srn_net.beta;

for n = 1:nlength 
    u = U(:, nin*(n-1)+1:nin*n);
    
    a1 = u*w1_in + r1*w1_rec + ones(ndata, 1)*b1;
    z1 = tanh(a1*beta); 
    %z1 = sigm(a1, beta);
           
    A1(:, :, n) = a1;
    Z1(:, :, n) = z1;
    R1(:, :, n) = r1;
    
    r1 = z1;
end

A2 = z1*w2 + ones(ndata, 1)*b2;

%Z2 = A2;
%Y = Z2;

maxcut = log(realmax) - log(srn_net.nout);
mincut = log(realmin);
A2 = min(A2, maxcut);
A2 = max(A2, mincut);
temp = exp(A2);
Z2 = temp./(sum(temp, 2)*ones(1, srn_net.nout));
Y = Z2;