function killTotal = Greedy2SimMacPlot(distType,L,runTime,velocityR,k,prm1,killRate)
% Simulates a group of mosquitoes following a Markov process and a robot
% using a 2-step greedy algorithm to hunt them
% distType = type of distribution ('StickyWalls' or 'Normal')
% L = size of workspace (m)
% runTime = time to run simulation (s)
% velocityR = robot velocity (m/s)
% killRate = percentage of population killed when robot visits cell
% distribution parameters
% sticky walls:
% prm1 = mosquito probability of changing cells
% prm2 = wall sticking factor (0=uniform distribution, 1=no movement away from walls)
% normal:
% prm1 = standard deviation of distribution
% prm2 = unused
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set default parameters
if nargin<1
    distType = 'Normal';
    L = 99; %size of workspace (m)
    runTime = 100; %time to run simulation (s)
    velocityR = 12; %robot velocity (m/s)
    killRate = 1; %percentage of population killed when robot visits cell
    k = 0.25; %mosquito probability of changing cells
    prm1 = L/5; %wall sticking factor (0=uniform distribution, 1=no movement away from walls)
end

if strcmp(distType,'StickyWalls')
    [Ps,w] = FindStickyWallTransitions(L,k,prm1);
elseif strcmp(distType,'Normal')
    mu = [L/2 L/2]; %mean must be at the center to take advantage of symmetry
    [Ps,w] = Find2DNormalTransitions(L,mu,prm1,k);
end

nM = 10000; %starting number of mosquitoes
timeStep = 1; %time lapse for each loop iteration (s)
%find number of loop iterations
nIters = velocityR*runTime/timeStep;

%initialize robot position
if strcmp(distType,'StickyWalls')
    PoseR = [1 1];
else
    PoseR = [1 1];%[ceil(L/2) ceil(L/2)];
end

%set whether to display progress plots
showPlots = true;

%set initial mosquito distribution
distrib = nM * w;

if showPlots
    %create robot path figure
    figure(1); clf; set(gcf,'color','w');
    set(gcf,'Position',[-23    21   587   684]);
    hDist1 = surf(distrib-20,'EdgeColor','none');
    caxis([0,4.0]-20)
    hold on
    view(0,90)
    
    
    
    %draw robot
    hRob = scatter(PoseR(2),PoseR(1),100,'b','filled');
    hold on
    hRobScreenArea = patch(PoseR(2),PoseR(1),'r');
    set(hRobScreenArea,'facealpha',0.5)
    hRobPath = plot(PoseR(2),PoseR(1),'-r');
    axis equal  %make axis lengths equal
    axis(L*[0,1,0,1])
    ax1 = gca;
   % ax1.XLabel.String = 'x (m)';
 %   ax1.YLabel.String = 'y (m)';
    
    set(get(ax1, 'XLabel'),'string','x (m)');
    set(get(ax1, 'YLabel'),'string','y (m)');
    
    set(get(ax1,'Title'),'string', {['Iteration 0 of ', num2str(nIters)];'0 mosquitoes killed'});
    
    %display distribution map
    figure(2); clf; set(gcf,'color','w');
    set(gcf,'Position',[515    22   766   683]);
    hDist = surf(distrib,'EdgeColor','none');
light
   %  Maybe turn off grid or make it lighter. mesh off
    ax2 = gca;
   % ax2.XLabel.String = 'x (m)';
   % ax2.YLabel.String = 'y (m)';
   % ax2.ZLabel.String = 'Number of Mosquitoes';
   % ax2.Title.String = {'Current Mosquito Population Distribution';['Step 0 of ', num2str(nIters)]};
set(get(ax2, 'XLabel'),'string','x (m)');
set(get(ax2, 'YLabel'),'string','y (m)');
set(get(ax2, 'ZLabel'),'string','Number of Mosquitoes');
set(get(ax2, 'Title'),'string', {'Current Mosquito Population Distribution';['Step 0 of ', num2str(nIters)]});
caxis([0,4.0])
   zl = zlim; zl(1) = 0;
end

%initialize iteration counter for mosquito movement
itrCnt = 0;

