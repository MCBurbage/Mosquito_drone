L = 10;
P = BuildMarkovMatrixWalled(L);
w = limitdist(P);

nIters = 5;
killPct = 0.5;
for i = 1:nIters
    %simulate robot motion
    
    %calculate cells robot visits in a step
    timeMap = UpdateTimeMap(pathStart,pathEnd,zeros(L,L),vel);
    %scale timeMap
    
    %convert 2D map to 1D vector and invert
    r = ones(L*L,1)-reshape(timeMap,1,numel(timeMap));
    %kill fraction of mosquitoes in each cell
    w = r.*w;
    %multiply by P to update population for next iteration
    w = P*w;
end