%This program is similar to ASHP_JNUaux, but it only allows to load a
%MATLAB binary file with data (it doesn't allow to load data in Campbell
%format) and it only displays data for heat pump 1.

clear;

%Global variables:
global x logging_interval T_Outside P_input_HP1 P_output_HP1; %dynamicDataDisplayJNU function will need these to calculate the performance data for the selected interval

%load 'x','T_SupplyHP1','T_SupplyHP2','T_SupplyHouse','T_SupplyDHW',
%'T_ReturnHP1','T_ReturnHP2','T_ReturnHouse','T_ReturnDHW','T_Coil1','T_Coil2','T_Outside',
%'P_HP1hydro','P_HP2hydro','P_HP1out','P_HP2out','P_DHW','Flow_HP1','Flow_HP2','Flow_House','Flow_DHW',
%'P_output_HP1','P_output_HP2','P_output_House','P_output_DHW':
load('Juneau_JNU_ASHP_TenSecond.mtl','-mat');

%Calculate the total input power:
P_input_HP1=P_HP1hydro+P_HP1out;

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Calculate the COP:
COP_HP1_HB=P_output_HP1./P_input_HP1; %COP of HP1 measured at the Hydrobox


%Plot data for HP2:
figure('units','normalized','outerposition',[0 0 1 1],'name','HP1');
%Plot the first graph:
plotHP1_1=subplot(3,1,1);
p=get(plotHP1_1,'Position'); set(plotHP1_1,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[T_Coil1,T_Outside,T_SupplyHP1,T_ReturnHP1,Flow_HP1,Flow_DHW],'.');
%hold on;
%plot(x,[Flow_HP2,Flow_House],'p','MarkerSize',5);
xlabel('date & time');
ylabel('T [F], Flow [gpm]');
h=clickableLegend({'T_{coil1}','T_{Outside}','T_{SupplyHP1}','T_{ReturnHP1}','Flow_{HP1}','Flow_{DHW}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the second graph:
plotHP1_2=subplot(3,1,2);
p=get(plotHP1_2,'Position'); set(plotHP1_2,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[P_HP1hydro,P_HP1out],'.');
xlabel('date & time');
ylabel('P [W]');
h=clickableLegend({'P_{input HP1hydro}','P_{input HP1outside}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the third graph:
plotHP1_3=subplot(3,1,3);
p=get(plotHP1_3,'Position'); set(plotHP1_3,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[P_input_HP1,P_output_HP1,COP_HP1_HB*100],'.');
xlabel('date & time');
ylabel('P [W], COP [%]');
h=clickableLegend({'P_{input HP1}','P_{output HP1}','COP_{HP1}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;

%Synchronize zoom for all three graphs:
linkaxes([plotHP1_1,plotHP1_2,plotHP1_3],'x');

%Show date and time on x axis:
dynamicDateTicks([plotHP1_1,plotHP1_2,plotHP1_3],'linked'); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks

%Calculate summary data for HP2:
Total_E_input_HP1=nansum(P_input_HP1)*logging_interval/1000; %Total energy input in kWh
Total_E_output_HP1=nansum(P_output_HP1)*logging_interval/1000; %Total energy output in kWh
Total_COP_HP1=Total_E_output_HP1/Total_E_input_HP1; %Total COP
%Display summary data for HP1:
fprintf('HP1 - input energy: %f kWh \n',Total_E_input_HP1);
fprintf('HP1 - output energy: %f kWh \n',Total_E_output_HP1);
fprintf('HP1 - overall COP: %f \n',Total_COP_HP1);

Avg_T_Outside=mean(T_Outside); %Average outside temperature
fprintf('Average outside temperature: %f F \n',Avg_T_Outside);

%Dynamically display performance data (COP, etc.) for the interval that the
%user zoomes onto for HP2:
dynamicDataDisplayJNU1(plotHP1_3);
