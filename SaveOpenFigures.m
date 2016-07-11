h = get(0,'children');
h = sort(h);
for i=1:length(h)
  saveas(h(i), ['figure' num2str(i)], 'fig');
%   print(['figure' num2str(i)],'-dpng')
%     saveas(h(i), get(h(i),'Name'), 'fig');
end