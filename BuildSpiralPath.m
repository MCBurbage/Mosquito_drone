function path = BuildSpiralPath(screenWidth,L)
% Generates a path shaped as an Archimedean spiral that covers a square 
% with side length L with spirals separated by the screenWidth value.
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%choose whether to see the spiral plotted
drawPlots = true;

%scale the distance between spirals
screenWidth = screenWidth/(2*pi);

%set the maximum theta value to cover the whole workspace
thMax = L*sqrt(2)*pi;

%create the waypoint angles
th = linspace(0,thMax,thMax*30)';

%set the x and y coordinates of each waypoint
x = L/2 + screenWidth*th.*cos(th);
y = L/2 + screenWidth*th.*sin(th);

%plot the spiral
if drawPlots
    plot(x, y)
    axis('equal')
    axis(L*[0,1,0,1])
end

%calculate the length of each path segment
%calculate the length of the line segments between each spiral point -
%this is an approximation of the spiral but is satisfactory for these
%purposes and much faster to compute
[n,~] = size(x);
starts = [x(1:n-1) y(1:n-1)];
ends = [x(2:n) y(2:n)];
dist = ((ends(:,1)-starts(:,1)).^2 + (ends(:,2)-starts(:,2)).^2).^0.5;
dist = [0; dist];
path = [x y dist];