function PoseM = MosquitoKiller(PoseM,L,width)
% Elimintes a swath of mosquitoes width wide across an area LxL meters.
% The swath will either be in the x or y direction and will cross the whole
% field.
%
% Authors: Mary Burbage (mcfieler@uh.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters
%defaults
if nargin<2
    disp('Aborted:  Insufficient parameters passed')
    return
end
if nargin<3
    width = 1;
end

%set width to half-width
width = width/2;

%set x or y mode randomly - mode = 0 -> y-mode, mode = 1 -> x-mode
xmode = (rand(1)<0.5);
%randomly select the center of the swath from a normal distributions
center = L/2 + randn(1)*(L/6);
%set the swath limits
minSwath = center - width;
maxSwath = center + width;

if xmode
    %kill mosquitoes in vertical swath
    %set mask to save mosquitoes outside swath
    mask = ((PoseM(:,1)<minSwath) | (maxSwath<PoseM(:,1)));
else
    %kill mosquitoes in horizontal swath
    %set mask to save mosquitoes outside swath
    mask = ((PoseM(:,2)<minSwath) | (maxSwath<PoseM(:,2)));
end
PoseM(:,4) = PoseM(:,4).*mask;

end
