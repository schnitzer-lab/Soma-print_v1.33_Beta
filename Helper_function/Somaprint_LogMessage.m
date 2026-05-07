function Somaprint_LogMessage(message, varargin)
% Somaprint_LogMessage
% Print to the MATLAB command window and optionally mirror the message
% into the GUI if a live logger callback is registered.

if nargin < 1 || isempty(message)
    return
end

appendNewline = true;
if nargin >= 2
    appendNewline = varargin{1};
end

if appendNewline
    fprintf('%s\n', message);
else
    fprintf('%s', message);
end

logger = [];
if isappdata(0, 'SomaprintLogger')
    logger = getappdata(0, 'SomaprintLogger');
end

if ~isempty(logger)
    try
        logger(message, appendNewline);
    catch
    end
end

drawnow limitrate;
end
