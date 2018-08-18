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

%Calculate summary data for HP2:
Total_E_input_HP2=nansum(P_input_HP2)*logging_interval/1000; %Total energy input in kWh
Total_E_output_HP2=nansum(P_output_HP2)*logging_interval/1000; %Total energy output in kWh
Total_COP_HP2=Total_E_output_HP2/Total_E_input_HP2; %Total COP
T_out_avg=nanmean(T_Outside); %Average outside temperature
%Display summary data for HP1:
fprintf('HP2 - input energy: %f kWh \n',Total_E_input_HP2);
fprintf('HP2 - output energy: %f kWh \n',Total_E_output_HP2);
fprintf('HP2 - overall COP: %f \n',Total_COP_HP2);
fprintf('Average outdoor T: %f F \n',T_out_avg);

