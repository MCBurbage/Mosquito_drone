function [path] = BuildBoustrophedonPath(Xstart,Ystart,PoseSwitch,h,L)
% Builds a boustrophedon path with distance h between parallel paths.
% It is bounded by (0,0) and (L,L).
% The path is returned as an array of coordinates (x,y,theta).
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize path segment counter
cnt = 1;

%set whether first pass moves up or down
if PoseSwitch(1,3) == -pi/2
    startUp = false;
else
    startUp = true;
end

%set the first location in the path at the starting pose
path(cnt,1) = Xstart;
path(cnt,2) = Ystart;
path(cnt,3) = pi;
cnt = cnt+1;

%get to start location
if Xstart ~= PoseSwitch(1,1)
    path(cnt,1) = PoseSwitch(1,1);
    path(cnt,2) = Ystart;
    if Xstart < PoseSwitch(1,1) 
        path(cnt,3) = 0;
    else
        path(cnt,3) = pi;
    end
    cnt = cnt+1;
end
if Ystart ~= PoseSwitch(1,2)
    path(cnt,1) = path(cnt-1,1);
    path(cnt,2) = PoseSwitch(1,2);
    if Ystart < PoseSwitch(1,2)
        path(cnt,3) = pi/2;
    else
        path(cnt,3) = -pi/2;
    end
    cnt = cnt+1;
end

while path(cnt-1,1)<L
    %move up/down a step
    path(cnt,1) = path(cnt-1,1);
    if startUp
        path(cnt,2) = L-h/2;
        path(cnt,3) = pi/2;
    else
        path(cnt,2) = h/2;
        path(cnt,3) = -pi/2;
    end
    cnt = cnt+1;
    
    %move right a step
    path(cnt,1) = path(cnt-1,1) + h;
    path(cnt,2) = path(cnt-1,2);
    path(cnt,3) = 0;
    cnt = cnt+1;
    
    %move down/up a step
    path(cnt,1) = path(cnt-1,1);
    if startUp
        path(cnt,2) = h/2;
        path(cnt,3) = -pi/2;
    else
        path(cnt,2) = L-h/2;
        path(cnt,3) = pi/2;
    end
    cnt = cnt+1;

    %move right a step
    path(cnt,1) = path(cnt-1,1) + h;
    path(cnt,2) = path(cnt-1,2);
    path(cnt,3) = 0;
    cnt = cnt+1;
end

%correct orientation for last step so that the path can be rejoined with
%the start if it is looped
path(cnt,:) = [path(cnt-1,1:2) pi];

%keep the path inside the boundaries
path(path(:,1)<0,1) = 0;
path(path(:,2)<0,2) = 0;
path(path(:,1)>L,1) = L;
path(path(:,2)>L,2) = L;