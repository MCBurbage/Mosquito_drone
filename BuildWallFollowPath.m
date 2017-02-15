function [path] = BuildWallFollowPath(L)
% Builds a path that follows the walls of a square area bounded by (0,0) 
% and (L,L) spaced out from the edge by half a cell.
% The path is returned as an array of coordinates (x,y,theta).
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set the first location in the path at the bottom left
path(1,1) = 0.5;
path(1,2) = 0.5;
path(1,3) = 0;

%set the second location in the path at the bottom right
path(2,1) = 0.5;
path(2,2) = L-0.5;
path(2,3) = pi/2;

%set the third location in the path at the top right
path(3,1) = L-0.5;
path(3,2) = L-0.5;
path(3,3) = 0;

%set the fourth location in the path at the top left
path(4,1) = L-0.5;
path(4,2) = 0.5;
path(4,3) = -pi/2;

%set the fifth location in the path at the bottom left (starting point)
path(5,1) = 0.5;
path(5,2) = 0.5;
path(5,3) = pi;