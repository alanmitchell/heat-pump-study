clear;

%load 'x','T_deliv','T_return','T_coil','T_out','P_input','Airflow','P_output':
load('CR1000_DLG_DHP_TenSecond_1min.mtl','-mat');

figure('units','normalized','outerposition',[0 0 0.75 0.68]);
%Plot the first graph:
%plot1=subplot(2,1,1);
%plot(T_out,P_input,'.');
%xlabel('outdoor temperature [F]');
%ylabel('P_{input} [W]');
%grid on;
%Plot the second graph:

%i_select=P_output>10;
%T_out=T_out(i_select);
%P_output=P_output(i_select);

%Mitsubishi specs for max power:
%T_spec=[-13,-4,5,50];
%Pmax=12500/3.41;
%Pout_spec=[0.62*Pmax, 0.82*Pmax, Pmax, Pmax];

%plot2=subplot(2,1,2);
plot(T_out,P_input,'.');
hold on;
%plot(T_spec,Pout_spec,'r','LineWidth',2);
xlabel('outdoor temperature [F]');
ylabel('P_{output} [W]');
grid on;
