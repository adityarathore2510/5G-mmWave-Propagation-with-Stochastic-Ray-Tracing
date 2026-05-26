function env = generate_urban_env(params)
% GENERATE_URBAN_ENV  Creates a stochastic urban environment with random
%   building placements, material assignments, and obstacle descriptors.
%
%  Input:
%    params  — simulation parameter struct from define_sim_params()
%
%  Output:
%    env     — struct describing the urban environment:
%               .buildings   — Nx4 matrix [x, y, width, height]
%               .materials   — Nx1 cell array of material names
%               .obstacles   — struct array of obstacle edges
%               .num_buildings
%               .num_obstacles
%               .tx_pos      — transmitter position [x, y]
%               .rx_pos_ref  — reference receiver position [x, y]
%
%  The random seed is fixed in params.seed to ensure reproducibility.

rng(params.seed);   % fix random seed

N  = params.num_buildings;
Lx = params.area_x;
Ly = params.area_y;

% ------------------------------------------------------------------
% 1.  PLACE BUILDINGS RANDOMLY IN THE AREA
% ------------------------------------------------------------------
buildings = zeros(N, 4);   % [x_center, y_center, width, height_3D]

material_choices = {'concrete', 'glass', 'brick', 'metal'};
% Probability distribution: mostly concrete / brick in urban areas
mat_prob = [0.50, 0.15, 0.25, 0.10];
materials = cell(N, 1);

for i = 1 : N
    w = params.building_w_min + rand() * ...
        (params.building_w_max - params.building_w_min);
    h_3d = params.building_h_min + rand() * ...
        (params.building_h_max - params.building_h_min);

    % Place building, keeping a margin of at least half the building width
    % from the area boundary
    margin  = w / 2 + 5;
    x_c     = margin + rand() * (Lx - 2 * margin);
    y_c     = margin + rand() * (Ly - 2 * margin);

    buildings(i, :) = [x_c, y_c, w, h_3d];

    % Assign a dominant wall material using the probability vector
    r   = rand();
    cum = cumsum(mat_prob);
    m_idx = find(cum >= r, 1);
    materials{i} = material_choices{m_idx};
end

% ------------------------------------------------------------------
% 2.  CONVERT BUILDINGS TO OBSTACLE EDGES (2-D top-view line segments)
%     Each building contributes 4 wall segments.
% ------------------------------------------------------------------
obstacle_list = [];
obs_count = 0;

for i = 1 : N
    xc = buildings(i, 1);
    yc = buildings(i, 2);
    w2 = buildings(i, 3) / 2;   % half width

    % Four corners
    corners = [ xc - w2,  yc - w2 ;   % bottom-left
                xc + w2,  yc - w2 ;   % bottom-right
                xc + w2,  yc + w2 ;   % top-right
                xc - w2,  yc + w2 ];  % top-left

    for wall = 1 : 4
        obs_count = obs_count + 1;
        p1 = corners(wall, :);
        p2 = corners(mod(wall, 4) + 1, :);

        obstacle_list(obs_count).p1       = p1;
        obstacle_list(obs_count).p2       = p2;
        obstacle_list(obs_count).material = materials{i};
        obstacle_list(obs_count).building = i;
        obstacle_list(obs_count).height   = buildings(i, 4);
    end
end

% ------------------------------------------------------------------
% 3.  TX / RX POSITIONS
% ------------------------------------------------------------------
% Transmitter: base station placed near the edge of the street
tx_pos = [10, Ly / 2];      % left side, mid-height

% Reference receiver (used for visualisation only; actual distances
% are swept in main.m)
rx_pos_ref = [Lx - 10, Ly / 2];

% ------------------------------------------------------------------
% 4.  PACK OUTPUT STRUCT
% ------------------------------------------------------------------
env.buildings      = buildings;
env.materials      = materials;
env.obstacles      = obstacle_list;
env.num_buildings  = N;
env.num_obstacles  = obs_count;
env.tx_pos         = tx_pos;
env.rx_pos_ref     = rx_pos_ref;
env.area_x         = Lx;
env.area_y         = Ly;

end
