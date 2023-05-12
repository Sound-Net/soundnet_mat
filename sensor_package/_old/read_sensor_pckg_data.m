%% reads all sensor pacakage data from a folder. 

clear 
clf

% folder='I:\SoundNet\4chan\20170819 St As Bay\134250533\'; 
% folder='F:\20170107 st4 Largs\benchtest\xsens_wav_sync_test\1678032921'; 
%  folder = 'F:\4 channel soundtrap data\AK556 H2';
% folder='E:\Google Drive\SMRU_research\Gill nets 2016\SoundTrap4c_wet_test_gillnet_1\sensor\'; 
% folder='H:\SoundTrap 4c\2018-05-03_pool_test\1678032921\';
% folder='E:\Google Drive\SMRU_research\Gill nets 2016\SoundTrap_4c\20180524_wet_test_6_STA_bay\Sensor_Package\';
% folder='C:\Users\jamie\Desktop\134250533\'; 
% folder='F:\SoundNet\4chan\20180822_KyleofLocahlsh_test\134250533\'; 
fodler='E:\Google Drive\SMRU_research\Gill nets 2016\SoundTrap_4c\20181130_Cornwall_AK587_H5\134250533\sensor_data';

%find all .csv files
[files] = dir(folder);
flag='RGB';

sensorData={}; 
for i=1:length(files)
    if (files(i).isdir) 
        continue; 
    end
    [pathstr,name,ext]=fileparts(files(i).name); 
    if (strcmp(ext,'.csv'))
        disp(['Opening: ' files(i).name ' ' num2str(i) ' of ' num2str(length(files))])
        try
        [sensorData]=[sensorData; importSensorPckgFile([folder '\' files(i).name])];
        catch ME
            disp('COULD NOT OPEN FILE  ^');
%             rethrow(ME)
        end
    end
end

disp('Finished loading from .csv: Formatting');

% load sensor data from the cell array 
[sensordatout, hello] = filtersensordat(sensorData, flag);

if (~strcmp('BAT', flag)) %TEMP because voltage is not read in ST firmware yet. 
for i=2:length(sensordatout(1,:))
index=find(sensordatout(:,i)~=0);
sensordatout = sensordatout(index,:);
end
end

if (strcmp('PT', flag))
    yyaxis left
    fig=plot(sensordatout(:,1),sensordatout(:,2));
    ylabel('Pressure (mbar)')
    yyaxis right
    plot(sensordatout(:,1),sensordatout(:,3));
    ylabel('Temeprature (Celsuis)')
    
elseif (strcmp('BAT', flag))
    yyaxis left
    fig=plot(sensordatout(:,1),sensordatout(:,2));
    ylabel('Battery (%)')
    yyaxis right
    plot(sensordatout(:,1),sensordatout(:,3));
    ylabel('Voltage (V)')
else
    % subplot(2,1,1)
    fig=figure(1);
    for i=2:length(sensordatout(1,:))
        plot(sensordatout(:,1), sensordatout(:,i))
        hold on
    end
end

if (strcmp('QT', flag))
    legend('X' ,'Y',  'Z', 'W');
    ylabel('quaternion value')
    ylim([-1, 1]);
elseif (strcmp('EL', flag))
    legend('heading', 'pitch', 'roll');
    ylabel('angle (degres)')
    %should filter zeros
    ylim([-180, 180]);
elseif (strcmp('RGB', flag))
    legend('red', 'blue', 'green');
    ylabel('Intensity (relative)')
end
xlabel('time')
datetick x
%set the 
dcm_obj = datacursormode(fig);
dcm_obj.UpdateFcn = @datestrTxt;

time=sensordatout(length(sensordatout(:,1)),1)-sensordatout(1,1);
disp(['The total time of sensor package recording was ' num2str(time*24) ' hours ' ])

% subplot(2,1,2)
% plot(timedpth, depthData)
% xlabel('time')
% ylabel('depth' )




