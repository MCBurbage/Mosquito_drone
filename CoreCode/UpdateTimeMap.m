function timeMap = UpdateTimeMap(pathStart,pathEnd,timeMap,vel)
% Takes two 2D vectors (pathStart and pathEnd) and determines how long the
% path length is in discrete integer cells and adds that value to a 2D
% matrix map (timeMap).  The path length is scaled by a velocity (vel).
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%return if insufficient arguments passed
if nargin<4
    return;
end

%total path length is zero
if dist(pathStart,pathEnd) == 0
    %set the cell
    cell = ceil(pathStart);
    %if the path starts on the edge of a cell, increment the cell number
    if ceil(pathStart(1)) == floor(pathStart(1))
        cell(1)=cell(1)+1;
    end
    if ceil(pathStart(2)) == floor(pathStart(2))
        cell(2)=cell(2)+1;
    end
    %no movement so add 1 to the existing map
    timeMap(cell(1),cell(2)) = timeMap(cell(1),cell(2))+1;
    return;
end

%define a small amount for avoiding errors at the boundaries
eps = 0.001;
[n,m] = size(timeMap);
%shift any values on the high boundaries inside the boundaries
pathStart(pathStart(:,1)==n,1) = n-eps;
pathStart(pathStart(:,2)==m,2) = m-eps;
pathEnd(pathEnd(:,1)==n,1) = n-eps;
pathEnd(pathEnd(:,2)==m,2) = m-eps;


%select the leftmost point on the path as the start of the path
%this eliminates checking whether the path leaves the cell to the left
if pathStart(1) > pathEnd(1) + eps
    [pathStart, pathEnd] = swap(pathStart,pathEnd);
end
%if the path is a vertical path, select the lower point as the start of the
%path
if abs(pathStart(1) - pathEnd(1)) < eps
    %switch path ends if the start is above the end
    if pathStart(2) - pathEnd(2) > eps
        [pathStart, pathEnd] = swap(pathStart,pathEnd);
    end
end

%set the starting point of the first path segment
thisStart = pathStart;
%set the starting cell
cell = ceil(pathStart);
%if the path starts on the edge of a cell, increment the cell number
if ceil(pathStart(1)) == floor(pathStart(1))
    cell(1)=cell(1)+1;
end
if ceil(pathStart(2)) == floor(pathStart(2))
    cell(2)=cell(2)+1;
end

%handle a vertical path (avoid infinite slope errors)
if abs(pathStart(1)-pathEnd(1))<eps
    x = pathStart(1);
    %find distance from start to first grid mark or end of path
    y = min(ceil(thisStart(2)),pathEnd(2));
    %if the path starts on a grid mark, move to the next grid mark
    if y == thisStart(2)
        y = thisStart(2) + 1;
    end
    %set the end of the current cell's segment of the path
    thisEnd = [x,y];
    %time in cell = distance traveled in cell / velocity
    thisTime = dist(thisStart,thisEnd)/vel;
    %add the new time to the existing map
    timeMap(cell(1),cell(2)) = timeMap(cell(1),cell(2))+thisTime;
    
    %return if the end of the path had been reached
    if thisEnd == pathEnd
        return;
    end
    
    while cell(2) < pathEnd(2)
        %set the start of the path in the next cell
        thisStart = thisEnd;
        
        %set the next cell
        cell(2) = cell(2)+1;
        %find distance to the next grid mark or end of path
        y = min(cell(2),pathEnd(2));
        %set the end of the current cell's segment of the path
        thisEnd = [x,y];
        %time in cell = distance traveled in cell / velocity
        thisTime = dist(thisStart,thisEnd)/vel;
        %add the new time to the existing map
        timeMap(cell(1),cell(2)) = timeMap(cell(1),cell(2))+thisTime;
        
        %return if the end of the path had been reached
        if thisEnd == pathEnd
            return;
        end
    end
    return;
end

%get the slope of the path
slope = (pathEnd(2)-pathStart(2))/(pathEnd(1)-pathStart(1));

%set the next cell to the current cell for the loop
nextCell = cell;

%set x to the next grid mark or the end of the path
x = min(ceil(thisStart(1)),pathEnd(1));
%if the path starts on the grid mark, the end is on the next grid mark
if x == thisStart(1)
    x = thisStart(1) + 1;
end
while cell(1) < pathEnd(1) || cell(2) < pathEnd(2)
    %set the next cell
    cell = nextCell;
    %calculate the y-coordinate corresponding to the x-coordinate
    y = (x-thisStart(1))*slope + thisStart(2);
    
    %check that this is actually where the path leaves the cell
    if abs(slope) < eps   %horizontal line must pass into the cell on the right
        %the next cell to evaluate is to the right of the current cell
        nextCell = [cell(1)+1,cell(2)];
    elseif y > cell(2)    %the path passes through the top of the cell
        %set y to the top of the cell
        y = cell(2);
        %calculate x based on y
        x = (y-thisStart(2))/slope + thisStart(1);
        %the next cell to evaluate is above the current cell
        nextCell = [cell(1),cell(2)+1];
    elseif y < cell(2)-1    %the path passes through the bottom of the cell
        %set y to the bottom of the cell
        y = cell(2)-1;
        %calculate x based on y
        x = (y-thisStart(2))/slope + thisStart(1);
        %the next cell to evaluate is below the current cell
        if cell(2) > 1
            nextCell = [cell(1),cell(2)-1];
        else
            nextCell = [cell(1),cell(2)];
        end
    elseif y == cell(2)  %the path passes through the top right corner of the cell
        %the next cell to evaluate is diagonally up from the current cell
        nextCell = [cell(1)+1,cell(2)+1];
    elseif y == cell(2)-1  %the path passes through the bottom right corner of the cell
        %the next cell to evaluate is diagonally down from the current cell
        if cell(2) > 1
            nextCell = [cell(1)+1,cell(2)-1];
        else
            nextCell = [cell(1)+1,cell(2)];
        end
    else
        %the next cell to evaluate is to the right of the current cell
        nextCell = [cell(1)+1,cell(2)];
    end
    %set the end of the current cell's segment of the path
    thisEnd = [x,y];
    %time in cell = distance traveled in cell / velocity
    thisTime = dist(thisStart,thisEnd)/vel;
    %add the new time to the existing map
    timeMap(cell(1),cell(2)) = timeMap(cell(1),cell(2))+thisTime;
    %return if the end of the path had been reached
    if abs(thisEnd - pathEnd) < eps
        return;
    end
    
    %set the start of the path in the next cell
    thisStart = thisEnd;
    %set the x-coordinate for the next cell
    x = min(nextCell(1),pathEnd(1));
end
end

function [a,b] = swap(a,b)% swap the values of two variables
c = a;
a = b;
b = c;
end

function d = dist(a,b)% norm 2 distance between two vectors
d=sum((a-b).^2).^.5;
end
