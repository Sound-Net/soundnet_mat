function [] = plot_sensor_data(sensordataStruct, startdate, enddate, linewidth)
% %PLOT_SENSOR_DATA Plot sensor data from the soundtrap
%
if nargin<3
    startdate = -inf;
    enddate = inf;
end

if nargin<4
    linewidth = 1;
end

if sensordataStruct.format ==1
    startind = 3;
else 
    startind = 2;
end

%% pressure
if (~isempty(sensordataStruct.PT))
    figure(1);
    clf
    yyaxis left
    sensordata=sensordataStruct.PT;
    sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );
    plot(sensordata(:,1), millibar2depth(sensordata(:,startind)), 'LineWidth', linewidth);
    ylabel('Depth (meters)')
    ylim([0,100]);
    yyaxis right
    plot(sensordata(:,1),sensordata(:,startind+1));
    xlim([startdate, enddate])
    ylim([-4,30]);
    datetick x;
    ylabel('Temeprature (Celsuis)')
    hold off
end
%% battery
if (~isempty(sensordataStruct.BAT))
    figure(2);
    clf
    sensordata=sensordataStruct.BAT;
    sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );
    plot(sensordata(:,1),sensordata(:,startind), 'LineWidth', linewidth);
    xlim([startdate, enddate])
    ylabel('Battery (%)')
end

%% eular angles
if (~isempty(sensordataStruct.EL))
    figure(3);
    sensordata=sensordataStruct.EL;
    sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );
    for i=startind:length(sensordata(1,:))
        if (i==3 || i==2 || i==4)
            angle = medfilt1(sensordata(:,i),3); %matlab wizarddry to remove spikes
        else
            angle = sensordata(:,i);
        end
        plot(sensordata(:,1), angle, 'LineWidth', linewidth)
        hold on
    end
    legend('roll', 'pitch', 'heading');
    xlim([startdate, enddate])
    datetick x;
    ylabel('angle (degrees)')
    %should filter zeros
    ylim([-180, 180]);
    hold off
end

%light sensors
if (~isempty(sensordataStruct.RGB))
    sensordata=sensordataStruct.RGB;
    sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );

    if (~isempty(sensordata))
        figure(4);

        for i=startind:length(sensordata(1,:))
            plot(sensordata(:,1), sensordata(:,i), 'LineWidth', linewidth)
            hold on
        end
        legend('red', 'green', 'blue');
        ylabel('light level (relative)')
        xlim([startdate, enddate])
        datetick x;
        %should filter zeros
        ylim([0,80]);
        hold off
    else
        disp('No light data in this time period')
    end

end


%light sensors
if (~isempty(sensordataStruct.LSP))

    nonometers = [415, 445, 480, 515, 555, 590, 630, 680];

    sensordata=sensordataStruct.LSP;
    sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );

    if (~isempty(sensordata))
        figure(4);

        for i=3:length(sensordata(1,:))-2
        
            if (i<=length(nonometers))
                   col = wavelength2color(nonometers(i)); 
            end
            plot(sensordata(:,1), sensordata(:,i), 'LineWidth', linewidth, 'Color', col); 

            hold on
        end
        legend({'415nm', '445nm', '480nm', '515nm', '555nm', '590nm', '630nm', '680nm'});
        ylabel('Spectral level (relative)')
        xlim([startdate, enddate])
        datetick x;
        %should filter zeros
        hold off
    else
        disp('No light data in this time period')
    end
end


end

