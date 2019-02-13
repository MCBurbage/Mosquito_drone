function [Ps, w,st] = Find1DNormalTransitions(L,mu,sigma,k)

if nargin<3
    L = 99; %size of workspace
    mu = L/2; % average
    sigma = L/5; %standard deviation of distribution
    k = 0.5; %diffusion rate from center cell
end

%NOTE:  This only works for an odd number of cells.
if mod(L,2) == 0
    L = L+1;
end

%find the desired stationary distribution
w = zeros(1,L); %initialize the distribution

%calculate percentage of population in each cell
w(1) = normcdf(1,mu,sigma) - normcdf(0,mu,sigma);
for i = 2:L
    w(i) = (normcdf(i,mu,sigma) - normcdf((i-1),mu,sigma));
end
w = w./sum(sum(w));

%calculate the number of unknowns - half the size of the matrix with three
%unknowns for each row except the first and last which have only two
%unknowns each
sz = ceil(L/2)*3-2;

%set number of cells in half the distribution
halfCells = ceil(L/2);

%construct constraint equations
%Fill top of Aeq matrix with probability constraints-each row must sum to 1
%Initialize with a zero matrix
AeqTop = zeros(halfCells, sz);
%The first cell has only two possible moves (stay or right)
AeqTop(1,1:2) = [1,1];
%The interior cells have three possible moves (left, stay, or right)
cnt = 3;
for i = 2:halfCells-1
    AeqTop(i,cnt:cnt+2) = [1,1,1];
    cnt=cnt+3;
end
%The last cell has only two possible moves (left or stay) but symmetry
%makes it twice as likely to leave as stay
AeqTop(halfCells,cnt:cnt+1) = [2,1];
%Fill top of Beq matrix with probability constraints
%Each row must sum to 1
BeqTop = ones(halfCells,1);

%Fill bottom of Aeq matrix with wP = w constraints
AeqBot = zeros(halfCells, sz);
%The first row only has two entries
AeqBot(1,1:3) = [w(1),0,w(2)];
%Interior rows have three entries
cnt = 2;
for i = 2:halfCells-1
    AeqBot(i,cnt:cnt+4) = [w(i-1),0,w(i),0,w(i+1)];
    cnt = cnt+3;
end
%The last row only has two entries but one is doubled due to symmetry
AeqBot(halfCells,cnt:sz) = [2*w(halfCells-1),0,w(halfCells)];

%Fill bottom of Beq matrix with wP = w constraints
BeqBot = w(1:halfCells)';

%Add final constraint that defines the diffusion rate for the center of the
%distribution
AeqLast = [zeros(1,sz-2),1,0];
BeqLast = k/2;

%Concatenate the Aeq and Beq matrices
Aeq = [AeqTop;AeqBot;AeqLast];
Beq = [BeqTop;BeqBot;BeqLast];

%Set the minimization target for all entries
f = ones(sz,1);

%Set the bounds on the solutions to be proper probabilities
%between 0 and 1
lb = zeros(sz,1);
ub = ones(sz,1);

%Solve for the values that minimize the last variable
x = linprog(f,[],[],Aeq,Beq,lb,ub);

%Build the transition matrix from the solutions to the linear programming
%problem
%initialize the transition matrices with zeros
P = zeros(L,L);
%The first row has two entries
P(1,1:2) = x(1:2);
cnt = 3;
%The interior rows have three entries
for i=2:halfCells-1
    P(i,i-1:i+1) = x(cnt:cnt+2);
    cnt = cnt+3;
end
%The center row has the last two entries
%The symmetry around the center reverses the order for the rest of the
%distribution
P(halfCells,halfCells-1:halfCells+1) = [x(sz-1) x(sz) x(sz-1)];
cnt = sz-2;
%The interior rows have three entries
for i=halfCells+1:L-1
    P(i,i-1:i+1) = flipud(x(cnt-2:cnt));
    cnt = cnt-3;
end
%The last row has the last two entries
P(L,L-1:L) = [x(2),x(1)];

%Convert the transition matrix to a sparse matrix
Ps = sparse(P);
%Find the eigenvalues
[V,~] = eigs(Ps');
%The first column holds the stationary distribution
st = V(:,1)';
%Normalize the stationary distribution to be proper probabilities [0,1]
st = st./sum(st);
st

%a=1;