%%Scaling and Rotation
function rtable = scaleWithRotate(s,ang)

if (s == 1 && ang == 0)
    r = [0;1;2;3;4;5;6;7];
    Xc = [-1.5;-1.5;0;1.5;1.5;1.5;0;-1.5];
    Yc = [0;1;1;1;0;-1;-1;-1];
    rtable = table(r,Xc,Yc);
elseif (s == 2 && ang == 0)
    r = [0;1;2;3;4;5;6;7];
    Xc = [-3;-3;0;3;3;3;0;-3];
    Yc = [0;2;2;2;0;-2;-2;-2];
    rtable = table(r,Xc,Yc);
elseif (s == 1 && ang == 45) 
    r = [0;1;2;3;4;5;6;7];
    Xc = [-1.765;-1.055;-0.35;0.7;1.765;1.055;0.35;-0.7];
    Yc = [0.35;1.055;1.765;0.7;-0.35;-1.055;-1.765;-0.7];
    rtable = table(r,Xc,Yc);
elseif (s == 2 && ang == 45) 
    r = [0;1;2;3;4;5;6;7];
    Xc = [-3.53;-2.11;-0.7;1.41;3.53;2.11;0.7;-1.41];
    Yc = [0.7;2.11;3.53;1.41;-0.7;-2.11;-3.53;-1.41];
    rtable = table(r,Xc,Yc);
elseif (s == 1 && ang == 90) 
    r = [0;1;2;3;4;5;6;7];
    Xc = [-1;-1;0;1;1;1;1;-1];
    Yc = [0;1.5;1.5;1.5;0;-1.5;-1.5;-1.5];
    rtable = table(r,Xc,Yc);
elseif (s == 2 && ang == 90) 
    r = [0;1;2;3;4;5;6;7];
    Xc = [-2;-2;0;2;2;2;0;2];
    Yc = [0;3;3;3;0;-3;-3;-3];
    rtable = table(r,Xc,Yc);
elseif (s == 1 && ang == 135) 
    r = [0;1;2;3;4;5;6;7];
    Xc = [-1.765;-0.7;0.35;1.055;1.765;0.7;-0.35;-1.055];
    Yc = [-0.35;0.7;1.765;1.055;0.35;-0.7;-1.765;-1.055];
    rtable = table(r,Xc,Yc);
elseif (s == 2 && ang == 135) 
    r = [0;1;2;3;4;5;6;7];
    Xc = [-3.53;-1.41;0.7;2.11;3.53;1.41;-0.7;-2.11];
    Yc = [-0.7;1.41;3.53;2.11;0.7;-1.41;-3.53;-2.11];
    rtable = table(r,Xc,Yc);
end