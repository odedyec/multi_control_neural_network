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
        
        function colors = get_color_space(obj)
            colors = colormap('jet'); 
            colors = colors(ceil(linspace(1, 64, obj.numOfControllers)), :);
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
                colors = obj.get_color_space();
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
        
        function i = get_controller_index_from_state(obj, state)
            i = 1;
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
            end
        end
        
        function u = controller_imp(obj, state)
            i = obj.get_controller_index_from_state(state);
            K = obj.K{i};
            u = K * state;
        end
        
        function plot_quiver_on_MAS(obj, logger)
            obj.plot('Clear', 1, 'Fig', 98)
            hold on;
            q_colors = obj.get_color_space();
            for i=1:logger.num_of_element-1
                x = logger.x(1, i);
                y = logger.x(2, i);
                xx = logger.x(1, i+1) - logger.x(1, i);
                yy = logger.x(2, i+1) - logger.x(2, i);
                ki = obj.get_controller_index_from_state([x;y]);
                quiver(x, y, xx, yy, 'Color', q_colors(ki, :), 'LineWidth', 2)
            end
        end
    end
end

