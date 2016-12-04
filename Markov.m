P = BuildMarkovMatrixWalledK(10);
Pss = P;
for j = 1:30
Pss = Pss*Pss;
end
w = limitdist(P);
%[V, ~] = eigs(P');
%Steady_State = V(:,1)/sum(V(:,1));
%X = vec2mat(Steady_State,10)';

nIters = 5;
killPct = 0.5;
for i = 1:nIters
    %calculate cells robot visits in a step
    %timeMap = UpdateTimeMap(pathStart,pathEnd,zeros(L,L),vel);
    %scale timeMap
    %convert 2D map to 1D vector
    %r = reshape(timeMap,1,numel(timeMap));
    %kill fraction of mosquitoes in those cells
    %w = r.*w;
    %multiply by P to update population for next iteration
    %w = P*w;
end