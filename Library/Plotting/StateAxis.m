
xpos = [.15];
xLength = .75;

ypos = [.175 .125 .075];
yLength = 0.000001;

fontSize = 10;

getLimits = get(axHan, 'Xlim');

ax3=axes('xlim',getLimits,'color','none');
set(ax3,'Units','Normalized');
set(ax3,'Position',[xpos ypos(1) xLength yLength]);
set(ax3,'Xtick', tickNums{1});
set(ax3,'XTickLabel',tickNames{1})
set(ax3,'FontSize',fontSize);
set(ax3,'XColor', [0 .25 0]);

ax4=axes('xlim',getLimits,'color','none');
set(ax4,'Units','Normalized');
set(ax4,'Position',[xpos ypos(2) xLength yLength]);
set(ax4,'Xtick', tickNums{2});
set(ax4,'XTickLabel',tickNames{2})
set(ax4,'FontSize',fontSize);
set(ax4,'XColor', [0 .5 0]);

ax5=axes('xlim',getLimits,'color','none');
set(ax5,'Units','Normalized');
set(ax5,'Position',[xpos ypos(3) xLength yLength]);
set(ax5,'Xtick', tickNums{3});
set(ax5,'XTickLabel',tickNames{3})
set(ax5,'FontSize',fontSize);
set(ax5,'XColor', [0 .75 0]);
