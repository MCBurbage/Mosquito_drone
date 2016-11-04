function res = TestingSpiralPrms

testCount = 5; %number of iterations to perform
maxDirMode = 3; %number of modes to test
inThreshVals = [0.3 0.4 0.5 0.6 0.7 0.8];
outThreshVals = [0.3 0.4 0.5 0.6 0.7 0.8];

totalTestCnt = 0;
if maxDirMode >= 1
    totalTestCnt = testCount;
end
if maxDirMode >= 2
    totalTestCnt = totalTestCnt + testCount;
end
if maxDirMode >= 3
    [~,m] = size(inThreshVals);
    [~,n] = size(outThreshVals);
    totalTestCnt = totalTestCnt + m*n*testCount;
end
if maxDirMode >= 4
    [o,~] = size(wpLists);
    totalTestCnt = totalTestCnt + m*testCount;
end
cnt = 1; %current test

res = zeros(totalTestCnt,5);

for i = 1:2
    dirMode = i;
    if dirMode > maxDirMode
        return;
    end
    for j = 1:testCount
        res(cnt,1) = dirMode;
        [res(cnt,4), res(cnt,5)] = SpiralMosquitoKiller(dirMode);
        cnt = cnt+1
    end
end
dirMode = 3;
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
dirMode = 4;
if dirMode > maxDirMode
    return;
end
%TODO:  Set up waypoint lists for comparison
for i = 1:testCount
end


end