mu = 0;
sigma = 2;
N = 5;
cell = zeros(1,N);
for i = 1:N
    cell(i) = normcdf(i,mu,sigma) - normcdf(i-1,mu,sigma);
end

% P(3,2) = cell(2)/(cell(2)+cell(4))*h;
% P(3,3) = 1-h;
% P(3,4) = cell(4)/(cell(2)+cell(4))*h;
% 
% P(4,3) = cell(3)/(cell(3)+cell(5))*k;
% P(4,4) = 1-k;
% P(4,5) = cell(5)/(cell(3)+cell(5))*k;
% P(4,3) = P(3,4);
%
% P(5,4) = m;
% P(5,5) = 1-m;
% P(5,4) = P(4,5);
%
% %set k and solve for m
% cell(5)/(cell(3)+cell(5))*k = P(4,5) = P(5,4) = m;
% cell(5)/(cell(3)+cell(5))*k = m;
% m = cell(5)/(cell(3)+cell(5))*k;
%
% %set k and solve for h
% cell(4)/(cell(2)+cell(4))*h = P(3,4) = P(4,3) = cell(3)/(cell(3)+cell(5))*k;
% cell(4)/(cell(2)+cell(4))*h = cell(3)/(cell(3)+cell(5))*k;
% 1/(cell(2)+cell(4))*h = cell(3)/cell(4)*1/(cell(3)+cell(5))*k;
% h = [cell(3)/cell(4)]*[(cell(2)+cell(4))/(cell(3)+cell(5))]*k;
%
% %going another step away from k
% %h is now known so solve for g
% cell(2)/(cell(2)+cell(4))*h = P(3,2) = P(2,3) = cell(3)/(cell(1)+cell(3))*g;
% cell(2)/(cell(2)+cell(4))*h = cell(3)/(cell(1)+cell(3))*g;
% cell(2)/cell(3)*1/(cell(2)+cell(4))*h = 1/(cell(1)+cell(3))*g;
% g = [cell(2)/cell(3)]*[(cell(1)+cell(3))/(cell(2)+cell(4))]*h;
% g = [cell(2)/cell(3)]*[(cell(1)+cell(3))/(cell(2)+cell(4))]*[cell(3)/cell(4)]*[(cell(2)+cell(4))/(cell(3)+cell(5))]*k;
% g = [cell(2)/cell(4)]*[(cell(1)+cell(3))/(cell(2)+cell(4))]*[(cell(2)+cell(4))/(cell(3)+cell(5))]*k;
% g = [cell(2)/cell(4)]*[(cell(1)+cell(3))/(cell(3)+cell(5))]*k;
%
% %going another step away from k
% %g is now known so solve for f
% cell(1)/(cell(1)+cell(3))*g = P(2,1) = P(1,2) = cell(2)/(cell(0)+cell(2))*f;
% cell(1)/(cell(1)+cell(3))*g = cell(2)/(cell(0)+cell(2))*f;
% cell(1)/cell(2)*1/(cell(1)+cell(3))*g = 1/(cell(0)+cell(2))*f;
% f = [cell(1)/cell(2)]*[(cell(0)+cell(2))/(cell(1)+cell(3))]*g;
% f = [cell(1)/cell(2)]*[(cell(0)+cell(2))/(cell(1)+cell(3))]*[cell(2)/cell(4)]*[(cell(1)+cell(3))/(cell(3)+cell(5))]*k;
% f = [cell(1)/cell(4)]*[(cell(0)+cell(2))/(cell(1)+cell(3))]*[(cell(1)+cell(3))/(cell(3)+cell(5))]*k;
% f = [cell(1)/cell(4)]*[(cell(0)+cell(2))/(cell(3)+cell(5))]*k;
%
% going another step away from k - at the end of the range
% %f is now known so solve for d
% d = P(0,1) = P(1,0) = cell(0)/(cell(0)+cell(2))*f;
% d = cell(0)/(cell(0)+cell(2))*f;
% d = [cell(0)/(cell(0)+cell(2))]*[cell(1)/cell(4)]*[(cell(0)+cell(2))/(cell(3)+cell(5))]*k;
% d = cell(0)*[cell(1)/cell(4)]*[1/(cell(3)+cell(5))]*k;


%set k at 1 st. dev. from mean
ksigma = 0.5;
k = zeros(1,N);
%calculate k for all other cells
%general formula
%k(i) = [cell(i)/cell(sigma)]*[(cell(i-1)+(cell(i+1))/(cell(sigma-1)+cell(sigma+1))]*k(sigma);
fact = ksigma/(cell(sigma)*(cell(sigma-1)+cell(sigma+1)));
i = 1;
k(i) = cell(i)*cell(i+1)*fact;
for i = 2:N-1
    k(i) = cell(i)*(cell(i-1)+cell(i+1))*fact;
end
i = N;
k(i) = cell(i)*cell(i-1)*fact;

%check for any k outside the bounds of [0,1]
kerr = (k<0) | (k>1);
%quit on error
if any(kerr)
    disp('Error:  k outside bounds [0,1]')
    return;
end
if k(1) > 0.5
    disp('Error:  center k > 0.5')
    return;
end

P = zeros(N*2-1,N*2-1);
i = 1;
j = N-(i-1);
P(i,i+1) = k(j);
P(i,i) = 1-k(j);
for i = 2:N-1
    j = N-(i-1);
    P(i,i-1) = cell(j+1)/(cell(j+1)+cell(j-1))*k(j);
    P(i,i+1) = cell(j-1)/(cell(j+1)+cell(j-1))*k(j);
    P(i,i) = 1-k(j);
end
i = N;
j = 1;
P(i,i-1) = k(j);
P(i,i+1) = k(j);
P(i,i) = 1-2*k(j);
for i = N+1:2*N-2
    j = i-(N-1);
    P(i,i-1) = cell(j-1)/(cell(j+1)+cell(j-1))*k(j);
    P(i,i+1) = cell(j+1)/(cell(j+1)+cell(j-1))*k(j);
    P(i,i) = 1-k(j);
end
i = 2*N-1;
j = i-(N-1);
P(i,i-1) = k(j);
P(i,i) = 1-k(j);

%condense P into a sparse matrix
Ps = sparse(P);

%calculate the stationary distribution of the population
[V,~] = eigs(Ps');
st = V(:,1).';
st = st./sum(st);

dist = [fliplr(cell),cell(2:N)];
%bar([dist', st'])
