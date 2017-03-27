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
filename = 'NormalSigmaResults.pdf';
vals = [99/20 99/10 99/5 99/2];
group1 = normalTestResults(normalTestResults(:,3)==vals(1),:);
group2 = normalTestResults(normalTestResults(:,3)==vals(2),:);
group3 = normalTestResults(normalTestResults(:,3)==vals(3),:);
group4 = normalTestResults(normalTestResults(:,3)==vals(4),:);

%row spacing
% filename = 'NormalRowSpaceResults.pdf';
% vals = [99/50 99/20 99/10 99/5];
% group1 = normalTestResults(normalTestResults(:,6)==vals(1),:);
% group2 = normalTestResults(normalTestResults(:,6)==vals(2),:);
% group3 = normalTestResults(normalTestResults(:,6)==vals(3),:);
% group4 = normalTestResults(normalTestResults(:,6)==vals(4),:);

f=figure;
% set positions for boxes
position_1 = 1:1:5;
position_2 = 1.2:1:5.2;
position_3 = 1.4:1:5.4;
position_4 = 1.6:1:5.6;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,5),'colors','b','positions',position_1,'width',0.15);
hold on  % Keep the first box plot on figure
% plot second set of boxes in red
h2 = boxplot(group2(:,8)/10000,group2(:,5),'colors',[0.8 0 0],'positions',position_2,'width',0.15);
% plot fourth set of boxes in green
h4 = boxplot(group4(:,8)/10000,group4(:,5),'colors',[0 0.5 0],'positions',position_4,'width',0.15);
% plot third set of boxes in gold
h3 = boxplot(group3(:,8)/10000,group3(:,5),'colors',[0.6 0.6 0],'positions',position_3,'width',0.15);
%set axis labels
set(gca,'XTickLabel',{'Spiral Out','Spiral to 50%','Spiral to 80%'}) %normal

%hide outliers
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
set(h3(7,:),'Visible','off')
set(h4(7,:),'Visible','off')
%build legend
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([16,11,1,6]), {num2str(vals(1)),num2str(vals(2)),num2str(vals(3)),num2str(vals(4))},'Location','eastoutside');

hold off
% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
ylim([0 1])
set(gcf,'PaperPositionMode','auto','PaperSize',[6,4],'PaperPosition',[0,0,6,4] );
%print(gcf, '-dpdf', filename);