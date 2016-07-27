function correctEEG(eegStruct,detrendSec)
    % Purpose is to apply 1/f^gamma scaling and detrending the EEG data (if
    % muse hasn't already done that)
    
    % Data we'll be working with
    raw = eegStruct.raw(:,2:end);
    timestamps = eegStruct.raw(:,1);
    
    % Detrend the signal
    if exist('detrendSec','var')
        
        [filter,nBin] = computeBoxCar(timestamps,detrendSec);
        
        time_average = conv(raw,filter);
        time_average = time_average(round(nBin/2):end-(round(nBin/2)));
        assert( numel(time_average) == numel(raw) );
        
        raw = raw-time_average;
        
    end
    
    % Compute 1/f correction
    [pxx,f] = pwelch(eeg_sample,220,100,220,Fs);
    
    
    
    %% Helper Functions
    function [box_car, nBin] = computeBoxCar(timestamps,seconds)
        mean_diff = mean(diff(timestamps));
        nBin = seconds/mean_diff;
        box_car = ones(1,nBin);
        box_car = box_car/sum(box_car);
    end

end