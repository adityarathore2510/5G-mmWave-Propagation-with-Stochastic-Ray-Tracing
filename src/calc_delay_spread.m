function rms_delay_spread = calc_delay_spread(ray_delays, ray_gains_dB)
% CALC_DELAY_SPREAD  Computes the RMS delay spread of a multipath channel.
%
%  Inputs:
%    ray_delays    — vector of propagation delays for each ray [s]
%    ray_gains_dB  — vector of received power for each ray [dBm]
%
%  Output:
%    rms_delay_spread  — RMS delay spread [s]
%
%  Definition (IEEE 802.11 / 3GPP convention):
%    Mean excess delay:
%      τ_mean = Σ( P_i · τ_i ) / Σ( P_i )
%
%    RMS delay spread:
%      σ_τ = sqrt( Σ(P_i · τ_i²) / Σ(P_i)  −  τ_mean² )
%
%    where P_i is the LINEAR power of ray i.
%
%  Reference: Rappaport, "Wireless Communications", 2nd ed., Eq. 3.12–3.14

if isempty(ray_delays) || isempty(ray_gains_dB)
    rms_delay_spread = 0;
    return;
end

% Convert dBm to linear power (mW)
P_linear = 10 .^ (ray_gains_dB / 10);

% Total power
P_total = sum(P_linear);

if P_total <= 0
    rms_delay_spread = 0;
    return;
end

% Mean excess delay
tau_mean = sum(P_linear .* ray_delays) / P_total;

% Mean square delay
tau_sq_mean = sum(P_linear .* (ray_delays .^ 2)) / P_total;

% RMS delay spread
rms_delay_spread = sqrt(max(tau_sq_mean - tau_mean^2, 0));

end
