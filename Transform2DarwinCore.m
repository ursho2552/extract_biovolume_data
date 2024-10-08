%% Prepare working environment and Read in imaging dataset

clear all

working_directory = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data';
addpath(genpath(working_directory))

cd(working_directory)

%%
load('Biovolume_data/MergedbaseC.mat', 'Mergedbase')

MergedbaseC = Mergedbase;

load('Biovolume_data/Mergedbase.mat', 'Mergedbase')

%%
all_values = [];
all_names = string([]);

instruments = string(["flowcyto", "IFCB", "Flowcamb20", "FlowcamNiskin", "UVP", "WP2", "bongo", "regent", "H20", "H5"]);%

for i = 1:length(instruments)
    
    disp('Getting values for '+ instruments(i))
    [values, names] = get_tot_values(Mergedbase, MergedbaseC, instruments(i));
    
     
    all_values = [all_values; values];
    all_names = [all_names; names];
    
    disp('done ')
end

%% Extend data

%load data
tara_stations = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data/Biovolume_data/TARA_locs_date.csv';
TARAlocsdate = importfile(tara_stations, 1, 211);

% go through each entry and extend the data if possible
rows = size(all_values,1);

for i = 1:rows
    if isnan(all_values(i,2))
        
        station = all_values(i,1);
        all_values(i,2) = Mergedbase(station).hydro.Latitude;
        all_values(i,3) = Mergedbase(station).hydro.Longitude;
        
%         all_values(i,2) = TARAlocsdate.Latitude(station);
%         all_values(i,3) = TARAlocsdate.Longitude(station);
       
    end
    
    if isnan(all_values(i,4))
        
        station = all_values(i,1);
        all_values(i,4) = TARAlocsdate.year(station);
        all_values(i,5) = TARAlocsdate.month(station);
        all_names(i,2) = sprintf('%04d-%02d-%02dT00:00:00', all_values(i,4), all_values(i,5), 0);
    end
end

%% Get carbon and regroupped data for each entry

supplementary_file = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data/Biovolume_data/table SI-4.xlsx';
table_supplement = get_supplementary_information(supplementary_file);

% Remove duplicate rows based on all columns
[table_supplement, ia] = unique(table_supplement, 'rows', 'stable');

%%
unique_names = unique(all_names(:,1));
regroupped_data_str = strings(rows, 2);
regroupped_data_float = NaN(rows, 4);

for i = 1:length(unique_names)
    
    indeces = find(all_names(:,1)==unique_names(i));
        
    idx_supplement = find(table_supplement.taxa==unique_names(i));

    if size(idx_supplement,1) > 0
        tmp_strings = repmat([table_supplement.livingnonliving(idx_supplement),...
        table_supplement.planktonicfunctionaltype(idx_supplement)], length(indeces), 1);
        
        tmp_floats = repmat([table_supplement.trophicgroup(idx_supplement),...
            table_supplement.ascallingparameterforcarbonconvertion(idx_supplement),...
            table_supplement.bexponentforcarbonconvertion(idx_supplement),...
            NaN], length(indeces), 1);
    
    else
        tmp_strings = repmat(["NaN","NaN"], length(indeces), 1);
        
        tmp_floats = repmat([NaN, NaN, NaN, NaN], length(indeces), 1);
        
    end

    regroupped_data_str(indeces,:) = tmp_strings;
    regroupped_data_float(indeces,:) = tmp_floats;
         
end

%% correct badfocus for certain instruments
special_case = "not_living_artefact_badfocus";

indeces = find(all_names(:,1) == special_case &...
    (all_names(:,3) == "IFCB" | all_names(:,3) == "H5" | all_names(:,3) == "H20" | all_names(:,3) == "Flowcamb20" | all_names(:,3) == "FlowcamNiskin"));

regroupped_data_str(indeces,:) = repmat(["living", "other_unidentified"], length(indeces), 1);
regroupped_data_float(indeces,1) = repmat(3.5, length(indeces), 1);


%% Put everything in a table and save as csv

