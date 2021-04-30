# low level interface
export StripSPI, send_bytes, send_colors

# high level interface
export set_pixel!, set_pixels!, clean_pixels!, shift_forward!, shift_backward!, hide_pixels, show_pixels

### MAIN SPI
# MOSI - output GPIO10 (alt0)
# MISO - input GPIO09 (alt0)
# CLK  - clock GPIO11 (alt0)
# CC0  - GPIO8 (alt0)
# CC1  - GPIO7 (alt0)

abstract type AbstractStrip end

"""
    struct StripSPI
        spi::Int                        # SPI number 1 or 2
        pixel_count::Int                # number of pixels in RGB Strip, equals to buffer size
        freq::Int                       # frequency in Hz for sending messages to WS281x chip
        color_indexes::Vector{Int}      # color indexes in RGB notation
        buffer::AbstractArray{UInt32}   # array storing states of pixels
    end

Object storing settings and states of addressable LED Strip.

StripSPI includes the intermediate buffer which is a variable storing pixel colors in RGB.

There are two ways working with StripSPI:

1. Sending colors directly to Strip using the methods like `send_bytes`, `send_colors`.

2. Updating buffer values and make changes visible after that using methods: `set_pixels!`, `clean_pixels!`, `show_pixels`, etc.
"""
struct StripSPI <: AbstractStrip
    spi::Int
    pixel_count::Int
    freq::Int
    color_indexes::Vector{Int}
    buffer::AbstractArray{UInt32}
end

# required rate calculated based on 3 bits per signal: 1.25 us => 0.8 MHz signal => 2.4 MHz
"""
    StripSPI(
        spi::Int;
        pixel_count::Int = 10,
        freq::Int = 800_000,
        color_type::String = "grb"
    )

Creates object representing LED Strip.

## Arguments

- `spi`: number of SPI used: `1` or `2`.

    `1` value corresponds to main SPI device. Data pin of LED Strip should be connected to MOSI (GPIO10),
    MISO (GPIO9), CLK (GPIO11), CC0 (GPIO8), CC1 (GPIO7) are not used for LED Strip.

    `2` value corresponds to alternative SPI device. Data pin of LED Strip should be connected to MOSI (GPIO20),
    MISO (GPI19), CLK (GPIO21), CC0 (GPI18), CC1 (GPI17), CC2 (GPIO16) are not used for LED Strip.

- `pixel_count`: number of physical pixels (RGB LED items)

    This value equals to buffer size.

- `freq`: signal rate of WS281x chip. Default 800000 Hz.

    Usually RGB LED Strip support 800 000 Hz messages (sometimes 400 000 Hz).
    
- `color_type`: RGB sequence may vary on some strips. Default is `grb`

    Valid values are "rgb", "rbg", "grb", "gbr", "bgr", "brg".

"""
function StripSPI(spi::Int; pixel_count::Int = 10, freq::Int = 800_000, color_type::String = "grb")
    # init
    if spi == 1
        path = "/dev/spidev0.0"
        @info "Use GPIO10 to connect signal (DIN) pin."
    elseif spi == 2
        path = "/dev/spidev0.1"
        @info "Use GPIO20 to connect signal (DIN) pin."
    else
        throw("SPI number should be 1 or 2, got $spi")
    end

    init_spi(path; max_speed_hz = freq * 3)

    strip_seq = split(color_type, "")
    color_indexes = indexin(strip_seq, ["r","g","b"]) # example [2,1,3] for "grb"

    StripSPI(spi, pixel_count, freq, color_indexes, zeros(UInt32, pixel_count))
end

"""
    send_bytes(
        strip::StripSPI,
        byte_array::AbstractArray{UInt8}
    )

Sending sequence of bytes to LED Strip. Each byte regulates brightness of one LED.
LED strip consists of pixels under control of the WS281x chip: tree LEDs per pixel.
To send the color "pixel-wisely" use `send_colors` method.

The method does not update the internal buffer of Strip object.

## Arguments

- `strip`: StripSPI object

- `byte_array`: Array of bytes `UInt8` to send. 
    First byte will be send to first LED (green), the second one will be send to second LED (red), etc.
    The byte's value regulates the brightness of corresponding LED. Three bytes together 
    regulates the color of pixel.
"""
function send_bytes(strip::StripSPI, byte_array::AbstractArray{UInt8})
    led_byte_array = _bytes_to_led_bytes(byte_array)
    spi_transfer(strip.spi, led_byte_array)
end

"""
    send_colors(
        strip::AbstractStrip,
        color_array::AbstractArray{UInt32}
    )

Send message to set Strip pixel colors in RGB notation.

The method does not update the internal buffer of Strip object.

## Example

```julia
send_colors(strip, [0x000000, 0xffffff, 0xff0000])`
```

The first pixel is red, second is white, third is red
the other pixels will not be updated.

## Arguments

- `strip`: StripSPI object

- `color_array`:  Each color is an unsigned 32-bit value (`UInt32`) where 
    the lower 24 bits define the red, green, blue data (each being 8 bits long).
"""
function send_colors(strip::AbstractStrip, color_array::AbstractArray{UInt32})
    byte_array = _colors_to_bytes(color_array, strip.color_indexes)
    send_bytes(strip, byte_array)
end

