%This program loads ASHP data (in the format generated by the Campbell
%datalogger), displays summary data (overall COP, etc.), and displays
%graphs that allow the user to zoom in a synchronized way.
%
%This is the Dillingham version (the difference between the Dillingham and
%Wrangell versions is in the proxy calibration curve for the airflow).

clear;

%Input:
file_name='Dillingham_DLG_DHP_FiveMinute.dat'; %Specify the file from which you want to read data
logging_interval=300; %Specify what logging interval (in seconds) was used in the above specified file

%Constants:
c_p = 0.240; %Specific heat of air in Btu/lb-F
ro=0.0749; %Density of air (in lb/ft^3) at standard conditions
VHC=c_p*ro; %Volumetric heat capacity of air in Btu/ft^3-F

%Condition the input data. The Campbell's file can include "NAN" values,
%but MATLAB's csvread function cannot read "NAN" values, it can only read
%NAN values (i.e. no quotes). So, this section replaces "NAN" values for
%NAN values and stores the result in a temporary file:
data_string=fileread(file_name);
data_string=strrep(data_string,'"NAN"','NAN');
fid=fopen('ASHP_data_temp.csv','w'); %Open temporary file
fprintf(fid,'%s',data_string);
fclose(fid);
data=csvread('ASHP_data_temp.csv',4,2); %store everything in one matrix (named data)
delete ('ASHP_data_temp.csv'); %Delete the temporary file

%Break the data matrix into individual variables (vectors):
T_deliv=mean(data(:,1:3),2); %Delivery T in F
T_return=mean(data(:,4:6),2); %Return T in F
T_coil=data(:,7); %Outdoor coil T in F
T_out=data(:,8); %Outdoor T in F
P_input=data(:,9); %Input electrical power in W
Airspeed=data(:,10); %Air speed in fpm

%Calculate the airflow from the air speed:
Airflow=1.0566*Airspeed+18.333; %Air flow in cfm from proxy calibration
Nonzero_speed=Airspeed>40; %Speed less than 40 fpm counts as zero speed
Airflow=Airflow.*Nonzero_speed; %Zero speed means zero flow

%Calculate the heat output:
Heat_rate=Airflow.*(T_deliv-T_return)*VHC*60; %Heat output rate in Btu/h
P_output=Heat_rate/3.412; %Heat output rate in W

%Calculate the COP:
COP = P_output./P_input;
Running=P_input>100; %The ASHP is considered actively running when input P > 100 W
COP = COP.*Running; %Only show COP when ASHP is running, otherwise show zero

%Airspeed_smooth=smooth(Airspeed);

%Plot data:
x=(1:size(data,1))*logging_interval/3600; %X axis is time in hours
figure('units','normalized','outerposition',[0 0 1 1]);
%Plot the first graph:
plot1=subplot(2,1,1);
plot(x,[T_coil,T_out,T_deliv,T_return,Airspeed],'.');
%hold on;
%plot(x,Airspeed,'.','MarkerSize',1);
xlabel('time [hours]');
ylabel('T [F], Airflow [cfm]');
legend('T_{coil}','T_{out}','T_{deliv}','T_{return}','Airflow');
grid on;
%Plot the second graph:
plot2=subplot(2,1,2);
plot(x,[P_input,P_output,COP*100],'.');
xlabel('time [hours]');
ylabel('P [W], COP [%]');
legend('P_{input}','P_{output}','COP');
grid on;
%Synchronize zoom for both graphs:
linkaxes([plot1,plot2],'x');

%Calculate summary data:
Total_E_input=nansum(P_input)*logging_interval/3600/1000; %Total energy input in kWh
Total_E_output=nansum(P_output)*logging_interval/3600/1000; %Total energy output in kWh
Total_COP=Total_E_output/Total_E_input; %Total COP
%Display summary data:
fprintf('Input energy: %f kWh \n',Total_E_input);
fprintf('Output energy: %f kWh \n',Total_E_output);
fprintf('Overall COP: %f \n',Total_COP);