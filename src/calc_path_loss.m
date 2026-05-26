function path_loss_dB = calc_path_loss(distance, freq_Hz, params, f_idx)
% CALC_PATH_LOSS  Computes total path loss combining free-space path loss
%   (FSPL), atmospheric oxygen absorption, and rain attenuation.
%
%  Inputs:
%    distance  — propagation distance [m]
%    freq_Hz   — carrier frequency [Hz]
%    params    — simulation parameter struct
%    f_idx     — index into per-frequency atmospheric loss arrays
%
%  Output:
%    path_loss_dB  — total path loss [dB]
%
%  Model:
%    FSPL(d,f) = 20·log10(4πd·f/c)   [dB]
%    L_atm(d)  = α_O2 · d             [dB]  (oxygen absorption)
%    L_rain(d) = α_rain · d           [dB]  (rain attenuation)
%    Total PL  = FSPL + L_atm + L_rain

c = params.c;

% --- Free-space path loss ---
% FSPL = 20*log10(4*pi*d*f/c)
fspl_dB = 20 * log10(4 * pi * distance * freq_Hz / c);

% --- Atmospheric oxygen absorption ---
% Values in params are in dB/m
atm_loss_dB  = params.atm_loss_dB_per_m(f_idx)  * distance;

% --- Rain attenuation (moderate rain, 25 mm/hr) ---
rain_loss_dB = params.rain_loss_dB_per_m(f_idx) * distance;

% --- Total path loss ---
path_loss_dB = fspl_dB + atm_loss_dB + rain_loss_dB;

end
