%folder where the csv files are located. 
csvfolder = '/Volumes/GoogleDrive/My Drive/SMRU_research/Gill nets 2016-20/SoundTrap_4c/20181002_Cornwall_AK580_H3/1678032921/sensor_data'; 
csvfolder = '/Users/au671271/Desktop/test_sensorpackage_data';
csvfolder='/Users/au671271/Library/CloudStorage/OneDrive-UniversityofStAndrews/Drifting Array (WP1b)/Sensor_Packages/Example files_2';

files  = dir(csvfolder);
hellodata = importSensorPckgFile2(fullfile(files(3).folder, files(3).name)); 


% x = importSensorPckgFile2('/Users/au671271/Desktop/test_sensorpackage_data/59277366_20230207_121409_840.csv'
% convert csv files to one matlab struct
[sensordata] = sensorcsv2mat(csvfolder);

%plot the sensor data
plot_sensor_data(sensordata); 
