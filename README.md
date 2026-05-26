# 5G mmWave Propagation with Stochastic Ray Tracing

<div align="center">

![MATLAB](https://img.shields.io/badge/MATLAB-R2021a+-blue?style=for-the-badge&logo=mathworks)
![5G](https://img.shields.io/badge/5G-mmWave-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**A complete MATLAB simulation of 5G millimeter-wave signal propagation in urban environments using stochastic geometric ray tracing.**

*Wireless Communication Engineering | Final Project Submission*

</div>

---

## 📋 Project Overview

This project models and simulates **5G New Radio (NR) mmWave** signal propagation using a stochastic ray tracing methodology applied to a randomly generated urban environment. The simulation accounts for all major propagation mechanisms that distinguish mmWave communications from sub-6 GHz systems.

### Frequencies Analysed
| Band | Frequency | Primary Application |
|------|-----------|---------------------|
| n257 | **28 GHz** | Urban macro / small cell |
| n260 | **39 GHz** | Urban small cell |
| n261 | **60 GHz** | Indoor / dense small cell |

---

## ✨ Features

- **Stochastic Ray Tracing** — randomised multi-ray propagation engine with configurable ray count and interaction probabilities
- **Reflection Modelling** — material-based amplitude reflection coefficients (concrete, glass, brick, metal)
- **Knife-Edge Diffraction** — Fresnel-Kirchhoff parameter with Lee's piecewise loss formula
- **Building Penetration** — ITU-R P.2040-based material penetration losses
- **Free-Space Path Loss** — exact FSPL with atmospheric oxygen absorption and rain attenuation
- **RMS Delay Spread** — computed from power-weighted multipath delay profile
- **Doppler Frequency Shift** — effective Doppler based on UE velocity and AoA angular spread
- **Stochastic Urban Environment** — randomly placed buildings (20 structures) with material assignments
- **9 Professional Plots** — auto-saved as PNG files in `/results`

---

## 📁 Repository Structure

```
5G mmWave Propagation with Stochastic Ray Tracing/
│
├── 📂 src/                          # MATLAB source code
│   ├── main.m                       # ← START HERE: main simulation script
│   ├── define_sim_params.m          # All tunable simulation parameters
│   ├── generate_urban_env.m         # Stochastic urban environment generator
│   ├── stochastic_ray_trace.m       # Core multi-ray propagation engine
│   ├── calc_path_loss.m             # FSPL + atmospheric + rain loss
│   ├── calc_reflection.m            # Material-based reflection loss
│   ├── calc_diffraction.m           # Knife-edge diffraction loss
│   ├── calc_penetration.m           # Building penetration loss
│   ├── calc_delay_spread.m          # RMS delay spread computation
│   ├── calc_doppler.m               # Effective Doppler shift calculation
│   └── plot_results.m               # All figure generation & saving
│
├── 📂 results/                      # Auto-generated PNG plots
│   ├── fig1_path_loss_vs_distance.png
│   ├── fig2_excess_loss.png
│   ├── fig3_delay_spread.png
│   ├── fig4_doppler_shift.png
│   ├── fig5_multipath_count.png
│   ├── fig6_urban_environment_map.png
│   ├── fig7_path_loss_cdf.png
│   ├── fig8_delay_spread_cdf.png
│   └── fig9_summary_dashboard.png
│
├── 📂 report/                       # Technical report
│   └── 5G_mmWave_Propagation_Report.md
│
├── 📂 docs/                         # Supporting documentation
│   └── viva_preparation.md
│
└── README.md                        # This file
```

---

## 🔧 MATLAB Requirements

| Requirement | Details |
|-------------|---------|
| **MATLAB Version** | R2021a or newer (R2022b+ recommended) |
| **Toolboxes** | **None required** — uses only base MATLAB |
| **Operating System** | Windows / macOS / Linux |
| **Memory** | ≥ 4 GB RAM recommended |
| **Disk Space** | ~50 MB for code + generated figures |

> ✅ No Phased Array Toolbox, Communications Toolbox, or Antenna Toolbox required.

---

## 🚀 How to Run

### Step 1 — Open MATLAB and Set Working Directory
```matlab
% Navigate to the src/ folder in MATLAB's Current Folder browser
% or use the command:
cd('path\to\project\src')
```

### Step 2 — Run the Main Script
```matlab
run('main.m')
% or simply type:
main
```

### Step 3 — Watch the Console Output
The simulation prints live status messages:
```
==========================================================
 5G mmWave Stochastic Ray Tracing Simulation
==========================================================

[INFO] Frequencies under test: 28  39  60 GHz
[INFO] Distance range: 10 – 500 m
[INFO] Number of rays per scenario: 50

[INFO] Generating stochastic urban environment ...
[INFO] Environment generated: 20 buildings, 80 obstacles

----------------------------------------------------------
[SIM] Frequency: 28 GHz
----------------------------------------------------------
[INFO] Mean path loss      : 127.45 dB
[INFO] Mean delay spread   : 12.38 ns
...

[INFO] All 9 figures generated and saved.
==========================================================
 Simulation Complete. Results saved in ../results/
==========================================================
```

### Step 4 — View Results
Open the `results/` folder to find all 9 PNG plots automatically saved.

---

## 📊 Expected Outputs

| Figure | Description |
|--------|-------------|
| `fig1_path_loss_vs_distance.png` | Total path loss vs distance (log scale) for all 3 frequencies |
| `fig2_excess_loss.png` | Additional attenuation beyond free-space path loss |
| `fig3_delay_spread.png` | RMS delay spread vs distance (ns) |
| `fig4_doppler_shift.png` | Mean Doppler shift bar chart per frequency |
| `fig5_multipath_count.png` | Number of significant multipath rays vs distance |
| `fig6_urban_environment_map.png` | 2D top-view map of buildings, TX, and RX |
| `fig7_path_loss_cdf.png` | Empirical CDF of path loss |
| `fig8_delay_spread_cdf.png` | Empirical CDF of RMS delay spread |
| `fig9_summary_dashboard.png` | 4-panel summary dashboard |

---

## 🏗️ Simulation Design Overview

### Urban Environment Model
- 500 m × 500 m simulation area
- 20 stochastically placed buildings (10–40 m height, 15–50 m footprint)
- Four building materials: **concrete** (50%), **brick** (25%), **glass** (15%), **metal** (10%)
- Random seed fixed at `42` for reproducibility

### Ray Tracing Engine
- 50 rays launched per TX-RX distance point
- Each ray undergoes 1–5 random interactions (reflect / diffract / penetrate)
- LOS probability follows 3GPP TR 38.901 UMa formula: `P_LOS = min(18/d, 1) × (1-exp(-d/36)) + exp(-d/36)`
- All ray power contributions summed in the linear domain

### Key Propagation Parameters
| Parameter | Value |
|-----------|-------|
| TX Power | 30 dBm (1 W) |
| TX Antenna Gain | 15 dBi |
| RX Antenna Gain | 10 dBi |
| UE Velocity | 30 m/s (108 km/h) |
| Channel Bandwidth | 400 MHz |
| Concrete Reflection Γ | 0.85 |
| Glass Penetration Loss | 3 dB |
| Concrete Penetration Loss | 20 dB |
| Oxygen Absorption @ 60 GHz | 15 dB/km |

---

## 📚 References

1. 3GPP TR 38.901 V17.0.0 — "Study on channel model for frequencies from 0.5 to 100 GHz"
2. ITU-R P.2040-1 — "Effects of building materials and structures on radiowave propagation"
3. Rappaport, T.S. et al., "Millimeter Wave Mobile Communications for 5G Cellular", *IEEE Access*, 2013
4. Lee, W.C.Y., "Mobile Communications Engineering", 2nd ed., McGraw-Hill
5. ITU-R P.676-12 — "Attenuation by atmospheric gases and related effects"

---

## 👤 Author

**Aditya Singh Rathore**
Wireless Communication Engineering
5G mmWave Propagation Project

---

## 📄 License

This project is submitted as academic coursework. Code is available for educational reference under the MIT License.
