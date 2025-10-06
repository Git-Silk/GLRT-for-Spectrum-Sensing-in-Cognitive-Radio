% GLRT PERFORMANCE VS. SAMPLES (N)
% This script generates the Probability of Detection (Pd) vs. SNR plot
% for the Proposed GLRT detector across different numbers of samples (N),
% replicating the concept of Figure 5 in the paper.

clear; close all; clc;

%% 1. PARAMETER SETUP
M = 4;        % Number of antennas (Fixed)
N_values = [4, 6, 8, 100, 500, 2000]; % Different number of samples (N) to test
sigma_w_sq = 1; % True noise variance (normalized to 1)
num_trials = 10000; % Number of simulation runs for statistical accuracy
Pfa_desired = 0.01; % Fixed Probability of False Alarm
SNR_dB_range = -25:1:10; % Range of SNR values to test (in dB)

% Initialize matrix to store Pd results (Rows=N_values, Cols=SNR_dB_range)
Pd_results = zeros(length(N_values), length(SNR_dB_range));

%% 2. MAIN LOOP: Iterate Through Different N Values
for n_idx = 1:length(N_values)
    N = N_values(n_idx);
    fprintf('--- Starting simulation for N = %d ---\n', N);

    % --- A. Calculate Empirical Threshold (gamma_GLRT) for the current N ---
    % Since N is small, we use the empirical percentile method for robustness.
    T_H0 = zeros(1, num_trials); 
    
    for i = 1:num_trials
        % Generate noise-only signal (CSCG, variance=1)
        W_H0 = (randn(M, N) + 1i * randn(M, N)) / sqrt(2);
        Rx_H0 = (W_H0 * W_H0') / N;
        eigenvalues = sort(eig(Rx_H0), 'descend');
        
        % GLRT Test Statistic: Ratio of Max Lambda to Sum of Lambdas
        T_H0(i) = eigenvalues(1) / sum(eigenvalues);
    end
    
    % Threshold is the (1-Pfa) percentile of the H0 distribution
    gamma_GLRT = prctile(T_H0, (1 - Pfa_desired) * 100);

    % --- B. PD CALCULATION (Under H1: Signal + Noise) ---
    for s_idx = 1:length(SNR_dB_range)
        SNR_dB = SNR_dB_range(s_idx);
        SNR_linear = 10^(SNR_dB / 10);
        
        detect_GLRT = 0;
        
        for i = 1:num_trials
            
            % Generate Signal (Rank-1) and Noise under H1
            h = (randn(M, 1) + 1i * randn(M, 1)) / sqrt(2);
            d = (randn(1, N) + 1i * randn(1, N)) / sqrt(2);
            
            signal = sqrt(SNR_linear) * h * d;
            noise = (randn(M, N) + 1i * randn(M, N)) / sqrt(2); 
            X_H1 = signal + noise;
            
            % Core Calculation
            Rx_H1 = (X_H1 * X_H1') / N;
            eigenvalues = sort(eig(Rx_H1), 'descend');
            
            % GLRT Test Statistic and Decision
            T_GLRT = eigenvalues(1) / sum(eigenvalues);
            if T_GLRT >= gamma_GLRT
                detect_GLRT = detect_GLRT + 1;
            end
        end
        
        % Store the Pd result
        Pd_results(n_idx, s_idx) = detect_GLRT / num_trials;
    end
end


%% 3. PLOTTING THE RESULTS
figure;
hold on;
colors = {'k','k-*','k-s','kx-','k^-','k-o'}; 

for n_idx = 1:length(N_values)
    N = N_values(n_idx);
    plot(SNR_dB_range, Pd_results(n_idx, :), colors{n_idx}, ...
         'LineWidth', 2,'MarkerSize',8, 'DisplayName', ['N = ', num2str(N)]);
end

grid on;
xlabel('Signal-to-Noise Ratio (SNR) [dB]');
ylabel('Probability of Detection (P_d)');
title(['Proposed GLRT Performance vs. Number of Samples (M=', num2str(M), ', P_{fa}=', num2str(Pfa_desired), ')']);
legend('Location', 'SouthEast');
ylim([0 1]);
xlim([min(SNR_dB_range) max(SNR_dB_range)]);
hold off;
