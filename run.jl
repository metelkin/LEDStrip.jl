using LEDStrip

colors = [
    0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff,
    0xff0000, 0x00ff00, 0x0000ff,
    0x000000, 0x000000,
]

@info "Starting..."

s = Strip(1; led_count = 142)
set_colors!(s, colors)

for i in 1:132
    show_colors(s)
    shift_forward!(s)
    sleep(0.1)
end

for i in 1:132
    show_colors(s)
    shift_backward!(s)
    sleep(0.1)
end

hide_colors(s)

@info "Stop."
