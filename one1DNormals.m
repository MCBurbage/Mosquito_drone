%initialize variables
L = 9; %workspace edge length
cellSize = 1; % 
mu = [L/2 L/2]; % average
sigma = [L/10 L/10]; 

nCells = L/cellSize;
p = zeros(2,nCells);

%calculate percentage of population in each cell
p(1,1) = normcdf(cellSize,mu(1),sigma(1));
for i = 2:nCells-1
    p(1,i) = (normcdf(i*cellSize,mu(1),sigma(1)) - normcdf((i-1)*cellSize,mu(1),sigma(1)));
end
p(1,nCells) = 1-sum(p(1,:));

wx = p(1,:);

%initialize the transition matrices with zeros
Px = zeros(nCells,nCells);

%calculate the number of unknowns - half the size of the matrix with three
%unknowns for each row except the first and last which have only two
%unknowns each
sz = ceil(nCells/2)*3-2;
% for loop construct constraints
% 
halfCells = ceil(nCells/2);

%Fill top of Aeq matrix with probability constraints-each row must sum to 1
%Initialize with a zero matrix
AeqTop = zeros(halfCells, sz);
%The first cell has only two possibilities
AeqTop(1,1:2) = [1,1];
%The interior cells have three possibilities
cnt = 3;
for i = 2:halfCells-1
    AeqTop(i,cnt:cnt+2) = [1,1,1];
    cnt=cnt+3;
end
%The last cell has only two possibilities but symmetry makes it twice as
%likely to leave as stay
AeqTop(halfCells,cnt:cnt+1) =  [2,1]; 
%Fill top of Beq matrix with probability constraints-each row must sum to 1
BeqTop = ones(halfCells,1);

%Fill bottom of Aeq matrix with wP = w constraints
AeqBot = zeros(halfCells, sz);  
%The first row only has two possibilities
AeqBot(1,1:3) =  [wx(1),0,wx(2)]; 
%Interior rows have three possibilities
cnt = 2;
for i = 2:halfCells-1
    AeqBot(i,cnt:cnt+4) = [wx(i-1),0,wx(i),0,wx(i+1)];
    cnt = cnt+3;
end
%The last row only has two possibilities but one is doubled due to symmetry
AeqBot(halfCells,cnt:sz) = [2*wx(halfCells-1),0,wx(halfCells)];

%Fill bottom of Aeq matrix with wP = w constraints
BeqBot = wx(1:halfCells)';

%Concatenate the Aeq and Beq matrices
Aeq = [AeqTop;AeqBot];
Beq = [AeqTop;AeqBot];

%Set the minimization target for the last entry (center of distribution)
f = zeros(sz,1);
f(end) = 1;  %minimize the last entry

%Set the bounds on the solutions to be proper probabilities
%between 0 and 1
lb = zeros(sz,1);
ub = ones(sz,1);

%Solve for the values that minimize the last variable
%x = zeros(sz,1);
x = linprog(f,[],[],Aeq,Beq,lb,ub);

Px(1,1:2) = x(1:2);
cnt = 3;
for i=2:halfCells-1
    Px(i,i-1:i+1) = x(cnt:cnt+2);
    cnt = cnt+3;
end
Px(halfCells,halfCells-1:halfCells+1) = [x(sz-1) x(sz) x(sz-1)];
cnt = sz-2;
for i=halfCells+1:nCells
    Px(i,i-1:i+1) = x(cnt+2:cnt);
    cnt = cnt-3;
end
Px(nCells,nCells-1:nCells) = x(2:1);