ProjectID= repmat("TARA_Oceans_imaging_devices", length(all_names), 1);
SampleID = all_names(:,4);
ContactName = repmat("Fabien Lombard, Lionel Guidi", length(all_names), 1);
ContactAdress = repmat("fabien.lombard@imev-mer.fr, lionel.guidi@imev-mer.fr", length(all_names), 1);

HabitatType = repmat('open ocean', length(all_names),1);
ParentEventID = repmat("TARA Oceans", length(all_names), 1) + ' st ' + all_values(:,1);
Source_Archive = repmat("Zenodo", length(all_names), 1);
BiblioCitationDOI = repmat("10.5281/zenodo.10478781, 10.1101/2024.02.09.579612", length(all_names), 1);
goedeticDatum = repmat("WGS8", length(all_names), 1);
Net_mesh_unit = repmat("µm", length(all_names), 1);
Net_surface_unit = repmat("m2", length(all_names), 1);

Abundance_unit = repmat("ind/m3", length(all_names), 1);
Biovolume_unit = repmat("mm3/m3", length(all_names), 1);
Carbon_biomass_unit = repmat("mg C", length(all_names), 1);

PFT = regroupped_data_str(:,2);
Latitude = all_values(:,2);
Longitude = all_values(:,3);
Depth = all_values(:,7);
Max_depth = all_values(:,8);
Min_depth = all_values(:,9);
Event_date = all_names(:,2);
Year = all_values(:,4);
Month = all_values(:,5);
Day = all_values(:,6);
TARA_station = all_values(:,1);
Instrument = all_names(:,3);
Sample_volume = all_values(:,10);
Net_mesh = all_values(:,11);
Net_surf = all_values(:,12);
Original_taxa_name = all_names(:,1);
Living = regroupped_data_str(:,1);
Trophic_group = regroupped_data_float(:,1);
Carbon_conversion_scaling = regroupped_data_float(:,2);
Carbon_conversion_exponent = regroupped_data_float(:,3);
Abundance = all_values(:,13);
Biovolume = all_values(:,14);
Carbon_biomass = all_values(:,15);

