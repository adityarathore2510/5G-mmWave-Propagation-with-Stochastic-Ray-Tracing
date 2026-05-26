function plot_results(results, params, env)
% PLOT_RESULTS  Generates, displays, and saves all simulation result figures.
%
%  Inputs:
%    results  — struct with per-frequency simulation results
%    params   — simulation parameter struct
%    env      — urban environment struct
%
%  Figures generated (saved to ../results/ as PNG):
%    Fig 1  — Path Loss vs Distance (all frequencies)
%    Fig 2  — FSPL comparison (theoretical vs simulated)
%    Fig 3  — Delay Spread vs Distance
%    Fig 4  — Doppler Shift vs Frequency
%    Fig 5  — Number of Multipath Components vs Distance
%    Fig 6  — Urban Environment Map (2D top view)
%    Fig 7  — Path Loss CDF comparison
%    Fig 8  — Delay Spread CDF

% Ensure results directory exists
if ~exist(params.results_dir, 'dir')
    mkdir(params.results_dir);
end

% Color scheme: distinct, colorblind-friendly palette
clr = {[0.00, 0.45, 0.74],   % blue   → 28 GHz
       [0.85, 0.33, 0.10],   % orange → 39 GHz
       [0.47, 0.67, 0.19]};  % green  → 60 GHz
freq_labels = {'28 GHz', '39 GHz', '60 GHz'};
freq_tags   = {'f28', 'f39', 'f60'};

% ======================================================================
% FIGURE 1 — Path Loss vs Distance (Log Scale)
% ======================================================================
fig1 = figure('Name', 'Path Loss vs Distance', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [50 50 900 600]);

ax = axes('Parent', fig1, 'Color', [0.15 0.15 0.18], ...
          'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
          'GridColor', [0.4 0.4 0.4], 'MinorGridAlpha', 0.15, ...
          'FontSize', 11, 'FontName', 'Arial');
grid(ax, 'on'); hold(ax, 'on');

for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        r = results.(tag);
        plot(ax, r.distances, r.path_loss, ...
            'Color', clr{k}, 'LineWidth', 2.2, ...
            'DisplayName', freq_labels{k});
    end
end

% Overlay theoretical FSPL for 28 GHz (dashed)
d_ref = logspace(log10(params.dist_min), log10(params.dist_max), 200);
fspl_ref = 20*log10(4*pi*d_ref*28e9 / 3e8);
plot(ax, d_ref, fspl_ref, '--', 'Color', clr{1}, ...
     'LineWidth', 1.2, 'DisplayName', '28 GHz FSPL (theory)');

