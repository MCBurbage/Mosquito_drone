function killTotal = NormalSim(L,nIters,velocityR,sigma,killRate,MODE,sw,inThresh,outThresh)
% Simulates a group of mosquitoes following a Markov process and a robot
% using any of three pre-planned paths to hunt them
% L = size of workspace (m)
% nIters = number of time step iterations to run
% velocityR = robot velocity (m/s)
% s = wall sticking factor (0=uniform distribution, 1=no movement away from walls)
% k = mosquito probability of changing cells
% killRate = percentage of population killed when robot visits cell
% MODE = path planning mode
% sw = path spacing
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%search path modes:
%1 - spiral out for whole time - no direction change
%2 - spiral out until inside has more mosquitoes than outside,
%then spiral back in until reach the center, then head back out, repeat
%3 - spiral out until inside population > a given percentage of
%mosquitoes, then spiral back in until the inside population < another
%percentage, repeat

%set default parameters
if nargin<1
    L = 99; %size of workspace (m)
    nIters = 300; %number of loop iterations
    velocityR = 12; %robot velocity
    sigma = [L/10 L/10]; %wall sticking factor (0=uniform distribution, 1=no movement away from walls)
    killRate = 0.9; %percentage of population killed when robot visits cell
    MODE = 3; %path planning mode
    sw = 1; %width of robot
    inThresh = 0.8; %threshold to turn in for MODE 3
    outThresh = 0.8; %threshold to turn out for MODE 3
end

nM = 10000; %starting number of mosquitoes
timeStep = 1; %time lapse for each loop iteration (s)
mu = [L/2 L/2]; %center of mosquito distribution

%calculate transition matrix and stationary distribution
[Ps,w] = Find2DNormalTransitions(L,mu,sigma);

%initialize robot position
PoseR = [L/2 L/2 0];

%calculate the path
pathR = BuildSquarrelPath(PoseR(1,1),PoseR(1,2),sw,L);
%set the robot's starting direction
headingOut = true;
stepDir = 1;
curStep = 1;

%set whether to display progress plots
showPlots = true;

%set amount robot moves in one time step
movement = velocityR*timeStep;
%Find path segments for each time step
region = findregion(pathR,nIters,PoseR,movement,false);
[~,~,numSteps] = size(region);
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
    cur_region = region(:,:,curStep);
    %remove zero rows - NOTE:  this means the robot can never be at [0 0 0]
    cur_region(~any(cur_region,2),:) = [];
    %get the number of movement segments in the current region
    [u, ~] = size(cur_region);
    %clear coverage area
    coverage = zeros(L,L);
    %calculate area covered for each segment of movement
    for j=2:u
        if headingOut
            %take steps in order
            z = j;
        else
            %take steps in reverse order
            z = u-(j-2);
        end
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
        if headingOut
            set(hRobPath,'Xdata', [xd,cur_region(:,1)'],'Ydata', [yd,cur_region(:,2)']);
        else
            set(hRobPath,'Xdata', [xd,flipud(cur_region(:,1))'],'Ydata', [yd,flipud(cur_region(:,2))']);
        end
        set(hRob,'Xdata',PoseR(:,1),'Ydata',PoseR(:,2));
        title({['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(round(killTotal)), ' mosquitoes killed']})
        
        %update the distribution map
        figure(2); set(gcf,'color','w');
        surf(distrib)
        xlabel('x (m)')
        ylabel('y (m)')
        zlabel('Number of Mosquitoes')
        zlim(zl)
        title({'Current Mosquito Population Distribution';['Step ', num2str(i), ' of ', num2str(nIters)]})
        
    %set the robot's distance from the center of the workspace
    r = dist(PoseR(1:2),mu);
    %count the living mosquitoes closer to the center than the robot
    popInside = sum(sum(distrib(floor(mu(1)-r):ceil(mu(1)+r),floor(mu(2)-r):ceil(mu(2)+r))));
    %count all living mosquitoes
    popLiving = nM - killTotal;
    %the rest of the living mosquitoes are farther from the center than the
    %robot
    popOutside = popLiving - popInside;
    
    %direction modes
    %dirMode = 1;  %spiral out for whole time - no direction change
    %dirMode = 2;  %spiral out until inside has more mosquitoes than outside,
    %then spiral back in until reach the center, then head back out, repeat
    %dirMode = 3;  %spiral out until inside population > a given percentage of
    %mosquitoes, then spiral back in until the inside population < another
    %percentage, repeat
    %dirMode = 4;  %spiral out and in to set waypoints
    %update the current step counter for next loop iteration
    if curStep>=numSteps
        %if reach the end of the path, turn around and go the other
        %direction
        headingOut = false;
        stepDir = -1;
    elseif curStep<=1
        %if reach the beginning of the path, turn around and go the other
        %direction
        headingOut = true;
        stepDir = 1;
    else
        if (MODE == 1)
            %no direction change except at ends of path
        elseif (MODE == 2)
            if headingOut && (popInside > popOutside)
                %set flag to head back in
                headingOut = false;
                %change direction
                stepDir = -1;
            end
        elseif (MODE == 3)
            if headingOut && (popInside > inThresh*popLiving)
                %set flag to head back in
                headingOut = false;
                %change direction
                stepDir = -1;
            elseif ~headingOut && (popOutside > outThresh*popLiving)
                %set flag to head back out
                headingOut = true;
                %change direction
                stepDir = 1;
            end
        end
    end
    curStep = curStep + stepDir;
    
        pause(0.2)
    end
end
end

function d = dist(a,b)% norm 2 distance between two vectors
d=sum((a-b).^2).^.5;
end
