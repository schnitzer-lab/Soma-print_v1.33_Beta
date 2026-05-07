function  score_augmented=WeightingGMM(score,threshold);
    noise_idx = score < threshold;
    signal_idx = score >= threshold;
    
    % 2. Calculate the balancing multiplier
    n_noise = sum(noise_idx);
    n_signal = sum(signal_idx);
    
    % Calculate how many times we need to repeat signal points to match noise mass
    % If you want them to account for EQUAL weight:
    multiplier = round(n_noise / n_signal);
    
    % 3. Create the Balanced Augmented Dataset
    noise_data = score(noise_idx);
    oversampled_signal = repmat(score(signal_idx)', multiplier, 1);
    
    % Reconstruct as a single column vector
    score_augmented = [noise_data(:); oversampled_signal(:)];


end