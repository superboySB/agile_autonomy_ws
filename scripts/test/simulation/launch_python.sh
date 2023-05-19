cd ~/agile_autonomy_ws
source devel/setup.bash
source ../cv_bridge_ws/install/setup.bash --extend
roscd planner_learning
python3 test_trajectories.py --settings_file=config/test_settings.yaml