%iterate movement of the mosquitoes and robot
for i = 1:nIters
    %simulate movement of mosquitoes once every second
    if itrCnt >= velocityR
        %shape distribution as a vector
        distrib = reshape(distrib, 1, numel(distrib));
        %multiply by the transition matrix
        distrib = distrib * Ps;
        %shape distribution as a map
        distrib = reshape(distrib, L, L);
        %reset iteration counter
        itrCnt = 0;
    end
    %compare mosquito populations in cells surrounding the robot
    %set matrix of options for first move
    option1 = getOptionMatrix(distrib,PoseR,L);
    
    %set matrix of options for second move
    option2 = zeros(5,5);
    
    %stay
    step1Pose = PoseR;
    %set up temporary distribution matrix
    tempDistrib = distrib;
    %if the pose is within the workspace, kill mosquitoes in that cell
    if ~any(step1Pose<1) && ~any(step1Pose>L)
        tempDistrib(step1Pose(1),step1Pose(2)) = tempDistrib(step1Pose(1),step1Pose(2))*(1-killRate);
    end
    %calculate the reward for the second step options
    option2(:,1) = option1(1) + getOptionMatrix(tempDistrib,step1Pose,L);
    
    %left
    step1Pose = [PoseR(1),PoseR(2)-1];
    %set up temporary distribution matrix
    tempDistrib = distrib;
    %if the pose is within the workspace, kill mosquitoes in that cell
    if ~any(step1Pose<1) && ~any(step1Pose>L)
        tempDistrib(step1Pose(1),step1Pose(2)) = tempDistrib(step1Pose(1),step1Pose(2))*(1-killRate);
    end
    %calculate the reward for the second step options
    option2(:,2) = option1(2) + getOptionMatrix(tempDistrib,step1Pose,L);
    
    %right
    step1Pose = [PoseR(1),PoseR(2)+1];
    %set up temporary distribution matrix
    tempDistrib = distrib;
    %if the pose is within the workspace, kill mosquitoes in that cell
    if ~any(step1Pose<1) && ~any(step1Pose>L)
        tempDistrib(step1Pose(1),step1Pose(2)) = tempDistrib(step1Pose(1),step1Pose(2))*(1-killRate);
    end
    %calculate the reward for the second step options
    option2(:,3) = option1(3) + getOptionMatrix(tempDistrib,step1Pose,L);
    
    %up
    step1Pose = [PoseR(1)-1,PoseR(2)];
    %set up temporary distribution matrix
    tempDistrib = distrib;
    %if the pose is within the workspace, kill mosquitoes in that cell
    if ~any(step1Pose<1) && ~any(step1Pose>L)
        tempDistrib(step1Pose(1),step1Pose(2)) = tempDistrib(step1Pose(1),step1Pose(2))*(1-killRate);
    end
    %calculate the reward for the second step options
    option2(:,4) = option1(4) + getOptionMatrix(tempDistrib,step1Pose,L);
    
    %down
    step1Pose = [PoseR(1)+1,PoseR(2)];
    %set up temporary distribution matrix
    tempDistrib = distrib;
    %if the pose is within the workspace, kill mosquitoes in that cell
    if ~any(step1Pose<1) && ~any(step1Pose>L)
        tempDistrib(step1Pose(1),step1Pose(2)) = tempDistrib(step1Pose(1),step1Pose(2))*(1-killRate);
    end
    %calculate the reward for the second step options
    option2(:,5) = option1(5) + getOptionMatrix(tempDistrib,step1Pose,L);
    
    %get the index of the option with the highest reward
    [max1,dir1] = max(option2);
    [~,dir2] = max(max1);
    %simulate movement of robot
    %step 1
    switch dir1(dir2)
        case 1 %stay
            %no movement - no change to PoseR
        case 2 %left
            PoseR(2) = PoseR(2)-1;
        case 3 %right
            PoseR(2) = PoseR(2)+1;
        case 4 %up
            PoseR(1) = PoseR(1)-1;
        case 5 %down
            PoseR(1) = PoseR(1)+1;
    end
    %increment iteration counter
    itrCnt = itrCnt + 1;
    %calculate kill and update distribution
    %multiply the distribution by the survival rate
    distrib(PoseR(1),PoseR(2)) = distrib(PoseR(1),PoseR(2))*(1-killRate);
    %step 2
    switch dir2
        case 1 %stay
            %no movement - no change to PoseR
        case 2 %left
            PoseR(2) = PoseR(2)-1;
        case 3 %right
            PoseR(2) = PoseR(2)+1;
        case 4 %up
            PoseR(1) = PoseR(1)-1;
        case 5 %down
            PoseR(1) = PoseR(1)+1;
    end
    %increment iteration counter
    itrCnt = itrCnt + 1;
    %calculate kill and update distribution
    %multiply the distribution by the survival rate
    distrib(PoseR(1),PoseR(2)) = distrib(PoseR(1),PoseR(2))*(1-killRate);
    %calculate the total kill so far
    killTotal = nM - sum(sum(distrib));
    
    %update figures
    if showPlots
        display(['step ',num2str(num2str(i)),' pose ', num2str(PoseR)])
        %add current region coordinates to the robot path trace
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,PoseR(2)],'Ydata', [yd,PoseR(1)]);
        set(hRob,'Xdata',PoseR(2),'Ydata',PoseR(1));
        %ax1.Title.String = {['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(round(killTotal)), ' mosquitoes killed']};
        
         set(get(ax1,'Title'),'string', {['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(round(killTotal)), ' mosquitoes killed']});
   
        
        %update the distribution map
        set(hDist,'Zdata',distrib)
        set(hDist1,'Zdata',distrib-20)
        
      %  ax2.ZLim = zl;
      %  ax2.Title.String = {'Current Mosquito Population Distribution';['Step ', num2str(i), ' of ', num2str(nIters)]};
        

set(ax2, 'ZLim',zl);
set(get(ax2, 'Title'),'string',...
    {'Current Mosquito Population Distribution';...
    ['Step ', num2str(i), ' of ', num2str(nIters)]});
        

        
        drawnow()
        %pause(0.02)
    end
end
end

%find the reward values for the move options
function options = getOptionMatrix(distrib,curCell,L)
%augment the distribution matrix with a -1 edging to eliminate checking
%corner and edge cases
distrib = [-1*ones(L,1) distrib -1*ones(L,1)];
distrib = [-1*ones(1,L+2); distrib; -1*ones(1,L+2)];
%set current position, incremented to account for boundary edging
r = curCell(1) + 1;
c = curCell(2) + 1;
%set a zero matrix for cells that are beyond the bounds of the
%array
if r <= 1 || c <= 1 || r > L+1 || c > L+1
    options = zeros(5,1);
    return
end
%[stay;left;right;up;down]
%interior cell - five options
options = [distrib(r,c);
    distrib(r,c-1);
    distrib(r,c+1);
    distrib(r-1,c);
    distrib(r+1,c)];
end
