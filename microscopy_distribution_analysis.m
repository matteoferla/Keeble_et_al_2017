%% Settings
analyses={'c-t0min-003','c-t3min-003','n-t0min-001','n-t3min-004'}; %dir *mat
names={'Cephalexin 0min','Cephalexin 45min','Untreated 0min','Untreated 45min'};
diviso=1/4; %quartiles
threshold=2; %pixels as some slices are like a 1 px big...
fun=@median;
spacing=20;

%% raw interp1
plotname='Interpolated ("Stretched") per pixel intensity of transverse slices';
raw=containers.Map(analyses,cell(numel(analyses),1));
figure
for j=1:numel(analyses)
    % read data
    imname=analyses{j};
    load([imname,'.mat']);
    frame=cellList{1};
    % remove empty ones
    frame=frame(not(cellfun(@isempty,frame)));
    frame=frame(not(cellfun(@(x) isempty(x.signal0),frame)));
    %init
    distro=zeros(numel(frame),spacing);
    % per cell interation
    for i=1:numel(frame)  % interation for each Eco cell in a frame
        eco=frame{i};
        good=eco.steparea>threshold; % some slices are like a 1 px big...
        distro(i,:)=interp1(linspace(0,1,numel(eco.signal1(good))),eco.signal1(good)./eco.steparea(good),linspace(0,1,spacing));
    end
    % plot
    subplot(1,numel(analyses),j)
    plot(linspace(0,1,spacing),distro)
    hold on
    plot(linspace(0,1,spacing),fun(distro,1),'k','LineWidth',3)
    title(imname)
    if (j==1)
        ylabel('intensity')
    end
    xlabel('Length of cell')
    set(gca,'TickDir','out');
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    %save for later.
    raw(imname)=distro;
end
suptitle(plotname)
%print('interp_per_pixel', '-dpng', '-r1200');

%% median normalised interp1
plotname='Median normalised interpolated ("Stretched") per pixel intensity of transverse slices';
normalised=containers.Map(analyses,cell(numel(analyses),1));
figure
for j=1:numel(analyses)
    % use above data.
    % per cell interation
    imname=analyses{j};
    distro=raw(imname);
    nordistro=distro./repmat(fun(distro,2),1,size(distro,2));
    subplot(1,numel(analyses),j)
    plot(linspace(0,1,spacing),nordistro)
    hold on
    plot(linspace(0,1,spacing),fun(nordistro,1),'k','LineWidth',3)
    title(imname)
    if (j==1)
        ylabel('intensity')
    end
    ylim([0.4 2.2])
    xlabel('Length of cell')
    set(gca,'TickDir','out');
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    normalised(imname)=nordistro;
end
suptitle(plotname)
%print('nor_interp_per_pixel', '-dpng', '-r1200');

%% combo
% {'c-t0min-003','c-t3min-003','n-t0min-001','n-t3min-004'}
plotname='Per frame median of median normalised interpolated ("Stretched") per pixel intensity of transverse slices';
col=containers.Map(analyses,{[0.8500    0.3250    0.0980],[0.8500    0.3250    0.0980],[0    0.4470    0.7410],[0    0.4470    0.7410]});
stile=containers.Map(analyses,{'-',':','-',':'});
figure;
hold on
rectangle('Position',[0.25 0.8 0.5 1.2],'FaceColor',[.9 .9 .9],'EdgeColor','none')
for j=1:numel(analyses)
    % use above data.
    % per cell interation
    imname=analyses{j};
    nordistro=normalised(imname);
    plot(linspace(0,1,spacing),fun(nordistro,1),'LineWidth',2,'Color',col(imname),'LineStyle',stile(imname));
end
legend(analyses,'Location','best')
xlabel('Length of cell');
ylabel('intensity');
set(gca,'TickDir','out');
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'Layer', 'Top');
title(plotname)
ylim([0.8 1.2])
%print('med_nor', '-dpng', '-r1200');



%% CI

