# PID Controlled Liquid Transfer System

This project implements a PID-controlled liquid level regulation system using an Arduino, an ultrasonic distance sensor, and a peristaltic pump. The goal is to maintain a stable water level in Tank B, regardless of disturbances or changes in fluid volume.

There are two tanks: Tank A and Tank B.
Tank A acts as a general-purpose water reservoir, and its liquid level is not important.
Tank B, however, is the target tank where the liquid level must be regulated precisely. An ultrasonic sensor is mounted above Tank B, facing downward vertically, to measure the distance from the sensor to the liquid surface — we call this value x₁.
A peristaltic pump connects the two tanks. Based on the measured value x₁, the pump either adds liquid from Tank A to Tank B when the level is too low, or removes excess liquid from Tank B back into Tank A when the level is too high.

This feedback system uses PID control logic implemented in Octave, with the Arduino acting as a low-level actuator responding to directional commands and PWM speed.

The PID output is computed using the following standard formula:

𝑢
(
𝑡
)
=
𝐾
𝑝
⋅
𝑒
(
𝑡
)
+
𝐾
𝑖
⋅
∫
𝑒
(
𝑡
)
 
𝑑
𝑡
+
𝐾
𝑑
⋅
𝑑
 
𝑒
(
𝑡
)
𝑑
𝑡
u(t)=K 
p
​
 ⋅e(t)+K 
i
​
 ⋅∫e(t)dt+K 
d
​
 ⋅ 
dt
de(t)
​
 
Where:

e(t) is the error between the measured and target liquid level (i.e., e(t) = x₁ - target)

Kp, Ki, and Kd are the proportional, integral, and derivative constants respectively

u(t) is the output value used to determine pump direction and PWM speed

## Installation 
# Step-1
Complete the physical installation of your system like in the pictures and diagrams below.
Here is the connection map of the system:

COMPONENT | DESCRIPTION | COMPONENT PIN | CARD PIN | CARD
--- | --- | --- | --- | ---
HC-SR04 | Ultrasonic Sound Sensor | TRIG | D7 | UNO
HC-SR04 | Ultrasonic Sound Sensor | ECHO | D6 | UNO
L298N | H BRIDGE | IN1 | D8 | UNO
L298N | H BRIDGE | IN2 | D9 | UNO
L298N | H BRIDGE | ENA | D10 (PWM) | UNO
12V ADAPTER | POWER SUPPLY | + / - | L298N
12V 3x5 PUMP | Peristaltic Water Pump | + | OUT1 | L298N
12V 3x5 PUMP | Peristaltic Water Pump | - | OUT2 | L298N


# Step-2
Using Arduino IDE, upload the [arduino/transfer_serial.ino](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/arduino/transfer_serial.ino) file to your card

# Step-3
- Run [matlab/standard_deviation/log_realistic.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/standard_deviation/log_realistic.m) script
- Input the direction of the pump for test
- Input the repeat count
- Check the generated .csv file 

- Run [matlab/standard_deviation/analyse.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/standard_deviation/analyse.m) script
- Read the output, the script will generate a variable at the end
- Check the generated pid_tolerance.mat file

# Step-4
Run [matlab/pid_control_serialport_mapped.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/pid_control_serialport_mapped.m)
