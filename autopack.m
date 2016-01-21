function w = autopack(net)

w = zeros(net.nwts, 1);
nfield = net.nfield;

for n = 1:nfield
    eval(sprintf('curr_field = net.field%d;', n));
    eval(sprintf('l = net.l%d;', n));
    eval(sprintf('m = net.m%d;', n));
    
    eval(sprintf('w_col = net.%s(:);', curr_field));
    
    w(l:m) = w_col;
end

