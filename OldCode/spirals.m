function path = BuildSpiralPath(screenWidth,L)

exactLength = false;

screenWidth = screenWidth/6;
th1 = logspace(-4,-2,500);
th2 = logspace(-2,0,1000);
th3 = logspace(0,2,1500);
th4 = logspace(2,2.5,1500);
th5 = logspace(2.5,2.7,4000);
th = [th1 th2 th3 th4 th5];

x = L/2 + screenWidth*th.*cos(th);
y = L/2 + screenWidth*th.*sin(th);
plot(x, y)    % or use polar
axis('equal')
axis(L*[0,1,0,1])

if exactLength
    %calculate the arc length of each spiral segment - this is the exact
    %length of each segment
    %arc length information here:  http://mathworld.wolfram.com/ArchimedeanSpiral.html
    %MATLAB hypergeometric function information here:  https://www.mathworks.com/help/symbolic/hypergeom.html
    %Mathematica hypergeometric function information here:  http://mathworld.wolfram.com/HypergeometricFunction.html
    dist = screenWidth*th.*hypergeom([-0.5 0.5],1.5,-th.^2);
else
    %calculate the length of the line segments between each spiral point -
    %this is an approximation of the spiral but is satisfactory for these
    %purposes and much faster to compute
    [~,n] = size(x);
    starts = [x(1:n-1)' y(1:n-1)'];
    ends = [x(2:n)' y(2:n)'];
    dist = ((ends(:,1)-starts(:,1)).^2 + (ends(:,2)-starts(:,2)).^2).^0.5;
end
path = [x y dist];