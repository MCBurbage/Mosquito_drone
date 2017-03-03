%tests to run with normal distribution simulation to optimize MODE 3
%parameters

%size of workspace
L = 99;
%standard deviation
sigma = L/10;
%time
testTime = 300;
%robot velocity
velocityR = 12;
%kill rate
killRate = 0.9;
%squarrel spacing
rowSpacing = L/50;
%path mode
mode = 3;
%turn in threshold
inThresh = [0.1 0.3 0.5 0.7 0.9];
%turn out threshold
outThresh = [0.1 0.3 0.5 0.7 0.9];


%get the number of tests to be performed
testCnt = numel(inThresh)*numel(outThresh);
%initialize the test data table
testResults = zeros(testCnt,3);
%initialize the test counter
cnt = 1;

for i = 1:numel(inThresh)
    for j = 1:numel(outThresh)
        disp(['Test ',num2str(cnt),' of ',num2str(testCnt)])
        disp(['i=',num2str(i),', j=',num2str(j)])
        %run simulation
        %set test result parametric information
        testResults(cnt,1) = inThresh(i);
        testResults(cnt,2) = outThresh(j);
        testResults(cnt,3) = NormalSim(L,testTime,velocityR,sigma,killRate,mode,rowSpacing,inThresh(i),outThresh(j));
        %increment the test counter
        cnt = cnt+1;
    end
end

