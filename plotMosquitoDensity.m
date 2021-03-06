function plotMosquitoDensity(filename)
% Generates surf plot of mosquito density using the .mat file passed to
% it (filename).
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%return if insufficient arguments passed
if nargin<1
    disp('Aborted:  Insufficient parameters passed')
    return;
end
wrapWorkspace = true;

%load the workspace file
load(filename)

%calculate the overall standard deviation
sigma = 5;

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
    %if the workspace is assumed to be continuous, find the closer of two
    %distances - direct and wrapped
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
xlabel('X Position (m)')
ylabel('Y Position (m)')
zlabel('Mosquito Count in 1m x 1m Squares')
set(gcf,'color','w');
colorbar

figure;
image(permute(displayimage,[2 1 3]))
hold on
scatter(PoseM(:,1),PoseM(:,2),'.','r')
contour(density')
axis equal
axis(L*[0,1,0,1])
hcolor = colorbar;
xlabel('x (m)')
ylabel('y (m)')
xlabel(hcolor,'Number of Mosquitoes (of 10,000)')
set(gcf,'PaperPositionMode','auto','PaperSize',[5,4],'PaperPosition',[0,0,5,4] );
%print(gcf, '-dpdf', '10kDensitySigma5Contour.pdf');