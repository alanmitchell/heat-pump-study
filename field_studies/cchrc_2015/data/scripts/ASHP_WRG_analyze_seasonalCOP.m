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
