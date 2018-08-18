clear;

%load 'Juneau_JNU_ASHP_TenSecond.mtl','x','T_SupplyHP1','T_SupplyHP2','T_SupplyHouse','T_SupplyDHW',
%'T_ReturnHP1','T_ReturnHP2','T_ReturnHouse','T_ReturnDHW','T_Coil1','T_Coil2','T_Outside',
%'P_HP1hydro','P_HP2hydro','P_HP1out','P_HP2out','P_DHW','Flow_HP1','Flow_HP2','Flow_House','Flow_DHW',
%'P_output_HP1','P_output_HP2','P_output_House','P_output_DHW':
load('Juneau_JNU_ASHP_TenSecond_10min.mtl','-mat');

%Calculate the total input power:
P_input_HP1=P_HP1hydro+P_HP1out;

%Take data after 11/23/2014 (when Jim finished insulating tees):
x_start=datenum('"2014-11-24 00:00:00"','"yyyy-mm-dd HH:MM:SS"');
x_start_i=find(x>x_start,1,'first');
T_Outside=T_Outside(x_start_i:end);
x=x(x_start_i:end);
P_output_HP1=P_output_HP1(x_start_i:end);
P_input_HP1=P_input_HP1(x_start_i:end);
Flow_DHW=Flow_DHW(x_start_i:end);

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

DHW_previous=false; %The DHW status in the previous run of for cycle - set the initial value to false (i.e. DHW not being heated)
i_start=1; %The first DHW heating cycle starts at index 1 (this will get overwritten by a new DHW heating start if index one doesn't actually represent DHW being heated)
COP_avg=[]; %start COP_avg as an empty array and then keep adding to it as calculating average COP's for new DHW heating cycles
T_out_avg=[]; %Average outside temperature for the cycle
time_start=[]; %Time when the cycle started
cycle_length=[]; %Time length of the DHW heating cycle
P_out_avg=[]; %Average output power during the cycle
for i = 1:length(x) %x represents the time axis
    DHW = Flow_DHW(i)>3; %Analyze the status of heating DHW (DHW is heated when the pump is running, i.e. when there is flow)
    if (DHW_previous==false) && (DHW==true) %if DHW heating started, remember when it started
        i_start=i;
    end
    if (DHW_previous==true) && (DHW==false) %if DHW heating ended, process the cycle
        if (x(i)-x(i_start))*24<10 %Only process the cycle if it's length was less than 10 hours, because otherwise it means it is spanning a gap in data (whcih occured on 3/12/2015)
            P_input_avg=nanmean(P_input_HP1(i_start:(i-1)));
            P_output_avg=nanmean(P_output_HP1(i_start:(i-1)));
            if P_output_avg>0000 %only store samples with output power above certain threshold (set threshold to 0 for all samples)
                COP_avg=[COP_avg, P_output_avg/P_input_avg];
                T_out_avg=[T_out_avg, mean(T_Outside(i_start:(i-1)))];
                time_start=[time_start, x(i_start)];
                cycle_length=[cycle_length, (x(i)-x(i_start))*24];
                P_out_avg=[P_out_avg, P_output_avg];
            end
        end
    end
    DHW_previous=DHW; %remember the status of the DHW heating
end

%plot(T_out_avg,P_out_avg,'.');
%xlabel('average outdoor temperature [F]');
%ylabel('Average output power [W]');
%return;


if 1 %Use "1" if this plot is done as a part of a larger plot that is combining plots from several programs
    plot(T_out_avg,COP_avg,'.r','MarkerSize',15);
else
    figure('units','normalized','outerposition',[0 0 1 1]);
    %Plot the first graph:
    plot1=subplot(2,1,1);
    plot(T_out_avg,cycle_length,'.');
    xlabel('average outdoor temperature [F]');
    ylabel('cycle length [h]');
    grid on;
    %Plot the second graph:
    plot2=subplot(2,1,2);
    plot(T_out_avg,COP_avg,'.');
    xlabel('average outdoor temperature [F]');
    ylabel('average COP');
    grid on;
end
