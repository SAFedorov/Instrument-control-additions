% Read and save trace from RSA device
% rng_list format: {[f_min1, f_max1], [f_min2, f_max2], ...}

function rsaReadAndSave(rsa_name, rng_list, varargin)
    p = inputParser();
    addParameter(p, 'trace_name', 'rsa_trace', @ischar);
    parse(p, varargin);
    
    trace_name = p.Results.trace_name;

    C = MyCollector.instance();
    Rsa = getInstrument(C, rsa_name);

    meas_dir = createSessionPath();
    
    Rsa.rbw = 1; % Hz
    Rsa.start_freq = 0; % Hz
    
    for i = 1:length(rng_list)
        Rsa.start_freq = rng_list{i}(1);
        Rsa.stop_freq = rng_list{i}(2);
        
        Tr = readTrace(Rsa);
        
        % Add the name of acquisition instrument
        AcqMdt = MyMetadata.acq(rsa_name);
        InstrSettingsMdt = readInstrumentSettings(app.Collector);

        % Make full metadata
        Tr.UserMetadata = [AcqMdt, InstrSettingsMdt];
        
        % Save trace
        save(Tr, fullfile(meas_dir, sprintf('%s_cent%eMHz_span%eMHz', ...
            trace_name, Rsa.cent_freq, rsa.span)));
    end
end

