%% Reduce ����
function res = reduce(img, f)
    size_filter = size(f);
    n_f = size_filter(2);  
    [h, w, c] = size(img);
    h_ = floor(h/2);  w_ = floor(w/2);
    temp = zeros(h, w_, c);  % ��һ����չ�����ʱͼ��
    res = ones(h_, w_, c);
    % �����˲�
    for i = 1: w_
        for j = 1: h
            p = [];
            for n = -(n_f-1)/2 : (n_f-1)/2
                p = [p; get_point(img, j, 2*i+n, c);];
            end
            temp(j, i, :) = f * p;
        end
    end
    % �����˲�
    for i = 1: w_
        for j = 1: h_
            p = [];
            for n = -(n_f-1)/2 : (n_f-1)/2
                p = [p; get_point(temp, 2*j+n, i, c);];
            end     
            res(j, i, :) = f * p;
        end
    end    
end