
# Multi-Antenna GLRT Spectrum Sensing for Cognitive Radio

This repository contains a MATLAB implementation of the spectrum sensing algorithms presented in the paper:

> P. Wang, J. Fang, N. Han and H. Li, "Multiantenna-Assisted Spectrum Sensing for Cognitive Radio," in *IEEE Transactions on Vehicular Technology*, vol. 59, no. 4, pp. 1791-1800, May 2010. 

The primary focus is the implementation of the paper's proposed Generalized Likelihood Ratio Test (GLRT) detector and a performance comparison against other existing methods.

## PPT
   - [Presentation](https://www.canva.com/design/DAGxwT6kUFg/xisFZ-Rxi00_JspBcrLj6A/edit?utm_content=DAGxwT6kUFg&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)
## Overview

Cognitive Radio (CR) systems require robust and rapid spectrum sensing to detect the presence of licensed "primary users" (PUs) before using a frequency band.This project simulates a scenario where a secondary user employs multiple antennas to detect a single primary user signal.

The key algorithm implemented is a GLRT detector which is advantageous because it does not require prior knowledge of the primary user's signal, the channel, or the noise variance. This makes it particularly effective in real-world scenarios where noise levels can be uncertain. The paper shows that this proposed GLRT detector offers superior performance, especially when the number of available signal samples is small—a critical requirement for vehicular applications where detection speed is key.

This implementation replicates two key figures from the paper:
1.  **Comparative Analysis:** A plot comparing the Probability of Detection ($P_d$) versus Signal-to-Noise Ratio (SNR) for the proposed GLRT, Energy Detector (ED), ED with noise uncertainty (ED-U), Arithmetic-to-Geometric Mean (AGM) detector, and Maximum-to-Minimum Eigenvalue (MME) detector.
2.  **GLRT Performance vs. Samples:** A plot showing how the performance of the proposed GLRT detector improves as the number of samples ($N$) increases.

## Directory Structure

```

.
├── GLRTmultiN.m
└── PdvsSNRAll.m

````

### File Descriptions

* `PdvsSNRAll.m` : This script generates a comparative performance plot of $P_d$ vs. SNR for the five key detectors analyzed in the paper: GLRT, ED, ED-U, AGM, and MME. Users can modify parameters such as the number of antennas ($M$), number of samples ($N$), and noise uncertainty to replicate figures like Fig. 2, 3, and 4 from the paper.

* `GLRTmultiN.m` : This script specifically evaluates the performance of the proposed GLRT detector across different numbers of samples ($N$). It generates a $P_d$ vs. SNR plot with multiple curves, each corresponding to a different value of $N$, effectively replicating Figure 5 from the paper.

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

You can easily modify the simulation parameters within each script's "PARAMETER SETUP" section. Key parameters include:
* `M`: Number of receiver antennas.
* `N` or `N_values`: Number of samples used for detection.
* `Pfa_desired`: The target Probability of False Alarm.
* `SNR_dB_range`: The range of SNR values (in dB) to simulate.
* `noise_uncertainty_dB`: (in `PdvsSNRAll.m`) The uncertainty in noise power for the ED-U detector, in dB.




