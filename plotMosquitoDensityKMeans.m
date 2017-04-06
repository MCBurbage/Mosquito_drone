function plotMosquitoDensityKMeans(filename)
% Generates surf plot of mosquito density using the .mat file passed to
% it (filename).
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%return if insufficient arguments passed
if nargin<1
    disp('File name required')
    return;
end
%set a number of means
k = 15;

%load the workspace file
load(filename)

%run k-means calculations
[assign,centers] = kmeans(PoseM(:,1:2),k);

%plot the means
scatter(centers(:,1),centers(:,2))
sd = zeros(1,k);
map = zeros(L,L);

for i=1:k
    %calculate standard deviation for individuals assigned to the cluster
    mask(:,1) = (assign==i);
    mask(:,2) = mask(:,1);
    currentPose = PoseM(:,1:2).*mask;
    currentPose = currentPose(any(currentPose,2),:);
    sd(i) = std2(currentPose);
    
    for x=1:L
        for y=1:L
            %get distance between current cell and cluster centroid
            d=dist([x,y],centers(i,:));
            %get normal PDF contribution of ith cluster to the cell
            map(x,y) = map(x,y) + normpdf(d,0,sd(i));
        end
    end
end
%now that we have the centers of the clusters and the standard deviations
%of the clusters, we can create a map of probabilities
%surf(map)
figure(1)
image(displayimage)
hold on
scatter(PoseM(:,2),PoseM(:,1),'.','k')
contour(map)
end

function d = dist(a,b)% norm 2 distance between two vectors
d=sum((a-b).^2).^.5;
end
