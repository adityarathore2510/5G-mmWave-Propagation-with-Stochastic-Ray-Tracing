% ==========================================================================
%  main.m — 5G mmWave Propagation with Stochastic Ray Tracing
%  Course Project | Wireless Communication Engineering
% ==========================================================================
%
%  Description:
%    This script simulates 5G millimeter-wave (mmWave) signal propagation
%    using a stochastic geometric ray tracing approach. Three carrier
%    frequencies (28 GHz, 39 GHz, 60 GHz) are evaluated in a simplified
%    urban environment. Key propagation phenomena modelled include:
%      - Free-space path loss (FSPL)
%      - Reflection loss
%      - Diffraction loss (knife-edge model)
%      - Penetration / transmission loss
%      - Multipath delay spread
%      - Doppler frequency shift
%
%  Usage:
%    Run this file directly in MATLAB. All result figures are saved as
%    PNG images inside the ../results/ directory automatically.
%
%  Dependencies:
%    calc_path_loss.m, calc_reflection.m, calc_diffraction.m,
%    calc_penetration.m, calc_delay_spread.m, calc_doppler.m,
%    generate_urban_env.m, stochastic_ray_trace.m, plot_results.m
%
%  MATLAB Version: R2021a or later (no special toolboxes required)
% ==========================================================================

clearvars; close all; clc;

fprintf('==========================================================\n');
fprintf(' 5G mmWave Stochastic Ray Tracing Simulation\n');
fprintf('==========================================================\n\n');

% ------------------------------------------------------------------
% 1.  SIMULATION PARAMETERS
% ------------------------------------------------------------------
params = define_sim_params();

fprintf('[INFO] Frequencies under test: %s GHz\n', ...
    num2str(params.frequencies / 1e9));
fprintf('[INFO] Distance range: %.0f – %.0f m\n', ...
    params.dist_min, params.dist_max);
fprintf('[INFO] Number of rays per scenario: %d\n\n', params.num_rays);

% ------------------------------------------------------------------
% 2.  GENERATE URBAN ENVIRONMENT
% ------------------------------------------------------------------
fprintf('[INFO] Generating stochastic urban environment ...\n');
env = generate_urban_env(params);
fprintf('[INFO] Environment generated: %d buildings, %d obstacles\n\n', ...
    env.num_buildings, env.num_obstacles);

% ------------------------------------------------------------------
% 3.  MAIN SIMULATION LOOP — iterate over each carrier frequency
% ------------------------------------------------------------------
results = struct();

for f_idx = 1 : length(params.frequencies)

    freq_Hz  = params.frequencies(f_idx);
    freq_GHz = freq_Hz / 1e9;

    fprintf('----------------------------------------------------------\n');
    fprintf('[SIM] Frequency: %.0f GHz\n', freq_GHz);
    fprintf('----------------------------------------------------------\n');

    % Distance vector (log-spaced for better visualisation)
    distances = logspace( log10(params.dist_min), ...
                          log10(params.dist_max), ...
                          params.num_dist_points );

    % Pre-allocate result arrays
    total_path_loss  = zeros(1, params.num_dist_points);
    delay_spread_arr = zeros(1, params.num_dist_points);
    doppler_arr      = zeros(1, params.num_dist_points);
    num_paths_arr    = zeros(1, params.num_dist_points);

    for d_idx = 1 : params.num_dist_points

        d = distances(d_idx);

        % (a) Stochastic ray tracing — returns multipath components
        [ray_paths, ray_delays, ray_gains] = stochastic_ray_trace( ...
            d, freq_Hz, env, params);

        % (b) Aggregate total received power (linear domain)
        total_rx_power_linear = sum(10.^(ray_gains / 10));
        total_path_loss(d_idx) = -10 * log10(total_rx_power_linear);

        % (c) Delay spread
        delay_spread_arr(d_idx) = calc_delay_spread(ray_delays, ray_gains);

        % (d) Doppler shift (worst-case across all paths)
        doppler_arr(d_idx) = calc_doppler( ...
            freq_Hz, params.ue_velocity, params.doppler_angle_spread);

        num_paths_arr(d_idx) = length(ray_paths);

    end % distance loop

    % Store results for this frequency
    tag = sprintf('f%d', round(freq_GHz));
    results.(tag).freq_GHz       = freq_GHz;
    results.(tag).distances      = distances;
    results.(tag).path_loss      = total_path_loss;
    results.(tag).delay_spread   = delay_spread_arr;
    results.(tag).doppler        = doppler_arr;
    results.(tag).num_paths      = num_paths_arr;

    fprintf('[INFO] Mean path loss      : %.2f dB\n', mean(total_path_loss));
    fprintf('[INFO] Mean delay spread   : %.2f ns\n', mean(delay_spread_arr)*1e9);
    fprintf('[INFO] Mean Doppler shift  : %.2f Hz\n\n', mean(doppler_arr));

end % frequency loop

% ------------------------------------------------------------------
% 4.  PLOT AND SAVE ALL RESULTS
% ------------------------------------------------------------------
fprintf('[INFO] Generating and saving result plots ...\n\n');
plot_results(results, params, env);

fprintf('==========================================================\n');
fprintf(' Simulation Complete. Results saved in ../results/\n');
fprintf('==========================================================\n');
