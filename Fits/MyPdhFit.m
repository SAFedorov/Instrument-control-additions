% Fit for PDH

classdef MyPdhFit < MyFit
    
    methods (Access = public)
        function this = MyPdhFit(varargin)
            this@MyFit( ...
                'fit_name',         'PDH', ...
                'fit_function',     'MyPdhFit.pdhSignal(x,a,b,c,d,e,f)', ...
                'fit_tex',          '$$a \frac{c\delta (c(1-\delta^2+c^2)\cos(\phi)+(1+\delta^2+c^2)\sin(\phi))}{(1+\delta^2)(1+(\delta+c)^2)(1+(\delta-c)^2)}+e,\, \delta = \frac{\Delta-b}{d}$$', ...
                'fit_params',       {'a','b','c','d','e','f'}, ...
                'fit_param_names',  {'Amplitude','Center','Width','Modulation','Offset','Phase'}, ...
                varargin{:});
        end
    end
    
    methods (Access = public, Static)
        function val = pdhSignal(x, a, x0, rw, mod_freq, offset, phi)
            
            % a     - resonance amplitude
            % x0    - center shift
            % rw    - resonance width
            % phi   - demodulation phase
            
            d = 2*(x-x0)/rw;    % normalized detuning
            s = 2*mod_freq/rw;  % sideband resolution factor
            
            den = (1+d.^2).*(1+(d+s).^2).*(1+(d-s).^2);
            val = a*s*d.*(s*(1-d.^2+s.^2)*cos(phi)+(1+d.^2+s.^2)*sin(phi))./den + ...
                offset;
        end
    end
    
    methods (Access = protected)
        
        function createUserParamList(this)
            addUserParam(this, 'mod_freq', ...
                'title',        'Modulation frequency (MHz)', ...
                'editable',     'on', ...
                'default',      1);
            addUserParam(this, 'lw', ...
                'title',        'Resonance linewidth (MHz)', ...
                'editable',     'off');
        end
        
        function calcUserParams(this)
            this.lw = this.mod_freq*this.param_vals(3)/this.param_vals(4);
        end
        
        function calcInitParams(this)
            ind = this.data_selection;
            
            x = this.Data.x(ind);
            y = this.Data.y(ind);
            
            this.param_vals = [1,0,1,1,0,0];
            this.lim_upper = [Inf,Inf,Inf,Inf,Inf,pi];
            this.lim_lower = [-Inf,-Inf,0,-Inf,-Inf,-pi];

            %Finds peaks on the positive signal (max 1 peak)
            rng_x = max(x)-min(x);
            try
                [max_val,max_loc,max_width,max_prom] = findpeaks(y,x,...
                    'MinPeakDistance',rng_x/2,'SortStr','descend',...
                    'NPeaks',1);
            catch ME
                warning(ME.message)
                max_prom = 0;
            end

            %Finds peaks on the negative signal (max 1 peak)
            try
                [min_val,min_loc,min_width,min_prom] = findpeaks(-y,x,...
                    'MinPeakDistance',rng_x/2,'SortStr','descend',...
                    'NPeaks',1);
            catch ME
                warning(ME.message)
                min_prom = 0;
            end

            if min_prom==0 || max_prom==0
                warning(['No peaks were found in the data, giving ' ...
                    'default initial parameters to fit function'])
                return
            end
            
            % Amplitude
            p_in(1) = (max_val+min_val)*3/(2*sqrt(2));
            
            % Location of the center
            p_in(2) = (min_loc+max_loc)/2;
            
            % Modulation frequency
            ind = (y-mean(y)).^2 > 0.2*max((y-mean(y)).^2);
            p_in(4) = (max(x(ind))-min(x(ind)))/2;
            
            % Resonance width
            p_in(3) = abs(min_loc-max_loc)/2;
            
            % Offset
            p_in(5) = mean(y);
            
            % Phase
            p_in(6) = 0;

            this.param_vals = p_in;
            this.lim_lower(3) = 0.01*p_in(3);
            this.lim_upper(3) = 100*p_in(3);
        end
        
        function genSliderVecs(this)
            genSliderVecs@MyFit(this)
            
            try 
                
                %We choose to have the slider go over the range of
                %the x-values of the plot for the center of the
                %Lorentzian.
                this.slider_vecs{2}=...
                    linspace(this.Fit.x(1),this.Fit.x(end),101);
                %Find the index closest to the init parameter
                [~,ind]=...
                    min(abs(this.param_vals(2)-this.slider_vecs{2}));
                %Set to ind-1 as the slider goes from 0 to 100
                set(this.Gui.(sprintf('Slider_%s',...
                    this.fit_params{2})),'Value',ind-1);
            catch 
            end
        end
    end
end

