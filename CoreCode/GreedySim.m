function killTotal = GreedySim(distType,L,runTime,velocityR,k,prm1,killRate)
% Simulates a group of mosquitoes following a Markov process and a robot
% using a 1-step greedy algorithm to hunt them
% distType = type of distribution ('StickyWalls' or 'Normal')
% L = size of workspace (m)
% runTime = time to run simulation (s)
% velocityR = robot velocity (m/s)
% killRate = percentage of population killed when robot visits cell
% k = mosquito probability of changing cells
% distribution parameters
% sticky walls:
% prm1 = wall sticking factor (0=uniform distribution, 1=no movement away from walls)
% normal:
% prm1 = standard deviation of distribution
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set default parameters
if nargin<1
    distType = 'StickyWalls';
    L = 100; %size of workspace (m)
    runTime = 100; %time to run simulation (s)
    velocityR = 12; %robot velocity (m/s)
    killRate = 0.9; %percentage of population killed when robot visits cell
    k = 0.25; %percentage of population leaving (center) cell
    prm1 = 0.5; %wall sticking factor (0=uniform distribution, 1=no movement away from walls)
end

kstep = k/velocityR;
if strcmp(distType,'StickyWalls')
    [Ps,w] = FindStickyWallTransitions(L,kstep,prm1);
elseif strcmp(distType,'Normal')
    mu = [L/2 L/2]; %mean must be at the center to take advantage of symmetry
    [Ps,w] = Find2DNormalTransitions(L,mu,prm1,kstep);
end

nM = 10000; %starting number of mosquitoes
timeStep = 1; %time lapse for each loop iteration (s)
%find number of loop iterations
nIters = velocityR*runTime/timeStep;

%initialize robot position
if strcmp(distType,'StickyWalls')
    PoseR = [1 1];
else
    PoseR = [ceil(L/2) ceil(L/2)];
end

%set whether to display progress plots
SHOW_PLOTS = true;

%set initial mosquito distribution
distrib = nM * w;

if SHOW_PLOTS
    %create robot path figure
    figure(1); clf; set(gcf,'color','w');
    %draw robot
    hRob = scatter(PoseR(2),PoseR(1),100,'b','filled');
    hold on
    %hRobScreenArea = patch(PoseR(2),PoseR(1),'b');
    %set(hRobScreenArea,'facealpha',0.5)
    hRobPath = plot(PoseR(2),PoseR(1),'-b');
    axis equal  %make axis lengths equal
    axis(L*[0,1,0,1])
    ax1 = gca;
    ax1.XLabel.String = 'x (m)';
    ax1.YLabel.String = 'y (m)';
    ax1.Title.String = {['Iteration 0 of ', num2str(nIters)];'0 mosquitoes killed'};
    
    %display distribution map
    figure(2); clf; set(gcf,'color','w');
    hDist = surf(distrib);
    ax2 = gca;
    ax2.XLabel.String = 'x (m)';
    ax2.YLabel.String = 'y (m)';
    ax2.ZLabel.String = 'Number of Mosquitoes';
    ax2.Title.String = {'Current Mosquito Population Distribution';['Step 0 of ', num2str(nIters)]};
    zl = zlim; zl(1) = 0;
end

%initialize iteration counter for mosquito movement
itrCnt = 1;

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
        itrCnt = 1;
    else
        %increment iteration counter
        itrCnt = itrCnt + 1;
    end
    %compare mosquito populations in cells surrounding the robot
    %set matrix of options for first move
    options = getOptionMatrix(distrib,PoseR,L);
    %get the index of the option with the highest reward
    [~,dir] = max(options);
    %simulate movement of robot
    switch dir
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
    %calculate kill and update distribution
    %multiply the distribution by the survival rate
    distrib(PoseR(1),PoseR(2)) = distrib(PoseR(1),PoseR(2))*(1-killRate);
    %calculate the total kill so far
    killTotal = nM - sum(sum(distrib));
    
    %update figures
    if SHOW_PLOTS
        %add current region coordinates to the robot path trace
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,PoseR(2)],'Ydata', [yd,PoseR(1)]);
        set(hRob,'Xdata',PoseR(2),'Ydata',PoseR(1));
        ax1.Title.String = {['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(round(killTotal)), ' mosquitoes killed']};
        
        %update the distribution map
        set(hDist,'Zdata',distrib)
        ax2.ZLim = zl;
        ax2.Title.String = {'Current Mosquito Population Distribution';['Step ', num2str(i), ' of ', num2str(nIters)]};
            
        pause(0.02)
    end
end
%display final path with color gradient
if SHOW_PLOTS
    xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
    col = 0:nIters;
    col = col/velocityR;
    %create robot color path figure
    figure(3); clf; set(gcf,'color','w');
    %draw robot
    h1 = scatter(PoseR(2),PoseR(1),100,'b','filled');
    hold on
    %draw path
    h2 = cline(xd,yd,col);
    axis equal  %make axis lengths equal
    axis(L*[0,1,0,1])
    title({['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(round(killTotal)), ' particles collected']});
    xlabel('x (m)')
    ylabel('y (m)')
    uistack(h1, 'top')
    hColor = colorbar;
    xlabel(hColor,'time (s)')
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
