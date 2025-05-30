# PID Controlled Liquid Transfer System
A PID controlled liquid transfer system. Built with a Arduino Uno, an HC-SR04, a 12V pump and an L298N H bridge for PWM control; using Octave (MATLAB .m program).

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
Using Arduino IDE, upload the arduino/script.ino file to your card

# Step-3
Run the [matlab/standard_deviation/log_dynamic.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/standard_deviation/log_dynamic.m) script
Input the direction of the pump for test
Input the repeat count
Check the generated .csv file 

Run [matlab/standard_deviation/analyse.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/standard_deviation/analyse.m) script
Read the output, the script will generate a variable at the end
Check the generated pid_tolerance.mat file

# Step-4
Run matlab/pid_control_serialport.m
