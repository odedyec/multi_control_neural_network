classdef ControllerBase < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        state_shape
        output_shape
        output_upper_sat
        output_lower_sat
    end
    
    methods(Access = public)
        function obj = ControllerBase(n, m, gu)
            obj.state_shape = n;
            obj.output_shape = m;
            obj.output_upper_sat = gu(1:m);
            obj.output_lower_sat = -gu(m+1:end);
        end
        
        function u = controller_imp(obj, state)
            u = 0;
        end
        
        function u = control(obj, state)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if length(state) ~= obj.state_shape
                error('State dimension error')
            end
            u = obj.controller_imp(state);
            u = obj.sat(u);
        end
        
        function u = sat(obj, u)
            %SAT Summary of this function goes here
            %   Detailed explanation goes here
            for i=1:obj.output_shape
                if u(i) < obj.output_lower_sat(i)
                    u(i) = obj.output_lower_sat(i);
                elseif u(i) > obj.output_upper_sat(i)
                    u(i) = obj.output_upper_sat(i);
                end
            end
        end


    end
end

