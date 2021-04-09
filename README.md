# RGB Led Strip

It is a Julia package for controlling addressable RGB LED Strip (WS281x chip) with Raspberry Pi. 

*NOTE! This package should be considered alpha. Not all features are implemented. But basically it works.*

[![GitHub issues](https://img.shields.io/github/issues/metelkin/LEDStrip.jl.svg)](https://GitHub.com/metelkin/LEDStrip.jl/issues/)
[![GitHub license](https://img.shields.io/github/license/metelkin/LEDStrip.jl.svg)](https://github.com/metelkin/LEDStrip.jl/blob/master/LICENSE)

## Introduction

The addressable RGB LED strip, which are based on WS281x chip or similar, is popular for different education and DIY projects.
It allows controlling the each pixel of strip and creating a nice colored show. On the [YouTube you can find examples](https://www.youtube.com/results?search_query=addressable+led+strip+raspberry+pi) how [Raspberry Pi](https://www.raspberrypi.org/) can be used for it.

This is a Julia's package for LED strip control which is based on [BaremetalPi.jl](https://github.com/ronisbr/BaremetalPi.jl) engine.

## Installation

1. You need Raspberry Pi with the default OS installed.
    I tested on Raspberry Pi 4 (Raspberry Pi OS 32bit) but it should be working with other Raspberry versions and OS.
1. SPI protocol should be turn on, see OS settings.
1. In other tutorials it is also recommended to set frequency in the file `/boot/config.txt` as follows
    ```txt
    core_freq=500
    core_freq_min=500

    # spidev.bufsiz=32768 # if SPI buffer too low
    ```
1. Julia should be installed on Raspberry Pi. 
    I have tested on v1.1.0 which can be installed with
    ```sh
    sudo apt update
    sudo apt install julia
    ```

1. The package can be installed as usual (from Julia env):

    ```julia
    ] add https://github.com/metelkin/LEDStrip.jl.git
    ```

1. Circuits

    **A.** LED strip can be connected based on the following scheme.
    The chip transforming the PI's 3.3V signal to 5V logic may be required if 3.3 signal is not enough for RGB Strip DIN. I use SN74AHCT125N chip.
    ![scheme-chip](./scheme-chip.png)

    **B.** In many cases LED Strips can work with 3.3V output signal. In that case the chip is not required.
    ![scheme-no-chip](./scheme-no-chip.png)

## Usage

"Hello World!" example

```julia
using LEDStrip

# set first SPI with GPIO10 (pin #19)
# total pixels count is 100
s = Strip(1; led_count = 100) 

# set pixels 1, 2, 3, 4 as red, green, blue, white
# for 5 seconds, then off
set_colors!(s, [0xff0000, 0xff0000, 0x00ff00, 0xffffff])
show_colors(s)
sleep(5.)
hide_colors(s)
```

You can also clone the repository and use test cases.

```sh
julia --project=. run.jl
```

## Video demo
[![Watch the video](https://img.youtube.com/vi/0c5QVqN6y7E/maxresdefault.jpg)](https://youtu.be/0c5QVqN6y7E)

## Known issues and limitations

Currently only SPI is supported via GPIO10 and GPIO20.
PWM and PCM protocols can be potentially used as well.

### TODO list

- [x] SPI, pins: GPIO10 or GPIO20
- [ ] soft PWM, pins: any?
- [ ] hard PWM (interfering with analog audio)
- [ ] PCM (interfering with digital audio)

## Related projects

- C library with connectors to Python and other languages (but not Julia)
    <https://github.com/jgarff/rpi_ws281x>
- NodeJS package
    https://www.npmjs.com/package/rpi-ws281x


## License

Published under [MIT License](LICENSE)

