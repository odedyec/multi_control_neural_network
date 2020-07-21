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
        
        function plot(obj, varargin)
            p = inputParser;
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addOptional(p, 'Fig',  99, validScalarPosNum);
            addOptional(p, 'Clear', 1, validScalarPosNum);
            addOptional(p, 'Colors', 0, validScalarPosNum);
            addOptional(p, 'Alpha', 0, validScalarPosNum);
            parse(p, varargin{:});
            if ~p.Results.Colors
                colors = colormap('jet'); 
                colors = colors(ceil(linspace(1, 64, obj.numOfControllers)), :);
            end
            clear_fig = p.Results.Clear;
            figure(p.Results.Fig);
            if clear_fig
                clf;
            end
            hold on;
            for i=obj.numOfControllers:-1:1
                obj.Omegas{i}.plot('alpha', p.Results.Alpha, 'color', colors(i, :));
                plot(obj.Omegas{i}.V(:, 1), obj.Omegas{i}.V(:, 2), 'x', 'Color', colors(i, :), 'MarkerSize', 12, 'LineWidth', 1)
            end
            hold off
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

