# Viva Preparation Guide
# 5G mmWave Propagation with Stochastic Ray Tracing

---

## 📌 How to Use This Document

Read through all 20 questions. For each question:
1. First try to answer from memory
2. Check the provided answer for completeness
3. Review the cross-questions to anticipate follow-ups

---

## SECTION A — Fundamental Concepts (Q1–Q7)

---

### Q1. What is millimeter-wave (mmWave) communication and why is it used in 5G?

**Answer:**
Millimeter-wave communication refers to wireless transmission in the frequency range of 30–300 GHz, where the corresponding wavelengths span 1–10 mm. In 5G New Radio (NR), the mmWave bands of interest are 24.25–52.6 GHz, specifically n257 (28 GHz), n258 (26 GHz), n260 (39 GHz), and n261 (60 GHz).

The primary motivation for adopting mmWave in 5G is the availability of large contiguous spectrum. Sub-6 GHz bands are heavily congested; in contrast, the mmWave range offers hundreds of MHz to several GHz of contiguous bandwidth per channel. For example, 5G NR allows up to 400 MHz channel bandwidth at 28 GHz. By Shannon's theorem (C = B·log₂(1 + SNR)), this directly translates to multi-Gbps peak data rates.

The trade-off is severe propagation loss: path loss scales as (4πd·f/c)², so doubling the frequency quadruples the free-space path loss. However, this is partially compensated by using massive MIMO antenna arrays (enabled by the smaller wavelength) to achieve high beamforming gain.

**Cross-Questions Faculty May Ask:**
- "What is the Shannon capacity limit and how does bandwidth affect it?"
- "Compare the path loss at 3.5 GHz (sub-6 GHz 5G) vs 28 GHz at 100 m separation."
- "Why can't we just increase transmit power to overcome mmWave path loss?"

---

### Q2. Explain the stochastic ray tracing approach used in your simulation.

**Answer:**
Ray tracing is a high-frequency electromagnetic wave propagation technique that models signals as geometric rays emanating from the transmitter. Each ray travels in a straight line until it interacts with an obstacle (building, wall, ground) where it may reflect, diffract, or be transmitted (penetrate).

**Deterministic ray tracing** requires exact knowledge of every building's geometry and material — computationally expensive and input-data intensive.

**Stochastic (geometric) ray tracing**, used in this simulation, replaces the exact geometry with a probabilistic model. Key stochastic elements include:
- Random building placement within the urban area
- Random selection of which obstacles each ray encounters
- Probabilistic decision between reflection, diffraction, and penetration
- LOS probability that depends on distance (following 3GPP TR 38.901 UMa model)

This approach models the *statistical behaviour* of an ensemble of urban environments rather than one specific city block — which is exactly what 3GPP channel models do. The 50 rays per TX-RX point represent independent random samples from the channel probability space.

**Cross-Questions:**
- "What is the difference between deterministic and statistical channel models?"
- "Which 3GPP channel model uses this approach?"
- "What is the purpose of fixing the random seed in your simulation?"

---

### Q3. Define path loss and write its mathematical formula. What causes higher path loss at 60 GHz vs 28 GHz?

**Answer:**
Path loss is the reduction in power density of a radio wave as it propagates through space. In the absence of obstacles (free-space), the Friis transmission equation gives:

**Free-Space Path Loss (FSPL):**
```
FSPL [dB] = 20·log₁₀(d) + 20·log₁₀(f) + 20·log₁₀(4π/c)
           = 20·log₁₀(d) + 20·log₁₀(f) − 147.55 dB
```
where d is in metres and f is in Hz.

**Total path loss in this simulation:**
```
PL_total = FSPL + L_atmospheric + L_rain + L_reflection + L_diffraction + L_penetration
```

At 60 GHz vs 28 GHz, path loss is higher for two reasons:
1. **Geometric spreading**: The FSPL increases by 20·log₁₀(60/28) ≈ **6.6 dB** purely from the frequency ratio
2. **Oxygen absorption**: At 60 GHz, the O₂ absorption resonance causes ~15 dB/km additional attenuation (vs ~0.03 dB/km at 28 GHz), which is significant at distances beyond ~100 m

