function Fig3
% requires the violin plot function  for matlab which can be found there:
% https://fr.mathworks.com/matlabcentral/fileexchange/170126-violinplot-matlab
loadSurveyData;

%%
default_figure([1 1 8.3 11.7]);
clf;
xh = .5;
yh = .5;
RoleList = {'PI' ; 'Postdoc'; 'PhD Student' ;  'RA' };
CList = {'All';'PI' ;  'PostDoc';'PhD' ;'RA'};
NList = {'Group Leader' ;  'PostDoc';'PhD' ;'Staff'};
Violin_Mksize = 8;
Violin_Alpha = 0.4;
FontSz = 6;
Stats = {};
%% violin plots of the averaged importance score across participants, for each Role
i=1;
hs{i}=my_subplot(5,5,1,[xh yh]);
hs{i}.Position(1) = hs{i}.Position(1)+.10;
hs{i}.Position(2) = hs{i}.Position(2) + .01;
axis off;
hp=hs{i}.Position;
axes('position',[hp(1) hp(2)-.07 1.5*hp(3) 1.1*hp(4)]);

avg_imp = mean(answ.importance,2);

Violin({avg_imp}, 1, 'ViolinColor',{[0 0 0]},'ViolinAlpha',{Violin_Alpha },'MarkerSize',Violin_Mksize);
for k=1:length(RoleList)
    dummy = strcmp(RoleList{k},dgs.CurrentRole);
    Violin({avg_imp(dummy)}, k + 2, 'ViolinColor',{colour.(CList{k+1})./255},'ViolinAlpha',{Violin_Alpha },'MarkerSize',Violin_Mksize);
end

xtickangle(45)
ylabel('Importance score','FontSize',FontSz)
ylim([1 5])
V0 = get(gca,'Position');
ThisR = ismember(dgs.CurrentRole,RoleList);
[p,~,stats]= kruskalwallis(avg_imp(ThisR),dgs.CurrentRole(ThisR),'off');
[c,~,~,gnames] = multcompare(stats,'display','off');
S = pRules(p);
title(['Kruskal Wallis ',S])
set(gca,'FontSize',FontSz)
XL = xlim;
plot(XL,[3 3],'--','Color',[0.8 0.8 0.8])
camroll(-90)
set(gca,'XTick',1:length(RoleList)+2,'XTickLabel',[{'All';''};NList],'FontSize',FontSz)
set(gca,'YAxisLocation','right')
xtickangle(0)
addLetter(gca,'a')
S = procKWmultcompare(c,gnames);
Stats{1,1} = [{'a'},{p},S];
%% violin plots of the averaged established score across participants, for each Role
axes('position',[V0(1)+V0(3)+0.05 V0(2) V0(3) V0(4)]);
avg_imp = mean(answ.isEstablished,2,"omitnan");

Violin({100*avg_imp}, 1, 'ViolinColor',{[0 0 0]},'ViolinAlpha',{Violin_Alpha},'MarkerSize',Violin_Mksize);
for k=1:length(RoleList)
    dummy = strcmp(RoleList{k},dgs.CurrentRole);
    Violin({100*avg_imp(dummy)}, k + 2, 'ViolinColor',{colour.(CList{k+1})./255},'ViolinAlpha',{Violin_Alpha },'MarkerSize',Violin_Mksize);
end

ylabel('Implementation Rate','FontSize',FontSz)
ylim([0 100])
V = get(gca,'Position');
set(gca, 'YTick', 0:50:100, 'FontSize',FontSz);
ThisR = ismember(dgs.CurrentRole,RoleList);
[p,~,stats] = kruskalwallis(avg_imp(ThisR),dgs.CurrentRole(ThisR),'off');
[c,~,~,gnames] = multcompare(stats,'display','off');
S = pRules(p);
title(['Kruskal Wallis ',S])
set(gca,'FontSize',FontSz)
XL = xlim;
plot(XL,[50 50],'--','Color',[0.8 0.8 0.8])
camroll(-90)
set(gca,'YAxisLocation','right')
set(gca,'XTick',1:length(RoleList)+2,'XTickLabel',[])
addLetter(gca,'c')
S = procKWmultcompare(c,gnames);
Stats{2,1} = [{'c'},{p},S];
%% plot distribution of importance and established scores

