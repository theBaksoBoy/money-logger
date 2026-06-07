package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"


Category :: struct {
    auto_add_multiplier: f32,
    items: []string,
    last_calculated_sum: f32,
}


category_directory: string = "" // directory that all the different categories are in

main :: proc() {
    LoadConfigFile()
    MainMenu()
}



LoadConfigFile :: proc() {

    home_dir := os.get_env("HOME", context.allocator)
    defer delete(home_dir)
    path := fmt.tprintf("%s/.config/money_logger/settings.txt", home_dir)
    data, err := os.read_entire_file_from_path(path, context.allocator)
    defer delete(data)
    // is this really the right way to do this? It feels fucked up.

    if err != os.ERROR_NONE {
        fmt.println("could not open ~/.config/money_logger/settings.txt\ndoes it exist?")
        os.exit(1)
    }

    file_string := string(data)

    // go through file and set variables to what is specified in the config
    for line in strings.split(file_string, "\n") {
        if strings.has_prefix(line, "category_directory=") {
            category_directory = line[len("category_directory="):]
        }
    }

    // ensure that all necessary values were specified in the config
    if category_directory == "" {
        fmt.println("category_directory=/example/path/ is missing from ~/.config/money_logger/settings.txt")
    }

}



PrintExistingCategories :: proc() {
    dir, _ := os.open(category_directory)
    defer os.close(dir)
    entries, _ := os.read_dir(dir, 1024, context.allocator)
    defer delete(entries)

    for entry in entries {
        if strings.has_suffix(entry.name, ".json") {
            base := strings.trim_suffix(entry.name, ".json")
            fmt.println(fmt.tprintf("    %s", base))
        }
    }
}



SaveCategoryJson :: proc(category: Category, category_name: string) {

    data, _ := json.marshal(
        category,
        json.Marshal_Options{
            pretty = true,
        }
    )
    defer delete(data)

    results := os.write_entire_file(fmt.tprintf("%s%s.json", category_directory, category_name), data)
}



MainMenu :: proc() {

    for {

        fmt.print("\n" +
            "[1] add/remove items\n" +
            "[2] get info\n" +
            "[3] manage categories\n" +
            "[1/2/3]: "
        )

        // get user's answer
        buffer: [128]byte
        _, _ = os.read(os.stdin, buffer[:])

        // parse user's answer
        if buffer[0] == byte('1') {
            fmt.println("WIP---------------------")
            break
        } else if buffer[0] == byte('2') {
            fmt.println("WIP---------------------")
            break
        } else if buffer[0] == byte('3') {
            CategoryMenu()
            break
        } else {
            fmt.println("invalid selection. try again.")
        }
    }
}
