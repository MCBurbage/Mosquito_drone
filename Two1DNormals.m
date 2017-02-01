%initialize variables
nM = 10000; % number initial mosquitos
L = 10; %workspace edge length
cellSize = 1; % 
mu = [L/2 L/2]; % average
sigma = [L/10 L/10]; 

nCells = L/cellSize;
p = zeros(nCells,2);

%calculate percentage of population in each cell
for i = 1:nCells
    p(1,i) = (normcdf(i*cellSize,mu(1),sigma(1)) - normcdf((i-1)*cellSize,mu(1),sigma(1)));
    p(2,i) = (normcdf(i*cellSize,mu(2),sigma(2)) - normcdf((i-1)*cellSize,mu(2),sigma(2)));
end

wx = p(1,:);
wy = p(2,:);

%initialize the transition matrices with zeros
Px = zeros(nCells,nCells);
Py = zeros(nCells,nCells);

%solve for the transitions from cells at either end of the distribution
%X

A = [wx(1) 0 wx(2); 1 1 0; 0 wx(1) -wx(2)];
B = [wx(1); 1; 0];
X = linsolve(A, B);
Px(1,1) = X(1);
Px(1,2) = X(2);
Px(2,1) = X(3);
Px(nCells,nCells) = X(1);
Px(nCells,nCells-1) = X(2);
Px(nCells-1, nCells) = X(3);
% A = [1 1; wx(1) wx(2)];
% B = [1; wx(1)];
% X = linsolve(A, B);
% Px(1,1) = X(1);
% Px(1,2) = X(2);
% Px(nCells,nCells) = X(1);
% Px(nCells,nCells - 1) = X(2);
%Y
% A = [1 1; wy(1) wy(2)];
% B = [1; wy(1)];
% X = linsolve(A, B);
% Py(1,1) = X(1);
% Py(1,2) = X(2);
% Py(nCells,nCells) = X(1);
% Py(nCells,nCells - 1) = X(2);

%solve for the transitions from cell at the center of the distribution
%NOTE:  this won't work for an uneven number of cells
%X
% A = [1 1 1; wx(nCells/2-1) wx(nCells/2) wx(nCells/2+1); 1 0 -1];
% B = [1; wx(nCells/2); 0];
% X = linsolve(A, B);
% Px(nCells/2,nCells/2-1) = X(1);
% Px(nCells/2,nCells/2) = X(2);
% Px(nCells/2,nCells/2+1) = X(3);
% %Y
% A = [1 1 1; wy(nCells/2-1) wy(nCells/2) wy(nCells/2+1); 1 0 -1];
% B = [1; wy(nCells/2); 0];
% X = linsolve(A, B);
% Py(nCells/2,nCells/2-1) = X(1);
% Py(nCells/2,nCells/2) = X(2);
% Py(nCells/2,nCells/2+1) = X(3);


for i = 2:nCells-1
    %X
    A = [wx(i) 0 wx(i+1); 1 1 0; 0 wx(i) -wx(i+1)];
    B = [wx(i)-wx(i-1)*Px(i-1,i); 1-wx(i-1)*Px(i,i-1); 0];
    X = linsolve(A, B);
    Px(i,i) = X(1);
    Px(i,i+1) = X(2);
    Px(i+1,i) = X(3);
    Px(nCells,nCells) = X(1);
    Px(nCells,nCells - 1) = X(2);
    Px(nCells - 1, nCells) = X(3);
    %     A = [1 1 1; wx(i-1) wx(i) wx(i+1); 0 wx(i) 0];
    %     B = [1; wx(i); wx(i-1)*Px(i-1,i)];
    %     X = linsolve(A, B);
    %     Px(i,i-1) = X(1);
    %     Px(i,i) = X(2);
    %     Px(i,i+1) = X(3);
    %Y
    %     A = [1 1 1; wy(i-1) wy(i) wy(i+1); 0 wy(i) 0];
    %     B = [1; wy(i); wy(i-1)*Py(i-1,i)];
    %     X = linsolve(A, B);
    %     Py(i,i-1) = X(1);
    %     Py(i,i) = X(2);
    %     Py(i,i+1) = X(3);
end

%calculate the number in each cell (2D)
ptot = zeros(nCells, nCells);
for i = 1:nCells
    for j = 1:nCells
        ptot(i,j) = nM*p(i,1)*p(j,2);
    end
end

%adjust w to be a vector
w = reshape(ptot,1,numel(ptot));

