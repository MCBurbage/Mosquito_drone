function killTotal = StickyWallsGreedySim(L,runTime,velocityR,s,k,killRate)

if nargin<1
    runTime = 1000; %time to run simulation (s)
    velocityR = 12; %robot velocity
    s = 0.5;
    L = 100;
    k = 0.25;
    killRate = 0.9; %percentage of population killed when robot visits cell
end

USE_EXISTING_MARKOV = false;
if USE_EXISTING_MARKOV
    load('StationaryDist.mat');
    L = sqrt(numel(w));
else
    [Ps,w] = StickyWalls(L,k,s);
end

nM = 10000;
timeStep = 1; %time lapse for each loop iteration (s)
%find number of loop iterations
nIters = velocityR*runTime/timeStep;

%set mode for search path:
%1 - wall following
%2 - boustrophedon
%3 - hybrid with wall following for one circuit then boustrophedon for remaining time

%initialize robot position
PoseR = [ceil(L/2) ceil(L/2)];

%set whether to display progress plots
showPlots = true;

%set initial mosquito distribution
distrib = nM * w;

if showPlots
    %create robot path figure
    figure(1); clf; set(gcf,'color','w');
    %draw robot
    hRob = scatter(PoseR(1),PoseR(2),100,'b','filled');
    hold on
    hRobScreenArea = patch(PoseR(1),PoseR(2),'b');
    set(hRobScreenArea,'facealpha',0.5)
    hRobPath = plot(PoseR(1),PoseR(2),'-b');
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
    r = PoseR(1);
    c = PoseR(2);
    %set matrix of options
    %[stay;left;right;up;down]
    if r == 1
        if c == 1
            %top left corner - three options
            options = [distrib(r,c);
                0;
                distrib(r,c+1);
                0;
                distrib(r+1,c)];
        elseif c == L
            %top right corner - three options
            options = [distrib(r,c);
                distrib(r,c-1);
                0;
                0;
                distrib(r+1,c)];
        else
            %top edge - four options
            options = [distrib(r,c);
                distrib(r,c-1);
                distrib(r,c+1);
                0;
                distrib(r+1,c)];
        end
    elseif r == L
        if c == 1
            %bottom left corner - three options
            options = [distrib(r,c);
                0;
                distrib(r,c+1);
                distrib(r-1,c)
                0];
        elseif c == L
            %bottom right corner - three options
            options = [distrib(r,c);
                distrib(r,c-1);
                0;
                distrib(r-1,c);
                0];
        else
            %bottom edge - four options
            options = [distrib(r,c);
                distrib(r,c-1);
                distrib(r,c+1);
                distrib(r-1,c);
                0];
        end
    elseif c == 1
        %left edge - four options
        options = [distrib(r,c);
            0;
            distrib(r,c+1);
            distrib(r-1,c);
            distrib(r+1,c)];
    elseif c == L
        %right edge - four options
        options = [distrib(r,c);
            distrib(r,c-1);
            0
            distrib(r-1,c);
            distrib(r+1,c)];
    else
        %interior cell - five options
        options = [distrib(r,c);
            distrib(r,c-1);
            distrib(r,c+1);
            distrib(r-1,c);
            distrib(r+1,c)];
    end
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
    if showPlots
        %add current region coordinates to the robot path trace
        figure(1)
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,PoseR(1)],'Ydata', [yd,PoseR(2)]);
        set(hRob,'Xdata',PoseR(1),'Ydata',PoseR(2));
        title({['Iteration ', num2str(i), ' of ', num2str(nIters)];[num2str(killTotal), ' mosquitoes killed']})
        
        %update the distribution map
        figure(2); set(gcf,'color','w');
        surf(distrib)
        xlabel('x (m)')
        ylabel('y (m)')
        zlabel('Number of Mosquitoes')
        zlim(zl)
        title({'Current Mosquito Population Distribution';['Step ', num2str(i), ' of ', num2str(nIters)]})
        
        pause(0.02)
    end
end