bound=nan(numel(analyses),spacing);
med=nan(numel(analyses),spacing);
for j=1:numel(analyses)
    imname=analyses{j};
    nordistro=normalised(imname);
    for i=1:spacing
        x=nordistro(:,i);
        SEM = std(x)/sqrt(length(x));               % Standard Error
        ts = tinv([0.025  0.975],length(x)-1);      % T-Score
        bound(j,i)= ts(2)*SEM;                      % Confidence Interval - mean
    end
    med(j,:)=mean(nordistro);
end
figure
boundedline(linspace(0,1,spacing),med(1,:), bound(1,:), 'r-','alpha','transparency',0.05)
hold on
boundedline(linspace(0,1,spacing),med(2,:), bound(2,:),'r:','alpha','transparency',0.05)
boundedline(linspace(0,1,spacing),med(3,:), bound(3,:),'b-','alpha','transparency',0.05)
boundedline(linspace(0,1,spacing),med(4,:), bound(4,:),'b:','alpha','transparency',0.05)
h={};
h{1}=plot(linspace(0,1,spacing),med(1,:), 'r-','LineWidth',2);
h{2}=plot(linspace(0,1,spacing),med(2,:),'r:','LineWidth',2);
h{3}=plot(linspace(0,1,spacing),med(3,:),'b-','LineWidth',2);
h{4}=plot(linspace(0,1,spacing),med(4,:),'b:','LineWidth',2);
legend(h,names,'Location','best')
xlabel('Length of cell');
ylabel('intensity');
set(gca,'TickDir','out');
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'Layer', 'Top');
%title(plotname)



print('med_nor_CI_trans005', '-dpng', '-r1200');



%% CI mod
intermed=nan(numel(analyses),spacing);
nmed=nan(numel(analyses),spacing);
nb=nan(numel(analyses),spacing);
for j=1:numel(analyses)
    bsp=spacing*diviso;
    intermed(j)=mean(med(j,bsp:bsp*2));
    nmed(j,:)=med(j,:)./intermed(j);
    nb(j,:)=bound(j,:)./intermed(j);
end
figure
%rectangle('Position',[0.25 0.6 0.5 1.4],'EdgeColor',[.9 .9 .9])
cmap=[0    0.4470    0.7410;0    0.4470    0.7410;0.8500    0.3250    0.0980;0.8500    0.3250    0.0980];
line([0.25 0.25],[0.6 1.4],'Color',[.7 .7 .7],'LineStyle',':')
line([0.75 0.75],[0.6 1.4],'Color',[.7 .7 .7],'LineStyle',':')
boundedline(linspace(0,1,spacing),nmed(1,:), nb(1,:), '-','alpha','transparency',0.05,'cmap',cmap(1,:))
hold on
boundedline(linspace(0,1,spacing),nmed(2,:), nb(2,:),':','alpha','transparency',0.05,'cmap',cmap(2,:))
boundedline(linspace(0,1,spacing),nmed(3,:), nb(3,:),'-','alpha','transparency',0.05,'cmap',cmap(3,:))
boundedline(linspace(0,1,spacing),nmed(4,:), nb(4,:),':','alpha','transparency',0.05,'cmap',cmap(4,:))
h=[];
stile='-:-:';
for i=1:4
h(i)=plot(linspace(0,1,spacing),nmed(i,:),'LineStyle', stile(i),'LineWidth',2,'Color',cmap(i,:));
end
legend(h,names,'Location','best')
xlabel('Fractional length of cell');
ylabel('Relative intensity');
set(gca,'TickDir','out');
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'Layer', 'Top');
ylim([0.6 1.4]);
%title(plotname)
%print('mod_nor_CI_trans005', '-dpng', '-r1200');

%% end to inter
%endian=containers.Map(analyses,cell(numel(analyses),1));
endian=nan(numel(analyses),999);
for j=1:numel(analyses)
    % use above data.
    % per cell interation
    imname=analyses{j};
    distro=normalised(imname);
    midpoints=mean(distro(:,2:end-1),2);
    ends=mean([distro(:,1),distro(:,end)],2);
    endian(j,1:numel(ends))=ends./midpoints;
