package pixelhash

import "core:hash"
import "core:c"
import "core:bytes"
import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:log"
import "core:strings"

import "core:image/bmp"
import "core:image/png"
import "core:image/tga"
import "core:image"

import stbi "vendor:stb/image"

HELP :: `Utility for testing Odin core:image.

It is used to generate a crc32 hash of the decoded pixels of an image, both
normal and vertically flipped. Decoding happens via stb_image and
odin:core/image to decrease the chance to accidently embed errors into the
test data. If the decoding results in different data, an error will be printed.

Supports PNG, BMP, TGA.

Usage: pixelhash.exe [--help|-h] [file1.png] [file2.tga] [file...]`

main :: proc() {
    context.logger = log.create_console_logger()

    args := os.args[1:]
    if len(args) == 0 {
        fmt.println(HELP)
    }
    for arg in args {
        assert(len(arg) > 1)
        if arg == "-h" || arg == "--help" {
            fmt.println(HELP)
            os.exit(0)
        }

        abs_filepath, ok_path := filepath.abs(arg)
        if !ok_path {
            log.errorf("Could not get absolute path of file '%v'. Skipping the file.", arg)
            continue
        }

        img, err := image.load_from_file(abs_filepath)
        if err != nil {
            log.errorf("Failed to load image '%v'! Error: '%v' Skipping the file.", abs_filepath, err)
            continue
        }
        defer image.destroy(img)
        pixels := bytes.buffer_to_bytes(&img.pixels)
        hash_ := hash.crc32(pixels)
        image.vertical_flip(img)
        hash_flipped := hash.crc32(pixels)

        {
            filename_c := strings.clone_to_cstring(abs_filepath, context.temp_allocator)
            stbi.set_flip_vertically_on_load(0)
            x, y, channels : i32
            buffer := stbi.load(
                filename=filename_c,
                x=&x,
                y=&y,
                channels_in_file=&channels,
                desired_channels=0,
                )
            if x != i32(img.width) {
                log.errorf("Image width doesn't match! width core:image: %v, stbi: %v", img.width, x)
            }
            if y != i32(img.height) {
                log.errorf("Image height doesn't match! height core:image: %v, stbi: %v", img.height, y)
            }
            if channels != i32(img.channels) {
                log.errorf("Image channels don't match! channels core:image: %v, stbi: %v", img.channels, channels)
            }

            bytes_image := x*y*channels
            hash_stbi := hash.crc32(buffer[:bytes_image])
            stbi.image_free(buffer)

            stbi.set_flip_vertically_on_load(1)
            buffer = stbi.load(
                filename=filename_c,
                x=&x,
                y=&y,
                channels_in_file=&channels,
                desired_channels=0,
                )
            hash_flipped_stbi := hash.crc32(buffer[:bytes_image])
            stbi.image_free(buffer)
            if hash_stbi != hash_ || hash_flipped_stbi != hash_flipped {
                fmt.printfln("WARNING: %v has different hashes!\nNormal:  core:image: 0x%08x, stbi: 0x%08x\nFlipped: image: 0x%08x, stbi: 0x%08x",
                    abs_filepath, hash_, hash_stbi, hash_flipped, hash_flipped_stbi)

                base_filename := filepath.base(abs_filepath)

                save_file_odin := strings.concatenate({base_filename, ".odin_image.bmp"})
                save_image_as_bmp(save_file_odin, img)


                save_file_stbi := strings.concatenate({base_filename, ".stbi.bmp"})
                img_stbi := stb_image_to_core_image(x, y, channels, buffer)
                save_image_as_bmp(save_file_stbi, &img_stbi)
                continue
            }
        }

        fmt.printfln("%v crc32: 0x%08x, flipped image crc32: 0x%08x (both in core:image and stb_image)", abs_filepath, hash_, hash_flipped)
    }
}

save_image_as_bmp :: proc(filename: string, img : ^image.Image) {
    err := bmp.save_to_file(filename, img)
    if err != nil {
        log.errorf("Error while trying to save file '%v': %v", filename, err)
    }
}

stb_image_to_core_image :: proc(x, y, channels: i32, pixels: [^]u8) -> image.Image {
    img: image.Image
    buffer : bytes.Buffer
    size := x*y*channels
    bytes.buffer_init(&buffer, pixels[:size])
    img.pixels = buffer
    return img
}