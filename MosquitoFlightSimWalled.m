function PoseM = MosquitoFlightSimWalled(PoseM,L,nIters,timeStep)
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
end

%set mosquito flight parameters
headingstdM = 3.0; %heading randomness for the mosquitos
velocitystdM = 0.4; %m/s  (The Biology of Mosquitos, Vol. II, A.N.Clements)

[nM,~]=size(PoseM);

%%% Loop for simulating movement
for i = 1:nIters
    XLast = PoseM(:,1);
    YLast = PoseM(:,2);
    thetaLast = PoseM(:,3);
    Sm = PoseM(:,4);
    
    %generate a random heading change
    headingchange = headingstdM*(-1 + 2*rand(nM,1));
    %new heading = old heading + random component
    theta = thetaLast+headingchange.*Sm;
    %set a random velocity calculate distance traveled
    movement = velocitystdM*rand(nM,1)*timeStep;
    X = XLast + movement.*cos(theta).*Sm;
    Y = YLast + movement.*sin(theta).*Sm;
    %handle mosquitoes that try to go out of bounds
    for j=1:nM
        if(Sm(j)&&(X(j)<0||L<X(j)||Y(j)<0||L<Y(j)))
            thetaTurn = theta(j);
            %calculate how far into the move the boundary is
            if((X(j)<0)&&(X(j)<Y(j))&&(X(j)<L-Y(j)))
                d1=(XLast(j))/cos(theta(j));
                XTurn=0;
                YTurn=YLast(j)+d1*sin(theta(j));
            elseif((L<X(j))&&(Y(j)<X(j))&&(L-X(j)<Y(j)))
                d1=(L-XLast(j))/cos(theta(j));
                XTurn=L;
                YTurn=YLast(j)+d1*sin(theta(j));
            elseif((Y(j)<0)&&(Y(j)<X(j))&&(Y(j)<L-X(j)))
                d1=(YLast(j))/sin(theta(j));
                XTurn=XLast(j)+d1*cos(theta(j));
                YTurn=0;
            elseif((L<Y(j))&&(X(j)<Y(j))&&(L-Y(j)<X(j)))
                d1=(L-YLast(j))/sin(theta(j));
                XTurn=XLast(j)+d1*cos(theta(j));
                YTurn=L;
            end
            d2=movement(j)-d1;
            %find a new heading and check that it will leave the mosquito inside
            %the workspace
            headingchange = (-pi+2*pi*rand(1,1));
            theta(j) = thetaTurn+headingchange;
            %calculate the final position of the mosquito
            X(j) = XTurn + d2*cos(theta(j));
            Y(j) = YTurn + d2*sin(theta(j));
            %loop until the mosquito stays in the workspace
            cnt = 0;
            while(X(j)<0||L<X(j)||Y(j)<0||L<Y(j))
                theta(j) = theta(j)+pi/16;
                X(j) = XTurn + d2*cos(theta(j));
                Y(j) = YTurn + d2*sin(theta(j));
                cnt = cnt+1;
            end
        end
    end
    
    %set the return value
    PoseM = [X,Y,theta,Sm];

end