end
figure
boxplot(endian','Notch','on');
title('Ends to Midpoints ratios')
ax=gca;
ax.XTickLabel=analyses;
ax.XTickLabelRotation=45;
print('ends_ratios', '-dpng', '-r1200');


[~,p]=kstest2(endian(3,:),endian(4,:))


%% Normal
figure
for j=1:numel(analyses)
    imname=analyses{j};
    nordistro=normalised(imname);
    [~,shapiro]=swtest(nordistro(:));
    display(shapiro)
    subplot(1,numel(analyses),j)
    ksdensity(nordistro(:))
end


%% Symmetry
dbbound=nan(numel(analyses),spacing);
dbmed=nan(numel(analyses),spacing);
interdbmed=nan(numel(analyses),spacing);
ndbmed=nan(numel(analyses),spacing);
ndbb=nan(numel(analyses),spacing);
bsp=spacing*diviso;
for j=1:numel(analyses)
    imname=analyses{j};
    nordistro=normalised(imname);
    dbdistro=nordistro/2+nordistro(1:size(nordistro,1),spacing:-1:1)/2;
    for i=1:spacing
        x=dbdistro(:,i);
        SEM = std(x)/sqrt(length(x));               % Standard Error
        ts = tinv([0.025  0.975],length(x)-1);      % T-Score
        dbbound(j,i)= ts(2)*SEM;                      % Confidence Interval - mean
    end
    dbmed(j,:)=mean(dbdistro);
    interdbmed(j)=mean(dbmed(j,bsp:bsp*2));
    ndbmed(j,:)=dbmed(j,:)./interdbmed(j);
    ndbb(j,:)=dbbound(j,:)./interdbmed(j);
end
m=dbmed;
b=dbbound;
m=ndbmed;
b=ndbb;
m=med;
b=bound;
m=nmed;
b=nb;
figure
%rectangle('Position',[0.25 0.6 0.5 1.4],'EdgeColor',[.9 .9 .9])
cmap=[0    0.4470    0.7410;0    0.4470    0.7410;0.8500    0.3250    0.0980;0.8500    0.3250    0.0980];
stile='-:-:';
line([0.25 0.25],[0.6 1.4],'Color',[.7 .7 .7],'LineStyle',':')
line([0.75 0.75],[0.6 1.4],'Color',[.7 .7 .7],'LineStyle',':')
%line([0.5 0.5],[0.6 1.4],'Color','k','LineStyle','-')
hold on
for i=1:4
    boundedline(linspace(0,1,spacing),m(i,:), b(i,:), stile(i),'alpha','transparency',0.05,'cmap',cmap(i,:))
end
h=nan(4,1);
for i=1:4
h(i)=plot(linspace(0,1,spacing),m(i,:),'LineStyle', stile(i),'LineWidth',2,'Color',cmap(i,:));
end
legend(h,names,'Location','best')
xlabel('Fractional length of cell');
ylabel('Relative intensity');
set(gca,'TickDir','out');
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'Layer', 'Top');
ylim([0.7 1.3]);

%%%
m=med;
b=bound;
figure
%rectangle('Position',[0.25 0.6 0.5 1.4],'EdgeColor',[.9 .9 .9])
cmap=[0    0.4470    0.7410;0.8500    0.3250    0.0980];
for j=1:2
    subplot(1,2,j)
    hold on
    line([0.25 0.25],[0.6 1.4],'Color',[.7 .7 .7],'LineStyle',':')
    line([0.75 0.75],[0.6 1.4],'Color',[.7 .7 .7],'LineStyle',':')
    %line([0.5 0.5],[0.6 1.4],'Color','k','LineStyle','-')
    for i=1:2
        boundedline(linspace(0,1,spacing),m(i+(j-1)*2,:), b(i+(j-1)*2,:), '-','alpha','transparency',0.1,'cmap',cmap(i,:))
    end
    h=nan(2,1);
    for i=1:2
        h(i)=plot(linspace(0,1,spacing),m(i+(j-1)*2,:),'-','LineWidth',2,'Color',cmap(i,:));
    end
    legend(h,names(1+(j-1)*2:2+(j-1)*2),'Location','best')
    xlabel('Fractional length of cell');
    ylabel('Relative intensity');
    set(gca,'TickDir','out');
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    set(gca,'Layer', 'Top');
    ylim([0.7 1.3]);
end
print('microCI_final_subplots', '-dpng', '-r1200');