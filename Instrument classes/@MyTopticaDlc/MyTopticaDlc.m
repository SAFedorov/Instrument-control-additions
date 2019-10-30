classdef MyTopticaDlc < handle
    %Class for controlling Toptica DLC 
    
    properties (SetAccess=protected)
        Device = tcpip('192.168.1.38', 1998);
   
    end
    properties (GetAccess=public, SetAccess=protected)
        % These properties use get methods to read value every time they
        % are addressed
        set_wavelength = 0.00000 % Set Wavelength in nm
        act_wavelength = 0.00000  % Actual Wavelength in nm
        set_current = 0   % Set Current in mA
        act_current = 0   % Act Current in mA
        laser_emission = 0 %0 for off, 1 for on
        rmt_wavelength_sweep_enabled = 0 %0 for disabled, 1 for enabled
        rmt_wavelength_sweep_input = 0 %specifies the BNC signal used 
        %for the analogue wavlength control. Legend:
        % 0 for Fine In 1
        % 1 for Fine In 2
        % 2 for Fast In 3
        % 3 for Fast in 4
        
        rmt_wavelength_sweep_factor = 0 %paramter specifying the factor 
        %applied to the signal in nm/V
        
        int_scan_enabled = 0
        int_scan_frequency = 0 %in Hz
        int_scan_amplitude = 0 %in V
        int_scan_offset = 0 %in V 
        int_scan_start = 0 %in V 
        int_scan_end = 0 %in V 
        int_scan_wform = 0 %0 = sine, 1 = triangle, 2 = rounded triangle
        
        
    end
    %% Constructor and destructor
    methods (Access=public)
    
        function this = MyTopticaDlc()
            if ~isOpen(this)
                disp(['Not connected to Toptica ', ...
                    'DLC. Attempting to initiate connection.'])
                openDevice(this);
                %wait for the Dlc to print to the buffer
                pause(1);
                %read out the buffer, before sending any queries.
                %Otherwise communicationn will get out of sync 
                char(fread(this.Device, [1, this.Device.BytesAvailable]));
            end
        end
    end
