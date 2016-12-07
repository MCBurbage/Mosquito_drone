function P = BuildMarkovMatrixNormal(L)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function simulates normally distributed mosquito motion in an LxL 
% environment to establish the Markov state transition probability matrix 
% for mosquitoes in a given cell.  
%
% Author:  Mary Burbage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%return if insufficient arguments passed
if nargin<1
    return;
end

%set the number of iterations
n = 10^7;
%initialize the probability matrix with a 3x3 element for each cell in one
%quadrant
N = zeros(ceil(L/2),ceil(L/2),3,3);

for i = 1:ceil(L/2)
    for j = 1:ceil(L/2)
        disp(['calculating cell (',num2str(i),',',num2str(j),')'])
        %randomly set n mosquitoes between 0 and 1 in each direction
        PoseM = [rand(n,2), 2*pi*rand(n,1), ones(n,1)];  %[x,y,theta,state] for all mosquitos
        %shift the mosquitoes to be between i and i+1 in the x direction 
        %and between j and j+1 in the y direction
        PoseM(:,1) = (i-1).*ones(n,1) + PoseM(:,1);
        PoseM(:,2) = (j-1).*ones(n,1) + PoseM(:,2);
        %simulate the mosquito move and record the end position
        PoseM = MosquitoFlightSimNormal(PoseM,L,1);
        
        %calculate the number of mosquitoes in each cell
        centers = {(i-2)+(0.5:1.0:2.5),(j-2)+(0.5:1.0:2.5)};
        %hist3(PoseM(:,1:2), 'Ctrs', centers);
        N(i,j,:,:) = hist3(PoseM(:,1:2), 'Ctrs', centers)/n;
    end
end
%create remaining three quadrants of N matrix by flipping the first
%quadrant
totalN = zeros(L,L,3,3);
totalN(1:ceil(L/2),1:ceil(L/2),:,:) = N;
for i = 1:ceil(L/2)
    for j = 1:floor(L/2)
        totalN(i,L-j+1,:,:) = flip(N(i,j,:,:),4);
    end
end
for i = 1:floor(L/2)
    for j = 1:ceil(L/2)
        totalN(L-i+1,j,:,:) = flip(N(i,j,:,:),3);
    end
    for j = 1:floor(L/2)
        totalN(L-i+1,L-j+1,:,:) = flip(flip(N(i,j,:,:),4),3);
    end
end

%for the edge cells, the row or column off the edge is 0%, and that row or
%column is added to the center row or column, depending upon which edge it
%is

%for the corner cells, after the edge updates are done for the row and then
%the column (or vice versa)

%initialize Markov probability transition matrix
P = zeros(L*L,L*L);

%handle corner cells
%top left
i = 1;
j = 1;
index = sub2ind([L L], i, j);
%same row
P(index, index) = totalN(i,j,1,1) + totalN(i,j,1,2) + totalN(i,j,2,1) + totalN(i,j,2,2);
P(index, index + L) = totalN(i,j,1,3) + totalN(i,j,2,3);
%row below
P(index, index + 1) = totalN(i,j,3,1) + totalN(i,j,3,2);
P(index, index + 1 + L) = totalN(i,j,3,3);
%top right
i = 1;
j = L;
index = sub2ind([L L], i, j);
%same row
P(index, index - L) = totalN(i,j,1,1) + totalN(i,j,2,1);
P(index, index) = totalN(i,j,1,2) + totalN(i,j,1,3) + totalN(i,j,2,2) + totalN(i,j,2,3);
%row below
P(index, index + 1 - L) = totalN(i,j,3,1);
P(index, index + 1) = totalN(i,j,3,2) + totalN(i,j,3,3);
%bottom left
i = L;
j = 1;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1) = totalN(i,j,1,1) + totalN(i,j,1,2);
P(index, index - 1 + L) = totalN(i,j,1,3);
%same row
P(index, index) = totalN(i,j,2,1) + totalN(i,j,2,2) + totalN(i,j,3,1) + totalN(i,j,3,2);
P(index, index + L) = totalN(i,j,2,3) + totalN(i,j,3,3);
%bottom right
i = L;
j = L;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1 - L) = totalN(i,j,1,1);
P(index, index - 1) = totalN(i,j,1,2) + totalN(i,j,1,3);
%same row
P(index, index - L) = totalN(i,j,2,1) + totalN(i,j,3,1);
P(index, index) = totalN(i,j,2,2) + totalN(i,j,2,3) + totalN(i,j,3,2) + totalN(i,j,3,3);

%handle edge cells
%left edge
j = 1;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1) = totalN(i,j,1,1) + totalN(i,j,1,2);
    P(index, index - 1 + L) = totalN(i,j,1,3);
    %same row
    P(index, index) = totalN(i,j,2,1) + totalN(i,j,2,2);
    P(index, index + L) = totalN(i,j,2,3);
    %row below
    P(index, index + 1) = totalN(i,j,3,1) + totalN(i,j,3,2);
    P(index, index + 1 + L) = totalN(i,j,3,3);
end
%right edge
j = L;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = totalN(i,j,1,1);
    P(index, index - 1) = totalN(i,j,1,2) + totalN(i,j,1,3);
    %same row
    P(index, index - L) = totalN(i,j,2,1);
    P(index, index) = totalN(i,j,2,2) + totalN(i,j,2,3);
    %row below
    P(index, index + 1 - L) = totalN(i,j,3,1);
    P(index, index + 1) = totalN(i,j,3,2) + totalN(i,j,3,3);
end
%top edge
i = 1;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %same row
    P(index, index - L) = totalN(i,j,1,1) + totalN(i,j,2,1);
    P(index, index) = totalN(i,j,1,2) + totalN(i,j,2,2);
    P(index, index + L) = totalN(i,j,1,3) + totalN(i,j,2,3);
    %row below
    P(index, index + 1 - L) = totalN(i,j,3,1);
    P(index, index + 1) = totalN(i,j,3,2);
    P(index, index + 1 + L) = totalN(i,j,3,3);
end
%bottom edge
i = L;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = totalN(i,j,1,1);
    P(index, index - 1) = totalN(i,j,1,2);
    P(index, index - 1 + L) = totalN(i,j,1,3);
    %same row
    P(index, index - L) = totalN(i,j,2,1) + totalN(i,j,3,1);
    P(index, index) = totalN(i,j,2,2) + totalN(i,j,3,2);
    P(index, index + L) = totalN(i,j,2,3) + totalN(i,j,3,3);
end

%handle interior cells
for i = 2:L-1
    for j = 2:L-1
        index = sub2ind([L L], i, j);
        %row above
        P(index, index - 1 - L) = totalN(i,j,1,1);
        P(index, index - 1) = totalN(i,j,1,2);
        P(index, index - 1 + L) = totalN(i,j,1,3);
        %same row
        P(index, index - L) = totalN(i,j,2,1);
        P(index, index) = totalN(i,j,2,2);
        P(index, index + L) = totalN(i,j,2,3);
        %row below
        P(index, index + 1 - L) = totalN(i,j,3,1);
        P(index, index + 1) = totalN(i,j,3,2);
        P(index, index + 1 + L) = totalN(i,j,3,3);
    end
end
end