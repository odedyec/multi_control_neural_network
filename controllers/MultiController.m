classdef MultiController < ControllerBase
    %MULTICONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        ConvHulls
        numOfControllers
        Omegas
    end
    
    methods(Access = public)
        function obj = MultiController(n, m, gu, A, B, Rs, Q, Fx, Fu, gx)
            %MULTICONTROLLER Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@ControllerBase(n, m, gu);
            numOfControllers = length(Rs);
            obj.numOfControllers = numOfControllers;
            obj.K = cell(obj.numOfControllers, 1);%zeros(obj.numOfControllers, 2);
            obj.ConvHulls = cell(obj.numOfControllers, 1);
            obj.Omegas = cell(obj.numOfControllers, 1);
            for i=1:obj.numOfControllers
                K = -dlqr(A, B, Q, diag(Rs(:, i)));
                obj.K{i} = K;
                fprintf('#########  %d   #########\n', i)
                Omega = get_invariant_set(A, B, K, Fx, Fu, gx, gu);
                obj.Omegas{i} = Omega;
                obj.ConvHulls{i} = Omega.V;
            end
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

