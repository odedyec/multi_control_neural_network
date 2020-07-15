classdef Plant
    %PLANT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        A
        B
        state_upper_bound
        state_lower_bound
        input_upper_bound
        input_lower_bound
        n
        m
    end
    
    methods
        function obj = Plant(A, B, gx, gu)
            %PLANT Construct an instance of this class
            %   Detailed explanation goes here
            n = size(A, 1);
            obj.n = n;
            m = size(B, 2);
            obj.m = m;
            obj.A = A;
            obj.B = B;
            obj.state_upper_bound = gx(1:n);
            obj.state_lower_bound = -gx(n+1:end);
            obj.input_upper_bound = gu(1:m);
            obj.input_lower_bound = -gu(m+1:end);
        end
        
        function x1 = propagate(obj,x, u)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            u = obj.sat_input(u);
            x1 = obj.A * x + obj.B * u;
            x1 = obj.sat_state(x1);
        end
        
        function x = sat_state(obj, x)
            %SAT Summary of this function goes here
            %   Detailed explanation goes here
            for i=1:obj.n
                if x(i) < obj.state_lower_bound(i)
                    x(i) = obj.state_lower_bound(i);
                elseif x(i) > obj.state_upper_bound(i)
                    x(i) = obj.state_upper_bound(i);
                end
            end
        end
        
        function u = sat_input(obj, u)
            %SAT Summary of this function goes here
            %   Detailed explanation goes here
            for i=1:obj.m
                if u(i) < obj.input_lower_bound(i)
                    u(i) = obj.input_lower_bound(i);
                elseif u(i) > obj.input_upper_bound(i)
                    u(i) = obj.input_upper_bound(i);
                end
            end
        end
    end
end

