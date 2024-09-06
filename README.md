# Hello world!

Works as is, but knowing myself, it is still a work in progress as I'm always trying to optimize my printer!
I'm still working on making the original Anet ET4 display work with klipper but for now Klipperscreen on an old android phone works like a charm! :)
# What's New?
#### 1. Forked Macros from Jschuh
Incorporated Jschuh's macros into the project and created a new install.sh script. This script automates the transfer of configuration files (.cfg) to /home/pi/printer_data/config, and also sets up a klipper-macros folder with Jschuh's macro configurations.

#### 2. Modified printer.cfg
Adjusted the printer.cfg file to support seamless installation of the macros.

#### 3. Variable Adjustments
Updated key variables such as endstop positions, and minimum/maximum limits to enhance compatibility and performance.

#### 4. Install Script as an Update Manager
The new install.sh script not only installs the necessary files but also functions as an update manager, ensuring you always have the latest version of the configuration and macros.

### Big thank you to Jschuh for all the macros. 
- Source : https://github.com/jschuh/klipper-macros

# Installation

#### Simply run the following command in your raspberry pi terminal:

```bash
bash <(curl -sL https://raw.githubusercontent.com/KarlAvec1K/Anet_ET4/main/install.sh)
