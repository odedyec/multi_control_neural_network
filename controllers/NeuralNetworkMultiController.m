classdef NeuralNetworkMultiController < ControllerBase
    %MULTICONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        ConvHulls
        numOfControllers
        net
    end
    
    methods(Access = public)
        function obj = NeuralNetworkMultiController(n, m, gu, Ks, convex_hulls)
            %MULTICONTROLLER Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@ControllerBase(n, m, gu);
            numOfControllers = length(Ks);
            obj.numOfControllers = numOfControllers;
            obj.K = Ks;
            obj.ConvHulls = convex_hulls;
        end
        
        function load_network(obj, net_file)
            obj.net = importKerasNetwork(net_file);
        end
        
        function u = controller_imp(obj, state)
            probs = obj.net.predict(reshape(state, 1, length(state), 1));
            K_alpha = 0;
            for j=1:length(obj.K)
                K_alpha = K_alpha + obj.K{j} * probs(j);
            end
            u = K_alpha * state;
        end
    end
end

