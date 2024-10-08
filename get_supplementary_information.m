function tableSI4 = get_supplementary_information(file_path)
% This function imports supplementary information from an Excel spreadsheet and
% processes the data into a structured table. The data contains information such as
% taxa, living/non-living status, planktonic functional types, and carbon conversion
% parameters. The function reads the specified worksheet from the Excel file, 
% handles missing data, and organizes it into a MATLAB table for further analysis.
%
% Inputs:
%   - file_path (string): The full path to the Excel file containing the supplementary data.
%
% Outputs:
%   - tableSI4 (table): A MATLAB table with the following columns:
%       - taxa (string): The taxonomic name of the organism.
%       - livingnonliving (categorical): The status of the organism as living or non-living.
%       - planktonicfunctionaltype (categorical): The functional type of the plankton.
%       - trophicgroup (double): The trophic group of the organism.
%       - ascallingparameterforcarbonconvertion (double): Scaling parameter for carbon conversion.
%       - bexponentforcarbonconvertion (double): Exponent for carbon conversion.
%
% Example:
%   tableSI4 = get_supplementary_information('/path/to/table SI-4.xlsx');
%
% In this example, the function imports data from the Excel file `table SI-4.xlsx`
% located at the specified path and returns the structured table `tableSI4` with the
% relevant supplementary information.

    %% Import the data
    [~, ~, raw] = xlsread(file_path,'Sheet1');
    raw = raw(2:end,:);
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    stringVectors = string(raw(:,[1,2,3]));
    stringVectors(ismissing(stringVectors)) = '';
    raw = raw(:,[4,5,6]);

    %% Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells

    %% Create output variable
    data = reshape([raw{:}],size(raw));

    %% Create table
    tableSI4 = table;

    %% Allocate imported array to column variable names
    tableSI4.taxa = stringVectors(:,1);
    tableSI4.livingnonliving = categorical(stringVectors(:,2));
    tableSI4.planktonicfunctionaltype = categorical(stringVectors(:,3));
    tableSI4.trophicgroup = data(:,1);
    tableSI4.ascallingparameterforcarbonconvertion = data(:,2);
    tableSI4.bexponentforcarbonconvertion = data(:,3);

    %% Clear temporary variables
    clearvars data raw stringVectors R;
    
end