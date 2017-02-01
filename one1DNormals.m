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
end

wx = p(1,:);

%initialize the transition matrices with zeros
Px = zeros(nCells,nCells);


%solve for the transitions from cells at either end of the distribution
%X
% x is 
sz = ceil(nCells*3/2)-2;
lb = zeros(sz,1);
ub = ones(sz,1);
f = zeros(sz,1);
f(end) = 1;  %minimize the last entry
% for loop construct constraints
% 
halfCells = ceil(nCells/2);

AeqTop = zeros(halfCells, sz);  
AeqTop(1,1:2) = [1,1];
c = 3;
for i = 1:halfCells-1
    AeqTop(i,c:c+3) = [1,1,1];
    c =c+3;
end
AeqTop(halfCells,c:c+1) =  [2,1]; 
BeqTop = ones(halfCells,1);

AeqBot = zeros(halfCells, sz);  
AeqBot(1,1:3) =  [wx(1),0,  wx(2)]; 
for i = 1:halfCells
    AeqBot(i,i) = wx(i-1);  %TODO: this is probably wrong
    AeqBot(i,i+1) = wx(i);
    AeqBot(i,i+2) = wx(i+1);
end

BeqBot = wx(1:halfCells)';

Aeq = [AeqTop;AeqBot];
beq = [AeqTop;AeqBot];

x = linprog(f,[],[],Aeq,beq,lb,ub)
