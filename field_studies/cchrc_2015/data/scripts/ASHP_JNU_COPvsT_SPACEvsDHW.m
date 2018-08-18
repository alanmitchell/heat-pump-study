%figure('units','normalized','outerposition',[0 0 1 1]);
figure('units','normalized','outerposition',[0 0 0.75 0.68]);
xlabel('Outdoor Temperature [F]');
ylabel('COP');
axis([30, 60, 0, 5]);
grid on;
hold on;
ASHP_JNU_analyze_integratedCOP2;
ASHP_JNU_analyze_integratedCOP1;


h=clickableLegend({'Daikin integrated COP - space heating','Daikin integrated COP - domestic hot water'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
set(h,'Location','best'); %Position the legend nicely in the graph

%print('-djpeg','-r300','COPvsT.jpg'); %Save figure into a file