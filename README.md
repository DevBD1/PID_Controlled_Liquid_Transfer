# Introduction

This project involves **two liquid-filled reservoirs**, labeled **A and B**. Reservoir A serves as a supply tank, and its liquid level is not critical. Reservoir B, however, requires a stable liquid level, which is the primary control objective. An ultrasonic distance sensor is mounted vertically above Reservoir B to measure the liquid depth, providing distance readings denoted as x₁. A **peristaltic liquid pump** connects the two reservoirs. The pump's role is to transfer excess liquid from Reservoir B to Reservoir A or to draw liquid from Reservoir A to replenish Reservoir B, depending on the measured liquid level.

# 📐 PID Control
To maintain the desired liquid level in Reservoir B, a PID (Proportional-Integral-Derivative) control algorithm is implemented. The controller minimizes the error between the setpoint and the measured value by adjusting the pump's operation. 
The PID control law is defined as:

```
u(t) = Kp * e(t) + Ki * ∫e(t)dt + Kd * de(t)/dt
```

**Where:**
- ```e(t)``` is the error between the measured and target level (e.g., e(t) = x₁ - target)
- ```Kp``` is the proportional gain
- ```Ki``` is the integral gain
- ```Kd``` is the derivative gain
- ```u(t)``` is the output used to determine the pump’s direction and speed (via PWM)

This PID controller ensures that the liquid level in Reservoir B remains stable despite disturbances or changes in system dynamics.

---
# ✅ Requirements

#### Software
- [GNU Octave](https://www.gnu.org/software/octave/) (Tested on version 10 (2025-03-25))
- [Arduino IDE](https://www.arduino.cc/en/software) (Tested on version 1.8.19 (Store 1.8.57.0))
- USB connection to Arduino board (Uno, Nano, etc.)
- `instrument-control` package for Octave

#### Hardware
- Arduino Uno
- HC-SR04:  Ultrasonic Sound Sensor
- L298N: H BRIDGE
- 12V 3x5 PUM: Peristaltic Water Pump
- 12V ADAPTER: Power Supply for the Pump
- 9V BATTERY: Power Supply for Arduino

#### Connection Map
Here is the connection map of the system:

COMPONENT | DESCRIPTION | COMPONENT PIN | CARD PIN | CARD
--- | --- | --- | --- | ---
HC-SR04 | Ultrasonic Sound Sensor | TRIG | D6 | UNO
HC-SR04 | Ultrasonic Sound Sensor | ECHO | D7 | UNO
L298N | H BRIDGE | IN1 | D8 | UNO
L298N | H BRIDGE | IN2 | D9 | UNO
L298N | H BRIDGE | ENA | D10 (PWM) | UNO
12V ADAPTER | POWER SUPPLY | + / - | L298N
12V 3x5 PUMP | Peristaltic Water Pump | + | OUT1 | L298N
12V 3x5 PUMP | Peristaltic Water Pump | - | OUT2 | L298N

---
# 🛠️ Installation 
Follow the steps below to set up the environment for PID-controlled liquid transfer.

### 📦 Octave Setup

1. Install the `instrument-control` package:

   ```octave
   pkg install -forge instrument-control
   pkg load instrument-control
   ```

2. Clone this repository or download the source code:

   ```bash
   git clone https://github.com/DevBD1/PID_Controlled_Liquid_Transfer.git
   cd PID_Controlled_Liquid_Transfer
   ```

3. (Optional) If you have `.env` or calibration constants, place them in the root folder.

4. Make sure your Arduino is connected via `COM3` or change the port in the script:

   ```matlab
   s = serialport("COM3", 9600);
   ```

### 🔌 Arduino Upload

1. Open [`arduino/transfer_serial.ino`](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/arduino/transfer_serial.ino) in Arduino IDE.
2. Select your correct board and COM port.
3. Upload the sketch.

### 🧪 First Start
To test the system and determine the standard deviation of sensor inputs:
1. Run [`matlab/standard_deviation/log_realistic.m`](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/standard_deviation/log_realistic.m) script
2. Input the direction of the pump for test
3. Input the repeat count
4. Check the generated .csv file 
5. Run [`matlab/standard_deviation/analyse.m`](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/standard_deviation/analyse.m) script
6. Read the output, the script will generate a variable at the end
7. Check the generated `pid_tolerance.mat` file

To start full PID control:
1. Run  [`matlab/pid_control_serialport_mapped.m`](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/pid_control_serialport_mapped.m) script

```octave
pid_control_serialport_mapped.m
```

---

# ⚙️ Configuration
You can modify the PID constants and port settings at the top of the `.m` files:

```matlab
Kp = 40;
Ki = 0.5;
Kd = 20;

s = serialport("COM3", 9600);  % Change if needed
```

Use log_static.m when the reservoir B is empty. The result is your max. height.

# 🧪 Other Scripts

- ```Fill or Empty``` -> dir: [.../matlab/fill_or_empty.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/fill_or_empty.m)
- ```Stop``` -> dir: [.../matlab/stop.m](https://github.com/DevBD1/PID_Controlled_Liquid_Transfer/blob/main/matlab/stop.m)
