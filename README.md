# Final Project: Two Player Racing Game

![Final product](Pictures/IMG_1161.jpeg)

## Expected Behaviors

* The goal of our project was to create a top down racing game where users dodge obstacles
  * One user should be able to move left and right controlling an individual car using the Nexys Board controller
  * The other user should be able to move left and right controlling an individual car using the Keypad controller
  * There should be random falling obstacles that the user needs to avoid with increasing difficulty
  * There should be a score counter for each player
  * There should be a penalty if you hit an obstacle
  * There should be a win scenario
 
## Necessary Equipment

* [Nexys A7-100T FPGA Board](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/)
* Computer with *[Vivado](https://www.xilinx.com/products/design-tools/vivado.html)* installed
* Micro-USB Cable
* VGA Cable
* Monitor/TV with VGA input or VGA adapter
* [PMOD KYPD](https://digilent.com/shop/pmod-kypd-16-button-keypad/)

## Code Modules Overview

* The **_[cardrive.vhd](CarGame/cardrive.vhd)_** is our top hierarchy file
  * Not many chages were made here from the original [pong.vhd](https://github.com/byett/dsd/tree/CPE487-Spring2025/Nexys-A7/Lab-6/pong.vhd)
  * We added the PMOD KYPD here and made it so that the buttons 6 and 3 controlled the left right for our car 2
  * We split up the 7 segment display by mapping our two scres to the left and right 4 segments respectively
  * Set the bounds for each player and the ball in this file
  * Initialized all our pins and determined their values
 
* The **_[cardrive.xdc](CarGame/cardrive.xdc)_** is where we established all the pins that we planned to use for control
  * The only thing we needed to really add here was the full keypad matrix which was 4 columns and 4 rows of pins 

* The **_[car_n_obstacles.vhd](CarGame/car_n_obstacles)_** has the most additions and changes, these changes include:
  * A wall draw process
  * Duplicated the ball draw function
  * A secondary car drawing process
  * A wheel drawing function that works with our 2 car drawing functions so they actually look like cars
  * Change mball to reset the ball, increase its speed, raise and lower our hit counters and randomize the balls x position
  * Developed a linear-feedback shift register to simulate random ball spawning positons on the x-axis
  * Set our colors for all entities

* The **_[leddec16.vhd](CarGame/leddec16.vhd)_** controls the 7 segment display and what drives each display
  * The changes made to this file revolve around seperating segments 0-3 and 4-7
  * We used two 16 bit logic vectors data and data2 to determine what score to show and where
  * Dig controls what digit to display
  * Seg converts the given digit to its corresponding hex value 

* The **_[clk_wiz_0](CarGame/clk_wiz_0.vhd)_** and **_[clk_wiz_0_clk_wiz](CarGame/clk_wiz_0_clk_wiz.vhd)_** modules were taken from the [given code for Lab 6](https://github.com/byett/dsd/tree/CPE487-Spring2025/Nexys-A7/Lab-6) and left unmodified.
  * These modules control the clock processes of the Nexys A7 board.
 
* The **_[vga_sync](CarGame/vga_sync.vhd)_** module (also given and unmodified) uses a clock to drive horizontal and vertical counters h_cnt and v_cnt, respectively.
  * These counters are then used to generate the various timing signals.
  * The vertical and horizontal sync waveforms, vsync and hsync, will go directly to the VGA display with the column and row address, pixel_col and pixel_row, of the current pixel being displayed.
  * This module also takes as input the current red, green, and blue video data and gates it with a signal called video_on.
  * This ensures that no video is sent to the display during the sync and blanking periods.

## Modifications Made

### Cardrive.vhd

* Changed entity name from 'pong' to 'cardrive.'
* Added KB_row OUT and kb_col INOUT to entity cardrive.
* Initialized car2pos to CONV_STD_LOGIC_VECTOR(650, 11) to set it on the right side of the barrier for player 2.
* Initialized display2 for the score to display.
* Initialized kb_row_signal, kb_col_signal, kp_value, and data_sel for the keypad functions.
* Changed component name from 'bat_n_ball' to 'car_n_obstacles.'
* Added car2_x IN and hit_cnt2 INOUT to component car_n_obstacles.
* Added data2 to component leddec16.
* In the pos process, changed the limits of where the first car can go from 0,800 to 20,305.
* In the pos process, added similar logic for car2pos but changed the limit from where car2 can go to 500,775. We also added logic to incorporate hitting the correct buttons by setting kb_row_signal <= "1011" and in the if statements, also check to see if KB_col(1) = '0' and KB_col(2)= '0.' This allows for buttons 6 and 3 to be pressed as the left and right movement keys.
* Set kb_row <= kb_row_signal to ensure that kb_row was "1011', which corresponds to row 3 on the keypad.
* In the portmap of car_n_obstacles, set hit_cnt2 => display2 and car2_x => car2pos.
* In the portmap of leddec16, set data => display and data2 => display2.

### Cardrive.xdc

* Pin screenshot and explanation

### car_n_obstacles.vhd

* put all our processes and modifications with screenshots here

### leddec16.vhd

* Initialized data2 to take the values for car2 similar to how data corresponds to the first car.

## Input/Output Description

## How to make this work in vivado

## Gameplay Summary

* Gameplay gifs and images here

## Difficulties and Itterations

## Contributions



