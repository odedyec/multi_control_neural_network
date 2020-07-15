function logger=run_system(plant, controller, x0, steps, ref)
if nargin == 4
    % set ref to regulation problem
    ref = x0 * 0;
end
if size(ref, 2) ~= steps
    if size(ref, 2) == 1
        ref = repmat(ref, 1, steps);
    else
        error('In run_system: ref should be with size [n, 1] or [n, steps]');
    end
end
    
logger = Logger(steps, plant.n, plant.m);
x = x0;
for step=1:steps
    u = controller.control(x - ref(:, step));
    logger.log(x, u);
    x = plant.propagate(x, u);
end  
logger.stop_logging
end