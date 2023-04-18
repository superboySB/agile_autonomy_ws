Note of details for how to retrain or fine-tune the codes in lower speed 

# Learning Plans (From high to low level control)
We need to read and modify these modules:

## [1-high] agile_autonomy, minimum_jerk_trajectories
agile_autonomy GPU>9GB (?)

## [2-middle] rpg_quadrotor_control
3 controller: velocity controller/ position_controller (no collision aviodance) / rpg_mpc 

rotors_gazebo_plugins: flappy.xarco

## [3-low] rotors_simulator