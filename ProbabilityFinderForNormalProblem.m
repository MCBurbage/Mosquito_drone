clear
clc

%set the number of iterations and build a matrix to hold the results
n = 10^5;
L = 100;
endPose = zeros(n,4);
N = zeros(L,L,3,3);

for i = 1:ceil(L/2)
    for j = 1:ceil(L/2)
        %iterate through the simulator
        for k = 1:n
            %create a mosquito position randomly between 1 and 2 in each direction
            startPose = [i + rand(1), j + rand(1), -pi + 2*pi*rand(1), 1];
            %simulate the mosquito move in an LxL world and record the end position
            endPose(k,:) = MosquitoFlightSimNormal(startPose,L,1);
        end
        %pull the x and y values from the position
        xyPos = endPose(:,1:2);
        %normalize the positions
        xyPos(:,1) = xyPos(:,1)-i;
        xyPos(:,2) = xyPos(:,2)-j;
        %calculate the number of mosquitoes in each cell
        N(i,j,:,:) = hist3(xyPos,[3,3])/n;
    end
end
