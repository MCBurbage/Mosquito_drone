%columns:
%1 - time
%2 - speed
%3 - sticking coefficient OR sigma
%4 - transition probability
%5 - kill rate
%6 - mode
%7 - row spacing
%8 - result

%set up data by value
%row spacing
filename = 'StickyRowSpaceResults.pdf';
vals = [2 5 10 20];
group1 = stickyTestResults(stickyTestResults(:,7)==vals(1),:);
group2 = stickyTestResults(stickyTestResults(:,7)==vals(2),:);
group3 = stickyTestResults(stickyTestResults(:,7)==vals(3),:);
group4 = stickyTestResults(stickyTestResults(:,7)==vals(4),:);

f=figure;
% set positions for boxes
position_1 = 1:1:4;
position_2 = 2.2:1:4.2;
position_3 = 2.4:1:4.4;
position_4 = 2.6:1:4.6;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,6),'colors','b','positions',position_1,'width',0.15);
hold on  % Keep the first box plot on figure
% plot second set of boxes in red
h2 = boxplot(group2(:,8)/10000,group2(:,6),'colors',[0.8 0 0],'positions',position_2,'width',0.15);
% plot fourth set of boxes in green
h4 = boxplot(group4(:,8)/10000,group4(:,6),'colors',[0 0.5 0],'positions',position_4,'width',0.15);
% plot third set of boxes in gold
h3 = boxplot(group3(:,8)/10000,group3(:,6),'colors',[0.6 0.6 0],'positions',position_3,'width',0.15);
%set axis labels
set(gca,'XTickLabel',{'Boustrophedon','Hybrid','Spiral'}) %sticky walls

%hide outliers
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
set(h3(7,:),'Visible','off')
set(h4(7,:),'Visible','off')
%build legend
box_vars = findall(gca,'Tag','Box');
%hLegend = legend(box_vars([10,7,1,4]), {num2str(vals(1)),num2str(vals(2)),num2str(vals(3)),num2str(vals(4))},'Location','eastoutside');
hLegend = legend(box_vars([10,7,1,4]), {'L/50 m','L/20 m','L/10 m','L/5 m'},'Location','eastoutside');

hold off
% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
set(gcf,'PaperPositionMode','auto','PaperSize',[6,4],'PaperPosition',[0,0,6,4] );
%print(gcf, '-dpdf', filename);