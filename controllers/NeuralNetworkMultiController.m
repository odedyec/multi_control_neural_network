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
        
        function load_network(obj)
            net_file = sprintf('networks/mcnn_classi_%d_%d.h5', obj.state_shape, obj.numOfControllers);
            obj.net = importKerasNetwork(net_file);
        end
        
        function u = controller_imp(obj, state)
            probs = obj.net.predict(reshape(state, 1, length(state), 1), 'ExecutionEnvironment', 'cpu');
            K_alpha = 0;
            for j=1:length(obj.K)
                K_alpha = K_alpha + obj.K{j} * probs(j);
            end
            u = K_alpha * state;
        end
        
        function train_network(obj, layers, epochs)
            %% Generate dataset
            N = length(obj.ConvHulls);
            db_size = 0;
            for i=1:N
                db_size = db_size + size(obj.ConvHulls{i}, 1);
            end
            data_x = zeros(db_size, obj.state_shape);
            data_y = zeros(db_size, 1);
            
            k = 1;
            for i=1:N
                for v=obj.ConvHulls{i}'
                    data_x(k, :) = v';
                    data_y(k, 1) = i;
                    k = k + 1;
                end
            end
            fname = sprintf('networks/mcnn_data_%d_%d.csv', obj.state_shape, N);
            csvwrite(fname, [data_x, data_y])
        %% Create YAML config file
        s = struct();
        s.states = obj.state_shape;
        s.controllers = N;
        s.epochs = epochs;
        s.batch_size = 6;
        s.train_test_split = 0;
        s.layers = layers;
        write_struct_to_yaml(s, 'networks/mcnn_config.yaml');
        %% Run python script
        system('python networks/mcnn_classification.py');
        end
    end
end

