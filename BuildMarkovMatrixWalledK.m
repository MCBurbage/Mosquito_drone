function P = BuildMarkovMatrixWalledK(L)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function simulates mosquito motion in an LxL walled environment to
% establish the Markov state transition probability matrix for mosquitoes
% in a given cell.  Mosquito samples are pulled from a uniform random
% distribution.
%
% Author:  Mary Burbage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k = 0.05;
N = [k/12, k/6, k/12; k/6, 1-k, k/6; k/12, k/6, k/12];

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
end