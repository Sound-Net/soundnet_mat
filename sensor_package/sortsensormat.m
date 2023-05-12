function [sensormat] = sortsensormat(sensormat, timelims)
%SORTSENSORMAT Sort the times for the sensor structure 

sensormat.EL = sorttimes(sensormat.EL, timelims); 
sensormat.RGB = sorttimes(sensormat.RGB, timelims); 
sensormat.LSP = sorttimes(sensormat.LSP, timelims); 
sensormat.PT = sorttimes(sensormat.PT, timelims); 
sensormat.BAT = sorttimes(sensormat.BAT, timelims); 

    function sensdata = sorttimes(sensdata, timelims)
        if (isempty(sensdata))
            return
        end
        [~, ind]= sort(sensdata(:,1)); 
        sensdata = sensdata(ind,:); 

        ind = sensdata(:,1)>timelims(1) & sensdata(:,1)<=timelims(2); 

        sensdata = sensdata(ind,:); 

    end


end

