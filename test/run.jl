using LEDStrip

const RGB_COLORS = [
    0xff0000,
    0xff0000,
    0x00ff00,
    0x00ff00,
    0x0000ff,
    0x0000ff,
    0x000000,
    0x000000,
]

const SNAKE_COLORS = [
    0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff,
    0xff0000, 0x00ff00, 0x0000ff,
    0x000000, 0x000000,
]

const RAINBOW_COLORS = [
    0xFF0000,   # red
    0xFF7F00,   # orange
    0xFFFF00,   # yellow
    0x00FF00,   # green
    0x0000FF,   # lightblue
    0x4B0082,   # blue
    0x9400D3,   # violet
]      

const PIXEL_COUNT = 100
s = SPIStrip(1; pixel_count = PIXEL_COUNT)

############################

@info "R-R-G-G-B-B..."

set_pixels!(s, RGB_COLORS, replicate = false)
show_pixels(s)
sleep(5.)
hide_pixels(s)
clean_pixels!(s)
sleep(1.)

@info "R-R-G-G-B-B repeated..."
set_pixels!(s, RGB_COLORS, replicate = true)
show_pixels(s)
sleep(5.)
hide_pixels(s)
clean_pixels!(s)

##########################

@info "All RED... All GREEN... All BLUE... All WHITE..."

set_pixels!(s, [0xff0000]; replicate = true)
show_pixels(s)
sleep(5)
set_pixels!(s, [0x00ff00]; replicate = true)
show_pixels(s)
sleep(5)
set_pixels!(s, [0x0000ff]; replicate = true)
show_pixels(s)
sleep(5)
set_pixels!(s, [0xffffff]; replicate = true)
show_pixels(s)
sleep(5)

hide_pixels(s)
clean_pixels!(s)
sleep(1.)

@info "Rainbow 7 colors..."

set_pixels!(s, RAINBOW_COLORS)
show_pixels(s)
sleep(5)
hide_pixels(s)
clean_pixels!(s)
sleep(1.)

@info "W-W-W-W-W-W-W-W-R-G-B snake moves forward and back..."

set_pixels!(s, SNAKE_COLORS)

for i in 1:90
    show_pixels(s)
    shift_forward!(s)
    sleep(0.1)
end

for i in 1:90
    show_pixels(s)
    shift_backward!(s)
    sleep(0.1)
end

hide_pixels(s)
clean_pixels!(s)

@info "Stop."
