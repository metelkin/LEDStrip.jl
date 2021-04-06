# RGB Led Strip

## Run on Raspberry Pi

```sh
julia --project=. run.jl
```

config.txt
```
core_freq=500
core_freq_min=500
...
spidev.bufsiz=32768
```

## Goal

Run LED strip on raspberry using **SPI**

## Alternatives

1. PWM
1. PWM analog audio
1. PCM digital audio I2S?

## references

rgb led strip in python
https://github.com/jgarff/rpi_ws281x

