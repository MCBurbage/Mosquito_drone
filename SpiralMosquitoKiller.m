function [coveragepct,killpct] = SpiralMosquitoKiller(dirMode, var1, var2)
%TODO:  Keep the robot within the workspace boundaries
%TODO:  Check net calculations

%defaults
if nargin<1
    dirMode = 1;
elseif nargin<3
    if dirMode == 3
        outThresh = 0.7;
        inThresh = 0.7;
    elseif dirMode == 4
        disp('Aborted:  Insufficient parameters passed')
        return;
    elseif dirMode > 4
        disp('Aborted:  Invalid turning mode')
        return;
    end
else
    if dirMode == 3
        outThresh = var1;
        inThresh = var2;
    elseif dirMode == 4
        outWp = var1;
        inWp = var2;
    end
end

%initialize constants
nM = 10000; %number of mosquitoes
L = 100; %workspace size (m)
nIters = 300; %number of loop iterations
timeStep = 1; %time lapse for each loop iteration (s)
mu = [L/2 L/2]; %center the mosquito distribution at the center of the workspace
sigma = L/10; %standard deviation of mosquito distribution
velocityR = 12;
screenWidth = 1;
sw = screenWidth/2;
velRStep = velocityR*timeStep;
%%% Initialize coverage map
coverage = zeros(L,L);

showPlots = false;

%direction modes
%dirMode = 1;  %spiral out for whole time - no direction change
%dirMode = 2;  %spiral out until inside has more mosquitoes than outside,
%then spiral back in until reach the center, then head back out, repeat
%dirMode = 3;  %spiral out until inside population > a given percentage of
%mosquitoes, then spiral back in until the inside population < another
%percentage, repeat
%dirMode = 4;  %spiral out and in to set waypoints

%initialize mosquito positions randomly
PoseM = [L*rand(nM,2),2*pi*rand(nM,1),ones(nM,1)];
%allow mosquitoes to move into normal distribution
PoseM = MosquitoFlightSimNormal(PoseM,L,5000,timeStep,mu,sigma);

%set the robot's starting direction
headingOut = true;
stepDir = 1;
outWpCnt = 1;
inWpCnt = 1;
%calculate the path
pathR = BuildSpiralPath(screenWidth,L);
[numSteps,~,~] = size(pathR);
curStep = 1;
%set the robot's starting position
PoseR = [pathR(curStep,1) pathR(curStep,2) pi/2];
Xr = PoseR(1,1);
Yr = PoseR(1,2);

%set background image
figure(1); clf; set(gcf,'color','w');
%draw mosquitos
hMos = scatter(PoseM(:,1),PoseM(:,2),3*PoseM(:,4),'r','*');
hold on
%draw robot
hRob = scatter(PoseR(:,1),PoseR(:,2),100,'b','filled');
hRobScreenArea = patch(PoseR(1,1),PoseR(1,2),'b');
set(hRobScreenArea,'facealpha',0.5)
hRobPath = plot(PoseR(1,1),PoseR(1,2),'-b');
axis equal  %make axis lengths equal
xlabel('x (m)')
ylabel('y (m)')
axis(L*[0,1,0,1])

