function formatAxes(ax)

% set(gcf, 'Color', 'w');

if nargin < 1
    set (gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [0.015 0.015], 'Fontsize', 8)
else
    set (ax, 'Box', 'off', 'TickDir', 'out', 'TickLength', [0.015 0.015], 'Fontsize', 8)

end
set(gcf,'color','w');
end
