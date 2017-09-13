load('medians.mat')
channelcodes = {'fsc', 'ssc', 'fl1', 'fl2', 'fl3', 'fl4'};
channel2name = containers.Map(channelcodes, ...
  {'Front Scatter', 'Side Scatter', '525/30 nm fluorescence (FL1)', '586/25 nm fluorescence (FL2)', '615/25 nm fluorescence (FL3)', '655/LP nm fluorescence (FL4)'});
channel2color = containers.Map(channelcodes, ...
  {'Front', 'Side', 'Green', 'Orange', 'Red', 'Far-red'});
channel2number = containers.Map(channelcodes, [3, 6, 9, 12, 15, 18]); %check .par in metadata.
%% plot with 20 uM
stile=':-';
channel='fl1';
figure;
hold on
sml={spyCwt,spyC2};
for i=1:2
    sampleMeans=sml{i};
set(gca,'ColorOrderIndex',1)
plot([0, 0.5, 1, 2, 5,10,20], cell2mat(values(sampleMeans, {'O', 'F5', 'E5', 'D5', 'C5','B5','A5'})) - sampleMeans('O'), ['x',stile(i)], 'LineWidth', 2)
plot([0, 0.5, 1, 2, 5, 10,20], cell2mat(values(sampleMeans, {'O', 'F10', 'E10', 'D10', 'C10','B10','A10'})) - sampleMeans('O'), ['x',stile(i)], 'LineWidth', 2)
plot([0, 0.5, 1, 2, 5, 10,20], cell2mat(values(sampleMeans, {'O', 'F20', 'E20', 'D20', 'C20','B20','A20'})) - sampleMeans('O'), ['x',stile(i)], 'LineWidth', 2)
end
xlabel('µM tag-mClover3')
ylabel(channel2name(channel))
legend({'5 min SpyC-wt/T-wt','10 min  SpyC-wt/T-wt', '20 min  SpyC-wt/T-wt','5 min SpyC002/T002','10 min  SpyC002/T002', '20 min  SpyC002/T002'},'Location','SouthEast')
set(gca,'TickDir','out');
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'Layer', 'Top');
print('final plot v2a', '-dpng', '-r1200');

%% plot without 20 uM
stile=':-';
figure;
hold on
sml={spyCwt,spyC2};
for i=1:2
    sampleMeans=sml{i};
set(gca,'ColorOrderIndex',1)
plot([0, 0.5, 1, 2, 5,10], cell2mat(values(sampleMeans, {'O', 'F5', 'E5', 'D5', 'C5','B5'})) - sampleMeans('O'), ['x',stile(i)], 'LineWidth', 2)
plot([0, 0.5, 1, 2, 5, 10], cell2mat(values(sampleMeans, {'O', 'F10', 'E10', 'D10', 'C10','B10'})) - sampleMeans('O'), ['x',stile(i)], 'LineWidth', 2)
plot([0, 0.5, 1, 2, 5, 10], cell2mat(values(sampleMeans, {'O', 'F20', 'E20', 'D20', 'C20','B20'})) - sampleMeans('O'), ['x',stile(i)], 'LineWidth', 2)
end
xlabel('µM tag-mClover3')
ylabel(channel2name(channel))
legend({'5 min SpyC-wt/T-wt','10 min  SpyC-wt/T-wt', '20 min  SpyC-wt/T-wt','5 min SpyC002/T002','10 min  SpyC002/T002', '20 min  SpyC002/T002'})
set(gca,'TickDir','out');
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'Layer', 'Top');
print('final plot v2b', '-dpng', '-r1200');