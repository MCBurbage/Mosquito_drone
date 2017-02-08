%initialize variables
nM = 10000; %starting number of mosquitoes
L = 100; %size of workspace (m)
nIters = 2000; %number of time steps to run mosquito simulation between robot runs
timeStep = 1; %length of time in one loop iteration (s)
mu = [L/2 L/2]; %center of mosquito distribution
sigma = L/10; %standard deviation of mosquito distribution
cumIters = 0; %cumulative iteration counter
numKilled = 0; %number of mosquitoes killed

%initialize mosquito positions randomly
PoseM = [repmat(mu,nM,1) + randn(nM,2)*sigma,2*pi*rand(nM,1),ones(nM,1)]; %normal distribution

%display scatter plot of positions
figure(1);
set(gcf,'color','w');
subplot(2,2,1)
scatter(PoseM(:,1),PoseM(:,2),'.');
axis equal  %make axis lengths equal
axis(L*[0,1,0,1])
xlabel('X Position (m)');
ylabel('Y Position (m)');
title('After Flight Simulation')
text(10,10,{[num2str(numel(PoseM(:,1))),' mosq. mean = ',num2str(mean(PoseM(:,1)),'%.2f'),',',num2str(mean(PoseM(:,2)),'%.2f')];...
    ['var =',num2str(var(PoseM(:,1)),'%.2f'),',',num2str(var(PoseM(:,2)),'%.2f')]});

%display histogram of positions
subplot(2,2,2)
hist3(PoseM(:,1:2));
xlabel('X Position (m)');
ylabel('Y Position (m)');
title('After Flight Simulation')
text(10,10,{[num2str(numel(PoseM(:,1))),' mosq. mean = ',num2str(mean(PoseM(:,1)),'%.2f'),',',num2str(mean(PoseM(:,2)),'%.2f')];...
    ['var =',num2str(var(PoseM(:,1)),'%.2f'),',',num2str(var(PoseM(:,2)),'%.2f')]});

suptitle({['Positions of ', num2str(nM), ' Mosquitoes'];['After ', num2str(cumIters), ' Iterations - ', num2str(numKilled), ' Killed']})
pause(1.0)

for i=1:10
    %simulate mosquitoes
    PoseM = MosquitoFlightSimNormal(PoseM,L,nIters,1,mu,sigma);
    cumIters = cumIters + nIters;
    %select living mosquitoes to plot
    PlotM = PoseM(logical(PoseM(:,4)),:);
    
    %display scatter plot of positions
    figure(1)
    subplot(2,2,1)
    scatter(PlotM(:,1),PlotM(:,2),'.')
    axis equal  %make axis lengths equal
    axis(L*[0,1,0,1])
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    title('After Flight Simulation')
    text(10,10,{[num2str(numel(PoseM(:,1))),' mosq. mean = ',num2str(mean(PoseM(:,1)),'%.2f'),',',num2str(mean(PoseM(:,2)),'%.2f')];...
        ['var =',num2str(var(PoseM(:,1)),'%.2f'),',',num2str(var(PoseM(:,2)),'%.2f')]});
    
    
    %display histogram of positions
    subplot(2,2,2)
    hist3(PlotM(:,1:2))
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    title('After Flight Simulation')
    
    %kill some mosquitoes
    PoseM = MosquitoKiller(PoseM,L);
    numKilled = sum(PoseM(:,4)==0);
    %select living mosquitoes to plot
    PlotM = PoseM(logical(PoseM(:,4)),:);
    
    %display scatter plot of positions
    subplot(2,2,3)
    scatter(PlotM(:,1),PlotM(:,2),'.');
    axis equal  %make axis lengths equal
    axis(L*[0,1,0,1])
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    title('After Killer Simulation')
    text(10,10,{[num2str(numel(PlotM(:,1))),' mosq. mean = ',num2str(mean(PlotM(:,1)),'%.2f'),',',num2str(mean(PlotM(:,2)),'%.2f')];...
        ['var =',num2str(var(PlotM(:,1)),'%.2f'),',',num2str(var(PlotM(:,2)),'%.2f')]});
    
    
    %display histogram of positions
    subplot(2,2,4)
    hist3(PlotM(:,1:2))
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    title('After Killer Simulation')
    
    suptitle({['Positions of ', num2str(nM), ' Mosquitoes'];['After ', num2str(cumIters), ' Iterations - ', num2str(numKilled), ' Killed']})
    pause(2.0)
    
    figure(2)
    normplot(PlotM(:,1:2))
end


