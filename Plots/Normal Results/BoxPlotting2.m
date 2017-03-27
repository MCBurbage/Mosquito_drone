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
%time
filename = 'NormalTimeResults.pdf';
vals = [300 600];
group1 = normalTestResults(normalTestResults(:,1)==vals(1),:);
group2 = normalTestResults(normalTestResults(:,1)==vals(2),:);

f=figure;
% set positions for boxes
position_1 = 1:1:5;
position_2 = 1.3:1:5.3;
% plot first set of boxes in blue
h1 = boxplot(group1(:,8)/10000,group1(:,5),'colors','b','positions',position_1,'width',0.18);
hold on  % Keep the first box plot on figure
% plot second set of boxes in red
h2 = boxplot(group2(:,8)/10000,group2(:,5),'colors',[0.8 0 0],'positions',position_2,'width',0.18);

%set axis labels
set(gca,'XTickLabel',{'Spiral Out','Spiral to 50%','Spiral to 80%','Greedy (1)','Greedy (2)'}) %normal

%hide outliers
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
%build legend
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([7,1]), {num2str(vals(1)),num2str(vals(2))},'Location','northwest');

hold off
% Insert texts and labels
ylabel('Fraction of Population Found')
xlabel('Search Method')
set(gcf,'PaperPositionMode','auto','PaperSize',[7,4],'PaperPosition',[0,0,7,4] );
%print(gcf, '-dpdf', filename);