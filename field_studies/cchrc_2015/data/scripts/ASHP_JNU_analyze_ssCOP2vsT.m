clear;

%load 'x','T_SupplyHP1','T_SupplyHP2','T_SupplyHouse','T_SupplyDHW',
%'T_ReturnHP1','T_ReturnHP2','T_ReturnHouse','T_ReturnDHW','T_Coil1','T_Coil2','T_Outside',
%'P_HP1hydro','P_HP2hydro','P_HP1out','P_HP2out','P_DHW','Flow_HP1','Flow_HP2','Flow_House','Flow_DHW',
%'P_output_HP1','P_output_HP2','P_output_House','P_output_DHW':
load('Juneau_JNU_ASHP_TenSecond_5min.mtl','-mat');

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Calculate the total input power:
P_input_HP2=P_HP2hydro+P_HP2out;

n=3; %n specifies how many samples next to each other will be analyzed for steady state

%Organize data into matrices that have n rows (subsequent samples are in columns:
x=reshapeNoError(x,n);
T_SupplyHP2=reshapeNoError(T_SupplyHP2,n);
T_ReturnHP2=reshapeNoError(T_ReturnHP2,n);
T_Coil2=reshapeNoError(T_Coil2,n);
T_Outside=reshapeNoError(T_Outside,n);
P_input_HP2=reshapeNoError(P_input_HP2,n);
Flow_HP2=reshapeNoError(Flow_HP2,n);
P_output_HP2=reshapeNoError(P_output_HP2,n);

%For each column, analyze whether that column represents a steady state:
ss=((max(P_input_HP2)-min(P_input_HP2))<120) & ((max(P_output_HP2)-min(P_output_HP2))<300);

%Merge rows into one using averaging:
x=mean(x)';
T_SupplyHP2=mean(T_SupplyHP2)';
T_ReturnHP2=mean(T_ReturnHP2)';
T_Coil2=mean(T_Coil2)';
T_Outside=mean(T_Outside)';
P_input_HP2=mean(P_input_HP2)';
Flow_HP2=mean(Flow_HP2)';
P_output_HP2=mean(P_output_HP2)';

%Calculate the COP:
COP = P_output_HP2./P_input_HP2;
Running=P_input_HP2>100; %The ASHP is considered actively running when input P > 100 W
COP = COP.*Running; %Only show COP when ASHP is running, otherwise show zero

ss=ss' & (P_output_HP2>1000); %Only take samples with output power above certain threshold

%Pull out the steady state samples:
T_Outside=T_Outside(ss);
COP=COP(ss);
x=x(ss);
P_output_HP2=P_output_HP2(ss);
P_input_HP2=P_input_HP2(ss);

%Take data after 11/23/2014 (when Jim finished insulating tees):
x_start=datenum('"2014-11-24 00:00:00"','"yyyy-mm-dd HH:MM:SS"');
x_start_i=find(x>x_start,1,'first');
T_Outside=T_Outside(x_start_i:end);
COP=COP(x_start_i:end);
x=x(x_start_i:end);
P_output_HP2=P_output_HP2(x_start_i:end);
P_input_HP2=P_input_HP2(x_start_i:end);

if 1 %Use "1" if this plot is done as a part of a larger plot that is combining plots from several programs
    plot(T_Outside,COP,'.b','MarkerSize',15);
else
    figure('units','normalized','outerposition',[0 0 1 1]);
    %Plot the first graph:
    plot1=subplot(2,1,1);
    plot(T_Outside,COP,'.');
    xlabel('outdoor temperature [F]');
    ylabel('COP');
    grid on;
    %Plot the second graph:
    plot2=subplot(2,1,2);
    p=plot(x,COP,'.');
    xlabel('date & time');
    ylabel('COP');
    grid on;
    dynamicDateTicks(plot2); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks
end
