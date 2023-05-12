function [] = sensormat2excel(excelfileroot, sensordata)
%SENSORCSV2MAT Reads data from sensor package .mat file and converts in
%EXCEL datenum stamped excel workbook where each sheet is a data stream

MAXROW= 1e6; %excel spreadsheets can only handle 1 millions rows.

% assume the orientation data has the highest samplerate.
ndatapoints = length(sensordata.EL(:,1));

sensorTableEL = array2table(sensordata.EL,"VariableNames",["Time","Heading (degrees)‚","Pitch (degrees)", "Roll (degrees)"]);
sensorTableEL{:,1} = sensorTableEL{:,1} - 693960;


sensorTableBAT = array2table(sensordata.BAT,"VariableNames",["Time","Percentage", "Voltage (V)"]);
sensorTableBAT{:,1} = sensorTableBAT{:,1} - 693960;


sensorTablePT = array2table(sensordata.PT,"VariableNames",["Time","Depth (m)", "Temperature (Celsuis)"]);
sensorTablePT{:,2} = millibar2depth(sensorTablePT{:,2});
sensorTablePT{:,1} = sensorTablePT{:,1} - 693960;


lightlevels = {'Time', '415nm', '445nm', '480nm', '515nm', '555nm', '590nm', '630nm', '680nm', 'Clear', 'NIR'};
sensorTableLSP = array2table(sensordata.LSP,"VariableNames",lightlevels);
sensorTableLSP{:,1} = sensorTableLSP{:,1} - 693960;


%now write multiple spreadsheets if needed - eqach spreadsheet is a chunk
%of one million data points.

startrow = 1;
while startrow<ndatapoints

    [filepath,name,ext] = fileparts(excelfileroot);
    
    excelfile = fullfile(filepath, [datestr(sensorTableEL{startrow,1}+693960, ...
        'yyyymmdd_HHMMSS') '_' name ext]);


   [filepath,name,ext] = fileparts(excelfile);


    disp(['Writing data points to ' name ext])

    endrow = min(ndatapoints, startrow+MAXROW);

    writetable(sensorTableEL(startrow:endrow,:),excelfile,'Sheet','Orientation');

    %now we assume the data rate of all the rest of the data streams is
    %less than orientation and we now have to find the correct indexes.

    batind = sensordata.BAT(:,1)>=sensordata.EL(startrow, 1) & sensordata.BAT(:,1)<sensordata.EL(endrow, 1); 
    writetable(sensorTableBAT(batind,:),excelfile,'Sheet','Battery'); 

    ptind = sensordata.PT(:,1)>=sensordata.EL(startrow, 1) & sensordata.PT(:,1)<sensordata.EL(endrow, 1); 
    writetable(sensorTablePT(ptind,:),excelfile,'Sheet','Depth-Temp');

    lspind = sensordata.LSP(:,1)>=sensordata.EL(startrow, 1) & sensordata.LSP(:,1)<sensordata.EL(endrow, 1); 
    writetable(sensorTableLSP(lspind,:),excelfile,'Sheet','Light Spectrum');

    startrow = startrow+MAXROW+1;

end


end

