export Strip, send

# MOSI - output #10 (alt0)
# MISO - input #09 (alt0)
# SCLK - clock #11 (alt0)

struct Strip
    spi::Int
    freq::Int
    buffer::AbstractArray{UInt8}
end

# required rate calculated based on 3 bits per signal: 1.25 us => 0.8 MHz signal => 2.4 MHz

function Strip(spi::Int; freq::Int = 800_000)
    # init
    if spi == 1
        path = "/dev/spidev0.0"
    elseif spi == 2
        path = "/dev/spidev0.1"
    else
        throw("spi number should be 1 or 2, got $spi")
    end

    init_spi(path; max_speed_hz = freq * 3)

    Strip(spi, freq, UInt8[])
end


function send(strip::Strip, message::AbstractArray{UInt8})
    msg_transformed = _transform(message)
    spi_transfer(strip.spi, msg_transformed)
end

# transforms bits to bits adapted for LED strip
function _transform(message::AbstractArray{UInt8})
    output = UInt8[]

    for x in message
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
