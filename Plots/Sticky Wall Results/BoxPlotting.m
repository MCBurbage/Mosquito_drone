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
%filename = 'StickyOverallResults.pdf';
%group1 = stickyTestResults;

%shortest time/speed
% filename = 'StickyLowTimeResults.pdf';
% group1 = stickyTestResults(stickyTestResults(:,1)==300,:);
% group1 = group1(group1(:,2)==6,:);

%highest time/speed
filename = 'StickyHighTimeResults.pdf';
group1 = stickyTestResults(stickyTestResults(:,1)==600,:);
group1 = group1(group1(:,2)==12,:);

f=figure;
% set positions for boxes
position_1 = 1:1:6;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,6),'colors','b','positions',position_1,'width',0.4);

%set axis labels
set(gca,'XTickLabel',{'Wall-Follow','Boustrophedon','Hybrid','Spiral','Greedy (1)','Greedy (2)'}) %sticky walls

%hide outliers
set(h1(7,:),'Visible','off')

% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
%ylim([0.05 0.8])
set(gcf,'PaperPositionMode','auto','PaperSize',[7,4],'PaperPosition',[0,0,7,4] );
%print(gcf, '-dpdf', filename);