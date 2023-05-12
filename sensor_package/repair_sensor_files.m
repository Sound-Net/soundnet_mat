% rename csv files that have a corrupted filename. Name the file based on
% the first dtaa point in the file.

%%%%INPUTS%%%%%
%%folder to repair and the sensor package ID
folder = '/Users/au671271/Library/CloudStorage/OneDrive-UniversityofStAndrews/Drifting Array (WP1b)/Data/Towing and float tests/Sensor data/20230226/';
folder = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230227';
folder = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230228\';
% folder = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230302-03';

ID  = 59257368;


%%%%RUN CODE%%%%%

%create new folder neame
if (strcmp(folder(end), '\') || strcmp(folder(end), '/'))
    folderout = [folder(1:end-1) '_repair'];
else
    folderout = [folder '_repair'];

end

%create the folder
mkdir(folderout);

files = dir(folder);

%iterate through all the files repairing the fielnames if needed
for i=1:length(files)

    disp(['Checking file: ' num2str(i) ' of ' num2str(length(files))]);

    %basic checks
    if (files(i).bytes ==0|| files(i).isdir)
        continue;
    end

    [filepath,name,ext]  = fileparts(fullfile(files(i).folder, files(i).name));

    try
        %does the filename need repaired
        if (length(files(i).name)>22 && strcmp(ext, '.csv') )
            filename = files(i).name;
        else
            disp(['Repairing file: ' files(i).name])
            data = fopen(fullfile(files(i).folder, files(i).name));
            A = textscan(data,'%s','Delimiter','\n');

            B = A{1,1};
            datarow = textscan(B{1,1},'%s','Delimiter',',');

            fclose(data);

            unixtime = str2num(datarow{1}{1});
            millis = round(str2num(datarow{1}{2})/1000);


            datenumtime = unixtime2mat(unixtime)+ millis/1000/60/60/24;

            timestring = datestr(datenumtime, 'yyyymmdd_HHMMSS_FFF');

            filename = [num2str(ID) '_' timestring '.csv'];
        end
        copyfile(fullfile(files(i).folder, files(i).name), fullfile(folderout, filename));

    catch e
        disp(e);
    end

end