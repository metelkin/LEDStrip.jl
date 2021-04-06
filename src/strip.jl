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

function Strip(spi::Int; freq::Int = 800)
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
    @info "Sending..."
    spi_transfer(1, msg_transformed)
end

# transforms color bits to spi specific bits
function _transform(message::AbstractArray{UInt8})
    output = message

    output
end
