%NOTE:  This only works for an odd number of cells.


%initialize variables
L = 99; %workspace edge length
cellSize = 1; %
mu = [L/2 L/2]; % average
sigma = [L/10 L/10]; %standard deviation of distribution

nCells = L/cellSize; %total number of cells
w = zeros(1,nCells); %initialize the distribution

%calculate percentage of population in each cell
w(1) = normcdf(cellSize,mu(1),sigma(1));
for i = 2:nCells-1
    w(i) = (normcdf(i*cellSize,mu(1),sigma(1)) - normcdf((i-1)*cellSize,mu(1),sigma(1)));
end
w(nCells) = 1-sum(sum(w));


%calculate the number of unknowns - half the size of the matrix with three
%unknowns for each row except the first and last which have only two
%unknowns each
sz = ceil(nCells/2)*3-2;

%set number of cells in half the distribution
halfCells = ceil(nCells/2);

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

%Fill bottom of Aeq matrix with wP = w constraints
BeqBot = w(1:halfCells)';

%Concatenate the Aeq and Beq matrices
Aeq = [AeqTop;AeqBot];
Beq = [BeqTop;BeqBot];

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
P = zeros(nCells,nCells);
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
for i=halfCells+1:nCells-1
    P(i,i-1:i+1) = flipud(x(cnt-2:cnt));
    cnt = cnt-3;
end
%The last row has the last two entries
P(nCells,nCells-1:nCells) = [x(2),x(1)];

%Convert the transition matrix to a sparse matrix
Ps = sparse(P);
%Find the eigenvalues
[V,~] = eigs(Ps');
%The first column holds the stationary distribution
st = V(:,1)';
%Normalize the stationary distribution to be proper probabilities [0,1]
st = st./sum(st);


%build the 2-D transition matrix from the 1-D transition matrix
%initialize the matrix with zeros
P2D = zeros(nCells*nCells,nCells*nCells);

%handle corner cells
%top left
i = 1;
j = 1;
idx2D = sub2ind([L L], i, j);
%same row
P2D(idx2D, idx2D) = P(i,i)*P(j,j);
P2D(idx2D, idx2D+L) = P(i,i)*P(j,j+1);
%row below
P2D(idx2D, idx2D+1) = P(i,i+1)*P(j,j);
P2D(idx2D, idx2D+1+L) = P(i,i+1)*P(j,j+1);

%top right
i = 1;
j = L;
idx2D = sub2ind([L L], i, j);
%same row
P2D(idx2D, idx2D-L) = P(i,i)*P(j,j-1);
P2D(idx2D, idx2D) = P(i,i)*P(j,j);
%row below
P2D(idx2D, idx2D+1-L) = P(i,i+1)*P(j,j-1);
P2D(idx2D, idx2D+1) = P(i,i+1)*P(j,j);

%bottom left
i = L;
j = 1;
idx2D = sub2ind([L L], i, j);
%row above
P2D(idx2D, idx2D-1) = P(i,i-1)*P(j,j);
P2D(idx2D, idx2D-1+L) = P(i,i-1)*P(j,j+1);
%same row
P2D(idx2D, idx2D) = P(i,i)*P(j,j);
P2D(idx2D, idx2D+L) = P(i,i)*P(j,j+1);

%bottom right
i = L;
j = L;
idx2D = sub2ind([L L], i, j);
%row above
P2D(idx2D, idx2D-1-L) = P(i,i-1)*P(j,j-1);
P2D(idx2D, idx2D-1) = P(i,i-1)*P(j,j);
%same row
P2D(idx2D, idx2D-L) = P(i,i)*P(j,j-1);
P2D(idx2D, idx2D) = P(i,i)*P(j,j);

%handle edge cells
%left edge
j = 1;
for i = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %row above
    P2D(idx2D, idx2D-1) = P(i,i-1)*P(j,j);
    P2D(idx2D, idx2D-1+L) = P(i,i-1)*P(j,j+1);
    %same row
    P2D(idx2D, idx2D) = P(i,i)*P(j,j);
    P2D(idx2D, idx2D+L) = P(i,i)*P(j,j+1);
    %row below
    P2D(idx2D, idx2D+1) = P(i,i+1)*P(j,j);
    P2D(idx2D, idx2D+1+L) = P(i,i+1)*P(j,j+1);
end

%right edge
j = L;
for i = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %row above
    P2D(idx2D, idx2D-1-L) = P(i,i-1)*P(j,j-1);
    P2D(idx2D, idx2D-1) = P(i,i-1)*P(j,j);
    %same row
    P2D(idx2D, idx2D-L) = P(i,i)*P(j,j-1);
    P2D(idx2D, idx2D) = P(i,i)*P(j,j);
    %row below
    P2D(idx2D, idx2D+1-L) = P(i,i+1)*P(j,j-1);
    P2D(idx2D, idx2D+1) = P(i,i+1)*P(j,j);
end

%top edge
i = 1;
for j = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %same row
    P2D(idx2D, idx2D-L) = P(i,i)*P(j,j-1);
    P2D(idx2D, idx2D) = P(i,i)*P(j,j);
    P2D(idx2D, idx2D+L) = P(i,i)*P(j,j+1);
    %row below
    P2D(idx2D, idx2D+1-L) = P(i,i+1)*P(j,j-1);
    P2D(idx2D, idx2D+1) = P(i,i+1)*P(j,j);
    P2D(idx2D, idx2D+1+L) = P(i,i+1)*P(j,j+1);
end

%bottom edge
i = L;
for j = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %row above
    P2D(idx2D, idx2D-1-L) = P(i,i-1)*P(j,j-1);
    P2D(idx2D, idx2D-1) = P(i,i-1)*P(j,j);
    P2D(idx2D, idx2D-1+L) = P(i,i-1)*P(j,j+1);
    %same row
    P2D(idx2D, idx2D-L) = P(i,i)*P(j,j-1);
    P2D(idx2D, idx2D) = P(i,i)*P(j,j);
    P2D(idx2D, idx2D+L) = P(i,i)*P(j,j+1);
end

%handle interior cells
for i = 2:L-1
    for j = 2:L-1
        idx2D = sub2ind([L L], i, j);
        %row above
        P2D(idx2D, idx2D-1-L) = P(i,i-1)*P(j,j-1);
        P2D(idx2D, idx2D-1) = P(i,i-1)*P(j,j);
        P2D(idx2D, idx2D-1+L) = P(i,i-1)*P(j,j+1);
        %same row
        P2D(idx2D, idx2D-L) = P(i,i)*P(j,j-1);
        P2D(idx2D, idx2D) = P(i,i)*P(j,j);
        P2D(idx2D, idx2D+L) = P(i,i)*P(j,j+1);
        %row below
        P2D(idx2D, idx2D+1-L) = P(i,i+1)*P(j,j-1);
        P2D(idx2D, idx2D+1) = P(i,i+1)*P(j,j);
        P2D(idx2D, idx2D+1+L) = P(i,i+1)*P(j,j+1);
    end
end

Ps2D = sparse(P2D);

%calculate the stationary distribution of the population
%get the eigenvalues
[V,~] = eigs(Ps2D');
%the first column of the matrix is the stationary distribution
w2D = V(:,1).';
%normalize the stationary distribution to value probabilities [0,1]
w2D = w2D./sum(w2D);
%reshape the final distribution from a row vector to an LxL map
w2D = reshape(w2D,L,L);
%save the data
if false %SAVE_INFO
    save('NormalStationaryDist.mat','Ps2D','w2D');
end
