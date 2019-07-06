function [Ymax,Xmax,finalmat,localmax] = voting(temp_mat,Yr,Xr)

%{
Performing Voting with smoothing for the new coordinates

Yr+1   1     2    1
Yr     2     3    2
Yr-1   1     2    1
     Xr-1    Xr  Xr+1
%}


for r = 1:8
    for p = 1:size(Xr{1,r},1)
        temp_mat(round(Yr{1,r}(p),0),round(Xr{1,r}(p),0))...
            = temp_mat(round(Yr{1,r}(p),0),round(Xr{1,r}(p),0))+3;
        temp_mat(round(Yr{1,r}(p)+1,0),round(Xr{1,r}(p),0))...
            = temp_mat(round(Yr{1,r}(p)+1,0),round(Xr{1,r}(p),0))+2;
        temp_mat(round(Yr{1,r}(p)-1,0),round(Xr{1,r}(p),0))...
            = temp_mat(round(Yr{1,r}(p)-1,0),round(Xr{1,r}(p),0))+2;
        temp_mat(round(Yr{1,r}(p),0),round(Xr{1,r}(p),0)+1)...
            = temp_mat(round(Yr{1,r}(p),0),round(Xr{1,r}(p)+1,0))+2;
        temp_mat(round(Yr{1,r}(p),0),round(Xr{1,r}(p)-1,0))...
            = temp_mat(round(Yr{1,r}(p),0),round(Xr{1,r}(p)-1,0))+2;
        temp_mat(round(Yr{1,r}(p)+1,0),round(Xr{1,r}(p)+1,0))...
            = temp_mat(round(Yr{1,r}(p)+1,0),round(Xr{1,r}(p)+1,0))+1;
        temp_mat(round(Yr{1,r}(p)-1,0),round(Xr{1,r}(p)+1,0))...
            = temp_mat(round(Yr{1,r}(p)-1,0),round(Xr{1,r}(p)+1,0))+1;
        temp_mat(round(Yr{1,r}(p)-1,0),round(Xr{1,r}(p)-1,0))...
            = temp_mat(round(Yr{1,r}(p)-1,0),round(Xr{1,r}(p)-1,0))+1;
        temp_mat(round(Yr{1,r}(p)+1,0),round(Xr{1,r}(p)-1,0))...
            = temp_mat(round(Yr{1,r}(p)+1,0),round(Xr{1,r}(p)-1,0))+1;
        
    end
end

[localmax,index] = max(temp_mat(:));
[Ymax,Xmax] = find(temp_mat == localmax);
finalmat = temp_mat;