%     

    %% Communication methods - read functions
    methods (Access=public)
        function bool=isOpen(this)
            if strcmp(this.Device.status,'open')
            bool=1;
            else
            bool=0;
            end
        end
        
        function openDevice(this)
            this.Device.InputBufferSize = 1024;
            fopen(this.Device);
        end
        
        function closeDevice(this)
            fclose(this.Device);
        end
        
        function ret_val = readSetWavelength(this)
            %read out the set wavelength
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:ctl:wavelength-set)'),'>%f >');
            this.set_wavelength = ret_val;
        end
        
        function ret_val = readActWavelength(this)
            %read out the actual wavelength
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:ctl:wavelength-act)'),'>%f >');
            this.act_wavelength = ret_val;
        end
        
        function ret_val = readSetCurrent(this)
            %read out the set current 
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:dl:cc:current-set)'),'>%f >');
            this.set_current = ret_val;
        end
        
        function ret_val = readActCurrent(this)
            %read out the actual current
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:dl:cc:current-act)'),'>%f >');
            this.act_current = ret_val;
        end
        
        function ret_val = readLaserEmission(this)
            %read out if the laser emission is swtiched on
            ret_message = sscanf(query(this.Device, ...
                '(param-ref ''emission-button-enabled)'),'>%s >');
            
            if strcmp(ret_message, "#f")
                ret_val = 0;
            elseif strcmp(ret_message, "#t")
                ret_val = 1;
            end
            this.laser_emission = ret_val;
        end
        
        function ret_val = readRmtWavelengthSweepEnabled(this)
            %read out if the rmt wavelength sweep is enabled
            ret_message = sscanf(query(this.Device, ...
                '(param-ref ''laser1:ctl:remote-control:enabled)'),'>%s >');
            
            if strcmp(ret_message, "#f")
                ret_val = 0;
            elseif strcmp(ret_message, "#t")
                ret_val = 1;
            end
            this.rmt_wavelength_sweep_enabled = ret_val;
        end
        
        function ret_val = readRmtWavelengthSweepInput(this)
            %read out the input BNC used for the sweep
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:ctl:remote-control:signal)'),'>%f >');
            this.rmt_wavelength_sweep_input = ret_val;
        end
        
        function ret_val = readRmtWavelengthSweepFactor(this)
            %read out the input BNC used for the sweep
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:ctl:remote-control:factor)'),'>%f >');
            this.rmt_wavelength_sweep_factor = ret_val;
        end
        
        function ret_val = readIntScanEnabled(this)
            %read out if internal scan is enabled
            ret_message = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:enabled)'),'>%s >');
            
            if strcmp(ret_message, "#f")
                ret_val = 0;
            elseif strcmp(ret_message, "#t")
                ret_val = 1;
            end
            this.int_scan_enabled = ret_val;
        end
        
        function ret_val = readIntScanFrequency(this)
            %read out frequency of internal scan
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:frequency)'),'>%f >');
            this.int_scan_frequency = ret_val;
        end
        
        function ret_val = readIntScanAmplitude(this)
            %read out amplitude of internal scan
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:amplitude)'),'>%f >');
            this.int_scan_amplitude = ret_val;
        end
        
        function ret_val = readIntScanOffset(this)
            %read out amplitude of internal scan
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:offset)'),'>%f >');
            this.int_scan_offset = ret_val;
        end
        
        function ret_val = readIntScanStart(this)
            %read out amplitude of internal scan
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:start)'),'>%f >');
            this.int_scan_start = ret_val;
        end
        
        function ret_val = readIntScanEnd(this)
            %read out amplitude of internal scan
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:end)'),'>%f >');
            this.int_scan_end = ret_val;
        end
        
        function ret_val = readIntScanWform(this)
            %read out waveform of internal scan
            ret_val = sscanf(query(this.Device, ...
                '(param-ref ''laser1:scan:signal-type)'),'>%f >');
            this.int_scan_enabled = ret_val;
        end
    end
    %% Communication methods - write functions
    methods (Access=public)
        function writeSetCurrent(this, new_value)
            %change the set current using the following frwite function.
            %32 is ASCII code for a white space
            message_returned = sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:dl:cc:current-set',...
                    32, num2str(new_value),')')),'>%f >');
            if  message_returned == 2
                disp("Warning. Value exceeds allowed parameter range.");
            end 
        end
        
        function writeSetWavelength(this, new_value)
            %change the set wavelength using the following frwite function.
            %Note that 32 is ASCII code for a white space
            ret_message = sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:dl:cc:wavelength-set',...
                    32, num2str(new_value),')')),'>%f >');
            if  ret_message == 2
                disp("Warning. Value exceeds allowed parameter range.");
            elseif ret_message ~= 0
                disp("Error. Value could not be changed.");
            end         
        end
        
        function writeRmtWavelengthSweepEnabled(this, new_value)
            %enable or disable the remote wavelength sweep
            if new_value == 0
                new_param = "#f";
            elseif new_value == 1
                new_param = "#t";
            end   
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:ctl:remote-control:enabled',...
                    32, num2str(new_param),')')),'>%f >');
        end
        
        function writeRmtWavelengthSweepInput(this, new_value)
            %change the input BNC used for the remote wavelength sweep
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:ctl:remote-control:signal',...
                    32, num2str(new_value),')')),'>%f >');
        end
        function writeRmtWavelengthSweepFactor(this, new_value)
            %change the factor (in nm/V) for the remote wavelength sweep
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:ctl:remote-control:factor',...
                    32, num2str(new_value),')')),'>%f >');
        end
        
        function writeIntScanEnabled(this, new_value)
            %enable or disable the internal wavelength sweep
            if new_value == 0
                new_param = "#f";
            elseif new_value == 1
                new_param = "#t";
            end   
            
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:enabled',...
                    32, num2str(new_param),')')),'>%f >');
        end
        
        function writeIntScanAmplitude(this, new_value)
            %change the amplitude (in V) of the internal scan
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:amplitude',...
                    32, num2str(new_value),')')),'>%f >');
        end
        
        function writeIntScanOffset(this, new_value)
            %change the offset (in V) of the internal scan
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:offset',...
                    32, num2str(new_value),')')),'>%f >');
        end
        
        function writeIntScanStart(this, new_value)
            %change the offset (in V) of the internal scan
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:start',...
                    32, num2str(new_value),')')),'>%f >');
        end
        
        function writeIntScanEnd(this, new_value)
            %change the offset (in V) of the internal scan
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:end',...
                    32, num2str(new_value),')')),'>%f >');
        end
        
        function writeIntScanFrequency(this, new_value)
            %change the frequency (in Hz) of the internal scan
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:frequency',...
                    32, num2str(new_value),')')),'>%f >');
        end
        
        function writeIntScanWform(this, new_value)
            %change the waveform of the internal scan
            sscanf(query(this.Device, ...
                    strcat('(param-set! ''laser1:scan:wform',...
                    32, num2str(new_value),')')),'>%f >');
        end
    end
     %% Set and get methods
    methods
        
        function val=get.set_wavelength(this)
            val=readSetWavelength(this);
        end
        function val=get.act_wavelength(this)
            val=readActWavelength(this); 
        end
        function val=get.set_current(this)
            val=readSetCurrent(this);     
        end
        function val=get.act_current(this)
            val=readActCurrent(this);  
        end
        function val=get.laser_emission(this)
            val=readLaserEmission(this);  
        end
        function val=get.rmt_wavelength_sweep_enabled(this)
            val=readRmtWavelengthSweepEnabled(this);  
        end
        function val=get.rmt_wavelength_sweep_input(this)
            val=readRmtWavelengthSweepInput(this);  
        end
        function val=get.rmt_wavelength_sweep_factor(this)
            val=readRmtWavelengthSweepFactor(this);  
        end
        function val=get.int_scan_enabled(this)
            val=readIntScanEnabled(this);  
        end
        function val=get.int_scan_frequency(this)
            val=readIntScanFrequency(this);  
        end
        function val=get.int_scan_amplitude(this)
            val=readIntScanAmplitude(this);  
        end
        function val=get.int_scan_offset(this)
            val=readIntScanOffset(this);  
        end
        function val=get.int_scan_start(this)
            val=readIntScanStart(this);  
        end
        function val=get.int_scan_end(this)
            val=readIntScanEnd(this);  
        end
        function val=get.int_scan_wform(this)
            val=readIntScanWform(this);  
        end
        
        
    end
end

