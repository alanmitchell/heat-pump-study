clear;

%load 'Juneau_JNU_ASHP_TenSecond.mtl','x','T_SupplyHP1','T_SupplyHP2','T_SupplyHouse','T_SupplyDHW',
%'T_ReturnHP1','T_ReturnHP2','T_ReturnHouse','T_ReturnDHW','T_Coil1','T_Coil2','T_Outside',
%'P_HP1hydro','P_HP2hydro','P_HP1out','P_HP2out','P_DHW','Flow_HP1','Flow_HP2','Flow_House','Flow_DHW',
%'P_output_HP1','P_output_HP2','P_output_House','P_output_DHW':
load('Juneau_JNU_ASHP_TenSecond_10min.mtl','-mat');

%Calculate the total input power:
P_input_HP2=P_HP2hydro+P_HP2out;

%Take data after 11/23/2014 (when Jim finished insulating tees):
x_start=datenum('"2014-11-24 00:00:00"','"yyyy-mm-dd HH:MM:SS"');
x_start_i=find(x>x_start,1,'first');
T_Outside=T_Outside(x_start_i:end);
x=x(x_start_i:end);
P_output_HP2=P_output_HP2(x_start_i:end);
P_input_HP2=P_input_HP2(x_start_i:end);

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Downsample n times:
n=48;
x=resampleByAvg(x,n);
T_Outside=resampleByAvg(T_Outside,n);
P_output_HP2=resampleByAvg(P_output_HP2,n);
P_input_HP2=resampleByAvg(P_input_HP2,n);

%Calculate the COP:
COP = P_output_HP2./P_input_HP2;
Running=P_input_HP2>100; %The ASHP is considered actively running when input P > 100 W
COP = COP.*Running; %Only show COP when ASHP is running, otherwise show zero

i_select=P_output_HP2>1000;
x=x(i_select);
T_Outside=T_Outside(i_select);
P_output_HP2=P_output_HP2(i_select);
P_input_HP2=P_input_HP2(i_select);
COP=COP(i_select);

if 1 %Use "1" if this plot is done as a part of a larger plot that is combining plots from several programs
    plot(T_Outside,COP,'.k','MarkerSize',15);
else
    figure('units','normalized','outerposition',[0 0 1 1]);
    %Plot the first graph:
    plot1=subplot(2,1,1);
    plot(T_Outside,P_output_HP2,'.');
    xlabel('average outdoor temperature [F]');
    ylabel('output power [W]');
    grid on;
    %Plot the second graph:
    plot2=subplot(2,1,2);
    plot(T_Outside,COP,'.');
    xlabel('average outdoor temperature [F]');
    ylabel('average COP');
    grid on;
end
