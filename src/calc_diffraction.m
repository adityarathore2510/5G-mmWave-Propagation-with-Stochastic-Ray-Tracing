function diff_loss_dB = calc_diffraction(d_total, obs, params)
% CALC_DIFFRACTION  Estimates diffraction loss using a simplified
%   knife-edge diffraction model (Fresnel-Kirchhoff parameter).
%
%  Inputs:
%    d_total  — total TX-to-RX distance [m]
%    obs      — obstacle struct with fields .height, .p1, .p2
%    params   — simulation parameter struct
%
%  Output:
%    diff_loss_dB  — diffraction loss [dB] (positive = attenuation)
%
%  Model:
%    Fresnel-Kirchhoff diffraction parameter:
%      ν = h_eff · sqrt(2(d1+d2) / (λ·d1·d2))
%
%    where h_eff is the effective obstacle height above the direct path,
%    d1 and d2 are distances from TX and RX to the obstacle midpoint.
%
%    Diffraction loss approximation (Lee's formula):
%      L_diff ≈ 0 dB                       , ν < -1
%      L_diff ≈ 20·log10(0.5 - 0.62ν)      , -1 ≤ ν ≤ 0
%      L_diff ≈ 20·log10(0.5·exp(-0.95ν))  ,  0 < ν ≤ 1
%      L_diff ≈ 20·log10(0.4 - sqrt(0.1184-(0.38-0.1ν)²)), 1 < ν ≤ 2.4
%      L_diff ≈ 20·log10(0.225/ν)           ,  ν > 2.4
%
%  Note: A stochastic height perturbation is applied to h_eff.

% We use a representative frequency (39 GHz) for the diffraction
% geometry, as the obstacle geometry is frequency-independent and the
% per-frequency FSPL is already captured in calc_path_loss.
c      = params.c;
freq_ref = 39e9;   % reference frequency for λ
lambda = c / freq_ref;

% Obstacle midpoint (2-D)
mid_x  = (obs.p1(1) + obs.p2(1)) / 2;
mid_y  = (obs.p1(2) + obs.p2(2)) / 2;

% Approximate distances from TX and RX to the obstacle midpoint
% TX is at env.tx_pos (not passed directly); use a fraction of d_total
d1 = d_total * (0.3 + rand() * 0.4);   % stochastic placement
d2 = d_total - d1;
d2 = max(d2, 1);   % numerical guard

% Effective obstacle height above direct TX-RX path
% The building height minus a random clearance (0–5 m)
h_building = obs.height;
clearance  = rand() * 5;
h_eff      = max(h_building - clearance, 0.5);

% Fresnel-Kirchhoff parameter
nu = h_eff * sqrt(2 * (d1 + d2) / (lambda * d1 * d2));

% Diffraction loss using Lee's piecewise approximation
if nu < -1
    diff_loss_dB = 0;
elseif nu <= 0
    diff_loss_dB = 20 * log10(0.5 - 0.62 * nu);
elseif nu <= 1
    diff_loss_dB = 20 * log10(0.5 * exp(-0.95 * nu));
elseif nu <= 2.4
    inner = 0.1184 - (0.38 - 0.1*nu)^2;
    inner = max(inner, 0);   % prevent sqrt of negative
    diff_loss_dB = 20 * log10(0.4 - sqrt(inner));
else
    diff_loss_dB = 20 * log10(0.225 / nu);
end

% Clip to physically reasonable range and ensure positive loss
diff_loss_dB = max(abs(diff_loss_dB), params.diffraction_loss_base);
diff_loss_dB = min(diff_loss_dB, 40);   % cap at 40 dB

end
