function refl_loss_dB = calc_reflection(material, params)
% CALC_REFLECTION  Computes the reflection loss for a given building
%   material using amplitude reflection coefficients defined in params.
%
%  Inputs:
%    material      — string: 'concrete', 'glass', 'brick', or 'metal'
%    params        — simulation parameter struct
%
%  Output:
%    refl_loss_dB  — reflection loss [dB] (positive value = attenuation)
%
%  Model:
%    Reflection coefficient Γ (dimensionless, 0–1 amplitude).
%    Power after reflection = Γ² × incident power.
%    Reflection loss [dB] = -20·log10(Γ)
%
%    A small random angle-dependent perturbation (±2 dB) is added to
%    simulate variations in angle of incidence across the simulation runs.

switch lower(material)
    case 'concrete'
        gamma = params.mat_concrete.reflect_coeff;
    case 'glass'
        gamma = params.mat_glass.reflect_coeff;
    case 'brick'
        gamma = params.mat_brick.reflect_coeff;
    case 'metal'
        gamma = params.mat_metal.reflect_coeff;
    otherwise
        gamma = 0.70;   % default: moderately reflective surface
end

% Power reflection coefficient = Γ²
% Loss in dB = -10·log10(Γ²) = -20·log10(Γ)
refl_loss_dB = -20 * log10(gamma);

% Add small stochastic angle-of-incidence variation (±2 dB)
refl_loss_dB = refl_loss_dB + (rand() - 0.5) * 4;

% Ensure non-negative (small numerical guard)
refl_loss_dB = max(refl_loss_dB, 0);

end
