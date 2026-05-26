function pen_loss_dB = calc_penetration(material, params)
% CALC_PENETRATION  Returns the signal penetration (transmission) loss for
%   a given building material, with a stochastic angle-dependent component.
%
%  Inputs:
%    material      — string: 'concrete', 'glass', 'brick', or 'metal'
%    params        — simulation parameter struct
%
%  Output:
%    pen_loss_dB   — penetration loss [dB] (positive = attenuation)
%
%  Values sourced from:
%    ITU-R P.2040-1 "Effects of building materials and structures on
%    radiowave propagation above about 100 MHz"
%    3GPP TR 38.901 Table 7.4.3-1
%
%  A frequency-dependent correction is not applied here because the
%  material loss table already encodes average behaviour across the
%  mmWave band; the primary frequency dependence is captured by FSPL.

switch lower(material)
    case 'concrete'
        base_loss = params.mat_concrete.pen_loss_dB;
    case 'glass'
        base_loss = params.mat_glass.pen_loss_dB;
    case 'brick'
        base_loss = params.mat_brick.pen_loss_dB;
    case 'metal'
        base_loss = params.mat_metal.pen_loss_dB;
    otherwise
        base_loss = 15;   % moderate default
end

% Stochastic variation: ±20 % of base loss (models varying wall thickness,
% angle of incidence, surface roughness, etc.)
variation  = base_loss * 0.2 * (rand() - 0.5);
pen_loss_dB = base_loss + variation;

% Clip to non-negative
pen_loss_dB = max(pen_loss_dB, 0);

end
