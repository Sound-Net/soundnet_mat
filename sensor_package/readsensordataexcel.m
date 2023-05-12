%%read sensordata and save to excel spreadsheet. 
clear

% % 2023-02-26
% folder = '/Users/au671271/Library/CloudStorage/OneDrive-UniversityofStAndrews/Drifting Array (WP1b)/Data/Towing and float tests/Sensor data/20230226_repair';
% folder  = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230226_repair';
% timelims = [datenum('20230226 00:00:00', 'yyyymmdd HH:MM:SS'), datenum('20230227 00:00:00', 'yyyymmdd HH:MM:SS')];
% 
% folder  = '/Users/au671271/Library/CloudStorage/OneDrive-UniversityofStAndrews/Drifting Array (WP1b)/Data/Towing and float tests/Sensor data/20230227_repair';
%  folder  = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230227_repair';
% % folder  = '/Users/au671271/Library/CloudStorage/OneDrive-UniversityofStAndrews/Drifting Array (WP1b)/Data/Towing and float tests/Sensor data/test2';
% timelims = [datenum('20230227 00:00:00', 'yyyymmdd HH:MM:SS'), datenum('20230228 00:00:00', 'yyyymmdd HH:MM:SS')];


% folder  = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230228_repair';
% timelims = [datenum('20230228 00:00:00', 'yyyymmdd HH:MM:SS'), datenum('20230229 00:00:00', 'yyyymmdd HH:MM:SS')];
% 

folder = 'C:\Users\Jamie Macaulay\OneDrive - University of St Andrews\Drifting Array (WP1b)\Data\Towing and float tests\Sensor data\20230302-03_repair';
timelims = [datenum('20230302 00:00:00', 'yyyymmdd HH:MM:SS'), datenum('20230304 00:00:00', 'yyyymmdd HH:MM:SS')];


% x = importSensorPckgFile2('/Users/au671271/Desktop/test_sensorpackage_data/59277366_20230207_121409_840.csv'
% convert csv files to one matlab struct
[sensordata] = sensorcsv2mat(folder, '',timelims);

sensordata = sortsensormat(sensordata, timelims);

%plot the sensor data
clf
plot_sensor_data(sensordata); 

%save as .mat file
save(fullfile(folder, 'sensordata.mat'));

%save as excel file
sensormat2excel(fullfile(folder, 'sensordata.xlsx'), sensordata);

h2 = findall(groot,'Type','figure');
for i=1:length(h2)
    saveas(h2(i), fullfile(folder, ['sensordata_figure_' num2str(i) '.png'])); 
    saveas(h2(i), fullfile(folder, ['sensordata_figure_' num2str(i) '.fig'])); 
end






