function P = FindWalledProbabilities(L)

%set the number of iterations
n = 10^7;
%randomly set n mosquitoes between 0 and 1 in each direction
PoseM = [rand(n,2), 2*pi*rand(n,1), ones(n,1)];  %[x,y,theta,state] for all mosquitos
%shift the mosquitoes to be between 1 and 2 in ech direction
PoseM(:,1:2) = ones(n,2) + PoseM(:,1:2);
%simulate the mosquito move in a 3x3 world and record the end position
PoseM = MosquitoFlightSimWalled(PoseM,3,1);

%calculate the number of mosquitoes in each cell
centers = {(0.5:1.0:2.5),(0.5:1.0:2.5)};
%hist3(PoseM(:,1:2), 'Ctrs', centers);
N = hist3(PoseM(:,1:2), 'Ctrs', centers)/n;

%results from run on 11/21/16
%N = [.0043 .0552 .0043; .0552 .762 .0552; .0043 .0552 .0043];
%therefore the probability of a move up/down/left/right is 5.52%, the
%probability of a diagonal move is 0.43%, and the probability of staying in
%the same square is 76.2%

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
P(index, index) = N(1,1) + N(1,2) + N(2,1) + N(2,2);
P(index, index + L) = N(1,3) + N(2,3);
%row below
P(index, index + 1) = N(3,1) + N(3,2);
P(index, index + 1 + L) = N(3,3);
%top right
i = 1;
j = L;
index = sub2ind([L L], i, j);
%same row
P(index, index - L) = N(1,1) + N(2,1);
P(index, index) = N(1,2) + N(1,3) + N(2,2) + N(2,3);
%row below
P(index, index + 1 - L) = N(3,1);
P(index, index + 1) = N(3,2) + N(3,3);
%bottom left
i = L;
j = 1;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1) = N(1,1) + N(1,2);
P(index, index - 1 + L) = N(1,3);
%same row
P(index, index) = N(2,1) + N(2,2) + N(3,1) + N(3,2);
P(index, index + L) = N(2,3) + N(3,3);
%bottom right
i = L;
j = L;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1 - L) = N(1,1);
P(index, index - 1) = N(1,2) + N(1,3);
%same row
P(index, index - L) = N(2,1) + N(3,1);
P(index, index) = N(2,2) + N(2,3) + N(3,2) + N(3,3);

%handle edge cells
%left edge
j = 1;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1) = N(1,1) + N(1,2);
    P(index, index - 1 + L) = N(1,3);
    %same row
    P(index, index) = N(2,1) + N(2,2);
    P(index, index + L) = N(2,3);
    %row below
    P(index, index + 1) = N(3,1) + N(3,2);
    P(index, index + 1 + L) = N(3,3);
end
%right edge
j = L;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = N(1,1);
    P(index, index - 1) = N(1,2) + N(1,3);
    %same row
    P(index, index - L) = N(2,1);
    P(index, index) = N(2,2) + N(2,3);
    %row below
    P(index, index + 1 - L) = N(3,1);
    P(index, index + 1) = N(3,2) + N(3,3);
end
%top edge
i = 1;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %same row
    P(index, index - L) = N(1,1) + N(2,1);
    P(index, index) = N(1,2) + N(2,2);
    P(index, index + L) = N(1,3) + N(2,3);
    %row below
    P(index, index + 1 - L) = N(3,1);
    P(index, index + 1) = N(3,2);
    P(index, index + 1 + L) = N(3,3);
end
%bottom edge
i = L;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = N(1,1);
    P(index, index - 1) = N(1,2);
    P(index, index - 1 + L) = N(1,3);
    %same row
    P(index, index - L) = N(2,1) + N(3,1);
    P(index, index) = N(2,2) + N(3,2);
    P(index, index + L) = N(2,3) + N(3,3);
end

%handle interior cells
for i = 2:L-1
    for j = 2:L-1
        index = sub2ind([L L], i, j);
        %row above
        P(index, index - 1 - L) = N(1,1);
        P(index, index - 1) = N(1,2);
        P(index, index - 1 + L) = N(1,3);
        %same row
        P(index, index - L) = N(2,1);
        P(index, index) = N(2,2);
        P(index, index + L) = N(2,3);
        %row below
        P(index, index + 1 - L) = N(3,1);
        P(index, index + 1) = N(3,2);
        P(index, index + 1 + L) = N(3,3);
    end
end