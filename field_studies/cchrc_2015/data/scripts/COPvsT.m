%figure('units','normalized','outerposition',[0 0 1 1]);
figure('units','normalized','outerposition',[0 0 0.75 0.68]);
xlabel('Outdoor Temperature [F]');
ylabel('COP');
axis([-12, 60, 0, 6.5]);
grid on;
hold on;
ASHP_DLG_analyze_ssCOPvsT;
ASHP_DLG_analyze_integratedCOP;
ASHP_WRG_analyze_ssCOPvsT;
ASHP_WRG_analyze_integratedCOP2;
ASHP_JNU_analyze_ssCOP2vsT;
ASHP_JNU_analyze_integratedCOP2;

%Mitsubishi specs:
plot(17,3.02,'s','MarkerEdgeColor','w','MarkerFaceColor','c','MarkerSize',11,'linewidth',2); %rated conditions at 17 F: COP = 6,700 Btu/h * 1W/(3.41 Btu/h) / 650W = 3.02
plot(17,2.12,'h','MarkerEdgeColor','k','MarkerFaceColor','c','MarkerSize',15,'linewidth',2); %maximum conditions at 17 F: COP = 12,500 Btu/h * 1W/(3.41 Btu/h) / 1,730W = 2.12

%Fujitsu specs:
plot(47,3.91,'s','MarkerEdgeColor','w','MarkerFaceColor','r','MarkerSize',11,'linewidth',2); %rated conditions at 47 F: COP = 16,000 Btu/h * 1W/(3.41 Btu/h) / 1,200W = 3.91

%Daikin specs:
plot(44.6,3.82,'s','MarkerEdgeColor','w','MarkerFaceColor','b','MarkerSize',11,'linewidth',2); %rated conditions at 44.6 F: COP = 28,760 Btu/h * 1W/(3.41 Btu/h) / 2,210W = 3.82

%h=clickableLegend({'Mitsubishi steady-state','Mitsubishi integrated','Mitsubishi specs @ 17 F and rated power','Mitsibishi specs @ 17 F and max power'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
%h=clickableLegend({'Fujitsu steady-state','Fujitsu integrated','Fujitsu specs @ 47 F and rated power'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
%h=clickableLegend({'Daikin steady-state','Daikin integrated','Daikin specs @ 44.6 F and rated power'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
h=clickableLegend({'Mitsubishi steady-state','Mitsubishi integrated','Fujitsu steady-state','Fujitsu integrated',...
    'Daikin steady-state','Daikin integrated','Mitsubishi specs @ 17 F and rated power','Mitsibishi specs @ 17 F and max power',...
    'Fujitsu specs @ 47 F and rated power','Daikin specs @ 44.6 F and rated power'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
%h=clickableLegend({'Heat pump 1 steady-state','Heat pump 1 integrated','Heat pump 2 steady-state','Heat pump 2 integrated',...
%    'Heat pump 3 steady-state','Heat pump 3 integrated','Heat pump 1 specs @ 17 F and rated power','Heat pump 1 specs @ 17 F and max power',...
%    'Heat pump 2 specs @ 47 F and rated power','Heat pump 3 specs @ 44.6 F and rated power'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
set(h,'Location','best'); %Position the legend nicely in the graph

%print('-djpeg','-r300','COPvsT.jpg'); %Save figure into a file