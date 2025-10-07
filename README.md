
# Multi-Antenna GLRT Spectrum Sensing for Cognitive Radio

This repository contains a MATLAB implementation of the spectrum sensing algorithms presented in the paper:

> P. Wang, J. Fang, N. Han and H. Li, "Multiantenna-Assisted Spectrum Sensing for Cognitive Radio," in *IEEE Transactions on Vehicular Technology*, vol. 59, no. [cite_start]4, pp. 1791-1800, May 2010. [cite: 1, 2, 3, 4, 5]

The primary focus is the implementation of the paper's proposed Generalized Likelihood Ratio Test (GLRT) detector and a performance comparison against other existing methods.

## Overview

[cite_start]Cognitive Radio (CR) systems require robust and rapid spectrum sensing to detect the presence of licensed "primary users" (PUs) before using a frequency band[cite: 27, 28, 31]. [cite_start]This project simulates a scenario where a secondary user employs multiple antennas to detect a single primary user signal[cite: 6, 54].

[cite_start]The key algorithm implemented is a GLRT detector which is advantageous because it does not require prior knowledge of the primary user's signal, the channel, or the noise variance[cite: 9, 57]. [cite_start]This makes it particularly effective in real-world scenarios where noise levels can be uncertain[cite: 40]. [cite_start]The paper shows that this proposed GLRT detector offers superior performance, especially when the number of available signal samples is small—a critical requirement for vehicular applications where detection speed is key[cite: 8, 12].

This implementation replicates two key figures from the paper:
1.  [cite_start]**Comparative Analysis:** A plot comparing the Probability of Detection ($P_d$) versus Signal-to-Noise Ratio (SNR) for the proposed GLRT, Energy Detector (ED), ED with noise uncertainty (ED-U), Arithmetic-to-Geometric Mean (AGM) detector, and Maximum-to-Minimum Eigenvalue (MME) detector[cite: 288, 289].
2.  [cite_start]**GLRT Performance vs. Samples:** A plot showing how the performance of the proposed GLRT detector improves as the number of samples ($N$) increases[cite: 303].

## Directory Structure

```

.
├── GLRTmultiN.m
└── PdvsSNRAll.m

````

### File Descriptions

* [cite_start]`PdvsSNRAll.m` [cite: 671][cite_start]: This script generates a comparative performance plot of $P_d$ vs. SNR for the five key detectors analyzed in the paper: GLRT, ED, ED-U, AGM, and MME[cite: 289]. [cite_start]Users can modify parameters such as the number of antennas ($M$), number of samples ($N$), and noise uncertainty to replicate figures like Fig. 2, 3, and 4 from the paper[cite: 287, 291].

* [cite_start]`GLRTmultiN.m` [cite: 645][cite_start]: This script specifically evaluates the performance of the proposed GLRT detector across different numbers of samples ($N$)[cite: 646, 649]. [cite_start]It generates a $P_d$ vs. SNR plot with multiple curves, each corresponding to a different value of $N$, effectively replicating Figure 5 from the paper[cite: 336].

## System Requirements

* **MATLAB:** No special toolboxes are required.

## How to Run the Code

1.  Clone or download this repository.
2.  Open MATLAB.
3.  Navigate to the repository's directory.
4.  Run the desired script from the MATLAB command window or editor:
    * To compare all detectors for a fixed N:
        ```matlab
        >> PdvsSNRAll
        ```
    * To analyze the GLRT detector's performance for various N:
        ```matlab
        >> GLRTmultiN
        ```
5.  The scripts will automatically execute the simulations and generate the corresponding plots.

### Customizing Simulation Parameters

[cite_start]You can easily modify the simulation parameters within each script's "PARAMETER SETUP" section[cite: 648, 672]. Key parameters include:
* [cite_start]`M`: Number of receiver antennas[cite: 648, 672].
* [cite_start]`N` or `N_values`: Number of samples used for detection[cite: 649, 672].
* [cite_start]`Pfa_desired`: The target Probability of False Alarm[cite: 650, 674].
* [cite_start]`SNR_dB_range`: The range of SNR values (in dB) to simulate[cite: 651, 674].
* [cite_start]`noise_uncertainty_dB`: (in `PdvsSNRAll.m`) The uncertainty in noise power for the ED-U detector, in dB[cite: 673].

## Understanding the Implementation

The simulation for each detector follows a two-step process based on Monte Carlo methods.

#### 1. Threshold Calculation

To ensure a fair comparison, the detection threshold for each method is first calculated empirically. [cite_start]This is done by simulating the **null hypothesis ($H_0$)**, where only noise is present[cite: 69].
* [cite_start]For a large number of trials (`num_trials`), the test statistic for each detector is calculated based on noise-only signals[cite: 650, 677].
* The detection threshold (`gamma`) is then set to the value that results in the desired Probability of False Alarm (`Pfa_desired`). [cite_start]This is achieved by finding the `(1 - Pfa_desired)` percentile of the distribution of the test statistics under $H_0$[cite: 658, 684].

#### 2. Probability of Detection ($P_d$) Calculation

[cite_start]Once the thresholds are set, the **alternative hypothesis ($H_1$)** is simulated, where a primary user's signal is present along with noise[cite: 89].
* [cite_start]For each SNR value in the specified range, the received signal (signal + noise) is generated over many trials[cite: 687, 690].
* [cite_start]In each trial, the detector's test statistic is calculated and compared against its pre-computed threshold[cite: 694, 695, 696, 698, 699].
* [cite_start]A "detection" is counted if the statistic exceeds the threshold[cite: 665].
* [cite_start]The $P_d$ for that SNR is the total number of detections divided by `num_trials`[cite: 666].

### Test Statistics Implemented

[cite_start]The core of each detector is its unique test statistic, calculated from the eigenvalues of the received signal's sample covariance matrix ($\hat{R}_{x}$)[cite: 108]. Let the sorted eigenvalues be $\hat{\lambda}_{1} \ge \hat{\lambda}_{2} \ge ... \ge \hat{\lambda}_{M}$.

* [cite_start]**Proposed GLRT:** The ratio of the largest eigenvalue to the sum of all eigenvalues[cite: 58, 141]. [cite_start]This is the test statistic implemented as `T_GLRT`[cite: 664, 694].
    $$T_{GLRT} = \frac{\hat{\lambda}_{1}}{\sum_{m=1}^{M}\hat{\lambda}_{m}}$$
* [cite_start]**Energy Detector (ED):** The total energy of the received signal, which is proportional to the trace of the covariance matrix (i.e., the sum of its eigenvalues)[cite: 76]. [cite_start]Implemented as `T_ED`[cite: 695].
    $$T_{ED} = \sum_{n=0}^{N-1}{||x(n)||}^{2} \propto \sum_{m=1}^{M}\hat{\lambda}_{m}$$
* [cite_start]**AGM Detector:** The ratio of the arithmetic mean to the geometric mean of the eigenvalues[cite: 50, 101]. [cite_start]Implemented as `T_AGM`[cite: 698].
    $$T_{AGM} = \frac{\frac{1}{M}\sum_{m=1}^{M}\hat{\lambda}_{m}}{(\prod_{m=1}^{M}\hat{\lambda}_{m})^{1/M}}$$
* [cite_start]**MME Detector:** The ratio of the maximum eigenvalue to the minimum eigenvalue[cite: 42, 114]. [cite_start]Implemented as `T_MME`[cite: 699].
    $$T_{MME} = \frac{\hat{\lambda}_{1}}{\hat{\lambda}_{M}}$$


