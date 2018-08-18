%This program is similar to ASHP_JNUaux, but it only allows to load a
%MATLAB binary file with data (it doesn't allow to load data in Campbell
%format) and it only displays data for heat pump 2.

clear;

%Global variables:
global x logging_interval T_Outside P_input_HP2 P_output_HP2; %dynamicDataDisplayJNU function will need these to calculate the performance data for the selected interval

%load 'x','T_SupplyHP1','T_SupplyHP2','T_SupplyHouse','T_SupplyDHW',
%'T_ReturnHP1','T_ReturnHP2','T_ReturnHouse','T_ReturnDHW','T_Coil1','T_Coil2','T_Outside',
%'P_HP1hydro','P_HP2hydro','P_HP1out','P_HP2out','P_DHW','Flow_HP1','Flow_HP2','Flow_House','Flow_DHW',
%'P_output_HP1','P_output_HP2','P_output_House','P_output_DHW':
load('Juneau_JNU_ASHP_TenSecond_10min.mtl','-mat');

%Calculate the total input power:
P_input_HP2=P_HP2hydro+P_HP2out;

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Calculate the COP:
COP_HP2_HB=P_output_HP2./P_input_HP2; %COP of HP2 measured at the Hydrobox
COP_HP2_House=P_output_House./P_input_HP2; %COP of HP2 measured at the house


%Plot data for HP2:
figure('units','normalized','outerposition',[0 0 1 1],'name','HP2');
%Plot the first graph:
plotHP2_1=subplot(3,1,1);
p=get(plotHP2_1,'Position'); set(plotHP2_1,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[T_Coil2,T_Outside,T_SupplyHP2,T_ReturnHP2,Flow_HP2],'.');
%hold on;
%plot(x,[Flow_HP2,Flow_House],'p','MarkerSize',5);
xlabel('date & time');
ylabel('T [F], Flow [gpm]');
h=clickableLegend({'T_{coil2}','T_{Outside}','T_{SupplyHP2}','T_{ReturnHP2}','Flow_{HP2}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the second graph:
plotHP2_2=subplot(3,1,2);
p=get(plotHP2_2,'Position'); set(plotHP2_2,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[P_HP2hydro,P_HP2out],'.');
xlabel('date & time');
ylabel('P [W]');
h=clickableLegend({'P_{input HP2hydro}','P_{input HP2outside}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the third graph:
plotHP2_3=subplot(3,1,3);
p=get(plotHP2_3,'Position'); set(plotHP2_3,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[P_input_HP2,P_output_HP2,COP_HP2_HB*100],'.');
xlabel('date & time');
ylabel('P [W], COP [%]');
h=clickableLegend({'P_{input HP2}','P_{output HP2}','COP_{HP2}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;

%Synchronize zoom for all three graphs:
linkaxes([plotHP2_1,plotHP2_2,plotHP2_3],'x');

%Show date and time on x axis:
dynamicDateTicks([plotHP2_1,plotHP2_2,plotHP2_3],'linked'); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks

%Calculate summary data for HP2:
Total_E_input_HP2=nansum(P_input_HP2)*logging_interval/1000; %Total energy input in kWh
Total_E_output_HP2=nansum(P_output_HP2)*logging_interval/1000; %Total energy output in kWh
Total_COP_HP2=Total_E_output_HP2/Total_E_input_HP2; %Total COP
%Display summary data for HP1:
fprintf('HP2 - input energy: %f kWh \n',Total_E_input_HP2);
fprintf('HP2 - output energy: %f kWh \n',Total_E_output_HP2);
fprintf('HP2 - overall COP: %f \n',Total_COP_HP2);

Avg_T_Outside=mean(T_Outside); %Average outside temperature
fprintf('Average outside temperature: %f F \n',Avg_T_Outside);

%Dynamically display performance data (COP, etc.) for the interval that the
%user zoomes onto for HP2:
dynamicDataDisplayJNU2(plotHP2_3);
