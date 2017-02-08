%calculate the number of mosquitoes surviving at each time step when they
%instantly reform a normal distribution at every iteration and the robot
%kills a percentage of them in a certain area at the center of the
%distribution

nM = 10000; %number of mosquitoes/particles
L = 100;    %length of workspace
mu = L/2;   %mean of distribution
sigma = L/10;   %st. dev. of distribution
killPct = 0.9;  %kill rate
r = 1.0;    %radius of area covered by robot in a time step

iters = 50;  %number of iterations for simulation
t = zeros(1,iters);

%calculate percentage of mosquitoes in the robot's kill area
insideRPct = normcdf(mu+r,mu,sigma) - normcdf(mu-r,mu,sigma);
%set surviving percentage at each time step
survivalPct = 1-killPct*insideRPct;
%initialize number of mosquitoes
newNM = nM;

%build array of number of living mosquitoes after each time step
for i = 1:iters
    newNM = newNM*survivalPct;
    t(i) = newNM;
end

%number of living mosquitoes at time t as a function of t
%f(t) = nM*survivalPct^t;

plot([nM t])
xlabel('Elapsed time (s)')
ylabel('Number of living mosquitoes')
title('Surviving Mosquitoes with Instantly Re-Formed Normal Distribution')