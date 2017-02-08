function res = TestingSpiralPrms

testCount = 5; %number of iterations to perform
maxDirMode = 3; %number of modes to test
inThreshVals = [0.3 0.4 0.5 0.6 0.7 0.8];
outThreshVals = [0.3 0.4 0.5 0.6 0.7 0.8];
%TODO:  Set up waypoint lists for comparison
wpLists = [1 2 3];

%find total number of tests to be run
totalTestCnt = 0;
%add mode 1 tests
if maxDirMode >= 1
    totalTestCnt = testCount;
end
%add mode 2 tests
if maxDirMode >= 2
    totalTestCnt = totalTestCnt + testCount;
end
%add mode 3 tests for all values from parametric arrays
if maxDirMode >= 3
    [~,m] = size(inThreshVals);
    [~,n] = size(outThreshVals);
    totalTestCnt = totalTestCnt + m*n*testCount;
end
%add mode 4 tests for all sets of waypoint lists
if maxDirMode >= 4
    [o,~] = size(wpLists);
    totalTestCnt = totalTestCnt + o*testCount;
end

%initialize results
res = zeros(totalTestCnt,5);
%initialize test counter
cnt = 1; %current test

%run mode 1 and 2 tests
for i = 1:2
    dirMode = i;
    %return if tests completed up to the maximum mode being tested
    if dirMode > maxDirMode
        return;
    end
    %run iterations of the test and save data
    for j = 1:testCount
        res(cnt,1) = dirMode;
        [res(cnt,4), res(cnt,5)] = SpiralMosquitoKiller(dirMode);
        cnt = cnt+1
    end
end

%run mode 3 tests
dirMode = 3;
%return if tests completed up to the maximum mode being tested
if dirMode > maxDirMode
    return;
end
for i = 1:testCount
    for j = 1:m
        for k = 1:n
            res(cnt,1) = dirMode;
            res(cnt,2) = inThreshVals(j);
            res(cnt,3) = outThreshVals(k);
            [res(cnt,4), res(cnt,5)] = SpiralMosquitoKiller(dirMode,inThreshVals(j),outThreshVals(k));
            cnt = cnt+1
        end
    end
end

%run mode 4 tests
dirMode = 4;
%return if tests completed up to the maximum mode being tested
if dirMode > maxDirMode
    return;
end
for i = 1:testCount
    for j = 1:o
        res(cnt,1) = dirMode;
        res(cnt,2) = o;
        [res(cnt,4), res(cnt,5)] = SpiralMosquitoKiller(dirMode,wpLists(o,:));
        cnt = cnt+1
    end
end

end