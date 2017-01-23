nM = 10000; %number of mosquitoes/particles
L = 100;    %length of workspace
killPct = 0.9;  %kill rate
r = 1.0;    %width of area covered by robot

k = 0.1;    %percentage of mosquitoes that leave the current cell
sk = k*0.23;    %percentage of mosquitoes that moves to a cell up/down/left/right
dk = k*0.02;    %percentage of mosquitoes that moves to a diagonal cell

s = 0.0;    %percentage of mosquitoes that "stick" to the walls - this is the percentage reduction in sk and dk for wall cells

%for the edge cells, the row or column off the edge is 0%, and that row or
%column is added to the center row or column, depending upon which edge it
%is

%initialize Markov probability transition matrix
P = zeros(L*L,L*L);

%handle corner cells
%top left
i = 1;
j = 1;
index = sub2ind([L L], i, j);
%same row
P(index, index) = 1-k + 2*sk + dk;
P(index, index + L) = sk + dk + (1-s)*dk/2;
%row below
P(index, index + 1) = sk + dk + (1-s)*dk/2;
P(index, index + 1 + L) = s*dk;

%top right
i = 1;
j = L;
index = sub2ind([L L], i, j);
%same row
P(index, index - L) = sk + dk + (1-s)*dk/2;
P(index, index) = 1-k + 2*sk + dk;
%row below
P(index, index + 1 - L) = s*dk;
P(index, index + 1) = sk + dk + (1-s)*dk/2;

%bottom left
i = L;
j = 1;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1) = sk + dk + (1-s)*dk/2;
P(index, index - 1 + L) = s*dk;
%same row
P(index, index) = 1-k + 2*sk + dk;
P(index, index + L) = sk + dk + (1-s)*dk/2;

%bottom right
i = L;
j = L;
index = sub2ind([L L], i, j);
%row above
P(index, index - 1 - L) = s*dk;
P(index, index - 1) = sk + dk + (1-s)*dk/2;
%same row
P(index, index - L) = sk + dk + (1-s)*dk/2;
P(index, index) = 1-k + 2*sk + dk;

%handle edge cells
%left edge
j = 1;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1) = sk + dk + (1-s)*dk;
    P(index, index - 1 + L) = s*dk;
    %same row
    P(index, index) = 1-k + sk + (1-s)*sk;
    P(index, index + L) = s*sk;
    %row below
    P(index, index + 1) = sk + dk + (1-s)*dk;
    P(index, index + 1 + L) = s*dk;
end

%right edge
j = L;
for i = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = s*dk;
    P(index, index - 1) = sk + dk + (1-s)*dk;
    %same row
    P(index, index - L) = s*sk;
    P(index, index) = 1-k + sk + (1-s)*sk;
    %row below
    P(index, index + 1 - L) = s*dk;
    P(index, index + 1) = sk + dk + (1-s)*dk;
end

%top edge
i = 1;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %same row
    P(index, index - L) = sk + dk + (1-s)*dk;
    P(index, index) = 1-k + sk + (1-s)*sk;
    P(index, index + L) = sk + dk + (1-s)*dk;
    %row below
    P(index, index + 1 - L) = s*dk;
    P(index, index + 1) = s*sk;
    P(index, index + 1 + L) = s*dk;
end

%bottom edge
i = L;
for j = 2:L-1
    index = sub2ind([L L], i, j);
    %row above
    P(index, index - 1 - L) = s*dk;
    P(index, index - 1) = s*sk;
    P(index, index - 1 + L) = s*dk;
    %same row
    P(index, index - L) = sk + dk + (1-s)*dk;
    P(index, index) = 1-k + sk + (1-s)*sk;
    P(index, index + L) = sk + dk + (1-s)*dk;
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

Pinf = P;
for i = 1:15
    Pinf = Pinf * Pinf;
end

w = reshape(Pinf(1,:),L,L);