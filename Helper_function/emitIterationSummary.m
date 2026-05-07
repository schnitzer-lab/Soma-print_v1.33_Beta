function emitIterationSummary(iterationIndex, scoreMatrix, map1, map2_tform, method, lr_cut, lambda, gmmfilter)
if ~isappdata(0, 'SomaprintIterationLogger')
    return
end

if nargin < 8 || isempty(gmmfilter)
    gmmfilter = 0;
end

logger = getappdata(0, 'SomaprintIterationLogger');
try
    [id1, id2, outputSummary, optionOutput, ~, ~, secondbest, AUC] = Somaprint_ComputeMatchStatistics( ...
        scoreMatrix, map1, map2_tform, method, lr_cut, lambda, gmmfilter, 0);
    summary = struct();
    summary.iteration = iterationIndex;
    summary.scoreMatrix = scoreMatrix;
    summary.id1 = id1;
    summary.id2 = id2;
    summary.outputSummary = outputSummary;
    summary.optionOutput = optionOutput;
    summary.secondbest = secondbest;
    summary.matchedPairs = numel(id1);
    if isempty(outputSummary)
        summary.meanScore = 0;
    else
        summary.meanScore = mean(outputSummary(:,3), 'omitnan');
    end
    summary.maxScore = max(scoreMatrix(:));
    summary.AUC = AUC;
    logger(summary);
catch
end
end
