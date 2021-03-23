    %% Save function violates parfor because MATLAB cannot determine which variables from the 
    % workspace will be saved.  The solution is to move the SAVE calls to a
    % separate function and call that function from inside the parfor loop
        

function [] = savadata(series_dir, trackedFeatureInfo, trackedFeatureIndx, trackStartRow, numSegments, tracksFinal )
    
    save([series_dir '/trackedFeatureInfo.mat'], 'trackedFeatureInfo');
    save([series_dir '/trackedFeatureIndx.mat'], 'trackedFeatureIndx');
    save([series_dir '/trackStartRow.mat'], 'trackStartRow');
    save([series_dir '/numSegments_.mat'], 'numSegments');
    save([series_dir '/tracksFinal.mat'], 'tracksFinal');
    
end