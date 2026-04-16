# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MATLAB-based EEG analysis pipeline for a response inhibition (Go/No-Go) task comparing two groups: **Experimental** (experienced, `exp`, 12 participants) and **Novice** (inexperienced, `nov`, 12 participants). Each participant may have multiple recording segments.

## Setup

1. Install **MATLAB R2024b** and clone **FieldTrip** from GitHub (Nov 2025 version).
2. Follow FieldTrip path setup: https://www.fieldtriptoolbox.org/faq/matlab/installation/
3. If EEGLAB is installed, remove it from the MATLAB path to avoid conflicts (EEGLAB is invoked programmatically by `my_autoica.m` only when needed).
4. Create `src/config.m` (gitignored — each developer maintains their own copy):
   ```matlab
   prj_dir = 'C:\path\to\EEG_analysis_exp1';
   addpath("utils\");
   main_channels = {'Cz', 'Fz', 'Pz'};
   groups = {'nov', 'exp'};
   conditions = {'go', 'nogo'};
   ```
5. Run scripts from `src/` in MATLAB; each script begins with `config` to load shared variables.

## Analysis Pipeline

Scripts must be run in order. Each stage reads from the previous stage's output directory.

| Stage | Script | Input → Output |
|-------|--------|---------------|
| 1 | `prepro1_flt_trl_baseline.m` | `rawdata/` → `result/prepro1/` |
| 2 | `prepro2_rm_badtrl.m` | `result/prepro1/` → `result/prepro2/` |
| 3 | `prepro3_ica.m` | `result/prepro2/` → `result/prepro3/` |
| 4 | `collect_trialinfo.m` | `result/prepro3/` → `result/trialinfo/` |
| 5 | `classification_by_label.m` | `result/prepro3/` → `result/erp_group_cond/` |
| 6 | `erp_to_freq.m` | `result/erp_group_cond/` → `result/freq_group_cond/` |
| 7 | `stat_*.m` (any order) | various result dirs → figures + stat outputs |

**Preprocessing details:**
- `prepro1`: Bandpass filter 1–100 Hz + notch 49–51 Hz, resample to 256 Hz, baseline correction (−100 to 0 ms), trial definition via custom trial functions
- `prepro2`: Visual artifact rejection (`ft_rejectvisual`) + 3SD-based outlier removal
- `prepro3`: Automatic ICA via EEGLAB + ICLabel; removes muscle (≥30%), eye/heart/line-noise/channel-noise artifacts (≥80% confidence threshold)

## Trial Definition

Participants 1–5 use `utils/mytrialfun_2.m`; participants 6–12 use `utils/mytrialfun.m`. Both read stimulus markers and behavioral CSV files to define task-locked trials. Trial codes: `1`=Go correct, `-1`=Go error, `2`=No-Go correct, `-2`=No-Go error.

## Statistical Analyses

All stat scripts use **cluster-based permutation tests (CBPT)** via FieldTrip:
- `stat_erp_cbpt.m`: ERP group comparison, 0–500 ms, 10,000 permutations, α=0.025 (two-sided), ≥4 neighbours required for cluster
- `stat_freq_cbpt.m`: Frequency bands — theta (4–7 Hz), alpha (7–13 Hz), beta (13–30 Hz), low gamma (30–45 Hz), high gamma (60–90 Hz)
- `stat_erp_ba_cbpt.m`: Brodmann Area ROI-based ERP analysis
- `stat_accuracy.m`: 2-way ANOVA (Group × Condition)
- `stat_rt.m`: Independent t-test on Go-trial response times

Neighbor definitions for spatial clustering are pre-computed in `src/utils/neighbours.mat`. Channel layout is `easycapM11.mat`.

## Key Utility Functions (`src/utils/`)

- `my_autoica.m`: Bridges FieldTrip ↔ EEGLAB for ICA; handles adaptive artifact thresholds
- `mytrialfun.m` / `mytrialfun_2.m`: Custom FieldTrip trial functions (participant-version-specific)
- `my_fig_statistics.m`: Generates standard stat figures (topomaps, time-series with significance masks)
- `my_freq_band_topomap.m`: Per-band topomap plotting
- `my_singleplot_TFR.m` / `my_multiplot_TFR.m`: Time-frequency representation plots

## Result Directory Layout

```
result/
├── prepro1/          # After filtering + trial definition
├── prepro2/          # After manual artifact rejection
├── prepro3/          # After ICA
├── trialinfo/        # Trial metadata (condition labels, RTs)
├── erp_group_cond/   # ERPs by group × condition
├── freq_group_cond/  # TFR data by group × condition
├── stat_erp_cbpt/    # CBPT results for ERPs
├── stat_freq_cbpt/   # CBPT results for frequency
└── ...               # Behavioral stats + figures
```

Files follow the naming convention `{group}_{condition}.mat` (e.g., `exp_go.mat`) for group-level data, and `{pname}_{segment}.mat` for per-participant data.

## Archive

`src/archive/` contains older or experimental scripts (response-locked analysis, earlier stat approaches). These are not part of the main pipeline and should not be modified without understanding the current alternatives.
