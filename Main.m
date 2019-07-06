%% Variables
%read_img -> The input image
%inp_img -> Image after adjusting the edge pixels to center
%Gmag -> Magnitude of the pixels
%Gdir -> Gradient of the pixels
%im -> Edges of the image
%Gdir_edge -> Direction of the edges
%Orient -> Orientation of the edges from 0 to 7 in clock wise direction
%accu -> Accumulator of votes
%Xmax -> A cell to store the X coordinate with highest votes
%Ymax -> A cell to store the Y coordinate with highest votes
%localmax -> An array to store the highest votes
%scale,theta -> 1 and 2 with rotations 0,45,90 and 135 respectively

%% Preprocessing

%read the image
read_img = imread ('test1.png');
inp_img = read_img;

%check if image is rgb or grayscale
if (ndims(inp_img)>2) %#ok<ISMAT>
    inp_img = rgb2gray(inp_img);
end

[row,col] = find(inp_img ~= 255);

%Check if the pixel is on the edges of the input image
%Move the image to center and merge with double of its size
if (size(inp_img,1)<500 && size(inp_img,2)<500)
    if(~isempty(find(row==1, 1)) || ~isempty(find(col==1, 1)) ||...
            ~isempty(find(col==size(inp_img,2), 1)) || ~isempty(find(col==size(inp_img,1), 1))||...
            ~isempty(find(row==2, 1)) || ~isempty(find(col==2, 1)) ||...
            ~isempty(find(col==size(inp_img,2)-1, 1)) || ~isempty(find(col==size(inp_img,1)-1, 1)))
        temp = kron(zeros(size(inp_img)),ones(2));
        a = size(temp,1);
        b = size(temp,2);
        for i = 1:a
            for j = 1:b
                temp(i,j) = 255;
            end
        end
        %Ref: https://www.mathworks.com/matlabcentral/answers/560-insert-a-matrix-within-a-matrix#answer_51139
        [row_temp,col_temp]=size(temp);
        fx=floor(row_temp/2)-floor(size(inp_img,1)/2);
        fy=floor(col_temp/2)-floor(size(inp_img,2)/2);
        merge_img=temp;
        for c=1:size(inp_img,1)
            for d=1:size(inp_img,2)
                merge_img(fx+c,fy+d)=inp_img(c,d);
            end
        end
        inp_img = merge_img;
    end
    temp_img = double(inp_img);
else
    temp_img = inp_img;
end


%% Calculating magnitude and gradient of the pixels

%Ref: https://www.mathworks.com/help/matlab/ref/conv2.html
%https://medium.com/datadriveninvestor/understanding-edge-detection-sobel-operator-2aada303b900
%Ref  : http://www.aishack.in/tutorials/canny-edge-detector/

%Sobel operator
Gx = [-1 0 1; -2 0 2; -1 0 1];
Gy = [1 2 1; 0 0 0; -1 -2 -1];

conv_x = conv2(temp_img, Gx, 'same');
conv_y = conv2(temp_img, Gy, 'same');

%Calculating Magnitude
Gmag = sqrt((conv_x.^2) + (conv_y.^2));

row_pix=size(temp_img,1);
col_pix=size(temp_img,2);
temp_img_2 = zeros (row_pix, col_pix);

%Calculating gradients

Gdir = atan2 (conv_x, conv_y);
Gdir = Gdir*180/pi;

%https://stackoverflow.com/questions/16600152/convert-negative-angle-to-positive-involves-invalid-operand-use
for e=1:row_pix
    for f=1:col_pix
        if (Gdir(e,f)<0)
            Gdir(e,f)=360+Gdir(e,f);
        end
    end
end

