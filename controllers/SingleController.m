classdef SingleController < ControllerBase
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
    end
    
    methods(Access = public)
        function obj = SingleController(n, m, gu, K)
            obj = obj@ControllerBase(n, m, gu);
            obj.K = K;
        end
        
        function u = controller_imp(obj, state)
            u = obj.K * state;
        end
    end
end
        