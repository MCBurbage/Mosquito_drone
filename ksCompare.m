%tests to run with sticky wall simulation for comparison

%size of workspace
L = 100;
%sticking factor
stick = [0.25 0.5 0.75];
%probability of particle leaving cell
transitionPct = [0.2 0.4 0.6];

%set up counters
cnt = 1;
testCnt = numel(stick)*numel(transitionPct);
wtest = zeros(testCnt,L);

for i = 1:numel(stick)
    for j = 1:numel(transitionPct)
        s = stick(i);
        k = transitionPct(j);
        [~,w] = StickyWalls(L,k,s);
        wtest(cnt,:) = w(L/2,:);
        cnt = cnt+1;
    end
end

%plot results
figure(1)
set(gcf,'color','w');
x = 1:L;
line(x,wtest(1,:))
line(x,wtest(4,:))
line(x,wtest(7,:))
%then the lines need to be color coded and a legend added
xlabel('X Position (m) for Y = 50m')
ylabel('Fraction of Population')
title('Cross-section of Population by Sticking Factor')