%% Finding the edges of the image

    %The Nonmaximum supression and Hysteresis Thresholding referred from below link
    %https://www.mathworks.com/matlabcentral/fileexchange/46859-canny-edge-detection
    %Nonmaximum supression
    for i=2:row_pix-1
        for j=2:col_pix-1
            if ((Gdir(i, j) >= 0 ) && (Gdir(i, j) < 22.5) || (Gdir(i, j) >= 157.5) && (Gdir(i, j) < 202.5) || (Gdir(i, j) >= 337.5) && (Gdir(i, j) <= 360))
                temp_img_2(i,j) = (Gmag(i,j) == max([Gmag(i,j), Gmag(i,j+1), Gmag(i,j-1)]));
            elseif ((Gdir(i, j) >= 22.5) && (Gdir(i, j) < 67.5) || (Gdir(i, j) >= 202.5) && (Gdir(i, j) < 247.5))
                temp_img_2(i,j) = (Gmag(i,j) == max([Gmag(i,j), Gmag(i+1,j-1), Gmag(i-1,j+1)]));
            elseif ((Gdir(i, j) >= 67.5 && Gdir(i, j) < 112.5) || (Gdir(i, j) >= 247.5 && Gdir(i, j) < 292.5))
                temp_img_2(i,j) = (Gmag(i,j) == max([Gmag(i,j), Gmag(i+1,j), Gmag(i-1,j)]));
            elseif ((Gdir(i, j) >= 112.5 && Gdir(i, j) < 157.5) || (Gdir(i, j) >= 292.5 && Gdir(i, j) < 337.5))
                temp_img_2(i,j) = (Gmag(i,j) == max([Gmag(i,j), Gmag(i+1,j+1), Gmag(i-1,j-1)]));
            end
        end
    end
    
    temp_img_2 = temp_img_2.*Gmag;
    
    %Thresholding with Hysterysis
    Thres_L = 0.05 * max(max(temp_img_2));
    Thres_H = 0.1 * max(max(temp_img_2));
    im = zeros (row_pix, col_pix);
    for i = 1  : row_pix
        for j = 1 : col_pix
            if (temp_img_2(i, j) < Thres_L)
                im(i, j) = 0;
            elseif (temp_img_2(i, j) > Thres_H)
                im(i, j) = 1;
            elseif ( temp_img_2(i+1,j)>Thres_H || temp_img_2(i-1,j)>Thres_H ||...
                    temp_img_2(i,j+1)>Thres_H || temp_img_2(i,j-1)>Thres_H ||...
                    temp_img_2(i-1, j-1)>Thres_H || temp_img_2(i-1, j+1)>Thres_H ||...
                    temp_img_2(i+1, j+1)>Thres_H || temp_img_2(i+1, j-1)>Thres_H)
                im(i,j) = 1;
            end
        end
    end
   

%coordinates of edges
[y, x] = find(im>0);

%% Find gradient of edges

Gdir_edge = zeros(size(Gdir));
for n = 1:size(x)
    Gdir_edge(y(n), x(n)) = Gdir(y(n), x(n));
end

%% Replacing all zeros to 999 to isolate from numbers 0 to 7
Orient = zeros(size(Gdir_edge));
l = size(Orient,1);
m = size(Orient,2);
for i = 1:l
    for j = 1:m
        Orient(i,j) = 999;
    end
end
%% Assigning Orientations from 0 to 7 to all the edges
for n = 1:size(x)
    if ((Gdir_edge(y(n), x(n)) >= 0 ) && (Gdir_edge(y(n), x(n)) < 22.5) || (Gdir_edge(y(n), x(n)) >= 337.5 ) && (Gdir_edge(y(n), x(n)) < 360))
        Orient(y(n), x(n)) = 6;
    elseif ((Gdir_edge(y(n), x(n)) >= 292.5 ) && (Gdir_edge(y(n), x(n)) < 337.5))
        Orient(y(n), x(n)) = 7;
    elseif ((Gdir_edge(y(n), x(n)) >= 247.5 ) && (Gdir_edge(y(n), x(n)) < 292.5))
        Orient(y(n), x(n)) = 0;
    elseif ((Gdir_edge(y(n), x(n)) >= 202.5 ) && (Gdir_edge(y(n), x(n)) < 247.5))
        Orient(y(n), x(n)) = 1;
    elseif ((Gdir_edge(y(n), x(n)) >= 157.5 ) && (Gdir_edge(y(n), x(n)) < 202.5))
        Orient(y(n), x(n)) = 2;
    elseif ((Gdir_edge(y(n), x(n)) >= 112.5 ) && (Gdir_edge(y(n), x(n)) < 157.5))
        Orient(y(n), x(n)) = 3;
    elseif ((Gdir_edge(y(n), x(n)) >= 67.5 ) && (Gdir_edge(y(n), x(n)) < 112.5))
        Orient(y(n), x(n)) = 4;
    elseif ((Gdir_edge(y(n), x(n)) >= 22.5 ) && (Gdir_edge(y(n), x(n)) < 67.5))
        Orient(y(n), x(n)) = 5;
    end
end
%% Retrieving R table
%{
r-table for given scale 's' and angle 'theta'
available rotations are 0,45,90,135 and scale 1,2
example : scaleWithRotate(1,90)
    r    Xc     Yc
    _    __    ____
    0    -1       0
    1    -1     1.5
    2     0     1.5
    3     1     1.5
    4     1       0
    5     1    -1.5
    6     1    -1.5
    7    -1    -1.5
%}

scale = [1; 2];
theta = [0; 45; 90; 135];
rtable{1,1} = 0;
% 1X8 cell : 1-0,45,90,135;2-0,45,90,135
for s = 1 : size(scale,1)
    for t = 1 : size(theta,1)
        rtable{s,t} = scaleWithRotate(scale(s),theta(t));
    end
