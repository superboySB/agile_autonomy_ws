#!bin/bash
kill -9 $(pgrep -f test_trajectories)
kill -9 $(pgrep -f dagger_training)
kill -9 $(pgrep -f rosbag)