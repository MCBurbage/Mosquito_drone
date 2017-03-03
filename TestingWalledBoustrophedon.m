%initialize variables
nM = 10000; %number of mosquitoes at start
L = 100; %size of workspace (m)
nIters = 300; %number of iterations to run mosquito simulation at a time
timeStep = 1; %time per iteration (s)
numKilled = 0; %number of mosquitoes killed

%initialize mosquito positions randomly
PoseM = [L*rand(nM,2),2*pi*rand(nM,1),ones(nM,1)];
if showPlots
    %display scatter plot of positions
    figure(1);
    set(gcf,'color','w');
    %draw mosquitos
    hMos = scatter(PoseM(:,1),PoseM(:,2),3*PoseM(:,4),'r','*');
    axis equal  %make axis lengths equal
    axis(L*[0,1,0,1])
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    title({['Positions of ', num2str(nM), ' Mosquitoes'];['After ', num2str(cumIters), ' Iterations']})
    
    pause(0.01)
end

for i=1:nIters
    %simulate mosquitoes for nIters time steps
    PoseM = MosquitoFlightSimWalled(PoseM,L,1);
    cumIters = cumIters + nIters;
    
    %display scatter plot of positions
    set(hMos,'Xdata', PoseM(:,1),'Ydata',PoseM(:,2))
    title({['Positions of ', num2str(nM), ' Mosquitoes'];['After ', num2str(cumIters), ' Iterations']})
    pause(0.1)
    
    %update histogram every 10 loop iterations
    if(mod(i, 10) == 0)
        figure(7)
        hist3(PoseM(:,1:2))
    end
end