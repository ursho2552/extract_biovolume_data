function struct_information = get_sample_information(database)
% This function extracts various metadata from a given sample in the `database`.
% It searches for key fields such as `SampleID`, `Date`, `Time`, `Latitude`,
% `Longitude`, `Depth`, `Volume`, and other relevant information. The function
% handles missing data and different naming conventions for fields, ensuring that
% the relevant information is collected if available. It also formats the date
% and time into an `event_date` string.
%
% Inputs:
%   - database (struct): A structured array representing a sample with potential fields for
%     sample metadata like date, time, location, depth, and volume.
%
% Outputs:
%   - struct_information (struct): A structure containing the extracted metadata with
%     the following fields:
%       - SampleID (string): The identifier for the sample.
%       - year (double): Year of the event (if available).
%       - month (double): Month of the event (if available).
%       - day (double): Day of the event (if available).
%       - hour (double): Hour of the event (if available).
%       - minutes (double): Minutes of the event (if available).
%       - seconds (double): Seconds of the event (if available).
%       - event_date (string): ISO 8601 formatted date and time string (or 'NaN' if missing).
%       - latitude (double): Latitude of the sample location.
%       - longitude (double): Longitude of the sample location.
%       - depth (double): Depth of the sample (if available).
%       - Zmax (double): Maximum depth recorded (if available).
%       - Zmin (double): Minimum depth recorded (if available).
%       - volume (double): Volume of the sample (if available).
%       - Netmesh (double): Net mesh size used (if available).
%       - Netsurf (double): Net surface area used (if available).
%
% Example:
%   sample_info = get_sample_information(Mergedbase(1));
%
% In this example, the function extracts the metadata from the first sample
% in the `Mergedbase` dataset and returns it in a structured format.

    FIELDS = string(["SampleID"; "Date"; "time"; "Latitude"; "Longitude";...
        "depth"; "Depth"; "Zmax"; "Zmin"; "vol"; "Vol"; "Netsurf"; "Netmesh"; "SampleBarcode"]);
    
    SampleID = NaN;
    year = NaN;
    month = NaN;
    day = NaN;
    hour = NaN;
    minutes = NaN;
    seconds = NaN;
    event_date = NaN;
    latitude = NaN;
    longitude = NaN;
    depth = NaN;
    Zmax = NaN;
    Zmin = NaN;
    volume = NaN;
    Netmesh = NaN;
    Netsurf = NaN;
    
    flag_present = is_field_present(database, FIELDS);
    
    %SampleID
    if flag_present(1)
        if flag_present(14)
            SampleID = string(strcat('TARA_', database.(FIELDS(14))));
        else
            SampleID = string(database.(FIELDS(1)));
        end
    end
    
    %Date
    if flag_present(2)
        date = char(string(database.(FIELDS(2))));
        year = str2num(date(1:4));
        month = str2num(date(5:6));
        day = str2num(date(7:8));
    end
    
    %time
    if flag_present(3)
        time = char(string(database.(FIELDS(3))));
       
        while length(time)<6
            time = strcat('0',time);
        end
        hour = str2num(time(1:2));
        minutes = str2num(time(3:4));
        seconds = str2num(time(5:6));
        
    end
    
    %Latitude
    if flag_present(4) && length(char(database.(FIELDS(4))))>0
        latitude = database.(FIELDS(4))(1); 
    end
    
    %Longitude
    if flag_present(5) && length(char(database.(FIELDS(5))))>0
        longitude = database.(FIELDS(5))(1);
    end
    
    %depth with different spellings and depth ranges
    if flag_present(6)
        depth = database.(FIELDS(6));
    end
    
    if flag_present(7)
        depth = database.(FIELDS(7));
    end
    
    if ~isnan(depth)
        
        if contains(string(depth), '999')
            depth = NaN;
        end
    end
    
    if flag_present(8)
        Zmax = database.(FIELDS(8));
    end
    
    if flag_present(9)
        Zmin = database.(FIELDS(9));
    end
    
    %Volume with different spellings
    if flag_present(10)
        volume = database.(FIELDS(10));
    end
    
    if flag_present(11)
        volume = database.(FIELDS(11));
    end
    
    %Net information
    if flag_present(12)
        Netmesh = database.(FIELDS(12));
    end
    
    if flag_present(13)
        Netsurf = database.(FIELDS(13));
    end
    
    %Potential eventdate
    if flag_present(2) && flag_present(3)
        event_date = sprintf('%04d-%02d-%02dT%02d:%02d:%02d', year, month, day, hour, minutes, seconds);
    elseif flag_present(2) && ~flag_present(3)
        event_date = sprintf('%04d-%02d-%02dT00:00:00', year, month, day);
    else
        event_date = 'NaN';
    end
    
    struct_information = struct('SampleID', SampleID,...
        'year', year, 'month', month, 'day', day, 'hour', hour,...
        'minutes', minutes, 'seconds', seconds, 'event_date', string(event_date), 'latitude', latitude,...
        'longitude', longitude, 'depth', depth, 'Zmax', Zmax,...
        'Zmin', Zmin, 'volume', volume, 'Netmesh', Netmesh,...
        'Netsurf', Netsurf);

end