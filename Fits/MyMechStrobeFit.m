% Stroboscopic exponential fit with user parameters defined for convenient
% characterization of mechanical resonators. Recognize autonomously the
% strobe gates and discards the data outside of these gates.

classdef MyMechStrobeFit < MyMechExponentialFit
    
    properties (GetAccess = public, SetAccess = protected)
        TdCursor  MyCursor
        h_sel_data
    end
    
    methods (Access = public)
        function this = MyMechStrobeFit(varargin)
            
                this@MyMechExponentialFit(varargin{:})
                
                if ~isempty(this.Axes)

                    %Add a horizontal cursor to set the threshold for strobe
                    %gates
                    ylim = this.Axes.YLim;
                    pos = ylim(1)*((ylim(2)/ylim(1))^0.4);

                    this.TdCursor = MyCursor(this.Axes, ...
                    'orientation',  'horizontal', ...
                    'position',     pos, ...
                    'Label',        'Dark threshold', ...
                    'Color',        [0.6, 0, 0]);
                end
                
            
        end
        
        %Include deletion of horizontal cursor when window is shut down
        
        function delete(this)
            delete@MyExponentialFit(this);
            if ~isempty(this.TdCursor)
                delete(this.TdCursor);
            end
        end    
        
    end
    
    methods (Access = protected)
        
        function createUserParamList(this)
            createUserParamList@MyMechExponentialFit(this)
            addUserParam(this,'ltime_start', 'title', 'Exclusion Interval Gate On (s)',...
                'editable', 'on', 'default', 0.5);
            addUserParam(this,'ltime_end', 'title', 'Exclusion Interval Gate Off (s)',...
                'editable', 'on', 'default', 0.1);
        end
        
        %Re-define the data selection, including the threshold for
        %detecting strobes
                
        function ind = findDataSelection(this)
            
            if ~isempty(this.ltime_end)
                lock_time_end=this.ltime_end;
            else
                lock_time_end=0.1;
            end       
            
            if ~isempty(this.ltime_start)
                lock_time_start=this.ltime_start;
            else
                lock_time_start=0.5;
            end
            
            if ~isempty(this.TdCursor)
                ymin=this.TdCursor.value;
                if ymin>max(this.Data.y)
                    ymin=0;
                    warning(['The selected threshold is too high for the data ',...
                    'range. It has been reset to 0.']);
                end
            else
                ymin=0;
            end
            
            ind_temp = (this.Data.y>ymin);
            ind=false(size(ind_temp));

            %Find transition times

            ind_temp=[0;diff(ind_temp)];

            %Offset transition times by lock time         
            
            strobe_on_times=this.Data.x(ind_temp==1)+lock_time_start;
            strobe_off_times=this.Data.x(ind_temp==-1)-lock_time_end;            
            
            %Handle the case in which no transitions are found
            
            if ~any(ind_temp)
                if numel(strobe_on_times)==0
                    strobe_on_times=this.Data.x(1)+lock_time_start;
                end
                if numel(strobe_off_times)==0
                    strobe_off_times=this.Data.x(end);
                end
            else
                
                %Handle strobes beginning or ending at the beginning or
                %end of the trace
                
                if numel(strobe_off_times) >=1 && numel(strobe_on_times) >=1
                    if strobe_off_times(1) < strobe_on_times(1)
                    strobe_on_times=...
                        [this.Data.x(1)+lock_time_start;strobe_on_times];
                    end
                end
                if numel(strobe_on_times) == numel(strobe_off_times)+1
                    strobe_off_times=[strobe_off_times;this.Data.x(end)];
                end
            end          

            %Construct data selection
             
            for k=1:numel(strobe_on_times)
                on_time=strobe_on_times(k);
                off_time=strobe_off_times(k);
                ind=ind | (this.Data.x<=off_time & this.Data.x >=on_time);
            end
            
            %Look for vertical cursors
            
            if this.enable_range_cursors
                xmin = min(this.RangeCursors.value);
                xmax = max(this.RangeCursors.value);
                ind = (this.Data.x>xmin & this.Data.x<xmax & ind);
            end
        end     
       
    end
    
 
end