set(ax, 'XScale', 'log');
xlabel(ax, 'Distance (m)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax, 'Path Loss (dB)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax, '5G mmWave Path Loss vs Distance — Urban Stochastic Model', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
leg = legend(ax, 'Location', 'northwest', 'FontSize', 10);
set(leg, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
         'EdgeColor', [0.5 0.5 0.5]);
xlim(ax, [params.dist_min, params.dist_max]);
ylim(ax, [50 220]);

save_figure(fig1, fullfile(params.results_dir, 'fig1_path_loss_vs_distance.png'), params);
fprintf('[PLOT] Saved: fig1_path_loss_vs_distance.png\n');

% ======================================================================
% FIGURE 2 — Path Loss Exponent Comparison (Simulated vs Free-Space)
% ======================================================================
fig2 = figure('Name', 'Simulated vs FSPL', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [100 50 900 600]);

ax2 = axes('Parent', fig2, 'Color', [0.15 0.15 0.18], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'GridColor', [0.4 0.4 0.4], 'FontSize', 11, 'FontName', 'Arial');
grid(ax2, 'on'); hold(ax2, 'on');

for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        r = results.(tag);
        freq_Hz = r.freq_GHz * 1e9;
        fspl_k  = 20*log10(4*pi*r.distances*freq_Hz / 3e8);

        % Simulated excess loss over FSPL
        excess_loss = r.path_loss - fspl_k;
        plot(ax2, r.distances, excess_loss, ...
            'Color', clr{k}, 'LineWidth', 2.2, ...
            'DisplayName', [freq_labels{k} ' Excess Loss']);
    end
end

set(ax2, 'XScale', 'log');
xlabel(ax2, 'Distance (m)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax2, 'Excess Loss above FSPL (dB)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax2, 'Additional Propagation Loss Beyond Free-Space', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
leg2 = legend(ax2, 'Location', 'northwest', 'FontSize', 10);
set(leg2, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
          'EdgeColor', [0.5 0.5 0.5]);
xlim(ax2, [params.dist_min, params.dist_max]);
ylim(ax2, [0 60]);

save_figure(fig2, fullfile(params.results_dir, 'fig2_excess_loss.png'), params);
fprintf('[PLOT] Saved: fig2_excess_loss.png\n');

% ======================================================================
% FIGURE 3 — RMS Delay Spread vs Distance
% ======================================================================
fig3 = figure('Name', 'RMS Delay Spread', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [150 50 900 600]);

ax3 = axes('Parent', fig3, 'Color', [0.15 0.15 0.18], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'GridColor', [0.4 0.4 0.4], 'FontSize', 11, 'FontName', 'Arial');
grid(ax3, 'on'); hold(ax3, 'on');

for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        r = results.(tag);
        % Convert delay spread from seconds to nanoseconds
        ds_ns = r.delay_spread * 1e9;
        plot(ax3, r.distances, ds_ns, ...
            'Color', clr{k}, 'LineWidth', 2.2, ...
            'DisplayName', freq_labels{k});
    end
end

set(ax3, 'XScale', 'log');
xlabel(ax3, 'Distance (m)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax3, 'RMS Delay Spread (ns)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax3, 'RMS Delay Spread vs Distance — mmWave Urban Channel', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
leg3 = legend(ax3, 'Location', 'northwest', 'FontSize', 10);
set(leg3, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
          'EdgeColor', [0.5 0.5 0.5]);
xlim(ax3, [params.dist_min, params.dist_max]);

save_figure(fig3, fullfile(params.results_dir, 'fig3_delay_spread.png'), params);
fprintf('[PLOT] Saved: fig3_delay_spread.png\n');

% ======================================================================
% FIGURE 4 — Doppler Shift vs Frequency (Bar Chart)
% ======================================================================
fig4 = figure('Name', 'Doppler Shift', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [200 50 700 500]);

ax4 = axes('Parent', fig4, 'Color', [0.15 0.15 0.18], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'GridColor', [0.4 0.4 0.4], 'FontSize', 11, 'FontName', 'Arial');
grid(ax4, 'on'); hold(ax4, 'on');

% Mean Doppler shift for each frequency
mean_dopplers = zeros(1, 3);
for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        mean_dopplers(k) = mean(results.(tag).doppler);
    end
end

b = bar(ax4, 1:3, mean_dopplers, 0.6);
b.FaceColor = 'flat';
b.CData = cell2mat(clr)';   % assign individual bar colours

set(ax4, 'XTickLabel', freq_labels, 'XTick', 1:3);
xlabel(ax4, 'Carrier Frequency', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax4, 'Mean Effective Doppler Shift (Hz)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax4, 'Doppler Frequency Shift Across mmWave Bands', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');

% Annotate bars with values
for k = 1 : 3
    text(ax4, k, mean_dopplers(k) + 5, ...
         sprintf('%.1f Hz', mean_dopplers(k)), ...
         'HorizontalAlignment', 'center', ...
         'Color', [1 1 1], 'FontSize', 11, 'FontWeight', 'bold');
end

save_figure(fig4, fullfile(params.results_dir, 'fig4_doppler_shift.png'), params);
fprintf('[PLOT] Saved: fig4_doppler_shift.png\n');

% ======================================================================
% FIGURE 5 — Number of Multipath Components vs Distance
% ======================================================================
fig5 = figure('Name', 'Multipath Count', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [250 50 900 600]);

ax5 = axes('Parent', fig5, 'Color', [0.15 0.15 0.18], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'GridColor', [0.4 0.4 0.4], 'FontSize', 11, 'FontName', 'Arial');
grid(ax5, 'on'); hold(ax5, 'on');

for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        r = results.(tag);
        % Apply a short moving-average for smoothness
        np_smooth = movmean(r.num_paths, 10);
        plot(ax5, r.distances, np_smooth, ...
            'Color', clr{k}, 'LineWidth', 2.2, ...
            'DisplayName', freq_labels{k});
    end
end

set(ax5, 'XScale', 'log');
xlabel(ax5, 'Distance (m)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax5, 'Number of Significant Multipath Components', ...
       'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax5, 'Multipath Richness vs Distance', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
leg5 = legend(ax5, 'Location', 'northeast', 'FontSize', 10);
set(leg5, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
          'EdgeColor', [0.5 0.5 0.5]);
xlim(ax5, [params.dist_min, params.dist_max]);

save_figure(fig5, fullfile(params.results_dir, 'fig5_multipath_count.png'), params);
fprintf('[PLOT] Saved: fig5_multipath_count.png\n');

% ======================================================================
% FIGURE 6 — Urban Environment Map (2-D Top View)
% ======================================================================
fig6 = figure('Name', 'Urban Environment Map', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [300 50 800 700]);

ax6 = axes('Parent', fig6, 'Color', [0.08 0.12 0.10], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'FontSize', 10, 'FontName', 'Arial');
hold(ax6, 'on');

% Draw buildings as filled rectangles
for i = 1 : env.num_buildings
    xc = env.buildings(i, 1);
    yc = env.buildings(i, 2);
    w2 = env.buildings(i, 3) / 2;

    % Colour building by material
    mat = env.materials{i};
    switch mat
        case 'concrete'; fc = [0.40 0.40 0.45];
        case 'glass';    fc = [0.20 0.50 0.70];
        case 'brick';    fc = [0.60 0.30 0.20];
        case 'metal';    fc = [0.55 0.55 0.58];
        otherwise;       fc = [0.45 0.45 0.45];
    end

    rectangle(ax6, 'Position', [xc-w2, yc-w2, w2*2, w2*2], ...
              'FaceColor', fc, 'EdgeColor', [0.8 0.8 0.8], 'LineWidth', 0.8);
end

% Draw TX
plot(ax6, env.tx_pos(1), env.tx_pos(2), '^', ...
     'MarkerSize', 14, 'MarkerFaceColor', [1 0.85 0], ...
     'MarkerEdgeColor', 'white', 'LineWidth', 1.5, ...
     'DisplayName', 'Base Station (TX)');

% Draw reference RX
plot(ax6, env.rx_pos_ref(1), env.rx_pos_ref(2), 'o', ...
     'MarkerSize', 12, 'MarkerFaceColor', [0.20 0.90 0.60], ...
     'MarkerEdgeColor', 'white', 'LineWidth', 1.5, ...
     'DisplayName', 'UE Reference (RX)');

% Draw a representative ray path (straight line TX→RX)
plot(ax6, [env.tx_pos(1), env.rx_pos_ref(1)], ...
          [env.tx_pos(2), env.rx_pos_ref(2)], '--', ...
     'Color', [1 0.5 0.2], 'LineWidth', 1.5, ...
     'DisplayName', 'LOS Path');

xlabel(ax6, 'X Position (m)', 'Color', [0.9 0.9 0.9], 'FontSize', 12);
ylabel(ax6, 'Y Position (m)', 'Color', [0.9 0.9 0.9], 'FontSize', 12);
title(ax6, 'Stochastic Urban Environment — Top View (500 m × 500 m)', ...
      'Color', [1 1 1], 'FontSize', 13, 'FontWeight', 'bold');

% Add material legend as a text annotation
text(ax6, 10, env.area_y - 20, 'Materials:', ...
     'Color', [1 1 1], 'FontSize', 9, 'FontWeight', 'bold');
text(ax6, 10, env.area_y - 40, '■ Concrete', 'Color', [0.70 0.70 0.75], 'FontSize', 9);
text(ax6, 10, env.area_y - 57, '■ Glass',    'Color', [0.20 0.50 0.70], 'FontSize', 9);
text(ax6, 10, env.area_y - 74, '■ Brick',    'Color', [0.60 0.30 0.20], 'FontSize', 9);
text(ax6, 10, env.area_y - 91, '■ Metal',    'Color', [0.55 0.55 0.58], 'FontSize', 9);

leg6 = legend(ax6, 'Location', 'southeast', 'FontSize', 9);
set(leg6, 'Color', [0.15 0.15 0.20], 'TextColor', [0.9 0.9 0.9], ...
          'EdgeColor', [0.5 0.5 0.5]);
axis(ax6, [0 env.area_x 0 env.area_y]);
axis(ax6, 'equal');

save_figure(fig6, fullfile(params.results_dir, 'fig6_urban_environment_map.png'), params);
fprintf('[PLOT] Saved: fig6_urban_environment_map.png\n');

% ======================================================================
% FIGURE 7 — Empirical CDF of Path Loss per Frequency
% ======================================================================
fig7 = figure('Name', 'CDF of Path Loss', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [350 50 900 600]);

ax7 = axes('Parent', fig7, 'Color', [0.15 0.15 0.18], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'GridColor', [0.4 0.4 0.4], 'FontSize', 11, 'FontName', 'Arial');
grid(ax7, 'on'); hold(ax7, 'on');

for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        r = results.(tag);
        pl_sorted = sort(r.path_loss);
        cdf_vals  = (1 : length(pl_sorted)) / length(pl_sorted);
        plot(ax7, pl_sorted, cdf_vals, ...
            'Color', clr{k}, 'LineWidth', 2.2, ...
            'DisplayName', freq_labels{k});
    end
end

xlabel(ax7, 'Path Loss (dB)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax7, 'CDF', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax7, 'Empirical CDF of Path Loss — All Frequencies', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
leg7 = legend(ax7, 'Location', 'southeast', 'FontSize', 10);
set(leg7, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
          'EdgeColor', [0.5 0.5 0.5]);

save_figure(fig7, fullfile(params.results_dir, 'fig7_path_loss_cdf.png'), params);
fprintf('[PLOT] Saved: fig7_path_loss_cdf.png\n');

% ======================================================================
% FIGURE 8 — Delay Spread CDF
% ======================================================================
fig8 = figure('Name', 'CDF of Delay Spread', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [400 50 900 600]);

ax8 = axes('Parent', fig8, 'Color', [0.15 0.15 0.18], ...
           'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
           'GridColor', [0.4 0.4 0.4], 'FontSize', 11, 'FontName', 'Arial');
grid(ax8, 'on'); hold(ax8, 'on');

for k = 1 : 3
    tag = freq_tags{k};
    if isfield(results, tag)
        r = results.(tag);
        ds_ns_sorted = sort(r.delay_spread * 1e9);
        cdf_vals     = (1 : length(ds_ns_sorted)) / length(ds_ns_sorted);
        plot(ax8, ds_ns_sorted, cdf_vals, ...
            'Color', clr{k}, 'LineWidth', 2.2, ...
            'DisplayName', freq_labels{k});
    end
end

xlabel(ax8, 'RMS Delay Spread (ns)', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
ylabel(ax8, 'CDF', 'Color', [0.9 0.9 0.9], 'FontSize', 13);
title(ax8, 'Empirical CDF of RMS Delay Spread', ...
      'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
leg8 = legend(ax8, 'Location', 'southeast', 'FontSize', 10);
set(leg8, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
          'EdgeColor', [0.5 0.5 0.5]);

save_figure(fig8, fullfile(params.results_dir, 'fig8_delay_spread_cdf.png'), params);
fprintf('[PLOT] Saved: fig8_delay_spread_cdf.png\n');

% ======================================================================
% FIGURE 9 — Frequency Comparison Summary (Subplot Dashboard)
% ======================================================================
fig9 = figure('Name', 'Summary Dashboard', ...
              'Color', [0.12 0.12 0.15], ...
              'Position', [450 50 1100 800]);

titles_sub = {'Path Loss (dB)', 'Delay Spread (ns)', 'Num. Paths', 'Doppler (Hz)'};
fields_sub = {'path_loss', 'delay_spread', 'num_paths', 'doppler'};
scales_sub = {1, 1e9, 1, 1};

for sp = 1 : 4
    ax_s = subplot(2, 2, sp, 'Parent', fig9);
    set(ax_s, 'Color', [0.15 0.15 0.18], ...
              'XColor', [0.85 0.85 0.85], 'YColor', [0.85 0.85 0.85], ...
              'GridColor', [0.4 0.4 0.4]);
    grid(ax_s, 'on'); hold(ax_s, 'on');

    for k = 1 : 3
        tag = freq_tags{k};
        if isfield(results, tag)
            r = results.(tag);
            y_data = r.(fields_sub{sp}) * scales_sub{sp};
            plot(ax_s, r.distances, y_data, ...
                'Color', clr{k}, 'LineWidth', 1.8, ...
                'DisplayName', freq_labels{k});
        end
    end

    set(ax_s, 'XScale', 'log');
    xlabel(ax_s, 'Distance (m)', 'Color', [0.8 0.8 0.8], 'FontSize', 10);
    ylabel(ax_s, titles_sub{sp}, 'Color', [0.8 0.8 0.8], 'FontSize', 10);
    title(ax_s, titles_sub{sp}, 'Color', [1 1 1], 'FontSize', 11);
    xlim(ax_s, [params.dist_min, params.dist_max]);

    if sp == 1
        leg_s = legend(ax_s, 'Location', 'northwest', 'FontSize', 8);
        set(leg_s, 'Color', [0.2 0.2 0.25], 'TextColor', [0.9 0.9 0.9], ...
                   'EdgeColor', [0.4 0.4 0.4]);
    end
end

sgtitle(fig9, '5G mmWave Channel Characterisation — Summary Dashboard', ...
        'Color', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');

save_figure(fig9, fullfile(params.results_dir, 'fig9_summary_dashboard.png'), params);
fprintf('[PLOT] Saved: fig9_summary_dashboard.png\n\n');

fprintf('[INFO] All %d figures generated and saved to:\n  %s\n\n', 9, params.results_dir);

end

% ======================================================================
%  LOCAL HELPER — save figure as PNG
% ======================================================================
function save_figure(fig_handle, file_path, params)
    print(fig_handle, file_path, params.fig_format, params.fig_dpi);
end
