export Strip, send_bytes, send_colors
export set_colors!, shift_forward!, shift_backward!, hide_colors, show_colors

# MOSI - output #10 (alt0)
# MISO - input #09 (alt0)
# SCLK - clock #11 (alt0)

struct Strip
    spi::Int
    led_count::Int
    freq::Int
    buffer::AbstractArray{UInt32} # 
end

# required rate calculated based on 3 bits per signal: 1.25 us => 0.8 MHz signal => 2.4 MHz

function Strip(spi::Int; led_count::Int = 10, freq::Int = 800_000)
    # init
    if spi == 1
        path = "/dev/spidev0.0"
    elseif spi == 2
        path = "/dev/spidev0.1"
    else
        throw("spi number should be 1 or 2, got $spi")
    end

    init_spi(path; max_speed_hz = freq * 3)

    Strip(spi, led_count, freq, zeros(UInt32, led_count))
end

function set_colors!(strip::Strip, arr::AbstractArray{UInt32})
    for i in 1:min(strip.led_count, length(arr))
        strip.buffer[i] = arr[i]
    end
end

function shift_forward!(strip::Strip)
    last_color = last(strip.buffer)
    for i in length(strip.buffer):-1:2
        strip.buffer[i] = strip.buffer[i-1]
    end
    strip.buffer[1] = last_color
    #pushfirst!()
end

function shift_backward!(strip::Strip)
    first_color = first(strip.buffer)
    for i in 1:(length(strip.buffer)-1)
        strip.buffer[i] = strip.buffer[i+1]
    end
    strip.buffer[strip.led_count] = first_color
    #pushfirst!()
end

function show_colors(strip::Strip)
    send_colors(strip, strip.buffer)
end

function hide_colors(strip::Strip)
    all_black = zeros(UInt32, strip.led_count)
    send_colors(strip, all_black)
end

function send_bytes(strip::Strip, byte_array::AbstractArray{UInt8})
    led_byte_array = _led_byte_array(byte_array)
    spi_transfer(strip.spi, led_byte_array)
end

function send_colors(strip::Strip, color_array::AbstractArray{UInt32})
    led_byte_array = _led_byte_array(color_array)
    spi_transfer(strip.spi, led_byte_array)
end

# transforms bits to bits adapted for LED strip
function _led_byte_array(byte_array::AbstractArray{UInt8})
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

function _led_byte_array(color_array::AbstractArray{UInt32})
    output = UInt8[]

    for x in color_array
        blue_part = x % 2^8
        x >>= 8
        green_part = x % 2^8
        x >>= 8
        red_part = x % 2^8

        push!(output, green_part, red_part, blue_part)
    end

    _led_byte_array(output)
end
