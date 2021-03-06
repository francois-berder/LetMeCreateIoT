![logo](https://static.creatordev.io/logo-md-s.svg)
# LetMeCreateIoT

**Master**  
[![Build Status](https://travis-ci.org/CreatorDev/LetMeCreateIoT.svg?branch=master)](https://travis-ci.org/mtusnio/LetMeCreateIoT)  
**Dev**  
[![Build Status](https://travis-ci.org/CreatorDev/LetMeCreateIoT.svg?branch=dev)](https://travis-ci.org/mtusnio/LetMeCreateIoT)

## Introduction

A collection of wrappers for the Contiki interfaces made to speed up the development of applications 
for the Mikro-e PIC32MX clicker.

|Wrappers||
|:------------| :-------------------|
|I²C|SPI|
|GPIO|GPIO Monitor|
|ADC|UDP/TCP & network helpers|
|Debug over 6lowpan|Power saving control|
|UART||

All drivers are checked out from [LMC 1.3](https://github.com/CreatorDev/LetMeCreate/tree/v1.3.0) and Contiki-specific patches are applied on top of them. Any drivers which were not ported are crossed out in the table below.

|Drivers|||
|:------------|:-------------------|:-------------------|
|~~7Seg~~|8x8R (Led Matrix)|Accel|
|ADC|Air quality|Alcohol|
|Alphanum|~~Bargraph~~|CO|
|Color|Color2|EVE|
|Fan|GYRO|IR distance|
|IR eclipse|Joystick|Light|
|Motion|OLED|Opto|
|Proximity|Relay|Relay2|
|Relay4 (partial support)|RTC|Thermo3|
|Weather||||

## Installation and updating

### Installation

```sh
$ ./install.sh -p path/to/contiki
```

To verify whether installation worked navigate to the examples directory, pick an example of your 
choice and run

```sh
make
```

### Uninstalling

If the Contiki symlink is not removed the library can be uninstalled with a single command:

```sh
./install.sh -u
```

### Updating

To update the library run:

```sh
git pull
./install.sh
```

As long as a symbolic link to Contiki directory exists the installation script will update all files.

### Feeds

The library checks out the main LMC repo to acquire drivers and apply patches on top of them. If you
prefer to exclude some drivers use the -e option during install with a regex matching the path or
filename:

```sh
./install.sh -e ./click/*
./install.sh -e *relay.*
./install.sh -e *joystick.* -e *relay.*
```

The driver feed headers and source files are also copied to your local repo to let you generate 
documentation with doxygen. Clean your repo when changing the clicks you include/exclude to prevent 
issues with documentation for non-used clickers being generated.

## Development

To use include the appropriate header files in your project, eg.:

```C
#include "letmecreate/core/spi.h"
#include "letmecreate/click/accel.h"
```

For reference how to use the different interfaces or click wrappers refer to a wide selection of 
examples in the examples directory.

### CI40 UDP server & client

In addition to wrappers for common networking functionality the repository contains two Python scripts
that can be used as 6lowpan client/server. Both of them can be found in the scripts directory, and
can be freely modifid to send and receive application data. For more help run:

```sh
python3 server.py -h
python3 client.py -h
```

If Python3 is not installed use [opkg](https://docs.creatordev.io/ci40/guides/openwrt-platform/#using-opkg)
to install the package:

```sh
opkg install python3
```

### Debug

LMCIoT offers debug capabilities over 6lowpan. This is achieved by adding a new macro, PRINTF, which 
sends data over 6lowpan every time it is needed. To enable first include the DEBUG_IP compilation 
define in the Makefile:

```Makefile
CFLAGS += -DDEBUG_IP=6lowpan:ip:of:ci40
```

By default data is not only sent over 6lowpan but also printed over UART. To disable serial logging use:

```Makefile
CFLAGS += -DDEBUG_IP=6lowpan:ip:of:ci40 -DDEBUG_NO_SERIAL
```

Then use the INIT_NETWORK_DEBUG and PRINTF macros in code:
```C
/* ... */
#include "letmecreate/core/debug.h"

PROCESS(main_process, "Main process");
AUTOSTART_PROCESSES(&main_process);
/*---------------------------------------------------------------------------*/
PROCESS_THREAD(main_process, ev, data)
{
    PROCESS_BEGIN();
    INIT_NETWORK_DEBUG();
    {
        PRINTF("Start!\n");
        /* ... */
```
Finally, copy scripts/debug_server.py to a CI40 with Python3 installed and run:
```sh
python3 debug_server.py
```

To disable debugging simply remove DEBUG_IP from CFLAGS. In this case INIT_NETWORK_DEBUG will 
resolve to no code at all and PRINTF will act as the standard printf function. For a full example 
program visit [examples/debug](https://github.com/CreatorDev/LetMeCreateIoT/tree/master/examples/debug). 
Additionally, all other examples can be used with network debug enabled by following the above steps.

### Compatibility with LMC

The interfaces are made to be as compatible with [LMC](https://github.com/CreatorDev/LetMeCreate) 
as much as possible to ensure the code is portable. When adding support for a new Click use its LMC
version, modify for use with LMCIoT and generate a patch, then place it in the
feeds/patches/ directory.

### Known issues

- At the moment the new udp connection sends dummy data to force router solicitation as soon as 
possible.
- IDLE/SLEEP power control options might not work properly.
- The CA8210 radio might still come online even when power_disable_peripherals is used. This will be
fixed once proper power saving is added for the radio.
