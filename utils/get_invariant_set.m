function Omega = get_invariant_set(A, B, K, Fx, Fu, gx, gu)
%DRAW_OMEGA Summary of this function goes here
%   Detailed explanation goes here
sys = LTISystem('A', A+B * K);
% Define constraints

Fc = [Fx; Fu*K]; 
gc = [gx; gu]; 
C=Polyhedron('A', Fc, 'b', gc);
sys.x.with('setConstraint');
sys.x.setConstraint = C;
Omega = sys.invariantSet();
