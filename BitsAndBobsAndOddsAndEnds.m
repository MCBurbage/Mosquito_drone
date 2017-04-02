%points on a disk
n = 10^4;
theta = 2*pi*rand(n,1);
r = 0.4*rand(n,1);

x = r.*cos(theta);
y = r.*sin(theta);

scatter(x,y,0.5,'.','k')
axis equal
xlabel('x (m)')
ylabel('y (m)')
ylim([-0.5 0.5])

%plot normals with different sigma values
L = 99; %size of workspace
mu = L/2; % average
sigma = [L/10 L/5 L/2]; %standard deviation of distribution
k = 0.25; %diffusion rate from center cell

%find the desired stationary distribution
w = zeros(numel(sigma),L); %initialize the distribution

%calculate percentage of population in each cell
for j = 1:numel(sigma)
    w(j,1) = normcdf(1,mu,sigma(j)) - normcdf(0,mu,sigma(j));
    for i = 2:L
        w(j,i) = (normcdf(i,mu,sigma(j)) - normcdf((i-1),mu,sigma(j)));
    end
    w(j,:) = w(j,:)./sum(sum(w(j,:)));
end

figure
plot(w(1,:))
hold on
plot(w(2,:))
plot(w(3,:))
xlabel('X Position (m) for Y = 50m')
ylabel('Fraction of Population')
legend('\sigma = L/10', '\sigma = L/5', '\sigma = L/2')
set(gcf,'PaperPositionMode','auto','PaperSize',[4,4],'PaperPosition',[0,0,4,4] );
print(gcf, '-dpdf', 'NormalDistribByStd.pdf');


%compare times for 1 and 2 greedy steps
cnt = 1;
for i = 100:100:1000
    for j = 1:10
        disp(['i=',num2str(i),',j=',num2str(j)])
        tic
        GreedySim('StickyWalls',100,i,12,0.25,0.5,0.9)
        t(j,cnt) = toc;
        tic
        Greedy2Sim('StickyWalls',100,i,12,0.25,0.5,0.9)
        t(j+10,cnt) = toc;
    end
    cnt = cnt+1;
end

for j = 1:10
    tavg1(j) = sum(t(1:10,j))/10;
    tavg2(j) = sum(t(11:20,j))/10;
end

x = 100:100:1000;
plot(x,tavg1)
hold on
plot(x,tavg2)
xlabel('Simulated Time (s)')
ylabel('Run Time (s)')
legend('1-Step Greedy','2-Step Greedy')

%test whether k/v in v steps = k in 1 step
k = 0.25;
v = 6;
kstep = k/v;
[Pk,~] = FindStickyWallTransitions(100,k,0.5);
[Pkstep,~] = FindStickyWallTransitions(100,kstep,0.5);
Pkfullstep = Pkstep^v;
diff = Pkfullstep-Pk;
maxDiff = max(max(diff));
%turns out they're up to 3% off
