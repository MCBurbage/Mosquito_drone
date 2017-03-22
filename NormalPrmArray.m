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
%probability of particle leaving center cell
transitionPct = [0.2 0.4 0.6];
%path mode
mode = [1 2 3 4 5];

%get the number of tests to be performed
testCnt = numel(sigma)*numel(testTime)*numel(velocityR)*numel(killRate)*numel(mode(1:3))*numel(rowSpacing)*numel(transitionPct) + numel(sigma)*numel(testTime)*numel(velocityR)*numel(killRate)*numel(mode(4:5))*numel(transitionPct)*20;
%initialize the test data table
testResults = zeros(testCnt,8);
%initialize the test counter
cnt = 1;

%run squarrel tests
for i = 1:numel(testTime)
    for j = 1:numel(velocityR)
        for k = 1:numel(sigma)
            for l = 1:numel(killRate)
                for m = 1:3
                    for n = 1:numel(rowSpacing)
                        for o = 1:numel(transitionPct)
                            disp(['Test ',num2str(cnt),' of ',num2str(testCnt)])
                            disp(['i=',num2str(i),', j=',num2str(j),', k=',num2str(k),', l=',num2str(l),', m=',num2str(m),', n=',num2str(n)])
                            %run simulation
                            %set test result parametric information
                            testResults(cnt,1) = testTime(i);
                            testResults(cnt,2) = velocityR(j);
                            testResults(cnt,3) = sigma(k);
                            testResults(cnt,4) = killRate(l);
                            testResults(cnt,5) = mode(m);
                            testResults(cnt,6) = rowSpacing(n);
                            testResults(cnt,7) = transitionPct(o);
                            try
                                testResults(cnt,8) = NormalSim(L,testTime(i),velocityR(j),sigma(k),transitionPct(o),killRate(l),mode(m),rowSpacing(n));
                            catch
                                testResults(cnt,8) = -1;
                            end
                            %increment the test counter
                            cnt = cnt+1;
                        end
                    end
                end
            end
        end
    end
end

%run greedy tests
for i = 1:numel(testTime)
    for j = 1:numel(velocityR)
        for k = 1:numel(sigma)
            for l = 1:numel(killRate)
                for m = 4:5
                    for o = 1:numel(transitionPct)
                        for p=1:20
                            disp(['Test ',num2str(cnt),' of ',num2str(testCnt)])
                            disp(['i=',num2str(i),', j=',num2str(j),', k=',num2str(k),', l=',num2str(l),', m=',num2str(m)])
                            %set test result parametric information
                            testResults(cnt,1) = testTime(i);
                            testResults(cnt,2) = velocityR(j);
                            testResults(cnt,3) = sigma(k);
                            testResults(cnt,4) = killRate(l);
                            testResults(cnt,5) = mode(m);
                            testResults(cnt,7) = transitionPct(o);
                            %run simulation
                            try
                                switch mode(m)
                                    case 4
                                        testResults(cnt,8) = GreedySim('Normal',L,testTime(i),velocityR(j),transitionPct(o),sigma(k),killRate(l));
                                    case 5
                                        testResults(cnt,8) = Greedy2Sim('Normal',L,testTime(i),velocityR(j),transitionPct(o),sigma(k),killRate(l));
                                end
                            catch
                                testResults(cnt,8) = -1;
                            end
                            %increment the test counter
                            cnt = cnt+1;
                        end
                    end
                end
            end
        end
    end
end
