function [region] = FindRegionNonOrthogonal(path,itr_R,PoseR,movement,repeat)
%Divides a path given by an array of way-points into itr_R segments of
%length movement, beginning at PoseR.
%
% Authors: Mary Burbage (mcfieler@uh.edu), Sheryl Monzoor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%region(:,:,k) stores the kth group of path segments that add up to a total
%length of movement

%set starting position
X = PoseR(1);
Y = PoseR(2);
a = PoseR(3);

%get number of segments in path
[end_P,~] = size(path);
%initialize path segment counter to second segment
cnt_P=2;

for k=1:itr_R
    %set the beginning pose for the kth movement segment
    region(1,:,k) = [X,Y,a];
    %reset running total moved for the current movement segment
    temp=0;
    %reset sub-segment counter
    ii=2;
    
    %if the path is to be repeated and the last segment has
    %been reached, reset the path segment counter
    if repeat && cnt_P > end_P
        cnt_P = 1;
    end
    %loop until the total distance in region(:,:,k) >= movement
    while temp < movement && cnt_P <= end_P
        %get magnitude and angle of path step
        [d,a] = dist(path(cnt_P,1:2),[X Y]);
        %if the next node is still within the current region
        if temp+d < movement
            temp = temp + d;
            %move to the next node
            X = path(cnt_P,1);
            Y = path(cnt_P,2);
            %add the path segment
            region(ii,:,k) =  path(cnt_P,:);
            cnt_P = cnt_P +1;
        else
            %set position for the end of the region
            %if the distance between current and next path node
            %is greater than movement step size then move the robot by
            %remainder of movement amount
            X = X + cos(a)*(movement - temp);
            Y = Y + sin(a)*(movement - temp);
            region(ii,:,k) = [X,Y,a];
            %if the move ends at the end of a path segment,
            %increment the path segment counter
            if temp+d == movement
                cnt_P = cnt_P +1;
            end
            %exit while loop for the current region segment
            break;
        end
        ii = ii + 1;
    end
end
end


function [d,a] = dist(p,q)
%set the norm 2 distance
d=sum((p-q).^2).^.5;
%set the angle of the vector from p to q
a=atan2(p(2)-q(2),p(1)-q(1));
%normalize the angle to [-pi,pi]
if a>pi
    a = a-2*pi;
elseif a<-pi
    a = a+2*pi;
end
end