% parse which column in dgs to query
which_cat = strcmp('CurrentRole', dgs.Properties.VariableNames);
% add categories
uniqueRoles = RoleList; % Unique positions
%% violin plots of the averaged importance score across participants, for each Role
Rl = {'e','f','g','h'};
A1  = axes('position',[V0(1) V0(2)-V0(4)-0.32 V0(3) 0.4]);
A = get(A1,'Position');
camroll(A1,-90)
A2 = axes('position',[V(1) A(2) V(3) A(4)]);
camroll(A2,-90)
A3 = {};
% Sort answers based on ascending average importance score
idx = strcmp(dgs{:, which_cat}, 'PI'); % keep observations for PI
[~, sorted_imp_indices] = sort(mean(answ.importance(idx,:)));

for k = 1:length(uniqueRoles)
    if k==0
        idx = true(size(dgs,1),1);
    else
        idx = strcmp(dgs{:, which_cat}, uniqueRoles{k}); % keep observations for each category
    end
    importance = answ.importance(idx,:);
    isEstablished = answ.isEstablished(idx,:);
    question_labels = answ.question_labels;

    [nA, nQ] =size(importance);

    zsc_importance = importance;
    % Compute the average score and standard error for each question
    avg_importance_scores = mean(zsc_importance , 1);
    se_importance_scores = std(zsc_importance , [], 1)/sqrt(nA);

    howmuchEstablished = nanmean(isEstablished, 1);
    seEstablished = nanstd(isEstablished, [],1)/sqrt(nA);

    % compute answer distribution for each question
    for iQ = 1:nQ
        impDist(:, iQ) = histcounts(importance(:, iQ), [-0.5:1:5.5]);
        impDist(:, iQ) = impDist(:, iQ) /sum(impDist(:, iQ));

        dummy = isEstablished(:, iQ);
        dummy(isnan(dummy)) = -1;
        estDist(:, iQ) = histcounts(dummy, [-1.5:1:2.5]);
        estDist(:, iQ) = estDist(:, iQ)/sum(estDist(:, iQ));
    end
    dummy = answ.implement(idx, :);
    for j=1:size(dummy,2)
        impledistbycat(k,:,j) = histcounts(dummy(:,j), [-0.1:0.4:1.2]);
        impledistbycat(k,:,j) = impledistbycat(k,:,j)/sum(impledistbycat(k,:,j));
    end
    % if isempty(sort_cat)
    % Sort answers based on ascending average importance score
    sorted_imp_scores = avg_importance_scores(sorted_imp_indices);

    % sort answers in ascending order for plotting purposes
    sorted_hme_scores = 100*howmuchEstablished(sorted_imp_indices);
    sorted_impDist = impDist(:, sorted_imp_indices);
    imp_sorted_labels = question_labels(sorted_imp_indices);
    imp_sorted_std = 100*se_importance_scores(sorted_imp_indices);
    imp_sorted_hme = 100*howmuchEstablished (sorted_imp_indices);

    se_sorted_hme = seEstablished(sorted_imp_indices);
    sorted_estDist = estDist(:, sorted_imp_indices);
    est_sorted_labels = question_labels(sorted_imp_indices);

    % compute correlation between imp and est
    lm = fitlm(sorted_imp_scores, imp_sorted_hme, "Intercept",true, "RobustOpts","on");

    % plot average importance y role for each question
    hold(A1,'on')
    errorbar(A1,sorted_imp_scores, imp_sorted_std, 'o','Color','none', 'MarkerFaceColor', colour.(CList{k+1})./255,'MarkerEdgeColor', colour.(CList{k+1})./255,'MarkerSize',3);
    box(A1,'off')
    %
    ylabel(A1,'Importance score')
    ylim(A1,[1 5])
    xlim(A1,[-1 31])
    XL = xlim(A1);
    plot(A1,XL,[3 3],'--','Color',[0.8 0.8 0.8])
    set(A1, 'XTick', 1:length(est_sorted_labels), 'XTickLabel', est_sorted_labels, 'XTickLabelRotation', 0,'FontSize',FontSz);
    set(A1,'YAxisLocation','right')
    % plot how established by role for each question
    hold(A2,'on')
    errorbar(A2,sorted_hme_scores, se_sorted_hme, 'o','Color','none', 'MarkerFaceColor', colour.(CList{k+1})./255,'MarkerEdgeColor', colour.(CList{k+1})./255,'MarkerSize',3);
    box(A2,'off')

    set(A2, 'YTick', 0:50:100,'FontSize',FontSz);
    ylabel(A2,'Implementation Rate')
    set(A2,'FontSize',FontSz)
    XL = xlim;
    plot(XL,[50 50],'--','Color',[0.8 0.8 0.8])
    ylim(A2,[0 100])
    xlim(A2,[-1 31])
    set(A2, 'XTick',1:length(est_sorted_labels),'XTickLabel',[],'FontSize',FontSz)
    set(A2,'YAxisLocation','right')

    % plot correlation between importance and establish
    if k==1
        A3{k} = axes('position',[V(1)+V(3)+0.09 V(2) V(3) V(4)]);
    else
        A3{k} = axes('position',[V2(1) V2(2)-V2(4)-0.04 V2(3) V2(4)]);
    end
    plot(A3{k},sorted_imp_scores, imp_sorted_hme, 'o','MarkerFaceColor',colour.(CList{k+1})./256, 'MarkerEdgeColor',colour.(CList{k+1})./256,'MarkerSize',4);
    [cc,p] = corr(sorted_imp_scores', imp_sorted_hme');S = pRules(p);
    Stats{k+2,1} = [Rl(k),{p}];
    hold(A3{k},'on')
    plot(A3{k},lm,'Marker','.','MarkerEdgeColor','none','MarkerFaceColor','none')
    axis(A3{k},'square')
    xlim(A3{k},[3.5 5])
    ylim(A3{k},[0 100])
    if k==length(uniqueRoles)
        set(A3{k}, 'YTick', 0:50:100,'FontSize',FontSz);
        xlabel(A3{k},'Importance score','FontSize',FontSz);

    else
        xlabel('')
        set(A3{k}, 'YTick', 0:50:100,'FontSize',FontSz)
    end
    ylabel(A3{k},'Implementation Rate','FontSize',FontSz);
    legend(A3{k},'off')
    title(A3{k},{NList{k},['r = ',num2str(round(cc,4)),S]},'FontSize',FontSz)
    box off;
    V2 = get(A3{k},'Position');
    set(A3{k},'FontSize',FontSz)
