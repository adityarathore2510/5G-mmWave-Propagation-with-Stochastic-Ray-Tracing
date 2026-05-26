function doppler_shift_Hz = calc_doppler(freq_Hz, velocity_mps, angle_spread_deg)
% CALC_DOPPLER  Computes the maximum and effective Doppler frequency shift
%   experienced by a moving UE in an environment with angular spread.
%
%  Inputs:
%    freq_Hz          — carrier frequency [Hz]
%    velocity_mps     — UE velocity [m/s]
%    angle_spread_deg — angle-of-arrival spread [degrees]; controls the
%                       effective Doppler bandwidth (not just the max shift)
%
%  Output:
%    doppler_shift_Hz — effective (RMS) Doppler shift [Hz]
%
%  Background:
%    Maximum Doppler shift: f_D,max = v · f_c / c
%    For a uniformly distributed AoA over ±θ_spread:
%      f_D,eff = f_D,max · cos(θ) averaged over the spread,
%    which for a uniform distribution in [-θ,+θ] simplifies to:
%      f_D,eff ≈ f_D,max · sinc(θ_spread / 180)  [approx.]
%
%    Here we use a simpler representative expression:
%      f_D,eff = f_D,max · |cos(θ_rms)|
%    where θ_rms is the RMS angle = angle_spread / sqrt(3) for uniform dist.
%
%  Note:
%    The returned value represents the dominant component of Doppler
%    broadening, useful for estimating channel coherence time.

c = 3e8;   % speed of light [m/s]

% Maximum Doppler shift
f_D_max = velocity_mps * freq_Hz / c;

% RMS angle (radians) for uniform AoA distribution over ±angle_spread
theta_rms = deg2rad(angle_spread_deg / sqrt(3));

% Effective Doppler shift
doppler_shift_Hz = f_D_max * abs(cos(theta_rms));

% Add a small stochastic perturbation (±5 %) to simulate real variability
doppler_shift_Hz = doppler_shift_Hz * (1 + 0.05 * (rand() - 0.5) * 2);

end
