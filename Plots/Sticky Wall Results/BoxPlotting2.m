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
%time
% filename = 'StickyTimeResults.pdf';
% vals = [300 600];
% group1 = stickyTestResults(stickyTestResults(:,1)==vals(1),:);
% group2 = stickyTestResults(stickyTestResults(:,1)==vals(2),:);

%speed/time
filename = 'StickySpeedTimeResultsLgFont.pdf';
group1 = stickyTestResults(stickyTestResults(:,1)==300,:);
group1 = group1(group1(:,2)==6,:);
group2 = stickyTestResults(stickyTestResults(:,1)==600,:);
group2 = group2(group2(:,2)==12,:);

f=figure;
% set positions for boxes
position_1 = 1:1:6;
position_2 = 1.3:1:6.3;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,6),'colors','b','positions',position_1,'width',0.18);
hold on  % Keep the first box plot on figure
% plot second set of boxes in red
h2 = boxplot(group2(:,8)/10000,group2(:,6),'colors',[0.8 0 0],'positions',position_2,'width',0.18);

%set axis labels
set(gca,'XTickLabel',{'WallFollow','Lawn-Mow','Hybrid','Spiral','Greedy(1)','Greedy(2)'}) %sticky walls

%hide outliers
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
%build legend
box_vars = findall(gca,'Tag','Box');
%hLegend = legend(box_vars([7,1]), {[num2str(vals(1)) ' s'],[num2str(vals(2)) ' s']},'Location','northwest');
hLegend = legend(box_vars([7,1]), {'Low Speed/Time','High Speed/Time'},'Location','northoutside');

hold off
% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
%ylim([0.05 0.8])
set(gcf,'PaperPositionMode','auto','PaperSize',[7,4],'PaperPosition',[0,0,7,4] );
%print(gcf, '-dpdf', filename);