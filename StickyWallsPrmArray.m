%tests to run with sticky wall simulation for comparison

%size of workspace
L = 100;
%time
testTime = [300 600];
%robot velocity
velocityR = [6 9 12];
%sticking factor
stick = [0.25 0.5 0.75];
%probability of particle leaving cell
transitionPct = [0.2 0.4 0.6];
%kill rate
killRate = [0.5 0.7 0.9];
%boustrophedon spacing
rowSpacing = [L/50 L/20 L/10 L/5];
%path mode
mode = [1 2 3 4 5 6];

%get the number of tests to be performed
testCnt = numel(testTime)*numel(velocityR)*numel(stick)*numel(transitionPct)*numel(killRate)*numel(mode)*numel(rowSpacing);
%initialize the test data table
testResults = zeros(testCnt,8);
%initialize the test counter
cnt = 1;

for i = 1:numel(testTime)
    for j = 1:numel(velocityR)
        for k = 1:numel(stick)
            for l = 1:numel(transitionPct)
                for m = 1:numel(killRate)
                    for n = 1:numel(mode)
                        for o = 1:numel(rowSpacing)
                            if (mode(n)==1 || mode(n)==5 || mode(n)==6) && o>1
                                %row spacing does not matter for
                                %wall-following and greedy modes so skip 
                                %all but the first test
                                continue;
                            end
                            
                            disp(['Test ',num2str(cnt),' of ',num2str(testCnt)])
                            disp(['i=',num2str(i),', j=',num2str(j),', k=',num2str(k),', l=',num2str(l),', m=',num2str(m),', n=',num2str(n),', o=',num2str(o)])
                            %run simulation
                            switch n
                                case {1, 2, 3, 4}
                                    %set test result parametric information
                                    testResults(cnt,1) = testTime(i);
                                    testResults(cnt,2) = velocityR(j);
                                    testResults(cnt,3) = stick(k);
                                    testResults(cnt,4) = transitionPct(l);
                                    testResults(cnt,5) = killRate(m);
                                    testResults(cnt,6) = mode(n);
                                    testResults(cnt,7) = rowSpacing(o);
                                    testResults(cnt,8) = StickyWallsSim(L,testTime(i),velocityR(j),stick(k),transitionPct(l),killRate(m),mode(n),rowSpacing(o));
                                    %increment the test counter
                                    cnt = cnt+1;
                                case 5
                                    for p=1:20
                                        %set test result parametric information
                                        testResults(cnt,1) = testTime(i);
                                        testResults(cnt,2) = velocityR(j);
                                        testResults(cnt,3) = stick(k);
                                        testResults(cnt,4) = transitionPct(l);
                                        testResults(cnt,5) = killRate(m);
                                        testResults(cnt,6) = mode(n);
                                        testResults(cnt,8) = GreedySim('StickyWalls',L,testTime(i),velocityR(j),stick(k),transitionPct(l),killRate(m));
                                        %increment the test counter
                                        cnt = cnt+1;
                                    end
                                case 6
                                    for p=1:20
                                        %set test result parametric information
                                        testResults(cnt,1) = testTime(i);
                                        testResults(cnt,2) = velocityR(j);
                                        testResults(cnt,3) = stick(k);
                                        testResults(cnt,4) = transitionPct(l);
                                        testResults(cnt,5) = killRate(m);
                                        testResults(cnt,6) = mode(n);
                                        testResults(cnt,8) = Greedy2Sim('StickyWalls',L,testTime(i),velocityR(j),stick(k),transitionPct(l),killRate(m));
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
end

