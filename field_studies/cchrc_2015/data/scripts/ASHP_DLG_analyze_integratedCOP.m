clear;

%load 'x','T_deliv','T_return','T_coil','T_out','P_input','Airflow','P_output':
load('CR1000_DLG_DHP_TenSecond_1min.mtl','-mat');

logging_interval=(x(2)-x(1))*24; %Calculate the logging interval (in hours) from the first two time stamps

defrost_previous=false; %The defrost status in the previous run of for cycle - set the initial value to false (i.e. no defrost)
i_start=1; %The first heat pump cycle starts at index 1
COP_avg=[]; %start COP_avg as an empty array and then keep adding to it as calculating average COP's for new cycles
T_out_avg=[]; %Average outside temperature for the cycle
time_start=[]; %Time when the cycle started
cycle_length=[]; %Time length of the cycle
P_out_avg=[]; %Average output power during the cycle
for i = 1:length(x) %x represents the time axis
    defrost = (T_coil(i)>(T_out(i)+10)) & (P_input(i)>100); %Analyze the status of defrost
    defrost = defrost | (P_input(i)<25); %Heat pump not running can be considered "defrosting" for the purpose of studying cycles (when the programmable themrmostat turns on in the morning, it should be counted as start of cycle)
    if (defrost_previous==false) && (defrost==true) %if defrost started, remember when it started
        i_defrost_start=i;
    end
    if (defrost_previous==true) && (defrost==false) %if defrost ended, process the cycle
        if Airflow(i-1)>0 %if the defrost that just eneded wasn't a real defrost and it was just heat pump in minimum flow waiting for thermostat call, then don't count this cycle and neither next cycle (see 12/23 15:00 for such situation)
            i_start=1; %this will make sure that the next cycle is not counted becuase it will be too long
        else
            if ((x(i)-x(i_start))*24<10) && ((x(i)-x(i_start))*24>0.2) %if the length of the cycle is too long or too short, then it is not a real cycle, so don't record it
                if (x(i)-x(i_defrost_start))*24*60<8 %if the length of the defrost is too long, then it is not a real defrost, so don't count the cycle
                    %E_input=nansum(P_input(i_start:(i-1)))*logging_interval/1000; %Energy input in kWh
                    %E_output=nansum(P_output(i_start:(i-1)))*logging_interval/1000; %Energy output in kWh
                    P_input_avg=nanmean(P_input(i_start:(i-1)));
                    P_output_avg=nanmean(P_output(i_start:(i-1)));
                    if P_output_avg>000 %only store samples with output power above certain threshold (set threshold to 0 for all samples)
                        COP_avg=[COP_avg, P_output_avg/P_input_avg];
                        T_out_avg=[T_out_avg, mean(T_out(i_start:(i-1)))];
                        time_start=[time_start, x(i_start)];
                        cycle_length=[cycle_length, (x(i)-x(i_start))*24];
                        P_out_avg=[P_out_avg, P_output_avg];
                    end
                end
            end
            i_start=i; %remember when the new cycle started
        end
    end
    defrost_previous=defrost; %remember the status of the defrost
end

%plot(T_out_avg,P_out_avg,'.');
%xlabel('average outdoor temperature [F]');
%ylabel('Average output power [W]');
%return;

if 0 %Use "1" if this plot is done as a part of a larger plot that is combining plots from several programs
    plot(T_out_avg,COP_avg,'.m','MarkerSize',15);
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
