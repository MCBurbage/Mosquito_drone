clear
clc

%set the number of iterations
n = 10^7;
%set the size of the workspace
L = 100;
%initialize the probability matrix with a 3x3 element for each cell
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
