function TARAlocsdate = importfile(filename, startRow, endRow)
% This function imports numeric and textual data from a CSV file, converting it 
% into a MATLAB table. The function reads data from the specified file, starting 
% at `startRow` and ending at `endRow`, and processes the columns to extract
% station, latitude, longitude, and date-related information. It handles non-numeric
% text and missing values, replacing them with `NaN` where applicable.
%
% Inputs:
%   - filename (string): The full path to the CSV file to be imported.
%   - startRow (integer): The row number to start reading from (default is 1).
%   - endRow (integer): The row number to stop reading at (default is until the end of the file).
%
% Outputs:
%   - TARAlocsdate (table): A MATLAB table with the following columns:
%       - VarName1: The first column of the dataset (numeric data).
%       - Station: Station identifier (numeric data).
%       - Latitude: Latitude of the station (numeric data).
%       - Longitude: Longitude of the station (numeric data).
%       - year: Year of the event (numeric data).
%       - month: Month of the event (numeric data).
%
% Example:
%   TARAlocsdate = importfile('TARA_locs_date.csv', 1, 211);
%
% In this example, the function reads data from the file 'TARA_locs_date.csv',
% starting at row 1 and ending at row 211, and returns the data in a table.
%
% Notes:
% - The function is auto-generated based on the structure of the specific CSV file,
%   and may require adjustments if the file format changes.
% - Non-numeric cells are automatically replaced with `NaN`.
% - The file is assumed to be comma-delimited (CSV format).

%% Initialize variables.
    delimiter = ',';
    if nargin<=2
        startRow = 1;
        endRow = inf;
    end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
    formatSpec = '%q%q%q%q%q%q%[^\n\r]';

%% Open the text file.
    fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
    dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for block=2:length(startRow)
        frewind(fileID);
        dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        for col=1:length(dataArray)
            dataArray{col} = [dataArray{col};dataArrayBlock{col}];
        end
    end

%% Close the text file.
    fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));

    for col=[1,2,3,4,5,6]
        % Converts text in the input cell array to numbers. Replaced non-numeric
        % text with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1)
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData(row), regexstr, 'names');
                numbers = result.numbers;

                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if numbers.contains(',')
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'))
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric text to numbers.
                if ~invalidThousandsSeparator
                    numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch
                raw{row, col} = rawData{row};
            end
        end
    end

%% Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
    TARAlocsdate = table;
    TARAlocsdate.VarName1 = cell2mat(raw(:, 1));
    TARAlocsdate.Station = cell2mat(raw(:, 2));
    TARAlocsdate.Latitude = cell2mat(raw(:, 3));
    TARAlocsdate.Longitude = cell2mat(raw(:, 4));
    TARAlocsdate.year = cell2mat(raw(:, 5));
    TARAlocsdate.month = cell2mat(raw(:, 6));

