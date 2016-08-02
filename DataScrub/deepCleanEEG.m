function [eegStruct,gamma]= cleanEEG(eegStruct,detrendSec)
    % Purpose is to de-trend signal and apply 1/f^gamma scaling and
    % detrending the EEG data (if muse hasn't already done that)
    %
    % This function is just a prototype and is untested. The autoregressive
    % filter construction part hasn't been written, and needs to be filled
    % in.
    %
    % The de-trending part should work with small fixes, for sufficiently
    % long time windows to de-trend over per point.
    
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
    
    %% 1/f correction
    
    % Get sampling rate
    fs = double(eegStruct.configuration.eeg_output_frequency_hz);
    
    % Fit 1/f ^ gamma -- gamma needs to be determined to scale out 1/f
    % noise
    
    s = fitoptions('Method','NonlinearLeastSquares',...
        'Lower',0.2,'Upper',10,'StartPoint',1);
    ft = fittype('1/(x^g)','options',s);
    counter = 1; fitOut=[]; gof=[];
    
    for chan = 2:size(sig_fft,2) % 1st column is timestamp column, so excluded
        
        for t = 1 : detrendSec : size(raw,1)-detrendSec % move over time windows and find the gamma coefficient
            
            % Get fft
            sig_fft = fft(raw(chan,t:t+detrendSec),...
                size(raw(chan,t:t+detrendSec),1),1);
            
            % Get frequencies
            f = [0:(fs/size(sig_fft,1)):fs-fs/size(sig_fft,1)]';
            
            % Fit gamma
            [fitOut(counter), gof(counter)] = fit( ...
                f(2:round(end/2)), ...
                abs(sig_fft(2:round(end/2),chan)), ...
                ft );
            
            % Warn, if low gof -- might need to tweak s (fit options)
            if abs(gof.adjrsquare) < 0.1; warning('Low fit'); end;
            
            % Increment counter
            counter = counter + 1;
        end
        
    end
        
    % Acquire median g.
    gVector = cat({fitOut.g});
    g = median(gVector);
    
    % Here we generate a time filter and apply it to the entirity of the
    % signal
    new_sig(:,chan) = scaleFFT(f, sig_fft(:,chan) , g );
    
    
    %% Helper Functions
    function sig = scaleFFT(f, sig, g)
        
        
        % REQUIRES AR-FITTING FILTER
        % Time-domain signal filter has to be constructed here and needs to
        % attenuate signal to the same degree at the measured pink noise.
        
    end
    
    function [box_car, nBin] = computeBoxCar(timestamps,seconds)
        mean_diff = mean(diff(timestamps));
        nBin = seconds/mean_diff;
        box_car = ones(1,nBin);
        box_car = box_car/sum(box_car);
    end

end