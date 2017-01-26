mu = 1.5;
sigma = 0.5;
cell(1) = normcdf(1,mu,sigma);
cell(2) = normcdf(2,mu,sigma)-normcdf(1,mu,sigma);
cell(3) = normcdf(3,mu,sigma)-normcdf(2,mu,sigma);

a = 0.5805;
b = 0.27;

T3 = [1-a  a   0;
     b/2 1-b b/2;
      0   a  1-a];
w3 = limitdist(T3)