% mu = 1.5;
% sigma = 0.5;
% cell(1) = normcdf(1,mu,sigma);
% cell(2) = normcdf(2,mu,sigma)-normcdf(1,mu,sigma);
% cell(3) = normcdf(3,mu,sigma)-normcdf(2,mu,sigma);

% a = 0.5805;
% b = 0.27;
% 
% T3 = [1-a  a   0;
%      b/2 1-b b/2;
%       0   a  1-a];
% w3 = limitdist(T3)

mu = 2.5;
sigma = 0.5;
for i = 1:5
    cell(i) = normcdf(i,mu,sigma) - normcdf(i-1,mu,sigma);
end

a = 0.905;
b = 0.3;
c = 0.5;
d = 0.5;

T5 = [1-a a     0   0     0;
      b   1-b-c c   0     0;
      0   d/2   1-d d/2   0;
      0   0     c   1-b-c b;
      0   0     0   a     1-a];
w5 = limitdist(T5)