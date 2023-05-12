 function [sensordata] = sensorcsv2mat(csvfolder, filemask, timelims)
%SENSORCSV2MAT Reads data from sensor package .csv file and converts in
%MATLAB datenum stamped .mat file structures with different data streams.

% csvfolder='E:\Google Drive\SMRU_research\Gill nets 2016\SoundTrap_4c\20180821_wet_test_Kyle_of_Lochalsh\1678032921\sensor_package\20180822\'; 
% csvfolder = '/Users/au671271/Desktop/test_sensorpackage_data';

if nargin<2 
     filemask = '';
end

if nargin<3
 timelims=[]; 
end

flags={'EL','BAT','PT','RGB', 'LSP'}; % the sensor package flags

%find all .csv files
[files] = dir(csvfolder);

sensordatacell={};
for i=1:length(files)
    if (files(i).isdir)
        continue;
    end
    [~,name,ext]=fileparts(files(i).name);
    % filter by both csv file type and contains xsens in the name (because 
    % there can also be temp and accel files recorded by soundtraps)
    if (strcmp(ext,'.csv') && contains(name, filemask) && files(i).name(1)~='.')
        try

            endofile = false;

            startrow = 1;
            endrow = 5000; 
            count =1; 
            while ~endofile || count==1
           
            newdata=importSensorPckgFile2(fullfile(csvfolder,files(i).name), startrow, endrow);
            
%             % for some reason we get a few cells that have say one more
%             % data point than the other cell, probably just a silly csv
%             % blank space thin...            
%             for j=1:length(newdata)
%                 minsize(j)=length(newdata{j});
%             end
%             minlen=min(minsize);
%             %now trim the cells
%             for j=1:length(newdata)
%                 newdata{j}=newdata{j}(1:minlen);
%             end
%             %should now always convert to cell array 
%             newdata=[newdata{:,1:8}]; %need to trim off the end cells which are somtimes just blank columns 
            if (isempty(newdata))
                endofile = true; 
                continue; 
            end

            starttime = ''; 
            %%filter data by timelimits so for very large .csv files we
            %%don't end up with loads of data we dont' want
             if (~isempty(timelims)) 
                 matdatatimes = unixtime2mat(cell2mat(newdata(:,1))); 
                 ind = matdatatimes>=timelims(1) & matdatatimes<=timelims(2); 
                 newdata= newdata(ind,:); 

                 if (~isempty(matdatatimes))
                    starttime =   datestr(matdatatimes(1));
                 end
             end



            [sensordatacell]=[sensordatacell; newdata];
            disp(['Opening: ' files(i).name ' ' num2str(i) ...
                ' of ' num2str(length(files)) ' no. ' num2str(length(newdata))...
                '  row: ' num2str(startrow) ' to ' num2str(endrow) ' ||| Data size: ' ...
                num2str(length(sensordatacell)) ' Chunk time: ' starttime])

            startrow = endrow+1; 
            endrow = startrow + 5000; 
            count = count+1; 

            end

        catch ME
            disp(['Opening: ' files(i).name ' ' num2str(i) ' of ' num2str(length(files))])
            disp('COULD NOT OPEN FILE  ^');
            rethrow(ME)
        end
    end
end

% matdata = struct('names',flags);

%go through the sensor data and extract the relevent data streams.
for i=1:length(flags)
    % load sensor data from the cell array
     [sensordatout, timesdatenum, format] = filtersensordat(sensordatacell, flags{i});

     if (format == 1)
        dataind = 3;
     else
        dataind = 2; 
     end
    
    if (~strcmp('BAT', flags{i}) && ~isempty(sensordatout)) %TEMP because voltage is not read in ST firmware yet.
        %all other flags bar BAT
        for j=dataind:length(sensordatout(1,:))
            index=find(sensordatout(:,j)~=0);
            sensordatout = sensordatout(index,:);
        end
    end
    
    if (strcmp('EL', flags{i}) && ~isempty(sensordatout)) 
        for j=dataind:length(sensordatout(1,:))
            index=find(sensordatout(:,j)<180 & sensordatout(:,j)>-180 & ...
                sensordatout(:,j)~=0);
            sensordatout = sensordatout(index,:);
        end
    end
    
    switch (flags{i})
        case 'EL' 
            sensordata.EL=sensordatout;
        case 'BAT'
            sensordata.BAT=sensordatout;
        case 'RGB'
            sensordata.RGB=sensordatout;
        case 'PT'
            sensordata.PT=sensordatout;
        case 'LSP'
            sensordata.LSP=sensordatout;
    end

    sensordata.format = format;
    
end

end

