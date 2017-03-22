function [Ps, w] = FindStickyWallTransitions(L,k,s)
% Builds a Markov transition matrix and stationary distribution for moving
% particles in a workspace.
% L is the size of the workspace
% k is the fraction of particles leaving the cell (total of off-diagonal
% elements of the transition matrix)
% s is the "sticking" coefficient - it reduces k for the edge cells (0 =
% edge same as center, 1 = can't leave edges
% Ps is the transition matrix (sparse)
% w is the stationary distribution
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SAVE_INFO = false;

%set the fraction of the mosquitoes that move to other cells
sk = k*0.23;    %to a cell up/down/left/right
dk = k*0.02;    %to a diagonal cell

%for the edge cells, the row or column off the edge is 0%, and that row or
%column is added to the center row or column, depending upon which edge it
%is
%corner cells do this for two edges

%initialize Markov probability transition matrix
P = zeros(L*L,L*L);

%handle corner cells
%top left
i = 1;
j = 1;
index = sub2ind([L L], i, j);
%same row
P(index, index) = 1-k + 2*sk + dk;
P(index, index + L) = sk + dk + s*dk/2;
%row below
P(index, index + 1) = sk + dk + s*dk/2;
P(index, index + 1 + L) = (1-s)*dk;

%top right
i = 1;
j = L;
index = sub2ind([L L], i, j);
%same row
P(index, index - L) = sk + dk + s*dk/2;
P(index, index) = 1-k + 2*sk + dk;
%row below
P(index, index + 1 - L) = (1-s)*dk;
P(index, index + 1) = sk + dk + s*dk/2;

%bottom left
i = L;
j = 1;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1) = sk + dk + s*dk/2;
P(index, index - 1 + L) = (1-s)*dk;
%same row
P(index, index) = 1-k + 2*sk + dk;
P(index, index + L) = sk + dk + s*dk/2;

%bottom right
i = L;
j = L;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1 - L) = (1-s)*dk;
P(index, index - 1) = sk + dk + s*dk/2;
%same row
P(index, index - L) = sk + dk + s*dk/2;
P(index, index) = 1-k + 2*sk + dk;

%handle edge cells
%left edge
j = 1;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1) = sk + dk + s*dk;
    P(index, index - 1 + L) = (1-s)*dk;
    %same row
    P(index, index) = 1-k + sk + s*sk;
    P(index, index + L) = (1-s)*sk;
    %row below
    P(index, index + 1) = sk + dk + s*dk;
    P(index, index + 1 + L) = (1-s)*dk;
end

%right edge
j = L;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = (1-s)*dk;
    P(index, index - 1) = sk + dk + s*dk;
    %same row
    P(index, index - L) = (1-s)*sk;
    P(index, index) = 1-k + sk + s*sk;
    %row below
    P(index, index + 1 - L) = (1-s)*dk;
    P(index, index + 1) = sk + dk + s*dk;
end

%top edge
i = 1;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %same row
    P(index, index - L) = sk + dk + s*dk;
    P(index, index) = 1-k + sk + s*sk;
    P(index, index + L) = sk + dk + s*dk;
    %row below
    P(index, index + 1 - L) = (1-s)*dk;
    P(index, index + 1) = (1-s)*sk;
    P(index, index + 1 + L) = (1-s)*dk;
end

%bottom edge
i = L;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = (1-s)*dk;
    P(index, index - 1) = (1-s)*sk;
    P(index, index - 1 + L) = (1-s)*dk;
    %same row
    P(index, index - L) = sk + dk + s*dk;
    P(index, index) = 1-k + sk + s*sk;
    P(index, index + L) = sk + dk + s*dk;
end

%handle interior cells
for i = 2:L-1
    for j = 2:L-1
        index = sub2ind([L L], i, j);
        %row above
        P(index, index - 1 - L) = dk;
        P(index, index - 1) = sk;
        P(index, index - 1 + L) = dk;
        %same row
        P(index, index - L) = sk;
        P(index, index) = 1-k;
        P(index, index + L) = sk;
        %row below
        P(index, index + 1 - L) = dk;
        P(index, index + 1) = sk;
        P(index, index + 1 + L) = dk;
    end
end

Ps = sparse(P);

%calculate the stationary distribution of the population
%get the eigenvalues
[V,~] = eigs(Ps');
%the first column of the matrix is the stationary distribution
w = V(:,1).';
%normalize the stationary distribution to value probabilities [0,1]
w = w./sum(w);
%reshape the final distribution from a row vector to an LxL map
w = reshape(w,L,L);
%save the data
if SAVE_INFO
    save('StationaryDist.mat','Ps','w');
end