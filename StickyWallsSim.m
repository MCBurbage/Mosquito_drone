function killTotal = StickyWallsSim(L,nIters,velocityR,s,k,killRate,MODE,sw)

if nargin<1
    nIters = 100;
    velocityR = 12;
    s = 0.5;
    L = 100;
    k = 0.25;
    killRate = 0.9; %percentage of population killed when robot visits cell
    MODE = 3;
    sw = 1; %width of robot
end

USE_EXISTING_MARKOV = false;
if USE_EXISTING_MARKOV
    load('StationaryDist.mat');
    L = sqrt(numel(w));
else
    [Ps,w] = StickyWalls(L,k,s);
end

nM = 10000;
nIters = 300; %number of loop iterations
timeStep = 1; %time lapse for each loop iteration (s)
velocityR = 12; %robot velocity

%set mode for search path:
%1 - wall following
%2 - boustrophedon
%3 - hybrid with wall following for one circuit then boustrophedon for remaining time

%initialize robot position
PoseR = [sw/2 sw/2 0];

%set whether to display progress plots
showPlots = false;

%calculate the path
if MODE == 1
    pathR = BuildWallFollowPath(sw,L);
elseif MODE == 2
    pathR = BuildBoustrophedonPath(sw/2,sw/2,PoseR,sw,L);
elseif MODE == 3
    %build wall-following path
    pathR = BuildWallFollowPath(sw,L);
    %build and add on a boustrophedon path
    pathR = [pathR; BuildBoustrophedonPath(sw/2,sw/2,PoseR,sw,L)];
    %add path segments to return to the start
    %segment to move back to starting x point
    [n,~] = size(pathR);
    pathR = [pathR; [pathR(1,1) pathR(n,2) -pi]];
else
    disp('No valid mode selected')
    return;
end

%set amount robot moves in one time step
movement = velocityR*timeStep;
%Find path segments for each time step
region = findregion(pathR,nIters,PoseR,movement,true);
%set the region counter for the first region
cnt_reg = 1;
%set initial mosquito distribution
distrib = nM * w;

if showPlots
    %create robot path figure
    figure(1); clf; set(gcf,'color','w');
    %draw robot
    hRob = scatter(PoseR(:,1),PoseR(:,2),100,'b','filled');
    hold on
    hRobScreenArea = patch(PoseR(1,1),PoseR(1,2),'b');
    set(hRobScreenArea,'facealpha',0.5)
    hRobPath = plot(PoseR(1,1),PoseR(1,2),'-b');
    axis equal  %make axis lengths equal
    xlabel('x (m)')
    ylabel('y (m)')
    axis(L*[0,1,0,1])
    
    %display distribution map
    figure(2); clf; set(gcf,'color','w');
    surf(distrib)
    xlabel('x (m)')
    ylabel('y (m)')
    zlabel('Number of Mosquitoes')
    title({'Current Mosquito Population Distribution';['Step 0 of ', num2str(nIters)]})
    zl = zlim; zl(1) = 0;
end

%iterate movement of the mosquitoes and robot
for i = 1:nIters
    %simulate movement of mosquitoes
    %shape distribution as a vector
    distrib = reshape(distrib, 1, numel(distrib));
    %multiply by the transition matrix
    distrib = distrib * Ps;
    %shape distribution as a map
    distrib = reshape(distrib, L, L);
    %simulate movement of robot
    %clear the current region from the previous step
    clear cur_region;
    %copy next region into the current region
    cur_region = region(:,:,cnt_reg);
    %remove zero rows - NOTE:  this means the robot can never be at [0 0 0]
    cur_region(~any(cur_region,2),:) = [];
    %increment region counter for next loop iteration
    cnt_reg = cnt_reg + 1;
    %get the number of movement segments in the current region
    [u, ~] = size(cur_region);
    %clear coverage area
    coverage = zeros(L,L);
    %calculate area covered for each segment of movement
    for z=2:u
        oldPoseR = PoseR;
        PoseR = cur_region(z,:);
        coverage = UpdateTimeMap(oldPoseR(1,1:2),PoseR(1,1:2),coverage,1);
    end
    %calculate kill and update distribution
    kill = killRate*coverage;
    %everything not killed has survived
    survival = ones(L,L) - kill;
    %multiply the distribution by the survival rate
    distrib = distrib.*survival;
    %calculate the total kill so far
    killTotal = nM - sum(sum(distrib));
    
    %update figures
    if showPlots
        %add current region coordinates to the robot path trace
        figure(1)
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,cur_region(:,1)'],'Ydata', [yd,cur_region(:,2)']);
        set(hRob,'Xdata',PoseR(:,1),'Ydata',PoseR(:,2));
        title({['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(killTotal), ' mosquitoes killed']})
        
        %update the distribution map
        figure(2); set(gcf,'color','w');
        surf(distrib)
        xlabel('x (m)')
        ylabel('y (m)')
        zlabel('Number of Mosquitoes')
        zlim(zl)
        title({'Current Mosquito Population Distribution';['Step ', num2str(i), ' of ', num2str(nIters)]})
        
        pause(0.2)
    end
end