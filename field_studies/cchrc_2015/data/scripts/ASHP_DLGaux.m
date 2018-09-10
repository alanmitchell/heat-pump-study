%This program does what ASHP_DLG does, but in addition to it:
%Downsamples the data n times and saves the data as a binary file so next time it is faster for MATLAB to load it
%OR (see "if 0" versus "if 1" below to use a switch between these two options)
%Loads a MATLAB binary file with previously stored data

clear;

%Global variables:
global x logging_interval T_out P_input P_output Airspeed; %dynamicDataDisplay function will need these to calculate the performance data for the selected interval

if 0 %Use 1 to load a file in the Campbell datalogger format or use 0 to load a file in Matlab format
    %Input:
    %file_name='Dillingham_DLG_DHP_TenSecond.dat'; %Specify the file from which you want to read data
    file_name='CR1000_DLG_DHP_TenSecond.dat'; %Specify the file from which you want to read data
    
    %Constants:
    c_p = 0.240; %Specific heat of air in Btu/lb-F
    ro=0.0749; %Density of air (in lb/ft^3) at standard conditions
    VHC=c_p*ro; %Volumetric heat capacity of air in Btu/ft^3-F
    
    %Load the input file:
    fid=fopen(file_name,'r');
    data=textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f','Delimiter',',','CollectOutput',true,'HeaderLines',4,'ReturnOnError',false,'TreatAsEmpty','"NAN"');
    %returns a cell array with two cells - each cell is an array - the first array is the dates and times, and second array is the numbers
    fclose(fid);
    %this takes too long for big input files:
    x=datenum(data{1},'"yyyy-mm-dd HH:MM:SS"'); %X axis is the date and time, which means the first array of the loaded data
    %so, instead, one can use this, which takes less time, but is less accurate:
    %x=datenum(data{1}((end-1):end)); %X axis is the date and time, which means the first array of the loaded data, but convert the last two only and assume there are no gaps, otherwise it takes a long time
    %x=transpose(linspace(x(2)-(x(2)-x(1))*(length(data{1})-1),x(2),length(data{1}))); %create the whole X axis by extrapolating the last two samples
    %
    data=data{2}(:,2:11); %Take the second array of the loaded data, delete the first column (record #) and overwrite the variable data with it (this will save memory)
    
    %Break the data matrix into individual variables (vectors):
    T_deliv=mean(data(:,1:3),2); %Delivery T in F
    T_return=mean(data(:,4:6),2); %Return T in F
    T_coil=data(:,7); %Outdoor coil T in F
    T_out=data(:,8); %Outdoor T in F
    P_input=data(:,9); %Input electrical power in W
    Airspeed=data(:,10); %Air speed in fpm
    
    %Calculate the airflow from the air speed:
    %Airflow=1.0566*Airspeed+18.333; %Air flow in cfm from proxy calibration done in Sep 2014 incorrectly
    Airflow=1.3083*Airspeed+5.1391; %Air flow in cfm from proxy calibration done in Jan 2015 correctly
    Nonzero_speed=Airspeed>40; %Speed less than 40 fpm counts as zero speed
    Airflow=Airflow.*Nonzero_speed; %Zero speed means zero flow
    
    %Airflow(isnan(Airflow))=1000; %Make NaN visible in graph
    
    %Calculate the heat output:
    Heat_rate=Airflow.*(T_deliv-T_return)*VHC*60; %Heat output rate in Btu/h
    P_output=Heat_rate/3.412; %Heat output rate in W
    
    %Downsample n times:
    n=6;
    x=resampleByAvg(x,n);
    T_deliv=resampleByAvg(T_deliv,n);
    T_return=resampleByAvg(T_return,n);
    T_coil=resampleByAvg(T_coil,n);
    T_out=resampleByAvg(T_out,n);
    P_input=resampleByAvg(P_input,n);
    Airflow=resampleByAvg(Airflow,n);
    P_output=resampleByAvg(P_output,n);
    
    save('CR1000_DLG_DHP_TenSecond_1min.mtl','x','T_deliv','T_return','T_coil','T_out','P_input','Airflow','P_output');
else
    load('CR1000_DLG_DHP_TenSecond.mtl','-mat');
end

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Calculate the COP:
COP = P_output./P_input;
Running=P_input>100; %The ASHP is considered actively running when input P > 100 W
COP = COP.*Running; %Only show COP when ASHP is running, otherwise show zero

%Plot data:
figure('units','normalized','outerposition',[0 0 1 1]);
%Plot the first graph:
plot1=subplot(2,1,1);
plot(x,[T_coil,T_out,T_deliv,T_return,Airflow],'.');
hold on;
%plot(x,Airflow,'.','MarkerSize',1);
%plot(x,Airspeed,'.');
xlabel('date & time');
ylabel('T [F], Airflow [cfm]');
h=clickableLegend({'T_{coil}','T_{out}','T_{deliv}','T_{return}','Airflow'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.01,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the second graph:
plot2=subplot(2,1,2);
plot(x,[P_input,P_output,COP*100],'.');
xlabel('date & time');
ylabel('P [W], COP [%]');
h=clickableLegend({'P_{input}','P_{output}','COP'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.01,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Synchronize zoom for both graphs:
linkaxes([plot1,plot2],'x');
%Show date and time on x axes:
%datetick('x');
dynamicDateTicks([plot1,plot2],'linked'); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks

%Calculate summary data:
Total_E_input=nansum(P_input)*logging_interval/1000; %Total energy input in kWh
Total_E_output=nansum(P_output)*logging_interval/1000; %Total energy output in kWh
Total_COP=Total_E_output/Total_E_input; %Total COP
T_out_avg=nanmean(T_out); %Average outside temperature
%Display summary data:
fprintf('Input energy: %f kWh \n',Total_E_input);
fprintf('Output energy: %f kWh \n',Total_E_output);
fprintf('Overall COP: %f \n',Total_COP);
fprintf('Average outdoor T: %f F \n',T_out_avg);

%Dynamically display performance data (COP, etc.) for the interval that the
%user zoomes onto:
dynamicDataDisplay(plot2);