function [mb_U, mb_T] = get_neutral_minibatch(srn_net, U, T, ndata, nminibatch,nlength, v, mu, lr)

mb_idx = randi(ndata, nminibatch, 1);
mb_U = U(mb_idx, :);
mb_T = T(mb_idx, :);

[mb_indicator, ~] = get_indicator_STRAIGHTFORWARD(srn_net, mb_U, mb_T, nlength, v, mu, lr);

cnt = 0;
while (abs(mb_indicator) > 0.01)
    %mb_indicator
    
    idx = randi(ndata);    
    sample_U = U(idx, :);
    sample_T = T(idx, :);
    [sample_indicator, ~] = get_indicator_STRAIGHTFORWARD(srn_net, sample_U, sample_T, nlength, v, mu, lr);
    
    %sample_indicator
    
    if ((mb_indicator > 0) && (sample_indicator < 0))
        mb_U = [mb_U;sample_U];
        mb_T = [mb_T;sample_T];
        
        [mb_indicator, ~] = get_indicator_STRAIGHTFORWARD(srn_net, mb_U, mb_T, nlength, v, mu, lr);
        
        continue;
    end
    
    if ((mb_indicator < 0) && (sample_indicator > 0))
        mb_U = [mb_U;sample_U];
        mb_T = [mb_T;sample_T];
        
        [mb_indicator, ~] = get_indicator_STRAIGHTFORWARD(srn_net, mb_U, mb_T, nlength, v, mu, lr);
        
        continue;
    end
    
    cnt = cnt + 1;
    if (cnt > 100)
        %mb_U = mb_U(1, :);
        %mb_T = mb_T(1, :);
        
        disp('bad');
        break;
    end
end

% disp('SUCCESS!!!');