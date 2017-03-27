%size of workspace
L = 99;
mu = [L/2 L/2]; %center of mosquito distribution
sigma = [L/10 L/10]; %wall sticking factor (0=uniform distribution, 1=no movement away from walls)
k = 0.2; %diffusion rate from center cell
nIters = 60; %number of loop iterations

%calculate transition matrix and stationary distribution
[Ps,w] = Find2DNormalTransitions(L,mu,sigma,k);
%set initial mosquito distribution
distrib = w;

%width of swath - must be an integer
width = 1;
%set the swath bounds
minSwath = ceil(L/2) - width;
maxSwath = ceil(L/2) + width;

%kill mosquitoes in vertical swath
distrib(minSwath:maxSwath,:) = 0;

%display distribution map
figure(2); clf; set(gcf,'color','w');
hDist = surf(distrib);
ax2 = gca;
ax2.XLabel.String = 'x (m)';
ax2.YLabel.String = 'y (m)';
ax2.ZLabel.String = 'Fraction of Population';
ax2.Title.String = {'Current Population Distribution';'Step 0'};
zl = zlim; zl(1) = 0;

for i = 1:nIters
    %simulate movement of mosquitoes
    %shape distribution as a vector
    distrib = reshape(distrib, 1, numel(distrib));
    %multiply by the transition matrix
    distrib = distrib * Ps;
    %shape distribution as a map
    distrib = reshape(distrib, L, L);
    %update the distribution map
    set(hDist,'Zdata',distrib)
    ax2.ZLim = zl;
    ax2.Title.String = {'Current Population Distribution';['Step ', num2str(i)]};
    pause(0.2)
end
