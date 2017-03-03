function [killTotal] = MosquitoSimWithBoustrophedon(screenWidth,velocitystdR)
% Simulates a group of n mosquitos in an area LxL meters using a random
% walk model that is biased toward green areas of a background image.
% Simulates a mosquito-killing robot following a boustrophedon coverage
% path that changes to a spiral when the mosquito concentration is high
% enough.
%
% Authors: Mary Burbage (mcfieler@uh.edu), Aaron Becker (atbecker@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%defaults
if nargin<2
    velocitystdR = 12.0; %m/s  https://3dr.com/solo-gopro-drone-specs/ Max speed: 55 mph (89 km/h), find a round metric number that is close to 25 mph
    screenWidth = 1;
end

showPlots = false;

nM = 10000; %number of mosquitos
L = 100; %width of workspace
nIters = 300; %300s = 5min or 900s = 15min flying time for drone

timeStep = 1; %seconds
killTotal = 0;

%%% Initialize robot
PoseR = [screenWidth/2,0,pi/2];
%%% Initialize mosquitos
PoseM = [L*rand(nM,2), 2*pi*rand(nM,1), ones(nM,1)];  %[x,y,theta,state] for all mosquitos
%%% Initialize kill log and coverage map
KillLog = zeros(nIters,1);
coverage = zeros(L,L);

if showPlots
    %draw mosquitos
    figure(1); clf; set(gcf,'color','w');
    hMos = scatter(PoseM(:,1),PoseM(:,2),3*PoseM(:,4),'k','*');
    hold on
    %draw robot
    hRob = scatter(PoseR(:,1),PoseR(:,2),100,'b','filled');
    hRobScreenArea = patch(PoseR(1,1),PoseR(1,2),'b');
    set(hRobScreenArea,'facealpha',0.5)
    hRobPath = plot(PoseR(1,1),PoseR(1,2),'-y');
    axis equal  %make axis lengths equal
    xlabel('x (m)')
    ylabel('y (m)')
    axis(L*[0,1,0,1])
end
sw=screenWidth/2;

%Build boustrophedon path
pathR = BuildBoustrophedonPath(PoseR(1),PoseR(2),PoseR,screenWidth,L);
%Find movement segments in path
movement = velocitystdR*timeStep;
region = FindRegion(pathR,nIters,PoseR,movement,true);
%set the region counter for the first region
cnt_reg = 1;

%%% Loop for simulating movement
for i = 1:nIters
    %%%% simulate mosquito movement
    PoseM = MosquitoFlightSimWalled2(PoseM,L,1);
    Sm = PoseM(:,4);
    
    %clear the temp region from the previous step
    clear region_tmp;
    
    %copy next region into temp region
    region_tmp = region(:,:,cnt_reg);
    %remove zero rows
    region_tmp(~any(region_tmp,2),:) = [];
    %increment region counter for next loop iteration
    cnt_reg = cnt_reg + 1;
    
    [u, ~] = size(region_tmp);
    %calculate net area for each segment of movement
    for z=2:u
        St = sin(region_tmp(z,3));
        Ct = cos(region_tmp(z,3));
        d1 = sqrt((region_tmp(z,1)-region_tmp(z-1,1))^2+(region_tmp(z,2)-region_tmp(z-1,2))^2);
        Xnet = region_tmp(z,1)+[-sw*St,-sw*St-d1*Ct,+sw*St-d1*Ct,+sw*St];
        Ynet = region_tmp(z,2)+[sw*Ct,sw*Ct-d1*St,-sw*Ct-d1*St,-sw*Ct];
        
        %map the pixels that are covered by the net
        coverage=coverage|poly2mask(Xnet,Ynet,L,L);
        killed = inpolygon(PoseM(:,1),PoseM(:,2),Xnet,Ynet);
        Sm = Sm & ~killed;
    end
    if showPlots
        %add temp region coordinates to path trace
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,region_tmp(:,1)'],'Ydata', [yd,region_tmp(:,2)']);
    end
    %update robot position for end of temp region
    PoseR = region_tmp(u,:);
    
    %update mosquito statistics
    killTotal = nM - nnz(Sm);
    PoseM(:,4) = Sm;
    
    %%%%%%%%%%%%%%%% UPDATE THE PLOT
    if showPlots
        %set mosquito color based on state (red = alive, white = dead)
        Cm = [ones(size(Sm)) +(~Sm) +(~Sm)];
        xd = get(hRobPath,'Xdata'); yd = get(hRobPath,'Ydata');
        set(hRobPath,'Xdata', [xd,PoseR(1)],'Ydata', [yd,PoseR(2)]);
        set(hRob,'Xdata', PoseR(1),'Ydata', PoseR(2))
        set(hRobScreenArea,'Xdata', Xnet,'Ydata', Ynet)
        set(hMos,'Xdata', PoseM(:,1),'Ydata',PoseM(:,2),'Cdata',Cm)
        %tidy up plot
        uistack(hRob, 'top')
        uistack(hRobScreenArea, 'top')
        title({[num2str(i), ' of ', num2str(nIters)];[num2str(killTotal), ' mosquitos killed']})
        
        drawnow; pause(0.01);
    end
end