end
%% Finding the coordinates of the orientations 0 to 7

for k = 1:8
    [Y{k},X{k}] = find(Orient==k-1);
end

%Computing new coordinates with respect to r table
Yr = Y;
Xr = X;

o = 1;
p = 1;

for q = 1:4
    for r = 1:8
        Yr{q,r} = Y{r} + rtable{o,p}.Yc(r);
        Xr{q,r} = X{r} + rtable{o,p}.Xc(r);
    end
    p = p+1;
end

o = 2;
p = 1;

for q = q+1:8
    for r = 1:8
        Yr{q,r} = Y{r} + rtable{o,p}.Yc(r);
        Xr{q,r} = X{r} + rtable{o,p}.Xc(r);
    end
    p = p+1;
end
%% Performing Voting

acc = zeros(size(inp_img));
Ymax{1,1} = 0;
Xmax{1,1} = 0;
accu{1,1} = 0;
localmax(1,1) = 0;

for u = 1:8
    
    [Ymax{1,u},Xmax{1,u},accu{1,u},localmax(1,u)] = voting(acc,Yr(u,:),Xr(u,:));
    
end

%% Result
fprintf('Maximum votes : %d \n', max(localmax));

sc = [1;1;1;1;2;2;2;2];
th = [0;45;90;135;0;45;90;135];
stable = table(sc,th);
max_index = find(localmax == max(localmax));

plotpoints = [0 0];

if size(max_index,2)>1
    for v = 1:size(max_index,2)
        if (size(Xmax{1,max_index(v)},1)>1)
            for r = 1: size(Xmax{1,max_index(v)},1)
                fprintf('The local maximum is at y = %d , x = %d for scale %d and rotation %d deg.\n',...
                    Ymax{1,max_index(v)}(r) ,Xmax{1,max_index(v)}(r),stable.sc(max_index(v)),stable.th(max_index(v)));
                if(plotpoints(1,1)~=0)
                    w = size(plotpoints,1);
                    plotpoints(w+1,1)= Ymax{1,max_index(v)}(r);
                    plotpoints(w+1,2)= Xmax{1,max_index(v)}(r);
                elseif(plotpoints(1,1)==0)
                    plotpoints(1,1)= Ymax{1,max_index(1)}(1);
                    plotpoints(1,2)= Xmax{1,max_index(1)}(1);
                    
                end
                
            end
        else
            fprintf('The local maximum is at y = %d, x = %d for scale %d and rotation %d deg.\n',...
                Ymax{1,max_index(v)} ,Xmax{1,max_index(v)},stable.sc(max_index(v)),stable.th(max_index(v)));
            if(plotpoints(1,1)~=0)
                w = size(plotpoints,1);
                plotpoints(w+1,1)= Ymax{1,max_index(v)};
                plotpoints(w+1,2)= Xmax{1,max_index(v)};
            elseif(plotpoints(1,1)==0)
                plotpoints(1,1)= Ymax{1,max_index(1)};
                plotpoints(1,2)= Xmax{1,max_index(1)};
                
            end
        end
    end
else
    if (size(Xmax{1,max_index(1)},1)>1)
        for z = 1: size(Xmax{1,max_index(1)},1)
            fprintf('The local maximum is at y = %d , x = %d for scale %d and rotation %d deg.\n',...
                Ymax{1,max_index(1)}(z) ,Xmax{1,max_index(1)}(z),stable.sc(max_index(1)),stable.th(max_index(1)));
            if(plotpoints(1,1)~=0)
                w = size(plotpoints,1);
                plotpoints(w+1,1)= Ymax{1,max_index(1)}(z);
                plotpoints(w+1,2)= Xmax{1,max_index(1)}(z);
            elseif(plotpoints(1,1)==0)
                plotpoints(1,1)= Ymax{1,max_index(1)}(1);
                plotpoints(1,2)= Xmax{1,max_index(1)}(1);
                
            end
            
        end
    else
        fprintf('The local maximum is at y = %d,x = %d for scale %d and rotation %d deg.\n',...
            Ymax{1,max_index} ,Xmax{1,max_index},stable.sc(max_index),stable.th(max_index));
        plotpoints(1,1)= Ymax{1,max_index};
        plotpoints(1,2)= Xmax{1,max_index};
    end
end


%% Plotting the local maxima
subplot(2,2,1),imshow(inp_img),title("Input Image");
subplot(2,2,2),imshow(im),title("Edges")
subplot(2,2,3),imshow(accu{1,max_index(1)}),title("Accumulator")
subplot(2,2,4),imshow(inp_img),title("Point with Max Votes")
hold on;
for i = 1 : size(plotpoints,1)
    
    plot(plotpoints(i,2),plotpoints(i,1),'r.');
    
end

