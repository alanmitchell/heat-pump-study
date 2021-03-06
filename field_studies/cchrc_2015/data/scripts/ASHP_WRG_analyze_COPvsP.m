clear;

%load 'x','T_deliv','T_return','T_coil','T_out','P_input','Airflow','P_output':
load('Wrangell_WRG_DHP_TenSecond_10min.mtl','-mat');

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps


n=6; %n specifies how many samples next to each other will be analyzed for steady state

%Organize data into matrices that have n rows (subsequent samples are in columns:
x=reshapeNoError(x,n);
T_deliv=reshapeNoError(T_deliv,n);
T_return=reshapeNoError(T_return,n);
T_coil=reshapeNoError(T_coil,n);
T_out=reshapeNoError(T_out,n);
P_input=reshapeNoError(P_input,n);
Airflow=reshapeNoError(Airflow,n);
P_output=reshapeNoError(P_output,n);

%For each column, analyze whether that column represents a steady state:
ss=((max(P_input)-min(P_input))<30) & ((max(P_output)-min(P_output))<60) & ((max(T_out)-min(T_out))<1);

%Merge rows into one using averaging:
x=mean(x)';
T_deliv=mean(T_deliv)';
T_return=mean(T_return)';
T_coil=mean(T_coil)';
T_out=mean(T_out)';
P_input=mean(P_input)';
Airflow=mean(Airflow)';
P_output=mean(P_output)';

%Calculate the COP:
COP = P_output./P_input;
Running=P_input>100; %The ASHP is considered actively running when input P > 100 W
COP = COP.*Running; %Only show COP when ASHP is running, otherwise show zero

ss=ss' & (P_output>1000); %Only take samples with output power above certain threshold

%Pull out the steady state samples:
T_out=T_out(ss);
COP=COP(ss);
x=x(ss);
P_output=P_output(ss);

%Take data after 12/2/2014 (when cleaning of filters and anemometer was done:
x_start=datenum('"2014-12-03 00:00:00"','"yyyy-mm-dd HH:MM:SS"');
x_start_i=find(x>x_start,1,'first');
T_out=T_out(x_start_i:end);
COP=COP(x_start_i:end);
x=x(x_start_i:end);
P_output=P_output(x_start_i:end);

%Select only a certain temperature range:
i_select=find(T_out>20 & T_out<25);
T_out=T_out(i_select);
COP=COP(i_select);
x=x(i_select);
P_output=P_output(i_select);

figure('units','normalized','outerposition',[0 0 1 1]);
%Plot the first graph:
plot1=subplot(2,1,1);
plot(P_output,COP,'.');
xlabel('output power [W]');
ylabel('COP');
grid on;
%Plot the second graph:
plot2=subplot(2,1,2);
p=plot(x,COP,'.');
xlabel('date & time');
ylabel('COP');
grid on;
%Show date and time on x axes:
%datetick('x');
dynamicDateTicks(plot2); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks

