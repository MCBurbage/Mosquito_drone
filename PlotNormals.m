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
