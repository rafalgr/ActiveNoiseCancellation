% /************************************************************************
% Copyright (c) 2023
% Author: Przemyslaw Ozga
% Project name: ANC using feedback and feedforward system
%
% Project description:
% Below is implemented of NLMS algorithm with feedforward active noise
% cancellation system. Below is the sketch of the implemented system. 
%
% In the following solution, the second transfer path is not estimated 
% in any way. It occurs in the solution of the system, but does not 
% assume a secondary path.
%
%              +-----------+                       +   
% x(k) ---+--->|   P(z)    |--yp(k)----------------> sum --+---> e(k)
%         |    +-----------+                          ^-   |
%         |                                           |    |
%         |        \                                ys(k)  | 
%         |    +-----------+            +-------+     |    |
%         +--->|   NLMS    |---yw(k)----|  S(z) |-----+    |
%              +-----------+            +-------+          |
%                       \                                  |
%                        -------                           |
%                                \     Error signal        | 
%                                  ------------------------+
%
% ************************************************************************/

function results = feedforwardNLMS(signal, length, pzFilteredSig, ...
    adaptationStep, bufferSize, testCaseName, mode, getPlots)

    tic
    % Calculate and generate LMS algorithm output signal (ys(k))
    nlmsOutput = zeros(bufferSize, 1);
    tempAdaptationStep = zeros(1, bufferSize);
    identError = zeros(1, length);

    for ids = bufferSize:length
        identErrorBuffer = signal(ids:-1:ids - bufferSize + 1);
        tempAdaptationStep(ids) = ...
            adaptationStep / (identErrorBuffer' * identErrorBuffer);
        identError(ids) = pzFilteredSig(ids) - sum(nlmsOutput' * identErrorBuffer);
        nlmsOutput = ...
            nlmsOutput + tempAdaptationStep(ids) * identErrorBuffer * identError(ids);
    end

    % Make sure that output error signal are column vectors
    identError = identError(:);
    results = identError;
    elapsedTime = toc;
    disp(strcat("[INFO] Measurement " + testCaseName + " time: " + elapsedTime));

    % Report the results
    if true(mode)
        getPlots.compareOutputSignalsForEachAlgorithms( ...
            testCaseName, signal, identError);
    end
end
