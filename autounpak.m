function net_out = autounpak(net, w)

net_out = net;
nfield = net.nfield;

for n = 1:nfield
    eval(sprintf('curr_field = net.field%d;', n))
    eval(sprintf('l = net.l%d;', n))
    eval(sprintf('m = net.m%d;', n))

    eval(sprintf('sz1 = net.sz%d_1;', n))
    eval(sprintf('sz2 = net.sz%d_2;', n))
    
    w_col = w(l:m);
    curr_w = reshape(w_col, sz1, sz2);
    
    eval(sprintf('net_out.%s = curr_w;', curr_field));    
end

