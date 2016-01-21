function indicator = get_indicator(D_array, W, dW, deltas_out)

nlength = size(D_array, 3);

%max_n = (nlength / 2) + floor((nlength / 2)*rand(1));

G = get_G(D_array, W, deltas_out);
dG = get_dG(D_array, W, dW, deltas_out);

G_c = G(:);
dG_c = dG(:);

indicator = sum(G_c.*dG_c); 
