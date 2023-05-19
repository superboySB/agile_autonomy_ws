cd ~/agile_autonomy_ws
source devel/setup.bash
source ../cv_bridge_ws/install/setup.bash --extend
roscd planner_learning
python3 dagger_training.py --settings_file=config/dagger_settings.yaml