function [ray_paths, ray_delays, ray_gains_dB] = stochastic_ray_trace( ...
    d_total, freq_Hz, env, params)
% STOCHASTIC_RAY_TRACE  Launches multiple rays from a transmitter toward a
%   receiver separated by distance d_total. Each ray undergoes a random
%   sequence of reflection, diffraction, and penetration events according
%   to the stochastic environment model.
%
%  Inputs:
%    d_total  — TX-to-RX straight-line distance [m]
%    freq_Hz  — carrier frequency [Hz]
%    env      — urban environment struct from generate_urban_env()
%    params   — simulation parameter struct
%
%  Outputs:
%    ray_paths     — cell array: each cell is a vector of interaction types
%                    ('LOS','reflect','diffract','penetrate')
%    ray_delays    — vector: propagation delay for each ray [s]
%    ray_gains_dB  — vector: total received power (dB re 1 mW) for each ray
%
%  Method:
%    For each ray a random number of obstacles is selected from the
%    environment. At each obstacle a probabilistic decision tree selects
%    whether the ray reflects, diffracts, or penetrates, weighted by
%    geometry and material properties. The path length is augmented by
%    additional distance for each interaction event. Final path loss
%    combines FSPL, accumulated reflection losses, diffraction losses,
%    penetration losses, and atmospheric attenuation.

rng('shuffle');   % allow stochastic variation per distance point

c        = params.c;
lambda   = c / freq_Hz;
num_rays = params.num_rays;

% Frequency index for per-frequency atmospheric loss lookup
[~, f_idx] = min(abs(params.frequencies - freq_Hz));

% Pre-allocate outputs
ray_paths    = cell(num_rays, 1);
ray_delays   = zeros(num_rays, 1);
ray_gains_dB = zeros(num_rays, 1);

% LOS probability based on distance (simplified 3GPP 38.901 UMa)
p_LOS = min(18 / d_total, 1) * (1 - exp(-d_total / 36)) + exp(-d_total / 36);

for r = 1 : num_rays

    % ---- Decide if this ray has a Line-of-Sight component ----
    is_LOS = rand() < p_LOS;

    if is_LOS && r == 1
        % First ray is always the LOS/dominant component if LOS exists
        path_length  = d_total;
        total_loss_dB = calc_path_loss(d_total, freq_Hz, params, f_idx);
        ray_paths{r}    = {'LOS'};
        ray_delays(r)   = path_length / c;
        ray_gains_dB(r) = params.tx_power_dBm + params.tx_gain_dBi + ...
                          params.rx_gain_dBi - total_loss_dB;
        continue;
    end

    % ---- NLOS ray: random interaction sequence ----
    % Randomly choose how many obstacles this ray encounters
    max_int    = params.max_reflections + params.max_diffractions;
    num_events = randi([1, max_int]);

    % Sample that many random obstacles from the environment
    n_obs = env.num_obstacles;
    if n_obs == 0
        num_events = 0;
    end

    accumulated_loss   = 0;
    extra_path         = 0;
    interaction_types  = {};

    for ev = 1 : num_events
        % Pick a random obstacle
        obs_idx  = randi(n_obs);
        obs      = env.obstacles(obs_idx);
        material = obs.material;

        % Random interaction probability weights:
        %   P(reflect) > P(penetrate) > P(diffract) for most surfaces
        p_reflect  = 0.55;
        p_penetrate = 0.30;
        % p_diffract = 1 - p_reflect - p_penetrate = 0.15

        roll = rand();
        if roll < p_reflect
            % REFLECTION -----------------------------------------------
            refl_loss_dB = calc_reflection(material, params);
            accumulated_loss = accumulated_loss + refl_loss_dB;
            extra_path = extra_path + (5 + rand() * 20);   % detour [m]
            interaction_types{end+1} = 'reflect';          %#ok<AGROW>

        elseif roll < (p_reflect + p_penetrate)
            % PENETRATION -----------------------------------------------
            pen_loss_dB  = calc_penetration(material, params);
            accumulated_loss = accumulated_loss + pen_loss_dB;
            extra_path = extra_path + (2 + rand() * 5);    % small detour
            interaction_types{end+1} = 'penetrate';        %#ok<AGROW>

        else
            % DIFFRACTION -----------------------------------------------
            diff_loss_dB = calc_diffraction(d_total, obs, params);
            accumulated_loss = accumulated_loss + diff_loss_dB;
            extra_path = extra_path + (10 + rand() * 30);  % longer detour
            interaction_types{end+1} = 'diffract';         %#ok<AGROW>
        end
    end

    % Total path length including interaction detours
    path_length = d_total + extra_path;

    % Free-space path loss for actual path length
    fspl_dB = calc_path_loss(path_length, freq_Hz, params, f_idx);

    % Total loss
    total_loss_dB = fspl_dB + accumulated_loss;

    % Clip unreasonably high losses so simulation remains numerically stable
    total_loss_dB = min(total_loss_dB, 200);

    % Store results
    ray_paths{r}    = interaction_types;
    ray_delays(r)   = path_length / c;
    ray_gains_dB(r) = params.tx_power_dBm + params.tx_gain_dBi + ...
                      params.rx_gain_dBi - total_loss_dB;
end

% Remove rays that have effectively zero power (< -200 dBm)
valid = ray_gains_dB > -200;
ray_paths    = ray_paths(valid);
ray_delays   = ray_delays(valid);
ray_gains_dB = ray_gains_dB(valid);

end
