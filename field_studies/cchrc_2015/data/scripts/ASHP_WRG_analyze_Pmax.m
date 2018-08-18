clear;

%load 'x','T_deliv','T_return','T_coil','T_out','P_input','Airflow','P_output':
load('Wrangell_WRG_DHP_TenSecond_10min.mtl','-mat');

figure('units','normalized','outerposition',[0 0 1 1]);
%Plot the first graph:
plot1=subplot(2,1,1);
plot(T_out,P_input,'.');
xlabel('outdoor temperature [F]');
ylabel('P_{input} [W]');
grid on;
%Plot the second graph:
plot2=subplot(2,1,2);
p=plot(T_out,P_output,'.');
xlabel('outdoor temperature [F]');
ylabel('P_{output} [W]');
grid on;
