function dynamicDataDisplayJNU2(axH)
%DYNAMICDATADISPLAYJNU2 is a function for the ASHP program for Juneau for heat pump 2. This function
%displays performance characteristics (energy input, energy output, COP,
%etc.) for the interval that the user zooms onto in the graph. It is
%displayed above the graph and updates with every zoom and pan.
%The input of the function is the handle for the axis that is analyzed and
%above which the data is to be displayed.

figH = get(axH, 'Parent'); %get the handle for the figure in which the axis is
z = zoom(figH);
p = pan(figH);
oldCallback=get(z,'ActionPostCallback'); %Save the handle for the old callback function to use later
set(z,'ActionPostCallback',@displayData);
set(p,'ActionPostCallback',@displayData);
displayData('',struct('Axes',axH)); % Call displayData once to display data initially

% ------------ End of dynamicDataDisplay -----------------------

    function displayData(obj,ev,varargin)%This callback function displays performance characteristics (energy input, energy output, COP,etc.).
        oldCallback(obj,ev,varargin{:}); %Call the old callback first (might, e.g., display date ticks on exes).
        
        global x logging_interval T_Outside P_input_HP2 P_output_HP2; %These were created in the ASHP program and now they are needed here.
        
        %Find the currently displayed interval on the x axis:
        xLimits=xlim(axH);
        i1=find(x>xLimits(1),1,'first'); %Index for the beginning of the interval
        i2=find(x<xLimits(2),1,'last'); %Index for the end of the interval
        
        %Calculate performance characteristics for the displayed interval:
        E_input=nansum(P_input_HP2(i1:i2))*logging_interval/1000; %Energy input in kWh
        E_output=nansum(P_output_HP2(i1:i2))*logging_interval/1000; %Energy output in kWh
        COP=E_output/E_input; %COP
        Avg_T_out=nanmean(T_Outside(i1:i2)); %Average outside temperature
        
        %Display the performance characteristics above the graph:
        title(axH,sprintf('Data for the displayed interval:      Energy input = %.2f kWh;   Energy output = %.2f kWh;   {\\bfCOP = %.3f};   Average outside T = %.2f F'...
            ,E_input,E_output,COP,Avg_T_out));
    end

end

