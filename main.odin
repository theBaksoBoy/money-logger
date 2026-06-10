package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"
import "core:time/datetime"


Category :: struct {
    auto_add_multiplier: f32,
    items: []Item,
    last_calculated_sum: f32,
}



Item :: struct {
    date: datetime.Date,
    money_delta: f32,
    description: string
}



Color :: enum {
    RESET,
    BLACK,
    RED,
    GREEN,
    YELLOW,
    BLUE,
    MAGENTA,
    CYAN,
    WHITE,
}
GetColor :: proc(color: Color) -> string {
    switch color {
    case .RESET: return "\x1b[0m"
    case .BLACK: return "\x1b[30m"
    case .RED: return "\x1b[31m"
    case .GREEN: return "\x1b[32m"
    case .YELLOW: return "\x1b[33m"
    case .BLUE: return "\x1b[34m"
    case .MAGENTA: return "\x1b[35m"
    case .CYAN: return "\x1b[36m"
    case .WHITE: return "\x1b[37m"
    }
    return ""
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



PrintExistingCategories :: proc(show_multipliers: bool) {

    remaining_multiplier: f32 = 1

    dir, _ := os.open(category_directory)
    defer os.close(dir)
    entries, _ := os.read_dir(dir, 1024, context.allocator)
    defer delete(entries)

    for entry in entries {
        if strings.has_suffix(entry.name, ".json") {
            base := strings.trim_suffix(entry.name, ".json")
            category := LoadCategory(base)

            if show_multipliers {
                fmt.println(fmt.tprintf("    %s: %s%d%%%s", base, GetColor(.CYAN), int(category.auto_add_multiplier * 100 + 0.5), GetColor(.RESET)))
                remaining_multiplier -= category.auto_add_multiplier
            } else {
                fmt.println(fmt.tprintf("    %s", base))
            }
        }
    }

    if show_multipliers {
        fmt.println(fmt.tprintf("    (%s%d%%%s remains, and goes into savings)", GetColor(.GREEN), int(remaining_multiplier * 100 + 0.5), GetColor(.RESET)))
    }
}



GetCategoryPath :: proc(category_name: string) -> string {
    return fmt.tprintf("%s%s.json", category_directory, category_name)
}



SaveCategoryJson :: proc(category: Category, category_name: string) {
    data, _ := json.marshal(
        category,
        json.Marshal_Options{
            pretty = true,
        }
    )
    defer delete(data)

    results := os.write_entire_file(GetCategoryPath(category_name), data)
}



LoadCategory :: proc(category_name: string) -> Category {

    json_string, err := os.read_entire_file_from_path(GetCategoryPath(category_name), context.allocator)
    if err != nil {
        fmt.println(fmt.tprintf("error reading the json file %s.json:", category_name), err)
        os.exit(1)
    }
    defer delete(json_string)
    category: Category
    unmarshal_err := json.unmarshal(json_string, &category)
    if unmarshal_err != nil {
        fmt.println(fmt.tprintf("error parsing the json file %s.json:", category_name), err)
        os.exit(1)
    }

    return category
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
            ItemMenu()
            break
        } else if buffer[0] == byte('2') {
            InfoMenu()
            break
        } else if buffer[0] == byte('3') {
            CategoryMenu()
            break
        } else {
            fmt.println("invalid selection. try again.")
        }
    }
}