end

impledistbycat = 100*impledistbycat;

addLetter(A1,'b')
addLetter(A2,'d')
for k=1:length(RoleList)
    addLetter(A3{k},Rl{k})
end



%% plot correlation between difference of mean importance score between PIs and lab members and mean importance across all
RoleList = {'PI' ; 'Postdoc'; 'PhD Student' ;  'RA' };
GroupBy = [1 2 2 2];
GroupN  = {'Group Leader','Group Members'};
Im = answ.importance;

Ug = unique(GroupBy,'stable');
m=[];
for i=1:length(Ug)
    dummy = Ug(i) == GroupBy;
    idx = ismember(dgs{:, which_cat}, RoleList(dummy));
    m(i,:) = mean(Im(idx,:));

end
M=[];
for i= 1:length(uniqueRoles)
    idx = strcmp(dgs{:, which_cat}, uniqueRoles{i}); % keep observations for each category
    M(i,:) = mean(Im(idx,:));
end
M = nanmean(M);
D = m(1,:) - m(2,:);
lm = fitlm(M, D, "Intercept",true, "RobustOpts","on");

A5 = axes('position',[A(1) A(2)-0.18 A(3) 0.13]);
A = get(gca,'Position');
plot(M, D, 'o','MarkerFaceColor','k', 'MarkerEdgeColor','k','MarkerSize',4); hold on

