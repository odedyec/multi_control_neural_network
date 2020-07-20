classdef Logger < handle
    %LOGGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        u
        x_counter
        u_counter
        num_of_element
        elapsed_time
        start_time
    end
    
    methods
        function obj = Logger(N, n, m)
            %LOGGER Construct an instance of this class
            %   Detailed explanation goes here
%             obj.start_time = tic;
            obj.elapsed_time = 0;
            obj.num_of_element = N;
            obj.x = zeros(n, N);
            obj.u = zeros(m, N);
            obj.x_counter = 0;
            obj.u_counter = 0;
        end
        
        function tic(obj)
            tic;
        end
        
        function toc_and_sum(obj)
            te = toc;
            obj.elapsed_time = obj.elapsed_time + te * 1000;
        end
            
        function add_x(obj, x)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if obj.x_counter == obj.num_of_element
                error('Logger is Full. Can not add more elements to logger.')
                return
            end
            obj.x_counter = obj.x_counter + 1;
            obj.x(:, obj.x_counter) = x;
        end
        
        function add_u(obj, u)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if obj.u_counter == obj.num_of_element
                error('Logger is Full. Can not add more elements to logger.')
                return
            end
            obj.u_counter = obj.u_counter + 1;
            obj.u(:, obj.u_counter) = u;
        end
        
        function log(obj, x, u)
            obj.add_u(u);
            obj.add_x(x);
        end
        
        function ctps = CTPS(obj)
            ctps = obj.elapsed_time / obj.num_of_element;
        end
        
        function c = cost(obj, ref)
            if nargin == 1
                ref = obj.x * 0;
            end
            c = sum(sum((obj.x - ref) .^ 2));
        end
        
        function plot(obj, fig, subplots, color, l_width)
            figure(fig);
            n = subplots(1);
            m = subplots(2);
            N = obj.num_of_element;
            for i=1:n
                for j=1:m
                    ind = (i-1) * m + j;
                    subplot(n, m, ind)
                    hold on
                    stairs(1:N, obj.x(ind, :),  color,'LineWidth', l_width)
                end
            end
        end
        
        function plot_u(obj, fig, subplots, color, l_width)
            figure(fig);
            n = subplots(1);
            m = subplots(2);
            N = obj.num_of_element;
            for i=1:n
                for j=1:m
                    ind = (i-1) * m + j;
                    subplot(n, m, ind)
                    hold on
                    stairs(1:N, obj.u(ind, :),  color,'LineWidth', l_width)
                end
            end
        end        
        
    end
end

