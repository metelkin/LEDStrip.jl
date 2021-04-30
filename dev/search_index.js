var documenterSearchIndex = {"docs":
[{"location":"api/#API-references","page":"API","title":"API references","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [LEDStrip]\nOrder   = [:type, :function]","category":"page"},{"location":"api/#LEDStrip.SPIStrip","page":"API","title":"LEDStrip.SPIStrip","text":"struct SPIStrip\n    spi::Int                        # SPI number 1 or 2\n    pixel_count::Int                # number of pixels in RGB Strip, equals to buffer size\n    freq::Int                       # frequency in Hz for sending messages to WS281x chip\n    color_indexes::Vector{Int}      # color indexes in RGB notation\n    buffer::AbstractArray{UInt32}   # array storing states of pixels\nend\n\nObject storing settings and states of addressable LED Strip.\n\nSPIStrip includes the intermediate buffer which is a variable storing pixel colors in RGB.\n\nThere are two ways working with SPIStrip:\n\nSending colors directly to Strip using the methods like send_bytes, send_colors.\nUpdating buffer values and make changes visible after that using methods: set_pixels!, clean_pixels!, show_pixels, etc.\n\n\n\n\n\n","category":"type"},{"location":"api/#LEDStrip.SPIStrip-Tuple{Int64}","page":"API","title":"LEDStrip.SPIStrip","text":"SPIStrip(\n    spi::Int;\n    pixel_count::Int = 10,\n    freq::Int = 800_000,\n    color_type::String = \"grb\"\n)\n\nCreates object representing LED Strip.\n\nArguments\n\nspi: number of SPI used: 1 or 2.\n1 value corresponds to main SPI device. Data pin of LED Strip should be connected to MOSI (GPIO10),   MISO (GPIO9), CLK (GPIO11), CC0 (GPIO8), CC1 (GPIO7) are not used for LED Strip.\n2 value corresponds to alternative SPI device. Data pin of LED Strip should be connected to MOSI (GPIO20),   MISO (GPI19), CLK (GPIO21), CC0 (GPI18), CC1 (GPI17), CC2 (GPIO16) are not used for LED Strip.\npixel_count: number of physical pixels (RGB LED items)\nThis value equals to buffer size.\nfreq: signal rate of WS281x chip. Default 800000 Hz.\nUsually RGB LED Strip support 800 000 Hz messages (sometimes 400 000 Hz).\ncolor_type: RGB sequence may vary on some strips. Default is grb\nValid values are \"rgb\", \"rbg\", \"grb\", \"gbr\", \"bgr\", \"brg\".\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.clean_pixels!-Tuple{LEDStrip.AbstractStrip}","page":"API","title":"LEDStrip.clean_pixels!","text":"clean_pixels!(strip::AbstractStrip)\n\nThis method removes colors from whole Strip buffer or in other words set them as black. This is the same as setting all buffer values as 0x000000. To make it visible you must use show_pixels after.\n\nArguments\n\nstrip: SPIStrip object\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.hide_pixels-Tuple{LEDStrip.AbstractStrip}","page":"API","title":"LEDStrip.hide_pixels","text":"hide_pixels(strip::AbstractStrip)\n\nClean physical buffer colors i.e. set them as black. This method does not change the buffer state. You can hide and show colors but buffer content will be the same.\n\nArguments\n\nstrip: SPIStrip object\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.send_bytes-Tuple{SPIStrip, AbstractArray{UInt8, N} where N}","page":"API","title":"LEDStrip.send_bytes","text":"send_bytes(\n    strip::SPIStrip,\n    byte_array::AbstractArray{UInt8}\n)\n\nSending sequence of bytes to LED Strip. Each byte regulates brightness of one LED. LED strip consists of pixels under control of the WS281x chip: tree LEDs per pixel. To send the color \"pixel-wisely\" use send_colors method.\n\nThe method does not update the internal buffer of Strip object.\n\nArguments\n\nstrip: SPIStrip object\nbyte_array: Array of bytes UInt8 to send.    First byte will be send to first LED (green), the second one will be send to second LED (red), etc.   The byte's value regulates the brightness of corresponding LED. Three bytes together    regulates the color of pixel.\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.send_colors-Tuple{LEDStrip.AbstractStrip, AbstractArray{UInt32, N} where N}","page":"API","title":"LEDStrip.send_colors","text":"send_colors(\n    strip::AbstractStrip,\n    color_array::AbstractArray{UInt32}\n)\n\nSend message to set Strip pixel colors in RGB notation.\n\nThe method does not update the internal buffer of Strip object.\n\nExample\n\nsend_colors(strip, [0x000000, 0xffffff, 0xff0000])`\n\nThe first pixel is red, second is white, third is red the other pixels will not be updated.\n\nArguments\n\nstrip: SPIStrip object\ncolor_array:  Each color is an unsigned 32-bit value (UInt32) where    the lower 24 bits define the red, green, blue data (each being 8 bits long).\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.set_pixel!-Tuple{LEDStrip.AbstractStrip, Int64, UInt32}","page":"API","title":"LEDStrip.set_pixel!","text":"set_pixel!(\n    strip::AbstractStrip,\n    num::Int,\n    color::UInt32\n)\n\nThis method updates the color of particular pixel in Strip's buffer. To make it visible you must use show_pixels after updating.\n\nExample\n\nset_pixel(strip, 10, 0x00ff00)\nshow_pixels(strip);\n\nSet pixel #10 as green and make it visible.\n\nArguments\n\nstrip: SPIStrip object\nnum: number of pixel in strip starting from 1.\ncolor: UInt32 value representing color and brightness.\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.set_pixels!-Tuple{LEDStrip.AbstractStrip, AbstractArray{UInt32, N} where N}","page":"API","title":"LEDStrip.set_pixels!","text":"set_pixels!(\n    strip::AbstractStrip,\n    arr::AbstractArray{UInt32};\n    replicate::Bool = false\n)\n\nThis method updates whole pixel buffer in Strip. To make it visible you must use show_pixels after updating.\n\nArguments\n\nstrip: SPIStrip object\ncolor_arr: UInt32 vector representing color and brightness for all pixels in Strip.   If this vector is longer than the buffer length the rest values will be ignored.   If color_arr is shorter the result will depend on replicate argument.\nreplicate: If true the shorter color_arr will be replicated to the end of buffer.\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.shift_backward!-Tuple{LEDStrip.AbstractStrip}","page":"API","title":"LEDStrip.shift_backward!","text":"shift_backward!(\n    strip::AbstractStrip;\n    circular::Bool = false\n)\n\nShifts Strip buffer values in negative direction, i.e. pixel #2 will be moved to pixel #1, #3 => #2, #4 => #3 etc. This can be used to create animation.\n\nArguments\n\nstrip: SPIStrip object\ncircular: If true the last pixel will be set as first.   If false the last value will be 0x000000 (black).\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.shift_forward!-Tuple{LEDStrip.AbstractStrip}","page":"API","title":"LEDStrip.shift_forward!","text":"shift_forward!(\n    strip::AbstractStrip;\n    circular::Bool = false\n)\n\nShifts Strip buffer values forward, i.e. pixel #1 will be moved to pixel #2, #2 => #3, #3 => #4 etc. This can be used to create animation.\n\nArguments\n\nstrip: SPIStrip object\ncircular: If true the #1 pixel will be set as the last one.   If false the first value will be 0x000000 (black).\n\n\n\n\n\n","category":"method"},{"location":"api/#LEDStrip.show_pixels-Tuple{LEDStrip.AbstractStrip}","page":"API","title":"LEDStrip.show_pixels","text":"show_pixels(strip::AbstractStrip)\n\nDisplay buffer content in pixels. Updating colors by set_pixels!, clean_pixels!, etc. changes only buffer state. This method make it visible in physical pixels.\n\nArguments\n\nstrip: SPIStrip object\n\n\n\n\n\n","category":"method"},{"location":"#LEDStrip.jl-package","page":"Home","title":"LEDStrip.jl package","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Raspberry Pi package for controlling addressable RGB LED Strip on WS281x chip (Neopixel) written in Julia. ","category":"page"},{"location":"#Introduction","page":"Home","title":"Introduction","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The addressable RGB LED strip, which are based on WS281x chip or similar, is popular for different education and DIY projects. It allows controlling the each pixel of strip and creating a nice colored show. On the YouTube you can find examples how Raspberry Pi can be used for it.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is a Julia's package for LED strip control which is based on BaremetalPi.jl engine.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Julia must be installed on Raspberry Pi.  I have tested on v1.1.0 which can be installed with:","category":"page"},{"location":"","page":"Home","title":"Home","text":"sudo apt update\nsudo apt install julia","category":"page"},{"location":"","page":"Home","title":"Home","text":"The package can be installed from Julia environment with:","category":"page"},{"location":"","page":"Home","title":"Home","text":"] add https://github.com/metelkin/LEDStrip.jl.git","category":"page"},{"location":"#Notes","page":"Home","title":"Notes","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"I have tested on RaspberryPi 4 with the Raspberry Pi OS installed. It seems it should work it should be working with other Raspberry versions and OS.","category":"page"},{"location":"","page":"Home","title":"Home","text":"SPI protocol should be turn on, see OS settings.","category":"page"},{"location":"","page":"Home","title":"Home","text":"In other tutorials it is also recommended to set frequency in the file /boot/config.txt as follows","category":"page"},{"location":"","page":"Home","title":"Home","text":"core_freq=500\ncore_freq_min=500","category":"page"},{"location":"","page":"Home","title":"Home","text":"In older versions of RasperryPi one should extend the SPI buffer size in /boot/config.txt.","category":"page"},{"location":"","page":"Home","title":"Home","text":"# spidev.bufsiz=32768 # if default SPI buffer too small","category":"page"},{"location":"","page":"Home","title":"Home","text":"See also the notes in other projects like here: https://github.com/jgarff/rpi_ws281x","category":"page"},{"location":"#Circuits","page":"Home","title":"Circuits","text":"","category":"section"},{"location":"#A.","page":"Home","title":"A.","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"LED strip can be connected based on the following scheme. RaspberryPi's 5V output is not enough as power for RGB LEd Strip. Use external power source.","category":"page"},{"location":"","page":"Home","title":"Home","text":"In many cases LED Strips can work with 3.3V output signal. In that case you need no additional chip elements.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: scheme-no-chip)","category":"page"},{"location":"#B.","page":"Home","title":"B.","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If the 3.3V signal is not enough for RGB Strip DIN a chip transforming 3.3V to 5V logic may be required. You can use SN74AHCT125N chip or similar. (Image: scheme-chip)","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"You can work with LEd pixels directly or using the internal LEDStrip buffer.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using LEDStrip\n\n# use main SPI MOSI connector is GPIO10\n# total pixels count is 100\ns = SPIStrip(1; pixel_count = 100) \n\n### Direct approach ###\n\n# set pixels 1, 2, 3, 4 as red, green, blue, white\nsend_colors(s, [0xff0000, 0x00ff00, 0x00ff00, 0xffffff])\n# clear pixels (set them black)\nsend_colors(s, [0x000000, 0x000000, 0x000000, 0x000000])\n\n### Using buffer ###\n\n# set pixels 1, 2, 3, 4 as red, green, blue, white\n# for 5 seconds\nset_pixels!(s, [0xff0000, 0x00ff00, 0x00ff00, 0xffffff]) # update buffer\nshow_pixels(s) # show buffered colors\nsleep(5.)\n# hide \nhide_pixels(s) # hide all colors\nsleep(5.)\n# show again\nshow_pixels(s) # show buffered colors","category":"page"},{"location":"#Video-demo","page":"Home","title":"Video demo","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: Watch the video)","category":"page"},{"location":"#Known-issues-and-limitations","page":"Home","title":"Known issues and limitations","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Currently only SPI is supported via GPIO10 and GPIO20. PWM and PCM protocols can be potentially supported in future versions.","category":"page"},{"location":"#Related-projects","page":"Home","title":"Related projects","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"C library with connectors to Python and other languages (but not Julia)   https://github.com/jgarff/rpi_ws281x\nNodeJS package   https://www.npmjs.com/package/rpi-ws281x","category":"page"}]
}
