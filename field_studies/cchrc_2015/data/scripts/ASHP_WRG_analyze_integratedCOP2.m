clear;

%load 'x','T_deliv','T_return','T_coil','T_out','P_input','Airflow','P_output':
load('Wrangell_WRG_DHP_TenSecond_10min.mtl','-mat');

if 1 %Use 1 if you only want to take data after 12/2/2014 (when cleaning of filters and anemometer was done) and before 5/8/2015 (the first air conditioning):
    x_start=datenum('"2014-12-03 00:00:00"','"yyyy-mm-dd HH:MM:SS"');
    x_start_i=find(x>x_start,1,'first');
    x_end=datenum('"2015-05-08 00:00:00"','"yyyy-mm-dd HH:MM:SS"');
    x_end_i=find(x<x_end,1,'last');
    x=x(x_start_i:x_end_i);
    T_deliv=T_deliv(x_start_i:x_end_i);
    T_return=T_return(x_start_i:x_end_i);
    T_coil=T_coil(x_start_i:x_end_i);
    T_out=T_out(x_start_i:x_end_i);
    P_input=P_input(x_start_i:x_end_i);
    Airflow=Airflow(x_start_i:x_end_i);
    P_output=P_output(x_start_i:x_end_i);
end

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Downsample n times:
n=48;
x=resampleByAvg(x,n);
T_deliv=resampleByAvg(T_deliv,n);
T_return=resampleByAvg(T_return,n);
T_coil=resampleByAvg(T_coil,n);
%T_out=resampleByAvg(T_out,n);
P_input=resampleByAvg(P_input,n);
Airflow=resampleByAvg(Airflow,n);
P_output=resampleByAvg(P_output,n);

%Do T_out separately to detect high temperature fluctuations (sensor affected by the sun), so those samples can be eliminated:
T_out=reshapeNoError(T_out,n);
i_select=(max(T_out)-min(T_out))<10; %Only select samples with low temperature swing
i_select=i_select';
T_out=nanmean(T_out)';


%Calculate the COP:
COP = P_output./P_input;
Running=P_input>100; %The ASHP is considered actively running when input P > 100 W
COP = COP.*Running; %Only show COP when ASHP is running, otherwise show zero

i_select=i_select & (COP>0);
x=x(i_select);
T_deliv=T_deliv(i_select);
T_return=T_return(i_select);
T_coil=T_coil(i_select);
T_out=T_out(i_select);
P_input=P_input(i_select);
Airflow=Airflow(i_select);
P_output=P_output(i_select);
COP=COP(i_select);

if 1 %Use "1" if this plot is done as a part of a larger plot that is combining plots from several programs
    plot(T_out,COP,'.g','MarkerSize',15);
else
figure('units','normalized','outerposition',[0 0 1 1]);
%Plot the first graph:
plot1=subplot(2,1,1);
plot(T_out,P_output,'.');
xlabel('average outdoor temperature [F]');
ylabel('output power [W]');
grid on;
%Plot the second graph:
plot2=subplot(2,1,2);
plot(T_out,COP,'.');
xlabel('average outdoor temperature [F]');
ylabel('average COP');
grid on;
end
