function PoseM = MosquitoFlightSimNormal(PoseM,L,nIters,timeStep,mu,sigma)
% Simulates a group of mosquitoes in an area LxL meters using a random
% walk model that is biased toward a normal distribution centered at
% (mu(1),mu(2)) with a standard deviation of sigma.
%
% Authors: Mary Burbage (mcfieler@uh.edu), Aaron Becker (atbecker@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%defaults
if nargin<3
    disp('Aborted:  Insufficient parameters passed')
    return
end
if nargin<4
    timeStep = 1;
    mu = [L/2 L/2];
    sigma = L/10;
elseif nargin<5
    mu = [L/2 L/2];
    sigma = L/10;
elseif nargin<6
    sigma = L/10;
end

%set mosquito flight parameters
headingstdM = 3.0; %heading randomness for the mosquitos
velocitystdM = 0.4; %m/s  (The Biology of Mosquitos, Vol. II, A.N.Clements)

[nM,~]=size(PoseM);

%%% Loop for simulating movement
for i = 1:nIters
    Sm = PoseM(:,4);
    
    %generate a normal distribution of target positions centered at mu and
    %with a standard deviation of sigma
    targetPoseM = repmat(mu,nM,1) + randn(nM,2)*sigma;
    %set biasheading toward target position
    deltaY = targetPoseM(:,2)-PoseM(:,2);
    deltaX = targetPoseM(:,1)-PoseM(:,1);
    biasheading=atan2(deltaY,deltaX);
    %generate a random component for the heading direction
    headingchange = headingstdM*(-1 + 2*rand(nM,1));
    %new heading = bias + random component
    theta = biasheading+headingchange.*Sm;
    %add a random velocity
    movement = velocitystdM*rand(nM,1)*timeStep;
    X = PoseM(:,1) + movement.*cos(theta).*Sm;
    Y = PoseM(:,2) + movement.*sin(theta).*Sm;
    % use the toroidal assumption to wrap everything back to L x L
    X = X-L*(X>L);
    X = X+L*(X<0);
    Y = Y-L*(Y>L);
    Y = Y+L*(Y<0);
    PoseM = [X,Y,theta,Sm];
end