[cc,p] = corr(sorted_imp_scores', imp_sorted_hme');S = pRules(p);

[cc_s,p_s] = corr(sorted_imp_scores', imp_sorted_hme', 'Type', 'Spearman');

% [x_sorted, idx] = sort(M);
% y_sorted = D(idx);
% 
% y_smooth = smooth(x_sorted, y_sorted, 0.8, 'lowess');
% plot(x_sorted, y_smooth, 'k', 'linewidth', 2)

x = M';
y = D';
% Compute ranks
x_ranks = tiedrank(x);
y_ranks = tiedrank(y);

% Compute Spearman correlation
[rho, sp] = corr(x, y, 'Type', 'Spearman'); %%%% ADD THIS AMONG THE STATS

% Fit linear regression on ranks
p = polyfit(x_ranks, y_ranks, 1);
y_fit = polyval(p, x_ranks);

% Map rank back to quantile positions (approximate for demo)
sortedy = sort(y, 'ascend');
intercept = (sortedy(floor(min(y_fit))) + sortedy(ceil(min(y_fit))))/2;

y_pred = ((intercept- min(y_fit))/ max(y_fit)) * (max(y)-min(y)) + ((y_fit - min(y_fit))/ max(y_fit)) * (max(y)-min(y));
x_pred = min(x) + (( x_ranks-1) / max( x_ranks)) * (max(x)-min(x));

[~, idx]= sort(y_pred, 'ascend');

% figure; 
% plot(M, D ,'o'); hold on
plot(x(idx), smooth(y_pred(idx),3), 'r-', 'LineWidth', 2);

Stats{k+3,1} = [Rl(k),{p}];
% plot(lm,'Marker','.','MarkerEdgeColor','none','MarkerFaceColor','none')

xlabel('Mean importance across all')
ylabel({'Difference of importance score','between groupe leaders and members'})
legend('off')
box off
 title(['r = ',num2str(round(cc,4)),S],'FontSize',FontSz)
set(gca,'FontSize',FontSz)
xlim([3.5 5])
addLetter(gca,'i')
%% bar plot mean importance for PIs vs lab members grouped by Careers, Teams, Policies


A6 = axes('position',[A(1)+A(3)+0.05 A(2) A(3)  A(4)]);
hold on
u = unique(answ.themes.questions,'stable');
N ={};
for i=1:length(u)
    dd = u(i) == answ.themes.questions;
    Violin({D(dd)}, i , 'ViolinColor',{colour.(answ.themes.names{i})./255},'ViolinAlpha',{Violin_Alpha },'MarkerSize',Violin_Mksize);
    N(dd) = answ.themes.names(i);
end

[p,~,stats]= kruskalwallis(D,N,'off');
[c,~,~,gnames] = multcompare(stats,'display','off');
S = pRules(p);


title(['Kruskal Wallis ',S])
S = procKWmultcompare(c,gnames);
Stats{k+4,1} = [{'j'},{p},S];
set(gca,'XTick',1:length(answ.themes.names),'XTickLabel',answ.themes.names)
set(gca,'FontSize',FontSz)
addLetter(gca,'j')
%%
nS = cellfun(@(x) length(x),Stats);
T = {};
for i=1:length(Stats)
    for j=1:nS
        if j<=length(Stats{i})
            T{i,j} = Stats{i}{j};
        end
    end
end
T = cell2table(T);
%%
writetable(T,fullfile(OutF,'Fig3_stats.xlsx'));
saveas(gcf, fullfile(OutF,'Fig3.pdf'));
print(gcf, fullfile(OutF,'Fig3.png'),'-dpng','-r600');