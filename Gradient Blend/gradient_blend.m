back = imread('back.jpg');
fore = imread('fore.png');
fore = imresize3(fore, [200, 200, 3]);



% function result = gradient_blend(fore, back)
    % ����ǰ��ͼ�ȱ���ͼҪС
    [h_f, w_f, c_f] = size(fore);
    [h_b, w_b, c_b] = size(back);
    
    % ����mask
    [center_fore, mask] = create_mask(fore);
    imshow(back);
    [x, y] = ginput(1);
    center_back = [x, y];
    close;
    
    back = double(back);
    fore = double(fore);
    % ����ڱ���ͼ�е�ƫ����
    x_shift = floor(center_back(1) - center_fore(1));    %���
    y_shift = floor(center_back(2) - center_fore(2));    %�߶�
    
    % ��ѡ��mask����
    index = find(mask~=0);  % ������ǰ��ͼ�е��б�ʾ����
    n = length(index);      % ��������
    A = zeros(n, n);       % ϵ������
    b = cell(c_f, 1);       % ����b, ǰ��ͼ���ݶ���Ϣ
    res = cell(c_f, 1);     % ���Է�����Ľ�
    for c = 1: c_f         
        b{c, 1} = zeros(n,1);         
    end
    disp(['mask��������:', num2str(n)]);
    if n > 25000
        disp('����̫��');
        return;
    end
    
    disp('�γ�ϵ������A��b');
    % �γ�ϵ������A��b
    count = 1;
    for i = 1 : w_f
        for j = 1 : h_f
            % �����mask�еĵ�
            if mask(j, i)
                for c = 1 : c_f
                    % ǰ��ͼ��Laplace�ݶ�
                    b{c, 1}(count) = 4*fore(j,i, c)-fore(j-1,i, c)-fore(j+1,i, c)-fore(j,i+1, c)-fore(j,i-1, c);

                    % ����A���е�����
                    A(count, count) = 4;

                    % A��������4����[j-1, i], [j+1, i], [j, i-1], [j, i+1],
                    % ��Ҫ�ж����Ƿ�Ϊ����
                    % [j-1, i]
                    if mask(j-1, i) == 1
                        position = (i-1) * h_f + j-1;         %�����������ȵ�λ��
                        order = find(index == position);      %�ǵڼ�������
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j-1+y_shift, i+x_shift, c);     %�߽��
                    end
                    % [j+1, i]
                    if mask(j+1, i) == 1
                        position = (i-1) * h_f + j+1;         
                        order = find(index == position);     
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j+1+y_shift, i+x_shift, c);
                    end
                    % [j, i+1]
                    if mask(j, i+1) == 1
                        position = (i+1-1) * h_f + j;       
                        order = find(index == position);      
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j+y_shift, i+1+x_shift, c);
                    end
                    % [j, i-1]
                    if mask(j, i-1) == 1
                        position = (i-1-1) * h_f + j;         
                        order = find(index == position);     
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j+y_shift, i-1+x_shift, c);
                    end
                end
                count = count + 1;
            end
         end
    end
    
    disp('������Է�����');
    % ������Է�����
    for c = 1: c_f
        res{c, 1} = sparse(A) \ b{c, 1};
    end
    
    disp('�����copy������ͼ');
    % �����copy������ͼ
    count = 1;
    for i = 1 : w_f
        for j = 1 : h_f
            if mask(j,i)
                for c = 1: c_f
                    back(j+y_shift, i+x_shift, c) = res{c, 1}(count);
                end
                count = count + 1;
            end
        end
    end
    result = uint8(back);
     
    figure;
    imshow(result);
% end