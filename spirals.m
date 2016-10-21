
screenWidth = 1;
th = 0:pi/40:5*pi;   
x = screenWidth*th.*cos(th);
y = screenWidth*th.*sin(th);
plot(x, y)    % or use polar   

%arc length information here:  http://mathworld.wolfram.com/ArchimedeanSpiral.html
%MATLAB hypergeometric function information here:  https://www.mathworks.com/help/symbolic/hypergeom.html
%Mathematica hypergeometric function information here:  http://mathworld.wolfram.com/HypergeometricFunction.html
%calculate the length of each spiral segment
s = screenWidth*th.*hypergeom([-0.5 0.5],1.5,-th.^2);
