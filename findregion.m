function [region] = findregion(path,itr_R,PoseR,movement,repeat)
%Divides a path given by an array of way-points into itr_R segments of
%length movement, beginning at PoseR.
%
%Note that this function only works with paths aligned with the x and y
%axes..
%
% Authors: Mary Burbage (mcfieler@uh.edu), Sheryl Monzoor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%region(:,:,k) stores the kth group of path segments that add up to a total
%length of movement

%set starting position
Xlast = PoseR(1,1);
Ylast = PoseR(1,2);
thetalast = PoseR(1,3);

%get number of segments in path
[end_P,~] = size(path);
%initialize path segment counter to second segment
cnt_P=2;

for k=1:itr_R
    %set the beginning pose for the kth movement segment
    region(1,:,k) = [Xlast,Ylast,thetalast];
    %reset running total moved for the current movement segment
    temp=0;
    %reset sub-segment counter 
    ii=2; 
    
    %loop until the total distance in region(:,:,k) >= movement
    while temp < movement && cnt_P <= end_P
        %check if robot is moving vertically
        %compare current X-coordinate to the next X-coordinate
        if path(cnt_P,1) == Xlast
            temp = temp + abs(path(cnt_P,2) - Ylast);
            %if the next node is still within the current region
            if temp < movement
                %move to the next node
                Xlast = path(cnt_P,1);
                Ylast = path(cnt_P,2);
                thetalast = path(cnt_P,3);
                
                region(ii,:,k) =  path(cnt_P,:);
                cnt_P = cnt_P +1;
            else
                %set position for the end of the region
                thetalast = path(cnt_P,3);
                Xlast = path(cnt_P,1);
                %if the distance between current and next path node
                %is greater than movement step size then move the robot by 
                %'movement' amount and subtract excess in y-direction
                Ylast = path(cnt_P,2) - sin(thetalast)*(temp - movement);
                region(ii,:,k) = [Xlast,Ylast,thetalast];
                %if the move ends at the end of a path segment,
                %increment the path segment counter
                if temp == movement
                    cnt_P = cnt_P +1;
                end
                %if the path is to be repeated and the last segment has
                %been reached, reset the path segment counter
                if repeat && cnt_P > end_P
                    cnt_P = 1;
                end
                break;
            end
            
            %check if robot is moving horizontally
        elseif path(cnt_P,2) == Ylast
            %add distance to next node to running total
            temp = temp + abs(path(cnt_P,1) - Xlast);
            %if the next node is still within the current region
            if temp < movement
                %move to the next node
                Xlast = path(cnt_P,1);
                Ylast = path(cnt_P,2);
                thetalast = path(cnt_P,3);
                region(ii,:,k) = path(cnt_P,:);
                cnt_P = cnt_P +1;
            else
                %set position for the end of the region
                thetalast = path(cnt_P,3);
                %if the distance between current and next path node
                %is greater than movement then move the robot by 'movement'
                %amount and subtract excess in x-direction
                Xlast = path(cnt_P,1) - cos(thetalast)*(temp - movement);
                Ylast = path(cnt_P,2);
                region(ii,:,k) = [Xlast,Ylast,thetalast];
                
                %if the move ends at the end of a path segment, increment
                %the path segment counter
                if temp == movement
                    cnt_P = cnt_P +1;
                end
                %if the path is to be repeated and the last segment has
                %been reached, reset the path segment counter
                if repeat && cnt_P > end_P
                    cnt_P = 1;
                end
                break;
            end
        else
            %with a square path aligned with the x and y axes, the last
            %position should always be equal to the next position in one
            %coordinate or the other; if not, there is an error so return
            return;
        end
        %if the path is to be repeated and the last segment has
        %been reached, reset the path segment counter
        if repeat && cnt_P > end_P
            cnt_P = 1;
        end
        ii = ii + 1;
    end
end
