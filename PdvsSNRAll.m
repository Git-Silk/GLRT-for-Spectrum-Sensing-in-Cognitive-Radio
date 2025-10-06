% COMPARATIVE SPECTRUM SENSING PERFORMANCE
% Replicates the comparison plot of Pd vs. SNR for the five key detectors 
% (GLRT, ED, ED-U, AGM, MME) in the paper (e.g., Figure 3).

clear; close all; clc;

%% 1. PARAMETER SETUP
M = 4;        % Number of antennas
N = 100;        % Number of samples
K_rank = 1;   % Rank of the signal (Single PU)
sigma_w_sq = 1; % True noise variance (normalized to 1)
noise_uncertainty_dB = 1; % Noise uncertainty for ED-U (3 dB as used in Fig 3)
num_trials = 100000;
Pfa_desired = 0.01; 
SNR_dB_range = -15:1:0; 
num_snr = length(SNR_dB_range);

% Initialize arrays to store Pd results
Pd_GLRT = zeros(1, num_snr);
Pd_ED_Ideal = zeros(1, num_snr);
Pd_EDU = zeros(1, num_snr);
Pd_AGM = zeros(1, num_snr);
Pd_MME = zeros(1, num_snr);

%% 2. THRESHOLD CALCULATION (Under H0: Noise Only)
% Thresholds are calculated from the statistical distribution of the test statistic 
% under H0 to ensure the Pfa_desired (0.01) is met.

T_H0 = zeros(num_trials, 5); % Matrix to store H0 statistics for all 5 detectors

for i = 1:num_trials
    % Generate noise-only signal (CSCG, variance=1)
    W_H0 = (randn(M, N) + 1i * randn(M, N)) / sqrt(2);
    Rx_H0 = (W_H0 * W_H0') / N;
    eigenvalues = sort(eig(Rx_H0), 'descend');
    
    lambda_1 = eigenvalues(1);
    sum_lambdas = sum(eigenvalues);
    
    % --- Test Statistics under H0 ---
    % 1. GLRT (Proposed): Ratio of Max Lambda to Sum of Lambdas
    T_H0(i, 1) = lambda_1 / sum_lambdas;
    
    % 2. ED (Ideal Noise): Total Energy
    T_H0(i, 2) = N * sum_lambdas;
    
    % 4. AGM: Arithmetic Mean / Geometric Mean
    geometric_mean = prod(eigenvalues)^(1/M);
    arithmetic_mean = sum_lambdas / M;
    T_H0(i, 4) = arithmetic_mean / geometric_mean;
    
    % 5. MME: Ratio of Max to Min Eigenvalue
    T_H0(i, 5) = eigenvalues(1) / eigenvalues(M);
end

% Calculate Thresholds (gamma) as the (1-Pfa)-th percentile of the H0 distributions
gamma_GLRT = prctile(T_H0(:, 1), (1 - Pfa_desired) * 100);
gamma_ED_Ideal = prctile(T_H0(:, 2), (1 - Pfa_desired) * 100);
gamma_AGM = prctile(T_H0(:, 4), (1 - Pfa_desired) * 100);
gamma_MME = prctile(T_H0(:, 5), (1 - Pfa_desired) * 100);

% For ED-U, the threshold is the ideal ED threshold multiplied by the uncertainty factor
noise_uncertainty_linear = 10^(noise_uncertainty_dB / 10);
gamma_EDU_Incorrect = gamma_ED_Ideal * noise_uncertainty_linear;


%% 3. PD CALCULATION (Under H1: Signal + Noise)
for s_idx = 1:num_snr
    SNR_dB = SNR_dB_range(s_idx);
    SNR_linear = 10^(SNR_dB / 10);
    
    % Initialize detection counters
    detect_GLRT = 0;
    detect_ED_Ideal = 0;
    detect_EDU = 0;
    detect_AGM = 0;
    detect_MME = 0;

    for i = 1:num_trials
        
        % --- Generate Signal (Rank-1) and Noise under H1 ---
        h = (randn(M, 1) + 1i * randn(M, 1)) / sqrt(2);
        d = (randn(1, N) + 1i * randn(1, N)) / sqrt(2);
        
        signal = sqrt(SNR_linear) * h * d;
        noise = (randn(M, N) + 1i * randn(M, N)) / sqrt(2); 
        X_H1 = signal + noise;
        
        % --- Core Calculation ---
        Rx_H1 = (X_H1 * X_H1') / N;
        eigenvalues = sort(eig(Rx_H1), 'descend');
        
        lambda_1 = eigenvalues(1);
        sum_lambdas = sum(eigenvalues);
        
        % --- Test Statistics and Decision ---
        
        % 1. GLRT: Ratio to Total Power
        T_GLRT = lambda_1 / sum_lambdas;
        if T_GLRT >= gamma_GLRT; detect_GLRT = detect_GLRT + 1; end
        
        % 2. ED (Ideal Noise): Total Energy
        T_ED = N * sum_lambdas;
        if T_ED >= gamma_ED_Ideal; detect_ED_Ideal = detect_ED_Ideal + 1; end

        % 3. ED-U (Ideal Noise, Incorrect Threshold)
        if T_ED >= gamma_EDU_Incorrect; detect_EDU = detect_EDU + 1; end

        % 4. AGM: Arithmetic Mean / Geometric Mean
        geometric_mean = prod(eigenvalues)^(1/M);
        arithmetic_mean = sum_lambdas / M;
        T_AGM = arithmetic_mean / geometric_mean;
        if T_AGM >= gamma_AGM; detect_AGM = detect_AGM + 1; end

        % 5. MME: Ratio of Max to Min Eigenvalue
        T_MME = eigenvalues(1) / eigenvalues(M);
        if T_MME >= gamma_MME; detect_MME = detect_MME + 1; end
    end
    
    % Store the Pd results
    Pd_GLRT(s_idx) = detect_GLRT / num_trials;
    Pd_ED_Ideal(s_idx) = detect_ED_Ideal / num_trials;
    Pd_EDU(s_idx) = detect_EDU / num_trials;
    Pd_AGM(s_idx) = detect_AGM / num_trials;
    Pd_MME(s_idx) = detect_MME / num_trials;
end

%% 4. PLOTTING THE RESULTS
figure;
hold on;
plot(SNR_dB_range, Pd_GLRT, 'r-', 'LineWidth', 2, 'DisplayName', 'Proposed GLRT');
plot(SNR_dB_range, Pd_AGM, 'b-o', 'MarkerSize', 5, 'DisplayName', 'AGM Detector');
plot(SNR_dB_range, Pd_MME, 'k^-', 'MarkerSize', 5, 'DisplayName', 'MME Detector');
plot(SNR_dB_range, Pd_ED_Ideal, 'k--', 'LineWidth', 1.5, 'DisplayName', 'ED (Ideal)');
plot(SNR_dB_range, Pd_EDU, 'b-*', 'LineWidth', 1.5, 'DisplayName', ['ED-U (', num2str(noise_uncertainty_dB), ' dB Uncertainty)']);

grid on;
xlabel('Signal-to-Noise Ratio (SNR) [dB]');
ylabel('Probability of Detection (P_d)');
title(['Detector Performance Comparison (M=', num2str(M), ', N=', num2str(N), ', P_{fa}=', num2str(Pfa_desired), ')']);
legend('Location', 'SouthEast');
ylim([0 1]);
xlim([min(SNR_dB_range) max(SNR_dB_range)]);
hold off;
