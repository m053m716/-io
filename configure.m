function cfg = configure(SUBJ, YYYY, MM, DD, ARRAY, BLOCK, varargin)
%CONFIGURE  Write and return configuration JSON object for a given session
%
% Syntax:
%   cfg = io.configure(f);
%   cfg = io.configure(SUBJ, YYYY, MM, DD, ARRAY, BLOCK, 'Name', value, ...);
%
% Inputs:
%   f - Struct returned by utils.get_block_name
%
%   -- or --
%
%   SUBJ - String: should be name of subject (e.g. "Rupert" or "Frank")
%   YYYY - year (numeric scalar)
%   MM - month (numeric scalar)
%   DD - day (numeric scalar)
%   ARRAY - String: "A" or "B" or "*" for array identifier
%   BLOCK - Recording block index (numeric scalar)
%
%   'Name', value pairs (see top of code, each field of pars):
%       rootdir_gen - The root folder where all the raw data stuff is kept.
%                       This should normally stay the same unless we move 
%                       our data share.
%
% Output:
%   cfg - io.JSON handle object to configuration data for this session.
%
% If the JSON file does not exist, a new one will be created and saved.
%
% See also: Contents, io.JSON, utils.get_subj_query, utils.get_block_name

pars = struct;
pars.ab_offset = 0; % seconds
pars.px = 1;  % Index corresponding to x-axis potentiometer
pars.py = 2;  % Index corresponding to y-axis potentiometer
pars.range_degrees = [50; 60];
pars.rootdir_gen = utils.parameters('generated_data_folder'); 
pars.set_potentiometers = true;
pars = utils.parse_parameters(pars, varargin{:});

if isstruct(SUBJ)
    [SUBJ, YYYY, MM, DD, ARRAY, BLOCK] = utils.get_subj_query(SUBJ);
end
f = utils.get_block_name(SUBJ, YYYY, MM, DD, ARRAY, BLOCK);


maps = struct;
fname_A = fullfile(f.Raw.Subj, sprintf("%s_A_Muscle-Map.json", f.Tank));
fname_B = fullfile(f.Raw.Subj, sprintf("%s_B_Muscle-Map.json", f.Tank));
if exist(fname_A, 'file')~=0
     maps.A = fname_A;
end
if exist(fname_B, 'file')~=0
    maps.B = fname_B;
end

if pars.set_potentiometers
    [Position, ~, Header] = io.load_wrist_task_trial_logs(f);
    if iscell(Position.Properties.CustomProperties.Parameters{1})
        PTab = Position.Properties.CustomProperties.Parameters{1}{1};
    else
        PTab = Position.Properties.CustomProperties.Parameters{1}; 
    end
    P = @(param)pars_table_wrapper(PTab, param);

    gx = str2double(P('X POSITION Gain'));
    gy = str2double(P('Y POSITION Gain'));
    x_degs = pars.range_degrees(pars.px)./(gx ./ 100);
    y_degs = pars.range_degrees(pars.py)./(gy ./ 100);

    td = str2double(P("Target Size")); % pixels
    % Proportional diameter in x-y dimensions given shape of monitor:
    tdx_p = td ./ str2double(P("Monitor X Pixels"));
    tdy_p = td ./ str2double(P("Monitor Y Pixels"));

    tdx = x_degs * tdx_p;
    tdy = y_degs * tdy_p;

    if exist(f.Generated.Config, 'file') == 0
        cfg = io.JSON(f.Generated.Config, ...
            "Version", sprintf("%s.%s.%s", Header(1).Version.major, Header(1).Version.minor, Header(1).Version.patch), ...
            "Px", pars.px, ...
            "Py", pars.py, ...
            "Map", maps, ...
            "Task", Header(1).Task, ...
            "Mode", P("Mode"), ...
            "Orientation", Header(1).Orientation, ...
            "X_Center", Header(1).X_Center, ...
            "Y_Center", Header(1).Y_Center, ...
            "Left_In", Header(1).Left_In, ...
            "Left_Out", Header(1).Left_Out, ...
            "Right_In", Header(1).Right_In, ...
            "Right_Out", Header(1).Right_Out, ...
            "Top_In", Header(1).Top_In, ...
            "Top_Out", Header(1).Top_Out, ...
            "Bottom_In", Header(1).Bottom_In, ...
            "Bottom_Out", Header(1).Bottom_Out, ...
            "X_Gain", gx, ...
            "Y_Gain", gy, ...
            "X_Effective_Degrees_Screen", x_degs, ...
            "Y_Effective_Degrees_Screen", y_degs, ...
            "Target_X_Degrees_Diameter", tdx, ...
            "Target_Y_Degrees_Diameter", tdy, ...
            "AB_Offset", pars.ab_offset ...
            );
    else
         cfg = io.JSON(f.Generated.Config);
         cfg.update( ...
            "Version", sprintf("%d.%d.%s", Header(1).Version.major, Header(1).Version.minor, Header(1).Version.patch), ...
            "Px", pars.px, ...
            "Py", pars.py, ...
            "Map", maps, ...
            "Task", Header(1).Task, ...
            "Mode", P("Mode"), ...
            "Orientation", Header(1).Orientation, ...
            "X_Center", Header(1).X_Center, ...
            "Y_Center", Header(1).Y_Center, ...
            "Left_In", Header(1).Left_In, ...
            "Left_Out", Header(1).Left_Out, ...
            "Right_In", Header(1).Right_In, ...
            "Right_Out", Header(1).Right_Out, ...
            "Top_In", Header(1).Top_In, ...
            "Top_Out", Header(1).Top_Out, ...
            "Bottom_In", Header(1).Bottom_In, ...
            "Bottom_Out", Header(1).Bottom_Out, ...
            "X_Gain", gx, ...
            "Y_Gain", gy, ...
            "X_Effective_Degrees_Screen", x_degs, ...
            "Y_Effective_Degrees_Screen", y_degs, ...
            "Target_X_Degrees_Diameter", tdx, ...
            "Target_Y_Degrees_Diameter", tdy ...
        );
        cfg.write();
    end
else
    if exist(f.Generated.Config, 'file') == 0
        cfg = io.JSON(f.Generated.Config, ...
            "Version", "Version", ...
            "Px", pars.px, ...
            "Py", pars.py, ...
            "Map", maps, ...
            "Task", "Task", ...
            "Mode", "Mode", ...
            "Orientation", "Orientation", ...
            "X_Center", 0, ...
            "Y_Center", 0, ...
            "Left_In", 0, ...
            "Left_Out", 0, ...
            "Right_In", 0, ...
            "Right_Out", 0, ...
            "Top_In", 0, ...
            "Top_Out", 0, ...
            "Bottom_In", 0, ...
            "Bottom_Out", 0, ...
            "X_Gain", 1, ...
            "Y_Gain", 1, ...
            "X_Effective_Degrees_Screen", 40, ...
            "Y_Effective_Degrees_Screen", 40, ...
            "Target_X_Degrees_Diameter", 1.5, ...
            "Target_Y_Degrees_Diameter", 1.5, ...
            "AB_Offset", pars.ab_offset ...
            );
    else
         cfg = io.JSON(f.Generated.Config);
         cfg.update( ...
            "Map", maps, ...
            "AB_Offset", pars.ab_offset ...
        );
        cfg.write();
    end 
end
fprintf(1, "Config file for <strong>%s</strong> has been saved.\n", f.Block);

end