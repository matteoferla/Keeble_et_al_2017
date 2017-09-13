%% Input
% normal way
%% Fluff
channelcodes = {'fsc', 'ssc', 'fl1', 'fl2', 'fl3', 'fl4'};
channel2name = containers.Map(channelcodes, ...
  {'Front Scatter', 'Side Scatter', '525/30 nm fluorescence (FL1)', '586/25 nm fluorescence (FL2)', '615/25 nm fluorescence (FL3)', '655/LP nm fluorescence (FL4)'});
channel2color = containers.Map(channelcodes, ...
  {'Front', 'Side', 'Green', 'Orange', 'Red', 'Far-red'});
channel2number = containers.Map(channelcodes, [3, 6, 9, 12, 15, 18]); %check .par in metadata.

%% Input
%%% read from file
scheme = readtable('scheme.csv', 'Encoding', 'UTF-8');
% something odd check:
% scheme.Properties.VariableNames

%%% parse file (and manually override if need be...)
% the short handles e.g. sample A
samplelist = scheme.samplelist;
% Files of those
sample2file = containers.Map(samplelist, scheme.file);
% Pretty names of those for titles
sample2name = containers.Map(samplelist, scheme.name);
% RGB for lines
sample2color = containers.Map(samplelist, num2cell([scheme.colorR, scheme.colorG, scheme.colorB], 2));
% dashingness
sample2style = containers.Map(samplelist, scheme.style);
%% histo
figure;
samples = samplelist;
sampleMeans = containers.Map(samplelist, nan(numel(samplelist), 1));

gated = true;
cutoff = [0, 0];
bs = - 2:0.02:4;
channel = 'fl1';
hold on
for i = 1:numel(samples)
    s = samples{i};
    data = fca_readfcs(sample2file(s)) / 100;
    if (gated)
        [a, b] = hist(data(:, 21), unique(data(:, 21)));
        [x, j] = sort(a, 'descend');
        gatevalue = b(j(1)); % OVERRIDDEN!!
        gatevalues = [2.5600, 335552, 838874];
        gatedness = zeros(size(data(:, 21)));
        for z = 1:numel(gatevalues)
            gatedness = gatedness + (data(:, 21) == gatevalues(z));
        end
    else
        gatedness = ones(size(data, 1), 1);
    end
    filtro = gatedness & (data(:, channel2number('fsc')) >= cutoff(1)) & (data(:, channel2number('ssc')) >= cutoff(2));
    [N, edges] = histcounts(log10(data(filtro, channel2number(channel))), bs);
    plot(10 .^ edges, [N, 0] / sum(filtro) * 1e4, 'LineWidth', 2, 'Color', sample2color(s), 'LineStyle', sample2style(s));
    % HACK
    m = median(data(filtro, channel2number(channel)));
    display(['Mean... ', sample2name(s), ' ', num2str(m)]);
      sampleMeans(s) = m;
end
ylabel('Counts') % based on bs
xlabel(channel2name(channel))
legend(values(sample2name, samples), 'Location', 'best')
%title(sprintf('Gated fluorescent distribution in %d bins', numel(bs)))
scala = 'log';
ax = gca;
ax.XScale = scala;
ax.TickDir = 'out';
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
xlim([1 1e3]);
set(gca,'Layer', 'Top');
print('E5-O points histo v2', '-dpng', '-r1200');