%iterate movement of the mosquitoes and robot
for i=1:nIters
    %move the mosquitoes one step
    PoseM = MosquitoFlightSimNormal(PoseM,L,1,timeStep,mu,sigma);
    Sm = PoseM(:,4);
    
    %move the robot one step
    movementR = 0;
    while(movementR < velRStep)
        curStep = curStep + stepDir;
        if curStep>numSteps || curStep<1
            %if reach the end of the path, turn around and go the other
            %direction
            headingOut = ~headingOut;
            stepDir = stepDir*(-1);
            break;
        end
        if (movementR + pathR(curStep,3)) > velRStep
            break;
        end
        movementR = movementR + pathR(curStep,3);
        %set robot's position after a path segment
        XrLast = Xr;
        YrLast = Yr;
        Xr = pathR(curStep,1);
        Yr = pathR(curStep,2);
        thetaR = atan2(Yr-YrLast,Xr-XrLast);
        %set area swept out as it followed that path segment
        St = sin(thetaR);
        Ct = cos(thetaR);
        if headingOut
            Xnet = Xr+[-sw*St,-sw*St-pathR(curStep,3)*Ct,+sw*St-pathR(curStep,3)*Ct,+sw*St];
            Ynet = Yr+[sw*Ct,sw*Ct-pathR(curStep,3)*St,-sw*Ct-pathR(curStep,3)*St,-sw*Ct];
        else
            Xnet = Xr+[-sw*St,-sw*St-pathR(curStep+1,3)*Ct,+sw*St-pathR(curStep+1,3)*Ct,+sw*St];
            Ynet = Yr+[sw*Ct,sw*Ct-pathR(curStep+1,3)*St,-sw*Ct-pathR(curStep+1,3)*St,-sw*Ct];
        end
        %map the pixels that are covered by the patch
        coverage=coverage|poly2mask(Xnet,Ynet,L,L);
        if movementR>0 && showPlots
            xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
            set(hRobPath,'Xdata', [xd,Xr],'Ydata', [yd,Yr]);
        end
        
        %kill mosquitoes in that area
        killed = inpolygon(PoseM(:,1),PoseM(:,2),Xnet,Ynet);
        Sm = Sm & ~killed;
    end
    PoseR = [Xr,Yr,thetaR];
    PoseM(:,4) = Sm;
    
    %set the robot's distance from the center of the workspace
    r = ((Xr - L/2)^2 + (Yr - L/2)^2)^0.5;
    %set the mosquitoes' distance from the center of the workspace
    rMos = ((PoseM(:,1) - L/2).^2 + (PoseM(:,2) - L/2).^2).^0.5;
    %set which mosquitoes are closer to the center than the robot
    mosInside = rMos<r;
    %count the living mosquitoes closer to the center than the robot
    popInside = nnz(mosInside.*Sm);
    %count all living mosquitoes
    popLiving = nnz(Sm);
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
    if (dirMode == 1)
        %no direction change except at ends of path
    elseif (dirMode == 2)
        if headingOut && (popInside > popOutside)
            %set flag to head back in
            headingOut = false;
            %change direction
            stepDir = -1;
        end
    elseif (dirMode == 3)
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
    elseif (dirMode == 4)
        if headingOut && (r > outWp(outWpCnt))
            %set flag to head back in
            headingOut = false;
            %change direction
            stepDir = -1;
            %increment waypoint counter
            outWpCnt = outWpCnt + 1;
        elseif ~headingOut && (r < inWp(inWpCnt))
            %set flag to head back out
            headingOut = true;
            %change direction
            stepDir = 1;
            %increment waypoint counter
            inWpCnt = inWpCnt + 1;
        end
    end
    
    %%%%%%%%%%%%%%%% UPDATE THE PLOT
    %set mosquito color based on state (red = alive, white = dead)
    Cm = [ones(size(Sm)) +(~Sm) +(~Sm)];
    set(hRob,'Xdata', PoseR(:,1),'Ydata', PoseR(:,2))
    set(hRobScreenArea,'Xdata', Xnet,'Ydata', Ynet)
    set(hMos,'Xdata', PoseM(:,1),'Ydata',PoseM(:,2),'Cdata',Cm)
    %tidy up plot
    uistack(hRob, 'top')
    uistack(hRobScreenArea, 'top')
    title({[num2str(i), ' of ', num2str(nIters)];[num2str(nM-popLiving), ' mosquitos killed']})
    
    if showPlots
        drawnow; pause(0.01);  %take these out if you don't need to watch it
    end
end

if false %showPlots
    %display area covered by robot
    figure(2); clf; set(gcf,'color','w');
    image(~coverage)
    axis equal  % make lengths equal
    xlabel('x (m)')
    ylabel('y (m)')
    axis(L*[0,1,0,1])
end

%set return values
coveragepct = mean(mean(coverage));
killpct = 1 - popLiving/nM;

end

