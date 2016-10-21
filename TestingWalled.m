%initialize variables
nM = 10000;
L = 100;
nIters = 200;
timeStep = 1;
cumIters = 0;
numKilled = 0;

%initialize mosquito positions randomly
PoseM = [L*rand(nM,2),2*pi*rand(nM,1),ones(nM,1)];

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

for i=1:100
    %simulate mosquitoes
    PoseM = MosquitoFlightSimWalled(PoseM,L,nIters);
    cumIters = cumIters + nIters;
    %display scatter plot of positions
    set(hMos,'Xdata', PoseM(:,1),'Ydata',PoseM(:,2))
    title({['Positions of ', num2str(nM), ' Mosquitoes'];['After ', num2str(cumIters), ' Iterations']})
    pause(0.1)
end