% Clean missing SampleID (crate one using eventdate, time, and instrument
rows = size(SampleID,1);

for i = 1:rows
    if ismissing(SampleID(i))
        SampleID(i) = 'D' + erase(Event_date(i), [":", "-"]) +  '_' + Instrument(i);
    end
end

occurrenceID = SampleID + '_' + Latitude + '_' + Longitude + '_' + Event_date + '_' + Original_taxa_name;

%% Data cleaning -- Check for misassigned station numbers

% Identify missasigned measurements
[C, ia, ic] = unique([TARA_station, Latitude, Longitude, Instrument], 'rows');
instruments = C(:,4);
unique_stations = str2double(C(:,1:3));

rows = size(unique_stations,1);

stations_test = [];
lat_lons = [];

for i=1:rows
    
    new_station = -1;
    delta_lat = abs(unique_stations(i,2) - TARAregevents.Latitude);
    delta_lon = abs(unique_stations(i,3) - TARAregevents.Longitude);
    
    delta_distance = sqrt(delta_lat.^2 + delta_lon.^2);
    
    if min(delta_distance) < 1

        
        [r, c] = find(delta_distance == min(delta_distance));
        
        stations = TARAregevents.Stationlabel(r);
        
        new_station = min(stations);
    end
    
    stations_test = [stations_test; [new_station]];
    lat_lons = [lat_lons; [unique_stations(i,2), unique_stations(i,3)]];
end

C(stations_test<0,:)
sum(stations_test<0)
lat_lons_misaligned = lat_lons(stations_test<0,:);

%% Correct values in unique_stations -- Compare stations lat lon in hydro

[r, c] = find(stations_test<0);

for i=1:size(r)
    
    station = unique_stations(r(i),1);
    
    unique_stations(r(i), 2) = Mergedbase(station).hydro.Latitude;
    unique_stations(r(i), 3) = Mergedbase(station).hydro.Longitude;

end

Latitude = unique_stations(ic,2);
Longitude = unique_stations(ic,3);

%% Correct NaN pft values if possible
[r, c] = find(PFT == "NaN");
disp(length(r))

listOfStrings = table_supplement.taxa;

PFT_flag = Living;
PFT_flag(:) = '';

for i = 1:length(r)
    [largestSubstring, label_r] = findLargestSubstring(Original_taxa_name(r(i)), listOfStrings, 0.75);
    
    if length(label_r) > 0
        
        label_r = label_r(1);
        PFT(r(i)) = table_supplement.planktonicfunctionaltype(label_r);
        Living(r(i)) = table_supplement.livingnonliving(label_r);
        Carbon_conversion_scaling(r(i)) = table_supplement.ascallingparameterforcarbonconvertion(label_r);
        Carbon_conversion_exponent(r(i)) = table_supplement.bexponentforcarbonconvertion(label_r);
        Trophic_group(r(i)) = table_supplement.trophicgroup(label_r);
        PFT_flag(r(i)) = 'estimated based on largest matching substring';
    end
end

%%
[r, c] = find(PFT == "NaN");
disp(length(r))

%% Create clean table

variable_names = {'ProjectID', 'SampleID', 'ContactName', 'ContactAdress'...
    'occurrenceID', 'ParentEventID', 'Source_Archive', 'BiblioCitationDOI',...
    'PFT', 'PFT_flag', 'decimalLatitude', 'decimalLongitude', 'goedeticDatum', 'HabitatType', 'Depth',...
    'Max_depth', 'Min_depth', 'Event_date', 'Year', 'Month',...
    'Day', 'TARA_Station', 'Instrument', 'Sample_volume',...
    'Net_mesh', 'Net_mesh_unit', 'Net_surface', 'Net_surface_unit', 'Original_taxa_name',...
    'Living', 'Trophic_group', 'Carbon_conversion_scaling',...
    'Carbon_conversion_exponent', 'Abundance', 'Abundance_unit',...
    'Biovolume', 'Biovolume_unit',...
    'Carbon_biomass', 'Carbon_biomass_unit'};

T = table(ProjectID, SampleID, ContactName, ContactAdress,...
    occurrenceID, ParentEventID, Source_Archive, BiblioCitationDOI,...
    PFT, PFT_flag, Latitude, Longitude, goedeticDatum, HabitatType, Depth, Max_depth,...
    Min_depth, Event_date, Year, Month, Day, TARA_station,...
    Instrument, Sample_volume, Net_mesh, Net_mesh_unit, Net_surf, Net_surface_unit, Original_taxa_name,...
    Living, Trophic_group, Carbon_conversion_scaling,...
    Carbon_conversion_exponent, Abundance, Abundance_unit,...
    Biovolume, Biovolume_unit, Carbon_biomass, Carbon_biomass_unit, 'VariableNames', variable_names);

% Save the table as a CSV file
data_directory = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data/Biovolume_data';
filename = 'Mergedbase_19072024_clean_location_estimated_name.csv';
cd(data_directory)

writetable(T, filename);

% Display a message confirming file save
disp(['Table saved as CSV file: ', filename]);

%%

categories = unique([Instrument, PFT], 'rows');

%%
[r, c] = find(PFT == "NaN");
Original_taxa_name(r)

%% Plot distribution

event_lat = TARAregevents.Latitude;
events_lon = TARAregevents.Longitude;

lons = -179.5:179.5;
lats = -89.5:89.5;
latlim = [-78 80];
lonlim = [-180 180];

h = figure('color','white');
hold on

axesm('robinson','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on')%...
   
axis off
setm(gca,'MLabelLocation',60,'LabelFormat','none','MLabelParallel','South');
setm(gca,'PLabelLocation',45,'LabelFormat','none');

load coastlines
plotm(coastlat,coastlon,'k');
p1 = plotm(Latitude, Longitude, 'bo', 'LineWidth', 3, 'DisplayName','Mergedbase events');
p2 = plotm(event_lat, events_lon, 'kx', 'LineWidth', 1, 'DisplayName','TARA events');

lgd = legend([p1 p2]);

lgd.FontSize = 14;


%% Prepare data for gridded netcdf


% gridded 1°x1° for each instrument, mean carbon, mean biovolume 


%% Compilation for Corentin
% ====================================================
% Only extract information from the metaplanktonC.mat
% ====================================================
clear all

working_directory = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data';
addpath(genpath(working_directory))

cd(working_directory)

load('Biovolume_data/metaplanktonC.mat')
metaplanktonC = metaplankton;

load('Biovolume_data/metaplankton.mat')
metaplankton = metaplankton;
%% Only use entries from merged2netsUVPH20

[data_stationsC, stations] = get_stations(metaplanktonC, 'merged2netsUVPH20');
[data_stations, ~] = get_stations(metaplankton, 'merged2netsUVPH20');

pft_names = metaplankton(1).pft180names;

%%
% extract values for each entry

TARA_station = [];
Latitude = [];
Longitude = [];
total_biovolume = [];
total_biovolumeC = [];
PFT = string([]);

for i = 1:length(stations)
    
    inner_struct = data_stations{i};
    innter_structC = data_stations{i};
    
    donut = inner_struct.donut;
    donutC = inner_struct.donut;
    
    for j = 1:length(donut)
        
        TARA_station = [TARA_station; stations(i) + 1];
        Latitude = [Latitude; metaplankton(stations(i)).Lat];
        Longitude = [Longitude; metaplankton(stations(i)).Lon];
        
        PFT(end + 1, 1) = pft_names{j};
        total_biovolume = [total_biovolume; donut(j)];
        total_biovolumeC = [total_biovolumeC; donutC(j)];
        
    end
    

end

%% Extend data
tara_stations = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data/Biovolume_data/TARA_locs_date.csv';
TARAlocsdate = importfile(tara_stations, 1, 211);

% go through each entry and extend the data if possible
rows = length(TARA_station);
Year_month = NaN(rows,2);

for i = 1:rows
    station = TARA_station(i) + 1;
    
    if isnan(Latitude(i))
        Latitude(i) = TARAlocsdate.Latitude(station);
        Longitude(i) = TARAlocsdate.Longitude(station);
    end
    
    Year_month(i,1) = TARAlocsdate.year(station);
    Year_month(i,2) = TARAlocsdate.month(station);
        
end

%%
data_directory = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data/Biovolume_data';

cd(data_directory)
% Filename for the CSV
filename = 'Donut_test_conversion_24052024_UHE.csv';

variable_names = {'PFT', 'Latitude', 'Longitude',...
     'Year', 'Month', 'TARA_Station', 'Instrument', 'Total_biovolume',...
     'Total_biovolume_unit', 'Total_carbon_content', 'Total_carbon_content_unit'  };

PFT = PFT;
Latitude = Latitude;
Longitude = Longitude;

Year = Year_month(:,1);
Month = Year_month(:,2);

TARA_station = TARA_station;
Instrument = repmat("Meta-Plk >20 µm", length(PFT), 1);


Total_biovolume = total_biovolume;
Total_biovolume_unit = repmat("mm3/m3", length(PFT), 1);
Total_carbon_content = total_biovolumeC;
Total_carbon_content_unit = repmat("mg C", length(PFT), 1);


% Creating the table
T = table(PFT, Latitude, Longitude, Year, Month, TARA_station,...
    Instrument, Total_biovolume, Total_biovolume_unit,...
    Total_carbon_content, Total_carbon_content_unit, 'VariableNames', variable_names);

% Save the table as a CSV file
writetable(T, filename);

% Display a message confirming file save
disp(['Table saved as CSV file: ', filename]);

%%

data_directory = '/net/kryo/work/ursho/PhD/Projects/BlueCloud/Imaging_data/Biovolume_data';

cd(data_directory)
% Filename for the CSV
filename = 'Donut_test_conversion_24052024_UHE.csv';

variable_names = {'PFT', 'Latitude', 'Longitude', 'Depth',...
     'Year', 'Month', 'TARA_Station', 'Instrument',  };

