function [sensordatout, secondsdatenum, format] = filtersensordat(sensorData, flag)
%FILTERSENSORDAT Finds a measurement type based on a string type
%   [SENSORDATOUT] = FILTERSENSORDAT(SENSORDATA, FLAG) extracts raw cell
%   data which correspnds to the desired FLAG from the sensor package along
%   with a time stamp. Flags can be ET= Euler angles, QT - quaternion
%   angle, PT - pressure time, TT - adv. temperature sensor.

% There are two file formats for sensor package data
%Format 1 - unix time, microseconds, audio_samples, falg, [data] (for SoundNet)
%Format 2 - unix time, microseconds, flag, [data] (for data loggers)


%first find the format
if (isnan(str2double(sensorData{1,4})))
    format = 2;
    flagind = 3;
else
    format = 1;
    flagind =4;
end
dataind = flagind+1; 

n=1;
indexAngle=zeros(length(sensorData(:,1)),1);
N=length(sensorData(:,1));
for i=1:N
    if (mod(i,100)==0)
        disp(['Extracting ' flag ' flag from sensor data ' num2str(100*(i/N)) '%'])
    end
    if (strcmp(sensorData{i,flagind}, flag))
        indexAngle(n)=i;
        n=n+1;
    end
end

indexAngle=indexAngle(1:n-1);

% indexAngle=indexAngle(1:n-1);
sensDat=sensorData(indexAngle,:);

if (isempty(sensDat))
    sensordatout=[]; 
    secondsdatenum=[]; 
end


% time
time=cell2mat(sensDat(:,1));
timemicro=cell2mat(sensDat(:,2));

if (format==1)
    timesample=cell2mat(sensDat(:,3));
end

%convert the time properly to MATLAB datenum
timemat=zeros(length(time),1);
for i=1:length(time)
    secondsdatenum(i)= timemicro(i)/1000000;  %microseconds since the unix time second
    if (secondsdatenum(i)>1)
        warning(['Seconds greater than 1: ' num2str(secondsdatenum(i))])
    end
    timemat(i)=unixtime2mat(time(i)) + secondsdatenum(i)/60/60/24;
end

if (strcmp(flag, 'EL'))
    %remove any random values which are not numeric - sometimes happens
    %with corrupted data.
    sensDatNumeric = sensDat(:,dataind:dataind+2);
    n=1;
    indexremove=[];
    for i=1:length(sensDatNumeric)
        for j=1:length(sensDatNumeric(i,:))
            if ~isnumeric((cell2mat(sensDatNumeric(i,j))))
                indexremove(n)=i;
                n=n+1;
                break;
            end
        end
    end
    sensDat(indexremove,:)=[];
    timemat(indexremove)=[];
    if (format==1)
        timesample(indexremove)=[];
    end
end

%now convert to correct format
switch (flag)
    case 'EL' %Euler Angles
        dataout=cell2mat(sensDat(:,[dataind:dataind+2]));
    case 'QT' %Quaternion
        dataout=cell2mat(sensDat(:,[dataind:dataind+3]));
    case 'PT'%Pressure temeprature
        dataout=cell2mat(sensDat(:,[dataind:dataind+1]));
    case 'TT' %Temperature fine scale
        dataout=cell2mat(sensDat(:,[dataind:dataind+1]));
    case 'BAT' % Battery level
        dataout=cell2mat(sensDat(:,[dataind:dataind+1]));
    case 'RGB' %Light sensor
        dataout=cell2mat(sensDat(:,[dataind:dataind+2]));
    case 'LSP' %Light spectrum sensor
        dataout=cell2mat(sensDat(:,dataind:dataind+9));
end

% %filter out corrupt zero values
% for i=2:length(dataout(1,:))
%     indexzero=find(dataout(:,i)==0);
%     timemat(indexzero,:)=[];
%     dataout(indexzero,:)=[];
% end


%retunr the data out
if format ==1
    sensordatout =[timemat timesample dataout];
else
    sensordatout =[timemat dataout];
end

% timemat=unixtime2mat(1517674842)+(651846/1000000)/24/24/60;
% datestr(timemat)

end

