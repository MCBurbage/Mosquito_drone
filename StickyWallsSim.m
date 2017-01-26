P = csvread('TransitionMatrix.csv');
w = csvread('StationaryDist.csv');
w = w';

nM = 10000;
L = sqrt(numel(w));
nIters = 100; %number of loop iterations
timeStep = 1; %time lapse for each loop iteration (s)
velocityR = 12;
screenWidth = 1;
sw = screenWidth/2;
velRStep = velocityR*timeStep;
killRate = 0.9;

%%% Initialize coverage map
coverage = zeros(L,L);

showPlots = true;

%calculate the path
pathR = BuildWallFollowPath(L);
[numSteps,~,~] = size(pathR);
curStep = 1;
%set the robot's starting position
PoseR = pathR(curStep,:);

%Find movement segments in path
k = 1000;
movement = velocityR*timeStep;
region = findregion(pathR,k,PoseR,movement,true);
%set the region counter for the first region
cnt_reg = 1;

%create figure
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

distrib = nM * w;

%iterate movement of the mosquitoes and robot
for i = 1:nIters
    %sim movement of mosquitoes
    distrib = reshape(distrib, 1, numel(distrib));
    distrib = distrib * P;
    distrib = reshape(distrib, L, L);
    %sim movement of robot
    %clear the temp region from the previous step
    clear region_tmp;
    %copy next region into temp region
    region_tmp = region(:,:,cnt_reg);
    %remove zero rows
    region_tmp(~any(region_tmp,2),:) = [];
    %increment region counter for next loop iteration
    cnt_reg = cnt_reg + 1;
    [u, ~] = size(region_tmp);
    %clear coverage area
    coverage = zeros(L,L);
    %calculate area covered for each segment of movement
    for z=2:u
        oldPoseR = PoseR;
        PoseR = region_tmp(z,:);
        coverage = UpdateTimeMap(oldPoseR(1,1:2),PoseR(1,1:2),coverage,1);
    end
    %update robot position for end of temp region
    PoseR = region_tmp(u,:);
    %calculate kill and update distribution
    kill = killRate*coverage;
    survival = ones(L,L) - kill;
    distrib = distrib.*survival;
    killTotal = nM - sum(sum(distrib));
    
    if showPlots
        figure(1)
        %add temp region coordinates to path trace
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,region_tmp(:,1)'],'Ydata', [yd,region_tmp(:,2)']);
        set(hRob,'Xdata',PoseR(:,1),'Ydata',PoseR(:,2));
        title({[num2str(i), ' of ', num2str(nIters)];[num2str(killTotal), ' mosquitos killed']})
        
        figure(2)
        surf(distrib)
        xlabel('x (m)')
        ylabel('y (m)')
        zlabel('Number of Mosquitoes')
        title({'Current Mosquito Population Distribution';['Step ', num2str(i), ' of ', num2str(nIters)]})
        
        pause(0.2)
    end
end