# ML-Based-Gain-Predictions-DC-Motor
DC motor with PID tuning in MATLAB and Simulink with dataset generation. ML-based gain prediction only based off parameters of one baseline motor.

This short project builds a Simulink DC motor speed-control model, then tunes PID gains using cost function. A dataset is generated from different "motor cases" and tuned PID gains, but the different motor cases are based around the one baseline motor example. There is a 10% deviation in possible motor cases from the original case, so this project does not completely predict the best PID tuning because it is limited. Future steps are to widen this limit so that the ML tuning may predict the best PID gains for a variety of DC motors.

Each training case is based off a "score", which I later found that the variable J is the proper control systems syntax. The score is based off of if the response has a lower tracking error, less overshoot, less final error, less control effort, and less late error. All PID gains are tested based off of this system.

The score really only tells us what is good for this case of motor. The search/prediction is pretty narrow.

Downloads:

MATLAB
Simulink
Statistics and Machine Learning Toolbox
