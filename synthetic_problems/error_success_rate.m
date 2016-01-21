function [e, relative_diff] = error_success_rate(T, Y, success_value)

if (nargin < 3)
    success_value = 0.04;
end   

ndata = size(T, 1);
relative_diff = abs(T - Y);
success_count = size(find(relative_diff < success_value), 1);

e = (success_count / ndata).*100;




