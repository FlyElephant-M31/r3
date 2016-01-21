function z = sigm(a, beta)

z = 1 ./ ( 1 + exp(-a.*beta));