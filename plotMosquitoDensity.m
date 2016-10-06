function plotMosquitoDensity(filename)
% Generates surf plot of mosquito density using the .mat file passed to
% it (filename).
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%return if insufficient arguments passed
if nargin<1
    return;
end
wrapWorkspace = true;

%load the workspace file
load(filename)

%calculate the overall standard deviation
sigma = std2(PoseM(:,1:2));

%initialize the density map
density = zeros(L,L);
iContribution = zeros(L,L);

%initialize x and y vectors
x = [1:L]';
y = [1:L]';
for i=1:nM
    %calculate difference from PoseM(i) to every x and y location
    xDiff = (x-PoseM(i,1)).^2;
    yDiff = (y-PoseM(i,2)).^2;
    if wrapWorkspace
        xDiff = xDiff.*(xDiff<=2500) + (x+(L-PoseM(i,1))).^2.*(xDiff>2500);
        xDiff = xDiff.*(xDiff<=2500) + (PoseM(i,1)+(L-x)).^2.*(xDiff>2500);
        yDiff = yDiff.*(yDiff<=2500) + (y+(L-PoseM(i,2))).^2.*(yDiff>2500);
        yDiff = yDiff.*(yDiff<=2500) + (PoseM(i,2)+(L-y)).^2.*(yDiff>2500);
    end
    for thisX = 1:L
        for thisY = 1:L
            %calculate the contribution of PoseM(i) to this x and y location
            iContribution(thisX,thisY) = exp(-(xDiff(thisX) + yDiff(thisY))/sigma^2);
        end
    end
    %add the contribution of PoseM(i) to the map
    density = density + iContribution;
end

%plot the map
surf(density);