**Cross-Questions:**
- "Calculate the FSPL at 28 GHz and 100 m."
- "At what distance does oxygen absorption become significant compared to FSPL at 60 GHz?"
- "What is the path loss exponent n and how does it differ from free space?"

---

### Q4. What is the Fresnel-Kirchhoff diffraction model and how is it applied?

**Answer:**
Diffraction is the phenomenon where radio waves bend around obstacles or through apertures, enabling signal propagation into shadowed regions. The Fresnel-Kirchhoff model quantifies this using the dimensionless **diffraction parameter ν (nu)**:

```
ν = h_eff · √(2(d₁ + d₂) / (λ · d₁ · d₂))
```

Where:
- h_eff = effective height of the obstacle above the direct path [m]
- d₁ = TX-to-obstacle distance [m]
- d₂ = obstacle-to-RX distance [m]
- λ = wavelength [m]

**Diffraction loss** (Lee's approximation):
- ν < −1: No loss (strong LOS)
- −1 ≤ ν ≤ 0: 20·log₁₀(0.5 − 0.62ν)
- 0 < ν ≤ 1: 20·log₁₀(0.5·e^(−0.95ν))
- 1 < ν ≤ 2.4: 20·log₁₀(0.4 − √(0.1184 − (0.38 − 0.1ν)²))
- ν > 2.4: 20·log₁₀(0.225/ν)

At mmWave frequencies, λ is very small, so ν becomes large even for modest building heights, resulting in **significantly higher diffraction loss** than sub-6 GHz. This is a major limitation — mmWave signals cannot easily bend around corners.

**Cross-Questions:**
- "What is a Fresnel zone and how does it relate to diffraction?"
- "Why is diffraction weaker at higher frequencies?"
- "In your code, what value did you cap the diffraction loss at and why?"

---

### Q5. Explain RMS delay spread and its importance in 5G system design.

**Answer:**
**RMS Delay Spread (στ)** is a measure of the time dispersion of a multipath channel. It is the power-weighted standard deviation of the arrival times of all multipath components:

```
τ_mean = Σ(Pᵢ·τᵢ) / Σ(Pᵢ)         [mean excess delay]

στ = √( Σ(Pᵢ·τᵢ²)/Σ(Pᵢ) − τ_mean² )
```

**Physical interpretation:** If 10 rays arrive at the receiver between 0 ns and 100 ns, with most power in the early arrivals, στ might be ~20–30 ns.

**Why it matters:**
1. **Inter-Symbol Interference (ISI):** If the symbol duration Ts < στ, energy from one symbol "leaks" into the next
2. **Coherence Bandwidth:** Bc ≈ 1/(5·στ). If the signal bandwidth exceeds Bc, frequency-selective fading occurs, requiring equalisation or OFDM
3. **OFDM Guard Interval:** The cyclic prefix must be longer than στ_max. 5G NR specifies cyclic prefix lengths accordingly

At mmWave with large bandwidths (400 MHz), each subcarrier is very narrow (~15/30/60/120 kHz), so the OFDM symbol duration is long enough that even ns-scale delay spreads are manageable. However, στ still impacts the choice of numerology (subcarrier spacing).

Typical urban mmWave στ values: **10–100 ns** at distances of 50–500 m.

**Cross-Questions:**
- "What is coherence bandwidth? Calculate it for στ = 20 ns."
- "What is the cyclic prefix in 5G NR OFDM and how is its length determined?"
- "How does delay spread vary with frequency in your simulation results?"

---

### Q6. What is the Doppler effect in wireless communications and how did you model it?

**Answer:**
The **Doppler effect** in radio channels occurs when there is relative motion between the transmitter and receiver. A wave transmitted at frequency fc is received at a shifted frequency:

```
f_received = fc ± f_D
```

The **maximum Doppler shift** occurs when the UE moves directly toward (or away from) the base station:
```
f_D,max = v · fc / c
```

Where v = UE velocity, c = speed of light.

**Example at 28 GHz with v = 30 m/s:**
```
f_D,max = 30 × 28×10⁹ / 3×10⁸ = 2800 Hz
```

In a real multipath environment, each ray arrives from a different angle θ, contributing a Doppler shift of f_D,max·cos(θ). The spread of Doppler components creates a **Doppler power spectrum** with bandwidth ≈ 2·f_D,max (for a uniform AoA distribution). The resulting **channel coherence time** is:

```
Tc ≈ 0.423 / f_D,max
```

In our simulation, the **effective Doppler shift** is computed as:
```
f_D,eff = f_D,max · |cos(θ_rms)|
```

where θ_rms = angle_spread/√3 (RMS angle for uniform distribution over the spread).

Doppler at 60 GHz would be 2.14× higher than at 28 GHz for the same velocity, requiring faster channel estimation and more frequent beam tracking.

**Cross-Questions:**
- "Calculate the coherence time at 28 GHz for v = 30 m/s."
- "What is the Jakes model for Doppler spectrum?"
- "How does Doppler affect the pilot (reference signal) design in 5G NR?"

---

### Q7. What are the key limitations of mmWave communication highlighted by your simulation?

**Answer:**

1. **High Free-Space Path Loss:** At 60 GHz, FSPL at 100 m is ~88 dB vs ~82 dB at 28 GHz. Combined with multipath effects, total path loss can exceed 150 dB, severely limiting range.

2. **Oxygen Absorption at 60 GHz:** At the oxygen resonance frequency, atmospheric absorption is ~15 dB/km. This makes 60 GHz unusable for distances beyond ~200–300 m in outdoor scenarios.

3. **High Penetration Loss:** Concrete walls attenuate mmWave signals by 20–40 dB (vs ~3–5 dB at 2.4 GHz). Metal surfaces are nearly opaque at 50+ dB loss. This makes indoor coverage from outdoor base stations extremely challenging.

4. **Limited Diffraction:** Short wavelengths mean mmWave signals cannot bend around corners effectively. Diffraction losses of 20–40 dB are typical, making NLOS coverage zones essentially dead zones.

5. **High Doppler at 60 GHz:** At 30 m/s, f_D,max ≈ 6000 Hz at 60 GHz. Fast channel variations require rapid beam tracking and frequent channel estimation, increasing signalling overhead.

6. **Small Coverage Radius:** The combination of factors above typically limits practical mmWave cell radius to 100–300 m, requiring very dense small cell deployment (~every 200 m in urban areas).

7. **Sensitivity to Blockage:** A single person or vehicle can block a mmWave link, causing instantaneous outages of 20–40 dB — a phenomenon not significant at lower frequencies.

**Cross-Questions:**
- "How does 5G handle the mmWave coverage problem? (Heterogeneous networks, beam management)"
- "Can rain cause significant mmWave attenuation? At what rain rate?"
- "What is the path loss exponent for your urban NLOS scenario?"

---

## SECTION B — Implementation & Code (Q8–Q14)

---

### Q8. Walk me through the main.m script — what does each section do?

**Answer:**
The `main.m` script is organised into four logical sections:

1. **Parameter Loading:** `define_sim_params()` returns a struct containing all configurable values — frequencies, environment geometry, material properties, UE velocity, ray tracing settings, and output paths. Centralising parameters here means you only change one file to run different scenarios.

2. **Environment Generation:** `generate_urban_env(params)` uses a fixed random seed to place 20 buildings stochastically in a 500×500 m area, assigns materials (concrete, glass, brick, metal) by probability, and converts buildings to 2D wall segments (obstacles) for ray tracing.

3. **Simulation Loop:** Outer loop over 3 frequencies; inner loop over 200 distance points. For each point, `stochastic_ray_trace()` launches 50 rays and returns delays and power levels. These are aggregated to compute total path loss (linear power sum → dB), delay spread (power-weighted std dev of delays), and Doppler shift (frequency-proportional calculation).

4. **Plotting & Saving:** `plot_results()` generates all 9 figures with consistent dark-theme styling and saves them to `../results/` as 150 DPI PNG files.

**Cross-Questions:**
- "Why do you use log-spaced distance points instead of linear spacing?"
- "Why is the RNG seeded inside generate_urban_env but shuffled inside stochastic_ray_trace?"
- "How would you parallelise this simulation using parfor?"

---

### Q9. How does your simulation compute total received power from multiple rays?

**Answer:**
Each of the 50 rays returns a received power in dBm. To find the total received power, we must combine them in the **linear (mW) domain**, not the dB domain — because received power is additive in linear scale:

```matlab
P_total_linear = sum(10.^(ray_gains_dB / 10))   % convert dBm → mW, then sum
total_path_loss = -10 * log10(P_total_linear)     % convert back to dB
```

This is equivalent to maximal ratio combining (MRC) in the sense that all ray contributions add constructively in power. In reality, ray phases matter and coherent combining involves complex amplitudes — but for channel modelling purposes, incoherent power addition is the standard approach used in 3GPP channel models and is appropriate for computing received signal strength (RSS).

The effective path loss is therefore:
```
PL_eff = TX_power - 10·log₁₀(Σ P_i_linear)
```

**Cross-Questions:**
- "Why can't you just average the dBm values?"
- "What is the 3GPP definition of path loss in TR 38.901?"
- "What is the difference between coherent and incoherent combining?"

---

### Q10. Explain the LOS probability model you implemented.

**Answer:**
The LOS probability model is taken from **3GPP TR 38.901 Table 7.4.2-1** for the Urban Macro (UMa) scenario:

```
P_LOS(d) = min(18/d, 1) × (1 − exp(−d/36)) + exp(−d/36)
```

This formula captures two regimes:
- **Short distances (d → 0):** P_LOS → 1 (almost always LOS at very short range)
- **Long distances (d → ∞):** The `min(18/d, 1)` term → 0, and exp(-d/36) → 0, so P_LOS → 0

At d = 36 m: P_LOS ≈ 0.5 × (1 − 1/e) + 1/e ≈ 0.68

At d = 200 m: min(18/200,1) = 0.09, so P_LOS ≈ 0.09 × 0.996 + 0.004 ≈ 0.094

This means at 200 m, only ~9.4% of channel realisations have LOS — confirming the NLOS-dominated nature of dense urban mmWave propagation.

In code:
```matlab
p_LOS = min(18/d_total, 1) * (1 - exp(-d_total/36)) + exp(-d_total/36);
is_LOS = rand() < p_LOS;
```

**Cross-Questions:**
- "Is this model for outdoor UMa or UMi? What changes for Urban Micro?"
- "How does LOS probability affect the path loss model in 3GPP?"
- "What is a Poisson point process and how is it used in urban LOS modelling?"

---

### Q11. How are reflection coefficients used and what values did you choose?

**Answer:**
The reflection coefficient Γ represents the fraction of wave amplitude reflected from a surface. The **power reflection coefficient** is Γ², and the reflection loss in dB is:

```
L_reflection [dB] = −20·log₁₀(Γ)
```

Values used, sourced from ITU-R P.2040 and 3GPP TR 38.901:

| Material | Γ (amplitude) | Power Loss [dB] |
|----------|--------------|-----------------|
| Concrete | 0.85 | ~1.4 dB |
| Glass | 0.70 | ~3.1 dB |
| Brick | 0.75 | ~2.5 dB |
| Metal | 0.95 | ~0.4 dB |

A ±2 dB random variation is added to model angle-of-incidence effects. In reality, the reflection coefficient depends on polarisation, angle of incidence (Fresnel equations), and surface roughness. For a smooth concrete wall at normal incidence, the complex relative permittivity at 28 GHz is approximately εr = 5.3 − j0.13, giving Γ ≈ 0.39 by the Fresnel formula. Our value of 0.85 is slightly higher, representing a well-polished or slightly moist concrete surface as a pessimistic case.

**Cross-Questions:**
- "Write the Fresnel reflection formula for vertical polarisation."
- "What is Snell's law and how does it apply to reflected radio waves?"
- "How does surface roughness affect the reflection coefficient? (Rayleigh roughness criterion)"

---

### Q12. What is the penetration loss model and what are realistic values at mmWave?

**Answer:**
Penetration loss (also called transmission loss or building entry loss) is the attenuation a signal experiences when passing through a building material. Our values follow **ITU-R P.2040-1**:

| Material | Penetration Loss | Notes |
|----------|-----------------|-------|
| Glass (standard) | 2–4 dB | Windows, facades |
| Glass (metallised/low-e) | 20–30 dB | Energy-efficient windows |
| Concrete | 15–25 dB | Outer walls, pillars |
| Brick | 10–20 dB | Older buildings |
| Metal/steel | 40–60 dB | Effectively opaque |
| Wood | 4–8 dB | Interior partitions |

These losses are **much higher** at mmWave than at 2.4/5 GHz (where glass might be 2 dB and concrete 5–10 dB) because at short wavelengths, even surface irregularities and material grain structure cause significant scattering and absorption.

A key 5G implication: outdoor-to-indoor mmWave coverage is essentially infeasible for concrete buildings. Indoor mmWave cells are required, or DAS (Distributed Antenna Systems) must pass fibre through buildings.

**Cross-Questions:**
- "How do energy-efficient windows affect indoor 5G coverage?"
- "What is O2I (outdoor-to-indoor) path loss in 3GPP?"
- "How is penetration loss modelled differently from reflection loss?"

---

### Q13. How is delay spread related to coherence bandwidth? Give a numerical example.

**Answer:**
Coherence bandwidth (Bc) is the range of frequencies over which the channel can be considered "flat" (constant gain and phase). It is inversely related to delay spread:

```
Bc ≈ 1 / (5 · σ_τ)     [conservative 90% coherence definition]
Bc ≈ 1 / (2π · σ_τ)    [50% coherence bandwidth]
```

**Numerical Example:**
If σ_τ = 30 ns (typical urban mmWave result at ~100 m):

```
Bc ≈ 1 / (5 × 30×10⁻⁹) = 6.67 MHz
```

Since 5G NR uses subcarrier spacings of 60 or 120 kHz at mmWave (numerology μ=2 or μ=3), each subcarrier bandwidth is far less than 6.67 MHz — so the channel **appears flat per subcarrier**. This is why OFDM works: it converts a wideband frequency-selective channel into many narrowband flat-fading subchannels.

However, the coherence bandwidth still matters for frequency-domain interpolation of pilot signals. With Bc = 6.67 MHz and 120 kHz subcarrier spacing, pilots must be spaced no more than ~55 subcarriers apart to ensure accurate channel estimation.

**Cross-Questions:**
- "What is the difference between frequency-flat and frequency-selective fading?"
- "How does OFDM overcome intersymbol interference?"
- "What numerology does 5G NR use for mmWave and why?"

---

### Q14. Why does the 60 GHz band have such distinctive propagation characteristics?

**Answer:**
The 60 GHz band (57–71 GHz in unlicensed use, n261 in 5G NR) has unique characteristics because it coincides with the **oxygen absorption resonance**:

1. **Oxygen Absorption (~15 dB/km):** O₂ molecules at 60 GHz absorb energy during rotation. This is actually beneficial for frequency reuse — a 60 GHz link at 300 m causes minimal interference beyond 1 km due to the extra 15 dB/km of natural shielding.

2. **Very Short Wavelength (5 mm):** A λ/2 dipole is only 2.5 mm long, enabling dense phased arrays in tiny form factors. 64-element arrays can fit in a 2–3 cm square.

3. **Near-Total Blockage:** The combination of high FSPL, oxygen absorption, and material penetration loss means a blocked link at 60 GHz is essentially unusable without alternative paths.

4. **Ideal for Specific Use Cases:** WiGig (IEEE 802.11ad/ay) uses 60 GHz for uncompressed video streaming within rooms (d < 10 m). Backhaul between buildings spaced < 200 m apart is also viable.

In the simulation, 60 GHz shows ~20 dB higher total path loss than 28 GHz at 200 m distance, driven by ~6.6 dB from FSPL and ~3 dB from O₂ absorption at that range.

**Cross-Questions:**
- "At what other frequencies does atmospheric absorption peak?"
- "What is WiGig and how does it use 60 GHz?"
- "Would you recommend 60 GHz for a 5G macro cell? Why or why not?"

---

## SECTION C — Results & Analysis (Q15–Q20)

---

### Q15. Explain your path loss results. What trend do you observe and why?

**Answer:**
The path loss vs distance plot (Fig. 1) shows three expected trends:

1. **Monotonic increase with distance:** All three frequencies show increasing path loss with distance, following a slope steeper than the free-space -20 dB/decade due to multipath interactions adding scatter loss.

2. **Frequency ordering (60 > 39 > 28 GHz):** Higher frequencies suffer greater path loss at all distances. The separation between curves grows at longer distances because atmospheric absorption (per metre) is greater at higher frequencies.

3. **Deviation from FSPL (Fig. 2):** The excess loss above FSPL ranges from ~5–30 dB in this simulation, representing the combined effect of reflection, diffraction, and penetration at urban obstacle interactions. This excess loss also increases with distance as the statistical probability of encountering more obstacles grows.

These results align well with published 28 GHz and 39 GHz urban measurement campaigns (Rappaport et al., NYU WIRELESS group).

**Cross-Questions:**
- "What path loss exponent (n) corresponds to your simulation results?"
- "How do your results compare to 3GPP 38.901 UMa NLOS formula?"
- "What is the link budget and how do you calculate cell coverage radius?"

---

### Q16. What does the CDF of path loss tell you?

**Answer:**
The Cumulative Distribution Function (CDF) of path loss (Fig. 7) shows the probability that path loss is below a given value. Key observations:

- **50th percentile (median path loss):** This represents the median link condition over the simulated distance range. At 28 GHz, it might be ~100 dB; at 60 GHz, ~110–115 dB.
- **90th percentile:** This is the design margin point — the system must handle path loss up to this value for 90% coverage probability. Designers add the difference between median and 90th percentile as **shadow fading margin** in link budgets.
- **Spread of each curve:** A wider CDF (more gradual slope) indicates greater variability in path loss — i.e., the channel is more unpredictable. In our stochastic model, this variability comes from random obstacle interactions.

The CDF is a key tool in network planning: it directly maps to coverage probability. If the system has a maximum path loss budget of 150 dB, the CDF at 150 dB gives the probability of providing service at any given random location.

---

### Q17. Discuss the delay spread results. What is the impact on 5G system design?

**Answer:**
Delay spread (Fig. 3) in our simulation increases with distance for all frequencies, from a few nanoseconds at 10 m to tens of nanoseconds at 500 m.

**Physical explanation:** At longer distances, more obstacles are encountered. Each obstacle creates a reflected/diffracted/penetrated ray with a longer travel path. The power-weighted spread of all these arrival times grows with distance.

**Frequency trend:** Lower frequencies (28 GHz) tend to show slightly larger delay spreads because the LOS probability decays more slowly and there are more surviving rays with non-trivial power. Higher frequencies lose ray power faster (more attenuation per interaction), so fewer paths contribute significantly, potentially reducing measured delay spread.

**5G Design Impact:**
- The cyclic prefix in 5G NR (with 120 kHz SCS, numerology μ=3) is 0.586 μs. Our simulated σ_τ of ~10–30 ns is well within this.
- The channel coherence bandwidth (~6–30 MHz for 10–100 ns delay spread) determines pilot density requirements in the frequency domain.
- Large delay spread means more OFDM subcarriers span more than one channel coherence bandwidth, requiring per-subcarrier channel estimation (not just interpolation).

---

### Q18. How does Doppler shift scale with frequency? What are the implications for 5G?

**Answer:**
Doppler shift is directly proportional to carrier frequency:

```
f_D = v · fc / c
```

At v = 30 m/s (108 km/h, vehicular):
| Frequency | f_D,max |
|-----------|---------|
| 28 GHz | 2,800 Hz |
| 39 GHz | 3,900 Hz |
| 60 GHz | 6,000 Hz |

**Coherence time** (time over which the channel can be assumed constant):
```
Tc ≈ 0.423 / f_D,max
```
- 28 GHz: Tc ≈ 0.151 ms
- 60 GHz: Tc ≈ 0.071 ms

**5G NR Implications:**
- The 5G NR slot duration with μ=3 (120 kHz SCS) is 0.125 ms, comparable to Tc at 60 GHz. This means the channel can change significantly within a slot at vehicular speeds, necessitating higher pilot density in the time domain.
- Beam tracking must occur at frequencies comparable to f_D. At 60 GHz, a narrow beam pointing error of even 1° can cause severe signal loss, and tracking must keep pace with Tc ≈ 0.07 ms.
- The Doppler spectrum bandwidth (±f_D,max) determines the minimum pilot spacing in the frequency domain for ISAM (Integrated Sensing and Communications).

**Cross-Questions:**
- "What is the Jakes spectrum and when does it apply?"
- "What is the 5G NR CSI-RS (Channel State Information Reference Signal) and how often is it transmitted?"

---

### Q19. What are the real-world applications of the phenomena you simulated?

**Answer:**

| Phenomenon Simulated | Real-World Application |
|---------------------|----------------------|
| Path loss modelling | Cell coverage planning, link budget analysis, BS placement |
| Reflection modelling | Passive reflector networks (IRS/RIS design) |
| Diffraction analysis | NLOS coverage assessment, relay node placement |
| Penetration loss | O2I coverage planning, indoor small cell sizing |
| Delay spread | OFDM cyclic prefix design, equaliser design |
| Doppler shift | Pilot spacing design, beam tracking algorithms, V2X communications |
| Urban environment model | 3GPP channel model validation, network simulation tools (NS-3, MATLAB 5G Toolbox) |

**Emerging applications:**
- **IRS (Intelligent Reflecting Surfaces):** Programmable metamaterial surfaces that reconfigure reflected rays to improve coverage — directly builds on reflection modelling
- **V2X (Vehicle-to-Everything):** High Doppler communications — directly relevant to the 30 m/s scenario simulated
- **6G channel modelling:** Frequencies up to 300 GHz, where all these effects are even more extreme

---

### Q20. If you had to extend this project, what improvements would you make?

**Answer:**
This is a question about engineering maturity — showing you understand what the current model simplifies.

**Short-term improvements (implementable in MATLAB):**

1. **3D Ray Tracing:** Current model is quasi-2D (top view). Extend to 3D geometry with rooftop diffraction, ground reflections, and elevation-dependent building interactions.

2. **Polarisation:** Add perpendicular (TE) and parallel (TM) reflection coefficients separately using Fresnel equations, rather than a single scalar Γ.

3. **Small-Scale Fading:** Add Rician fading (K-factor) for LOS paths and Rayleigh fading for NLOS paths on top of the ray tracing output.

4. **Actual 3GPP Cluster Model:** Implement the 3GPP TR 38.901 cluster-based channel model with exact delay/angle distributions.

**Medium-term improvements:**

5. **Massive MIMO Beamforming:** Model the transmit beamforming gain as a function of direction, using ULA (Uniform Linear Array) beam patterns.

6. **Dynamic Channel:** Introduce time-varying channel (moving UE trajectory) and study channel temporal correlation.

7. **Wideband Transfer Function:** Compute the frequency-domain channel H(f) from the delay profile and plot the coherence bandwidth directly.

**Research-level extensions:**

8. **Machine Learning Integration:** Train a neural network on the stochastic ray trace outputs to predict path loss from simplified geometric features.

9. **THz Channel Extension:** Extend to 0.1–1 THz for 6G channel modelling, adding molecular absorption and rough surface scattering.

10. **Real LiDAR-Based Environment:** Replace the stochastic building model with a real city block imported from OpenStreetMap or LiDAR point clouds.

---

## 📝 Quick Reference — Key Equations

| Quantity | Formula |
|----------|---------|
| FSPL | 20·log₁₀(4πdf/c) dB |
| Reflection Loss | −20·log₁₀(Γ) dB |
| Diffraction ν | h·√(2(d₁+d₂)/(λd₁d₂)) |
| RMS Delay Spread | √(Σ Pᵢτᵢ²/ΣPᵢ − τ̄²) |
| Doppler Shift | v·fc/c Hz |
| Coherence BW | 1/(5·στ) Hz |
| Coherence Time | 0.423/f_D,max s |
| Shannon Capacity | B·log₂(1+SNR) bps |

---

*Good luck with your viva! Remember: confidence, clear reasoning, and being honest about simplifications beats trying to bluff technical details.*
