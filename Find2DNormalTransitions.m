function [Ps2D, w2D] = Find2DNormalTransitions(L,mu,sigma)

if nargin<3
    L = 99; %size of workspace
    mu = [L/2 L/2]; % average
    sigma = [L/8 L/8]; %standard deviation of distribution
end

%NOTE:  This only works for an odd number of cells.
if mod(L,2) == 0
    L = L+1;
end

%build the 1-D transition matrices
[Ps1Dx,~] = Find1DNormalTransitions(L,mu(1),sigma(1));
[Ps1Dy,~] = Find1DNormalTransitions(L,mu(2),sigma(2));

%build the 2-D transition matrix from the 1-D transition matrix
%initialize the matrix with zeros
P2D = zeros(L*L,L*L);

%handle corner cells
%top left
i = 1;
j = 1;
idx2D = sub2ind([L L], i, j);
%same row
P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
P2D(idx2D, idx2D+L) = Ps1Dx(i,i)*Ps1Dy(j,j+1);
%row below
P2D(idx2D, idx2D+1) = Ps1Dx(i,i+1)*Ps1Dy(j,j);
P2D(idx2D, idx2D+1+L) = Ps1Dx(i,i+1)*Ps1Dy(j,j+1);

%top right
i = 1;
j = L;
idx2D = sub2ind([L L], i, j);
%same row
P2D(idx2D, idx2D-L) = Ps1Dx(i,i)*Ps1Dy(j,j-1);
P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
%row below
P2D(idx2D, idx2D+1-L) = Ps1Dx(i,i+1)*Ps1Dy(j,j-1);
P2D(idx2D, idx2D+1) = Ps1Dx(i,i+1)*Ps1Dy(j,j);

%bottom left
i = L;
j = 1;
idx2D = sub2ind([L L], i, j);
%row above
P2D(idx2D, idx2D-1) = Ps1Dx(i,i-1)*Ps1Dy(j,j);
P2D(idx2D, idx2D-1+L) = Ps1Dx(i,i-1)*Ps1Dy(j,j+1);
%same row
P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
P2D(idx2D, idx2D+L) = Ps1Dx(i,i)*Ps1Dy(j,j+1);

%bottom right
i = L;
j = L;
idx2D = sub2ind([L L], i, j);
%row above
P2D(idx2D, idx2D-1-L) = Ps1Dx(i,i-1)*Ps1Dy(j,j-1);
P2D(idx2D, idx2D-1) = Ps1Dx(i,i-1)*Ps1Dy(j,j);
%same row
P2D(idx2D, idx2D-L) = Ps1Dx(i,i)*Ps1Dy(j,j-1);
P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);

%handle edge cells
%left edge
j = 1;
for i = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %row above
    P2D(idx2D, idx2D-1) = Ps1Dx(i,i-1)*Ps1Dy(j,j);
    P2D(idx2D, idx2D-1+L) = Ps1Dx(i,i-1)*Ps1Dy(j,j+1);
    %same row
    P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
    P2D(idx2D, idx2D+L) = Ps1Dx(i,i)*Ps1Dy(j,j+1);
    %row below
    P2D(idx2D, idx2D+1) = Ps1Dx(i,i+1)*Ps1Dy(j,j);
    P2D(idx2D, idx2D+1+L) = Ps1Dx(i,i+1)*Ps1Dy(j,j+1);
end

%right edge
j = L;
for i = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %row above
    P2D(idx2D, idx2D-1-L) = Ps1Dx(i,i-1)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D-1) = Ps1Dx(i,i-1)*Ps1Dy(j,j);
    %same row
    P2D(idx2D, idx2D-L) = Ps1Dx(i,i)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
    %row below
    P2D(idx2D, idx2D+1-L) = Ps1Dx(i,i+1)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D+1) = Ps1Dx(i,i+1)*Ps1Dy(j,j);
end

%top edge
i = 1;
for j = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %same row
    P2D(idx2D, idx2D-L) = Ps1Dx(i,i)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
    P2D(idx2D, idx2D+L) = Ps1Dx(i,i)*Ps1Dy(j,j+1);
    %row below
    P2D(idx2D, idx2D+1-L) = Ps1Dx(i,i+1)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D+1) = Ps1Dx(i,i+1)*Ps1Dy(j,j);
    P2D(idx2D, idx2D+1+L) = Ps1Dx(i,i+1)*Ps1Dy(j,j+1);
end

%bottom edge
i = L;
for j = 2:L-1
    idx2D = sub2ind([L L], i, j);
    %row above
    P2D(idx2D, idx2D-1-L) = Ps1Dx(i,i-1)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D-1) = Ps1Dx(i,i-1)*Ps1Dy(j,j);
    P2D(idx2D, idx2D-1+L) = Ps1Dx(i,i-1)*Ps1Dy(j,j+1);
    %same row
    P2D(idx2D, idx2D-L) = Ps1Dx(i,i)*Ps1Dy(j,j-1);
    P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
    P2D(idx2D, idx2D+L) = Ps1Dx(i,i)*Ps1Dy(j,j+1);
end

%handle interior cells
for i = 2:L-1
    for j = 2:L-1
        idx2D = sub2ind([L L], i, j);
        %row above
        P2D(idx2D, idx2D-1-L) = Ps1Dx(i,i-1)*Ps1Dy(j,j-1);
        P2D(idx2D, idx2D-1) = Ps1Dx(i,i-1)*Ps1Dy(j,j);
        P2D(idx2D, idx2D-1+L) = Ps1Dx(i,i-1)*Ps1Dy(j,j+1);
        %same row
        P2D(idx2D, idx2D-L) = Ps1Dx(i,i)*Ps1Dy(j,j-1);
        P2D(idx2D, idx2D) = Ps1Dx(i,i)*Ps1Dy(j,j);
        P2D(idx2D, idx2D+L) = Ps1Dx(i,i)*Ps1Dy(j,j+1);
        %row below
        P2D(idx2D, idx2D+1-L) = Ps1Dx(i,i+1)*Ps1Dy(j,j-1);
        P2D(idx2D, idx2D+1) = Ps1Dx(i,i+1)*Ps1Dy(j,j);
        P2D(idx2D, idx2D+1+L) = Ps1Dx(i,i+1)*Ps1Dy(j,j+1);
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
