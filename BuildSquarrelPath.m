function [path] = BuildSquarrelPath(Xstart,Ystart,h,L)
% Builds a square spiral that has squares centered at 
% (Xstart,Ystart) with distance h between parallel paths.
% It is bounded by (0,0) and (L,L).
% The spiral is returned as an array of coordinates (x,y,theta).
%
% Authors: Mary Burbage (mcfieler@uh.edu), Sheryl Monzoor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Initialization
s = 0; %length of a side of the path
loopCount=L/(2*h); %max loops in spiral is size of workspace/distance between parallel paths
                    
%set first location in spiral
path(1,1) = Xstart;
path(1,2) = Ystart;
path(1,3) = 0;
cnt = 2;

for i=1:loopCount
    %increase step size
    s = s+h;
    %move right a step
    path(cnt,1) = path(cnt-1,1) + s;
    path(cnt,2) = path(cnt-1,2);
    path(cnt,3) = 0;
    cnt = cnt+1;
    
    %move up a step
    path(cnt,1) = path(cnt-1,1);
    path(cnt,2) = path(cnt-1,2) + s;
    path(cnt,3) = pi/2;
    cnt = cnt+1;
    
    %increase step size
    s = s+h;
    %move left a step
    path(cnt,1) = path(cnt-1,1) - s;
    path(cnt,2) = path(cnt-1,2);
    path(cnt,3) = pi;
    cnt = cnt+1;

    %move down a step
    path(cnt,1) = path(cnt-1,1);
    path(cnt,2) = path(cnt-1,2) - s;
    path(cnt,3) = -(pi/2);
    cnt = cnt+1;
end

%keep the path inside the boundaries
path(path(:,1)<0.5,1) = 0.5;
path(path(:,2)<0.5,2) = 0.5;
path(path(:,1)>L-0.5,1) = L-0.5;
path(path(:,2)>L-0.5,2) = L-0.5;