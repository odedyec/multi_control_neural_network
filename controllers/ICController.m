classdef ICController < ControllerBase
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        Omega
        f
        W
        E
        G
        n
        m
        C
        A
        B
        K_outer
        opts
    end
    
    methods(Access = public)
        function obj = ICController(n, m, gu, A, B, K, Fx, Fu, gx, K_outer)
            obj = obj@ControllerBase(n, m, gu);sys = LTISystem('A', A+B*K);
            obj.K_outer = K_outer;
            obj.n = n;
            obj.m = m;
            obj.K = K;
            Fc = [Fx; Fu*K_outer];
            gc = [gx; gu]; 
            obj.C=Polyhedron('A', Fc, 'b', gc);
            sys.x.with('setConstraint');
            sys.x.setConstraint = obj.C;
            obj.Omega = sys.invariantSet();
            obj.f = [zeros(1, n) 1]';
            obj.G = [obj.C.A -obj.C.b; -obj.Omega.A obj.Omega.b];
            obj.W = [zeros(size(obj.C.b)); obj.Omega.b];
            obj.E = [zeros(size(obj.C.A)); -obj.Omega.A];
            obj.A = A;
            obj.B = B;
            obj.opts = optimoptions('linprog','Display','off');
        end
        
        function u = controller_imp(obj, state)
            if(obj.Omega.contains(state)) % inside Omega
                u = obj.K * state;
            elseif (~obj.C.contains(state)) %outside C
                u = obj.K * state;
            else
                s = linprog(obj.f,obj.G,obj.W+obj.E*state,[],[],[-inf(1, obj.n),0],[inf(1, obj.n), 1], obj.opts);
                rv = s(1:end-1);
                ro = state-rv;
                c = s(end);
                xv=rv/c;
%                 s1 = linprog([zeros(1, obj.m) 1]',[obj.C.A*obj.B -obj.C.b],-obj.C.A*obj.A*xv,[],[],[obj.output_lower_sat' 0], [obj.output_upper_sat' 1], obj.opts);
%                 uv=s1(1);
%                 u = uv*c + obj.K*ro;
                u = obj.K_outer * rv + obj.K * ro;
            end
        end
    end
end
        