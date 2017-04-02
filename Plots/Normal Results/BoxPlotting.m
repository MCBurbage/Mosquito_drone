%columns:
%1 - time
%2 - speed
%3 - sigma
%4 - kill rate
%5 - mode
%6 - row spacing
%7 - transition probability
%8 - result

%set up data by value
%kill rate
% filename = 'NormalKillRateResults.pdf';
% vals = [0.5 0.7 0.9];
% group1 = normalTestResults(normalTestResults(:,4)==vals(1),:);
% group2 = normalTestResults(normalTestResults(:,4)==vals(2),:);
% group3 = normalTestResults(normalTestResults(:,4)==vals(3),:);

%k
% filename = 'NormalKResults.pdf';
% vals = [0.2 0.4 0.6];
% group1 = normalTestResults(normalTestResults(:,7)==vals(1),:);
% group2 = normalTestResults(normalTestResults(:,7)==vals(2),:);
% group3 = normalTestResults(normalTestResults(:,7)==vals(3),:);

%velocity
filename = 'NormalVelocityResults.pdf';
vals = [6 9 12];
group1 = normalTestResults(normalTestResults(:,2)==vals(1),:);
group2 = normalTestResults(normalTestResults(:,2)==vals(2),:);
group3 = normalTestResults(normalTestResults(:,2)==vals(3),:);

f=figure;
% set positions for boxes
position_1 = 1:1:5;
position_2 = 1.3:1:5.3;
position_3 = 1.6:1:5.6;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,5),'colors','b','positions',position_1,'width',0.18);
hold on  % Keep the first box plot on figure
% plot second set of boxes in green
h3 = boxplot(group3(:,8)/10000,group3(:,5),'colors',[0 0.5 0],'positions',position_3,'width',0.18);
% plot middle set of boxes in red
h2 = boxplot(group2(:,8)/10000,group2(:,5),'colors',[0.8 0 0],'positions',position_2,'width',0.18);

%set axis labels
%set(gca,'XTickLabel',{'Wall-Follow','Lawn-Mowing','Hybrid','Spiral','Greedy (1)','Greedy (2)'}) %sticky walls
set(gca,'XTickLabel',{'Spiral Out','Spiral to 50%','Spiral to 80%','Greedy (1)','Greedy (2)'}) %normal

%hide outliers
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
set(h3(7,:),'Visible','off')
%build legend
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([13,1,7]), {[num2str(vals(1)) ' m/s'],[num2str(vals(2)) ' m/s'],[num2str(vals(3)) ' m/s']},'Location','northwest');

hold off
% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
set(gcf,'PaperPositionMode','auto','PaperSize',[7,4],'PaperPosition',[0,0,7,4] );
%print(gcf, '-dpdf', filename);