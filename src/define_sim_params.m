function params = define_sim_params()
% DEFINE_SIM_PARAMS  Returns a structure containing all simulation parameters.
%
%  Returns:
%    params  — struct with fields for frequencies, environment geometry,
%              material properties, mobility, and ray tracing settings.
%
%  Modify the values in this file to explore different scenarios.

% ------------------------------------------------------------------
% CARRIER FREQUENCIES  (Hz)
% ------------------------------------------------------------------
params.frequencies = [28e9, 39e9, 60e9];   % 28 / 39 / 60 GHz bands

% ------------------------------------------------------------------
% DISTANCE RANGE  (metres)
% ------------------------------------------------------------------
params.dist_min        = 10;        % minimum TX–RX separation [m]
params.dist_max        = 500;       % maximum TX–RX separation [m]
params.num_dist_points = 200;       % number of sample points along distance

% ------------------------------------------------------------------
% PHYSICAL CONSTANTS
% ------------------------------------------------------------------
params.c = 3e8;            % speed of light [m/s]

% ------------------------------------------------------------------
% ANTENNA / LINK PARAMETERS
% ------------------------------------------------------------------
params.tx_power_dBm   = 30;         % transmit power [dBm]  (1 W = 30 dBm)
params.tx_gain_dBi    = 15;         % transmit antenna gain [dBi]
params.rx_gain_dBi    = 10;         % receive antenna gain [dBi]
params.noise_figure   = 7;          % receiver noise figure [dB]
params.bandwidth_MHz  = 400;        % channel bandwidth [MHz] — 5G NR mmWave

% ------------------------------------------------------------------
% STOCHASTIC RAY TRACING SETTINGS
% ------------------------------------------------------------------
params.num_rays         = 50;       % number of rays launched per TX position
params.max_reflections  = 3;        % maximum allowed reflections per ray
params.max_diffractions = 2;        % maximum diffraction events per ray
params.ray_spread_angle = 180;      % half-angle of ray fan [degrees]
params.seed             = 42;       % RNG seed for reproducibility

% ------------------------------------------------------------------
% URBAN ENVIRONMENT GEOMETRY
% ------------------------------------------------------------------
params.area_x          = 500;       % simulation area width  [m]
params.area_y          = 500;       % simulation area height [m]
params.num_buildings   = 20;        % number of buildings to place randomly
params.building_h_min  = 10;        % minimum building height [m]
params.building_h_max  = 40;        % maximum building height [m]
params.building_w_min  = 15;        % minimum building footprint width [m]
params.building_w_max  = 50;        % maximum building footprint width [m]
params.street_width    = 20;        % typical street width [m]

% ------------------------------------------------------------------
% MATERIAL PROPERTIES — Reflection & Penetration Coefficients
%
%  Reflection coefficient Γ (dimensionless, 0–1 linear amplitude)
%  Penetration / transmission loss L_pen [dB]
%
%  Values sourced from ITU-R P.2040 and 3GPP TR 38.901 Table 7.4.3-1
% ------------------------------------------------------------------

% Concrete (outer walls of buildings)
params.mat_concrete.reflect_coeff  = 0.85;   % amplitude reflection coeff
params.mat_concrete.pen_loss_dB    = 20;      % penetration loss [dB]

% Glass (windows)
params.mat_glass.reflect_coeff     = 0.70;
params.mat_glass.pen_loss_dB       = 3;       % low penetration loss

% Metal / steel structures
params.mat_metal.reflect_coeff     = 0.95;
params.mat_metal.pen_loss_dB       = 50;      % nearly opaque

% Brick walls
params.mat_brick.reflect_coeff     = 0.75;
params.mat_brick.pen_loss_dB       = 15;

% Ground (asphalt)
params.mat_ground.reflect_coeff    = 0.60;
params.mat_ground.pen_loss_dB      = 40;      % not typically penetrated

% ------------------------------------------------------------------
% DIFFRACTION PARAMETERS (Knife-Edge Model)
% ------------------------------------------------------------------
params.diffraction_loss_base = 6;   % minimum diffraction loss [dB]

% ------------------------------------------------------------------
% UE MOBILITY & DOPPLER
% ------------------------------------------------------------------
params.ue_velocity          = 30;     % UE velocity [m/s]  (~108 km/h, vehicular)
params.doppler_angle_spread = 60;     % angle-of-arrival spread [degrees]
                                      % determines effective Doppler bandwidth

% ------------------------------------------------------------------
% ATMOSPHERIC / ENVIRONMENTAL LOSSES  (added per km)
% ------------------------------------------------------------------
% Oxygen absorption (dominant at 60 GHz ~ 15 dB/km)
params.atm_loss_dB_per_m = [0.001, 0.002, 0.015];
%                           28GHz   39GHz  60GHz
% Rain attenuation at moderate rain rate (25 mm/hr) per metre
params.rain_loss_dB_per_m = [0.002, 0.004, 0.006];

% ------------------------------------------------------------------
% OUTPUT SETTINGS
% ------------------------------------------------------------------
params.results_dir  = fullfile(fileparts(fileparts(mfilename('fullpath'))), ...
                               'results');
params.fig_format   = '-dpng';      % save format for plots
params.fig_dpi      = '-r150';      % resolution

end
