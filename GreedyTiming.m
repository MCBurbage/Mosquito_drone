disp('one-step')
for i=1:10
tic
GreedySim('StickyWalls',100,300,12,.5,.25,.9);
toc
end

disp('two-step')
for i=1:10
tic
Greedy2Sim('StickyWalls',100,300,12,.5,.25,.9);
toc
end