"""
    set_pixel!(
        strip::AbstractStrip,
        num::Int,
        color::UInt32
    )

This method updates the color of particular pixel in Strip's buffer.
To make it visible you must use `show_pixels` after updating.

## Example

```julia
set_pixel(strip, 10, 0x00ff00)
show_pixels(strip);
```
Set pixel #10 as green and make it visible.

## Arguments

- `strip`: StripSPI object

- `num`: number of pixel in strip starting from 1.

- `color`: `UInt32` value representing color and brightness.
"""
function set_pixel!(strip::AbstractStrip, num::Int, color::UInt32)
    strip.buffer[num] = color
end

"""
    set_pixels!(
        strip::AbstractStrip,
        arr::AbstractArray{UInt32};
        replicate::Bool = false
    )

This method updates whole pixel buffer in Strip.
To make it visible you must use `show_pixels` after updating.

## Arguments

- `strip`: StripSPI object

- `color_arr`: `UInt32` vector representing color and brightness for all pixels in Strip.
    If this vector is longer than the buffer length the rest values will be ignored.
    If `color_arr` is shorter the result will depend on `replicate` argument.

- `replicate`: If `true` the shorter `color_arr` will be replicated to the end of buffer.
"""
function set_pixels!(strip::AbstractStrip, color_arr::AbstractArray{UInt32}; replicate::Bool = false)
    if replicate
        template = repeat(color_arr, ceil(Int, strip.pixel_count / length(color_arr)))
        for i in 1:strip.pixel_count
            set_pixel!(strip, i, template[i])
        end
    else
        for i in 1:min(strip.pixel_count, length(color_arr))
            set_pixel!(strip, i, color_arr[i])
        end
    end
end

"""
    clean_pixels!(strip::AbstractStrip)

This method removes colors from whole Strip buffer or in other words set them as black.
This is the same as setting all buffer values as 0x000000.
To make it visible you must use `show_pixels` after.

## Arguments

- `strip`: StripSPI object
"""
function clean_pixels!(strip::AbstractStrip)
    for i in 1:strip.pixel_count
        strip.buffer[i] = 0x0
    end
end

"""
    show_pixels(strip::AbstractStrip)

Display buffer content in pixels.
Updating colors by `set_pixels!`, `clean_pixels!`, etc. changes only buffer state.
This method make it visible in physical pixels.

## Arguments

- `strip`: StripSPI object
"""
function show_pixels(strip::AbstractStrip)
    send_colors(strip, strip.buffer)
end

"""
    hide_pixels(strip::AbstractStrip)

Clean physical buffer colors i.e. set them as black.
This method does not change the buffer state.
You can hide and show colors but buffer content will be the same.

## Arguments

- `strip`: StripSPI object
"""
function hide_pixels(strip::AbstractStrip)
    all_black = zeros(UInt32, strip.pixel_count)
    send_colors(strip, all_black)
end

"""
    shift_forward!(
        strip::AbstractStrip;
        circular::Bool = false
    )

Shifts Strip buffer values forward, i.e. pixel #1 will be moved to pixel #2, #2 => #3, #3 => #4 etc.
This can be used to create animation.

## Arguments

- `strip`: StripSPI object

- `circular`: If `true` the #1 pixel will be set as the last one.
    If `false` the first value will be 0x000000 (black).
"""
function shift_forward!(strip::AbstractStrip; circular::Bool = false)
    last_color = last(strip.buffer)
    for i in length(strip.buffer):-1:2
        strip.buffer[i] = strip.buffer[i-1]
    end
    if circular
        strip.buffer[1] = last_color
    else
        strip.buffer[1] = 0x0
    end
end

"""
    shift_backward!(
        strip::AbstractStrip;
        circular::Bool = false
    )

Shifts Strip buffer values in negative direction, i.e. pixel #2 will be moved to pixel #1, #3 => #2, #4 => #3 etc.
This can be used to create animation.

## Arguments

- `strip`: StripSPI object

- `circular`: If `true` the last pixel will be set as first.
    If `false` the last value will be 0x000000 (black).
"""
function shift_backward!(strip::AbstractStrip; circular::Bool = false)
    first_color = first(strip.buffer)
    for i in 1:(length(strip.buffer)-1)
        strip.buffer[i] = strip.buffer[i+1]
    end
    if circular
        strip.buffer[strip.pixel_count] = first_color
    else
        strip.buffer[strip.pixel_count] = 0x0
    end
end

# transforms bits to bits adapted for LED strip
function _bytes_to_led_bytes(byte_array::AbstractArray{UInt8})
    output = UInt8[]

    for x in byte_array
        template = 0b100100100100100100100100

        # create 24 bit from 8 bits
        y = copy(x)
        for i in 0:7
            digit = y % 2
            template = digit << (1 + 3*i) | template
            y >>= 1
        end
        
        # splitting 24 bits to three UInt8
        part3 = template % 2^8
        template >>= 8
        part2 = template % 2^8
        template >>= 8
        part1 = template % 2^8

        push!(output, part1, part2, part3)
    end

    output
end

# split UInt32 values to 3 UInt8 values bit-wisely. 8 first bits will be ignored.
function _colors_to_bytes(color_array::AbstractArray{UInt32}, color_indexes::Vector{Int})
    output = UInt8[]

    one_pixel_bytes = zeros(UInt8,3) # b/g/r
    for x in color_array
        one_pixel_bytes[color_indexes[3]] = x % 2^8 # blue
        x >>= 8
        one_pixel_bytes[color_indexes[2]] = x % 2^8 # green
        x >>= 8
        one_pixel_bytes[color_indexes[1]] = x % 2^8 # red

        push!(output, one_pixel_bytes...)
    end

    output
end
