nM = 10000;
L = 100;
cellSize = 1;
mu = [L/2 L/2];
sigma = [L/10 L/10];

nCells = L/cellSize;
p = zeros(nCells,2);
for i = 1:nCells
    p(i,1) = (normcdf(i*cellSize,mu(1),sigma(1)) - normcdf((i-1)*cellSize,mu(1),sigma(1)));
    p(i,2) = (normcdf(i*cellSize,mu(2),sigma(2)) - normcdf((i-1)*cellSize,mu(2),sigma(2)));
end

ptot = zeros(nCells, nCells);
for i = 1:nCells
    for j = 1:nCells
        ptot(i,j) = p(i,1)*p(j,2);
    end
end
ptot = nM*ptot;

w = reshape(ptot,numel(ptot),1);
