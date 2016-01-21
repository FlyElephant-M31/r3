function z1_deriv = sigm_deriv(z, beta)

z1_deriv = beta .* (z.* (1 - z));