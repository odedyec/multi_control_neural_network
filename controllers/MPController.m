classdef MPController < ControllerBase
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mpc
    end
    
    methods(Access = public)
        function obj = MPController(n, m, gu, A, B, gx, Q, R)
            obj = obj@ControllerBase(n, m, gu);
            model = LTISystem('A', A, 'B', B);
            model.x.min = -gx(n+1:end);
            model.x.max = gx(1:n);
            model.u.min = -gu(m+1:end);
            model.u.max = gu(1:m);
            
            model.x.penalty = QuadFunction(Q);
            model.u.penalty = QuadFunction(R);
            
            P = model.LQRPenalty;
            Tset = model.LQRSet;
            model.x.with('terminalPenalty');
            model.x.with('terminalSet');
            model.x.terminalPenalty = P;
            model.x.terminalSet = Tset;
            horizon = 20;
            obj.mpc = MPCController(model, horizon);
        end
        
        function u = controller_imp(obj, state)
            u = obj.mpc.evaluate(state);
        end
    end
end
        