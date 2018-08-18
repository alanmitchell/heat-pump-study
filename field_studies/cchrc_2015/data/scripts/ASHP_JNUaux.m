%This program does what ASHP_JNU does, but in addition to it:
%Downsamples the data n times and saves the data as a binary file so next time it is faster for MATLAB to load it
%OR (see "if 0" versus "if 1" below to use a switch between these two options)
%Loads a MATLAB binary file with previously stored data

clear;

%Global variables:
global x logging_interval T_Outside P_input_HP1 P_output_HP1; %dynamicDataDisplayJNU function will need these to calculate the performance data for the selected interval

if 0 %Use 1 to load a file in the Campbell datalogger format or use 0 to load a file in Matlab format
    
    %Input:
    file_name='Juneau_JNU_ASHP_TenSecond.dat'; %Specify the file from which you want to read data
    
    %Constants:
    c_p = 1; %Specific heat of water in Btu/lb-F
    ro=8.304; %Density of water (in lb/gal) - source: Engineering Toolbox, 90F
    VHC=c_p*ro; %Volumetric heat capacity of water in Btu/gal-F
    
    %Load the input file:
    fid=fopen(file_name,'r');
    data=textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Delimiter',',','CollectOutput',true,'HeaderLines',4,'ReturnOnError',false,'TreatAsEmpty','"NAN"');
    %returns a cell array with two cells - each cell is an array - the first array is the dates and times, and second array is the numbers
    fclose(fid);
    %this takes too long for big input files:
    x=datenum(data{1},'"yyyy-mm-dd HH:MM:SS"'); %X axis is the date and time, which means the first array of the loaded data
    %so, instead, one can use this, which takes less time, but is less accurate:
    %x=datenum(data{1}((end-1):end)); %X axis is the date and time, which means the first array of the loaded data, but convert the last two only and assume there are no gaps, otherwise it takes a long time
    %x=transpose(linspace(x(2)-(x(2)-x(1))*(length(data{1})-1),x(2),length(data{1}))); %create the whole X axis by extrapolating the last two samples
    %
    data=data{2}(:,2:21); %Take the second array of the loaded data, delete the first column (record #) and overwrite the variable data with it (this will save memory)
    
    %Break the data matrix into individual variables (vectors):
    T_SupplyHP1=data(:,1); %Supply T in F for HP1
    T_SupplyHP2=data(:,2); %Supply T in F for HP2
    T_SupplyHouse=data(:,3); %Supply T in F for House
    T_SupplyDHW=data(:,4); %Supply T in F for DHW
    T_ReturnHP1=data(:,5); %Return T in F for HP1
    T_ReturnHP2=data(:,6); %Return T in F for HP2
    T_ReturnHouse=data(:,7); %Return T in F for House
    T_ReturnDHW=data(:,8); %Return T in F for DHW
    T_Coil1=data(:,9); %Outdoor coil T in F for HP1
    T_Coil2=data(:,10); %Outdoor coil T in F for HP2
    T_Outside=data(:,11); %Outside T in F
    P_HP1hydro=data(:,12); %Eletrical power in W for Hydrobox1
    P_HP2hydro=data(:,13); %Eletrical power in W for Hydrobox2
    P_HP1out=data(:,14); %Electrical power in W for the outsides unit of HP1
    P_HP2out=data(:,15); %Electrical power in W for the outsides unit of HP2
    P_DHW=data(:,16); %Electrical power in W for DHW heater
    Flow_HP1=data(:,17); %Flow of HP1 in gal/min measured right at Hydrobox1
    Flow_HP2=data(:,18); %Flow of HP2 in gal/min measured right at Hydrobox2
    Flow_House=data(:,19); %House flow in gal/min
    Flow_DHW=data(:,20); %DHW heater flow in gal/min
    
    %Calculate the heat output:
    Heat_rate_HP1=Flow_HP1.*(T_SupplyHP1-T_ReturnHP1)*VHC*60; %Heat output rate in Btu/h
    Heat_rate_HP2=Flow_HP2.*(T_SupplyHP2-T_ReturnHP2)*VHC*60; %Heat output rate in Btu/h
    Heat_rate_House=Flow_House.*(T_SupplyHouse-T_ReturnHouse)*VHC*60; %Heat output rate in Btu/h
    Heat_rate_DHW=Flow_DHW.*(T_SupplyDHW-T_ReturnDHW)*VHC*60; %Heat output rate in Btu/h
    P_output_HP1=Heat_rate_HP1/3.412; %Heat output rate in W
    P_output_HP2=Heat_rate_HP2/3.412; %Heat output rate in W
    P_output_House=Heat_rate_House/3.412; %Heat output rate in W
    P_output_DHW=Heat_rate_DHW/3.412; %Heat output rate in W
    
    %Downsample n times:
    n=60;
    x=resampleByAvg(x,n);
    T_SupplyHP1=resampleByAvg(T_SupplyHP1,n);
    T_SupplyHP2=resampleByAvg(T_SupplyHP2,n);
    T_SupplyHouse=resampleByAvg(T_SupplyHouse,n);
    T_SupplyDHW=resampleByAvg(T_SupplyDHW,n);
    T_ReturnHP1=resampleByAvg(T_ReturnHP1,n);
    T_ReturnHP2=resampleByAvg(T_ReturnHP2,n);
    T_ReturnHouse=resampleByAvg(T_ReturnHouse,n);
    T_ReturnDHW=resampleByAvg(T_ReturnDHW,n);
    T_Coil1=resampleByAvg(T_Coil1,n);
    T_Coil2=resampleByAvg(T_Coil2,n);
    T_Outside=resampleByAvg(T_Outside,n);
    P_HP1hydro=resampleByAvg(P_HP1hydro,n);
    P_HP2hydro=resampleByAvg(P_HP2hydro,n);
    P_HP1out=resampleByAvg(P_HP1out,n);
    P_HP2out=resampleByAvg(P_HP2out,n);
    P_DHW=resampleByAvg(P_DHW,n);
    Flow_HP1=resampleByAvg(Flow_HP1,n);
    Flow_HP2=resampleByAvg(Flow_HP2,n);
    Flow_House=resampleByAvg(Flow_House,n);
    Flow_DHW=resampleByAvg(Flow_DHW,n);
    P_output_HP1=resampleByAvg(P_output_HP1,n);
    P_output_HP2=resampleByAvg(P_output_HP2,n);
    P_output_House=resampleByAvg(P_output_House,n);
    P_output_DHW=resampleByAvg(P_output_DHW,n);
    
    save('Juneau_JNU_ASHP_TenSecond.mtl','x','T_SupplyHP1','T_SupplyHP2','T_SupplyHouse','T_SupplyDHW', ...
        'T_ReturnHP1','T_ReturnHP2','T_ReturnHouse','T_ReturnDHW','T_Coil1','T_Coil2','T_Outside',...
        'P_HP1hydro','P_HP2hydro','P_HP1out','P_HP2out','P_DHW','Flow_HP1','Flow_HP2','Flow_House','Flow_DHW',...
        'P_output_HP1','P_output_HP2','P_output_House','P_output_DHW');
    
else
    load('Juneau_JNU_ASHP_TenSecond_1min.mtl','-mat');
end

%Calculate the total input power for HP1 and HP2:
P_input_HP1=P_HP1hydro+P_HP1out; %Total input power of HP1
P_input_HP2=P_HP2hydro+P_HP2out; %Total input power of HP2

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

%Calculate the COP:
COP_HP1_HB=P_output_HP1./P_input_HP1; %COP of HP1 measured at the Hydrobox
COP_HP1_DHW=P_output_DHW./P_input_HP1; %COP of HP1 measured at the DHW tank
COP_HP2_HB=P_output_HP2./P_input_HP2; %COP of HP2 measured at the Hydrobox
COP_HP2_House=P_output_House./P_input_HP2; %COP of HP2 measured at the house

%P_HP1hydro(isnan(P_HP1hydro))=8000; %Make NaN values visible in the graph

%Plot data for HP1:
figure('units','normalized','outerposition',[0 0 1 1],'name','HP1');
%Plot the first graph:
plotHP1_1=subplot(3,1,1);
p=get(plotHP1_1,'Position'); set(plotHP1_1,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[T_Coil1,T_Outside,T_SupplyHP1,T_SupplyDHW,T_ReturnHP1,T_ReturnDHW],'.');
hold on;
plot(x,[Flow_HP1,Flow_DHW],'p','MarkerSize',5);
xlabel('date & time');
ylabel('T [F], Flow [gpm]');
h=clickableLegend({'T_{coil1}','T_{Outside}','T_{SupplyHP1}','T_{SupplyDHW}','T_{ReturnHP1}','T_{ReturnDHW}','Flow_{HP1}','Flow_{DHW}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the second graph:
plotHP1_2=subplot(3,1,2);
p=get(plotHP1_2,'Position'); set(plotHP1_2,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[P_HP1hydro,P_HP1out,P_DHW],'.');
xlabel('date & time');
ylabel('P [W]');
h=clickableLegend({'P_{input HP1hydro}','P_{input HP1outside}','P_{input DHW}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;
%Plot the third graph:
plotHP1_3=subplot(3,1,3);
p=get(plotHP1_3,'Position'); set(plotHP1_3,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[P_input_HP1,P_output_HP1,P_output_DHW,COP_HP1_HB*100,COP_HP1_DHW*100],'.');
xlabel('date & time');
ylabel('P [W], COP [%]');
h=clickableLegend({'P_{input HP1}','P_{output HP1}','P_{output DHW}','COP_{HP1 HB}','COP_{HP1 DHW}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;

%Plot data for HP2:
figure('units','normalized','outerposition',[0 0 1 1],'name','HP2');
%Plot the first graph:
plotHP2_1=subplot(3,1,1);
p=get(plotHP2_1,'Position'); set(plotHP2_1,'Position',[p(1)-0.04,p(2),p(3),p(4)]); %Position the plot more to the left so the legend can fit on the right
plot(x,[T_Coil2,T_Outside,T_SupplyHP2,T_SupplyHouse,T_ReturnHP2,T_ReturnHouse],'.');
hold on;
plot(x,[Flow_HP2,Flow_House],'p','MarkerSize',5);
xlabel('date & time');
ylabel('T [F], Flow [gpm]');
h=clickableLegend({'T_{coil2}','T_{Outside}','T_{SupplyHP2}','T_{SupplyHouse}','T_{ReturnHP2}','T_{ReturnHouse}','Flow_{HP2}','Flow_{House}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
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
plot(x,[P_input_HP2,P_output_HP2,P_output_House,COP_HP2_HB*100,COP_HP2_House*100],'.');
xlabel('date & time');
ylabel('P [W], COP [%]');
h=clickableLegend({'P_{input HP2}','P_{output HP2}','P_{output House}','COP_{HP2 HB}','COP_{HP2 House}'}); %This function was downloaded from http://www.mathworks.com/matlabcentral/fileexchange/21799-clickablelegend
p=get(h,'Position'); set(h,'Position',[1-p(3)-0.001,p(2),p(3),p(4)]); %Position the legend outside the graph
grid on;

%Synchronize zoom for all six graphs:
linkaxes([plotHP1_1,plotHP1_2,plotHP1_3,plotHP2_1,plotHP2_2,plotHP2_3],'x');

%Show date and time on x axes:
dynamicDateTicks([plotHP1_1,plotHP1_2,plotHP1_3],'linked'); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks
dynamicDateTicks([plotHP2_1,plotHP2_2,plotHP2_3],'linked'); %This function was donwloaded from http://www.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks

%Calculate summary data for HP1:
Total_E_input_HP1=nansum(P_input_HP1)*logging_interval/1000; %Total energy input in kWh
Total_E_output_HP1=nansum(P_output_HP1)*logging_interval/1000; %Total energy output in kWh
Total_COP_HP1=Total_E_output_HP1/Total_E_input_HP1; %Total COP
%Display summary data for HP1:
fprintf('HP1 - input energy: %f kWh \n',Total_E_input_HP1);
fprintf('HP1 - output energy: %f kWh \n',Total_E_output_HP1);
fprintf('HP1 - overall COP: %f \n',Total_COP_HP1);

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
%user zoomes onto for HP1:
dynamicDataDisplayJNU(plotHP1_3);
