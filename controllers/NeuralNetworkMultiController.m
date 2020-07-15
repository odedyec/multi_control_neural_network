classdef NeuralNetworkMultiController < ControllerBase
    %MULTICONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        ConvHulls
    end
    
    methods(Access = public)
        function obj = NeuralNetworkMultiController(Ks, convex_hulls, gx, n, m, gu)
            %MULTICONTROLLER Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@ControllerBase(n, m, gu);
            numOfControllers = length(Ks);
            obj.numOfControllers = numOfControllers;
            obj.K = Ks;
            obj.ConvHulls = convex_hulls;
        end
        
        function u = controller_imp(obj, state)
            i = 1;
            K = obj.K{i};
            while true
%                 if abs(K * state) < 1
                if obj.Omegas{i}.contains(state)
                    break
                end
                i = i + 1;
                if i == obj.numOfControllers + 1
                    i = obj.numOfControllers;
                    break;
                end
                K = obj.K{i};
            end
            u = K * state;
        end
    end
end

