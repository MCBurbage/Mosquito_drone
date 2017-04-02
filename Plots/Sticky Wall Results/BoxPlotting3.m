%columns:
%1 - time
%2 - speed
%3 - sticking coefficient OR sigma
%4 - transition probability
%5 - kill rate
%6 - mode
%7 - row spacing
%8 - result

stickyTestResults = csvread('StickyWallResults.csv');

%set up data by value
%kill rate
filename = 'StickyKillRateResults.pdf';
vals = [0.5 0.7 0.9];
group1 = stickyTestResults(stickyTestResults(:,5)==vals(1),:);
group2 = stickyTestResults(stickyTestResults(:,5)==vals(2),:);
group3 = stickyTestResults(stickyTestResults(:,5)==vals(3),:);

%sticking coefficient
% filename = 'StickySResults.pdf';
% vals = [0.25 0.5 0.75];
% group1 = stickyTestResults(stickyTestResults(:,3)==vals(1),:);
% group2 = stickyTestResults(stickyTestResults(:,3)==vals(2),:);
% group3 = stickyTestResults(stickyTestResults(:,3)==vals(3),:);

%k
% filename = 'StickyKResults.pdf';
% vals = [0.2 0.4 0.6];
% group1 = stickyTestResults(stickyTestResults(:,4)==vals(1),:);
% group2 = stickyTestResults(stickyTestResults(:,4)==vals(2),:);
% group3 = stickyTestResults(stickyTestResults(:,4)==vals(3),:);

%velocity
% filename = 'StickyVelocityResults.pdf';
% vals = [6 9 12];
% group1 = stickyTestResults(stickyTestResults(:,2)==vals(1),:);
% group2 = stickyTestResults(stickyTestResults(:,2)==vals(2),:);
% group3 = stickyTestResults(stickyTestResults(:,2)==vals(3),:);

f=figure;
% set positions for boxes
position_1 = 1:1:6;
position_2 = 1.3:1:6.3;
position_3 = 1.6:1:6.6;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,6),'colors','b','positions',position_1,'width',0.18);
hold on  % Keep the first box plot on figure
% plot second set of boxes in green
h3 = boxplot(group3(:,8)/10000,group3(:,6),'colors',[0 0.5 0],'positions',position_3,'width',0.18);
% plot middle set of boxes in red
h2 = boxplot(group2(:,8)/10000,group2(:,6),'colors',[0.8 0 0],'positions',position_2,'width',0.18,'Labels',{'Wall-Follow','Lawn-Mowing','Hybrid','Spiral','Greedy (1)','Greedy (2)'});

%set axis labels
set(gca,'XTickLabel',{'Wall-Follow','Boustrophedon','Hybrid','Spiral','Greedy (1)','Greedy (2)'}) %sticky walls

%hide outliers
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
set(h3(7,:),'Visible','off')
%build legend
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([13,1,7]), {[num2str(vals(1))],[num2str(vals(2))],[num2str(vals(3))]},'Location','northwest');

hold off
% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
set(gcf,'PaperPositionMode','auto','PaperSize',[7,4],'PaperPosition',[0,0,7,4] );
%print(gcf, '-dpdf', filename);