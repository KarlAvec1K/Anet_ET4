## Hello world!

Works as is, but knowing myself, it is still a work in progress as I'm always trying to optimize my printer!
I'm still working on making the original Anet ET4 display work with klipper but for now Klipperscreen on an old android phone works like a charm! :)

## What's new?

1. Added a bunch of macros from jschuh. and made a new install.sh.*
2. Ajusted a couple variables (endstop, min, max, etc)
3. New "install.sh" also work as a update manager. It'll make sure you have the latest version of this branch.

*Big thank you to jschuh for all the macros. 
 Source : https://github.com/jschuh/klipper-macros

## Installation

To install the configuration files, simply run the following command in your raspberry pi terminal:

```bash
bash <(curl -sL https://raw.githubusercontent.com/KarlAvec1K/Anet_ET4/dev/install.sh)
