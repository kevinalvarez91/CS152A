# DanceDanceRevolution FPGA Implementation

This project is a hardware implementation of the popular DanceDanceRevolution (DDR) game on an FPGA board. By leveraging the built-in buttons on the FPGA board for directional controls and utilizing the built-in pixel screen for move visualization, this version provides a unique and engaging way to experience DDR. 

## Overview 

DanceDanceRevolution (DDR) is a rhythm and dance game where players must hit directional inputs in time with music and on-screen prompts. In this FPGA-based implementation, the built-in buttons serve as the primary input mechanism, allowing players to move left and right. The onboard pixel screen is used to display the sequences of moves that players must follow. 

## Key Features

### Gameplay Mechanics
- **Directional Buttons** : Use the FPGA board's built-in buttons to control the left and right movements. 
- **Pixel Screen Display** : The built-in pixel screen visually represents the direction arrows you need to hit in sync with the beat of the music. 

### Performance

Running DDR on an FPGA provides the advantage of hardware-level performance. This ensures responsive input handling and smooth display updates, creating a seamless gaming experience. 

### Custom songs and Levels

While the initial implementation includes a set of pre-defined songs and levels, the architecture allows for customization. Users can add their own sequences and music tracks by modifying the relevant parts of the codebase. 

## Hardware Requirements

To run this DDR implementation, you will need: 

- An FPGA Development Board equipped with: 
  - Built-in directional buttons
  - A built-in pixel screen for display purposes

## How it Works 

### Input Handling

The FPGA's buttons are configured to register left and right movement inputs. During gameplay, these inputs are captured and processed in real-time to determine if the player hits the correct sequence prompted by the on-screen arrows. 

### Display Management 

The built-in pixel screen on the FPGA board is utilized to display the arrows that the player must follow. This involves updating the screen at regular intervals to ensure that the arrows move in sync with the music's beat. 

### Scoring System

The scoring system is integrated into the FPGA's logic, tracking player performace in real-time. Points are awarded based on timing accuracy, with more points given for hitting the arrows precisely on beat. 

### Sound Integration

While this implementation focuses on leveraging the FPGA's built-in capabilities, sound integration can be added via external modules or peripherals. The system can be expanded to include audio output for a more immersive experience. 

## Installation and Setup
1. **Clone the Repositoy** : Start by cloning the project repository to your local machine. 
~~~
git clone https://github.com/kevinalvarez91/CS152A.git
cd CS152A/Lab4 
~~~
2. Built it on Vivado


## License
This project is licensed under the MIT License. You are free to use, modify, and distribute the code with appropriate attribution. Refer to the LICENSE file for more details.

## Conclusion
This FPGA-based implementation of DanceDanceRevolution brings the excitement of the classic rhythm game to a hardware platform. By utilizing the built-in buttons and pixel screen, this project offers a unique way to play DDR, highlighting the versatility and performance of FPGA technology. Dive into the code, customize your experience, and enjoy the rhythmic challenges of DDR on your FPGA board!
