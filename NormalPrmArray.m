%tests to run with normal distribution simulation for comparison

%size of workspace
L = 99;
%standard deviation
sigma = [L/20 L/10 L/5 L/2];
%time
testTime = [300 600];
%robot velocity
velocityR = [6 9 12];
%kill rate
killRate = [0.5 0.7 0.9];
%squarrel spacing
rowSpacing = [L/50 L/20 L/10 L/5];
%path mode
mode = [1 2 3 4 5];

%get the number of tests to be performed
testCnt = numel(sigma)*numel(testTime)*numel(velocityR)*numel(killRate)*numel(mode)*numel(rowSpacing);
%initialize the test data table
testResults = zeros(testCnt,7);
%initialize the test counter
cnt = 1;

for i = 1:numel(testTime)
    for j = 1:numel(velocityR)
        for k = 1:numel(sigma)
            for l = 1:numel(killRate)
                for m = 1:numel(mode)
                    for n = 1:numel(rowSpacing)
                        if (mode(m)==4 || mode(m)==5) && n>1
                            %row spacing does not matter for greedy modes
                            %so skip all but the first test
                            continue;
                        end
                        
                        disp(['Test ',num2str(cnt),' of ',num2str(testCnt)])
                        disp(['i=',num2str(i),', j=',num2str(j),', k=',num2str(k),', l=',num2str(l),', m=',num2str(m),', n=',num2str(n)])
                        %run simulation
                        switch mode(m)
                            case {1, 2, 3}
                                %set test result parametric information
                                testResults(cnt,1) = testTime(i);
                                testResults(cnt,2) = velocityR(j);
                                testResults(cnt,3) = sigma(k);
                                testResults(cnt,4) = killRate(l);
                                testResults(cnt,5) = mode(m);
                                testResults(cnt,6) = rowSpacing(n);
                                testResults(cnt,7) = NormalSim(L,testTime(i),velocityR(j),sigma(k),killRate(l),mode(m),rowSpacing(n));
                                %increment the test counter
                                cnt = cnt+1;
                            case 4
                                for p=1:20
                                    %set test result parametric information
                                    testResults(cnt,1) = testTime(i);
                                    testResults(cnt,2) = velocityR(j);
                                    testResults(cnt,3) = sigma(k);
                                    testResults(cnt,4) = killRate(l);
                                    testResults(cnt,5) = mode(m);
                                    testResults(cnt,7) = GreedySim('Normal',L,testTime(i),velocityR(j),sigma(k),0,killRate(l));
                                    %increment the test counter
                                    cnt = cnt+1;
                                end
                            case 5
                                for p=1:20
                                    %set test result parametric information
                                    testResults(cnt,1) = testTime(i);
                                    testResults(cnt,2) = velocityR(j);
                                    testResults(cnt,3) = sigma(k);
                                    testResults(cnt,4) = killRate(l);
                                    testResults(cnt,5) = mode(m);
                                    testResults(cnt,7) = Greedy2Sim('Normal',L,testTime(i),velocityR(j),sigma(k),0,killRate(l));
                                    %increment the test counter
                                    cnt = cnt+1;
                                end
                        end
                    end
                end
            end
        end
    end
end

