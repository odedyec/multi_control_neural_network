function logger=run_system(plant, controller, x0, steps)
logger = Logger(steps, plant.n, plant.m);
x = x0;
for step=1:steps
    u = controller.control(x);
    logger.log(x, u);
    x = plant.propagate(x, u);
end  
logger.stop_logging
end