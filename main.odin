package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"
import "core:time"
import "core:slice"


Category :: struct {
    auto_add_multiplier: f32,
    items: [dynamic]Item,
    last_calculated_sum: f32,
}



Item :: struct {
    date: string,
    money_delta: f32,
    description: string,
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
        fmt.print(GetColor(.GREEN))
        _, _ = os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

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
            fmt.print(GetColor(.RED))
            fmt.println("invalid selection. try again.")
            fmt.print(GetColor(.RESET))
        }
    }
}



LoadConfigFile :: proc() {

    home_dir := os.get_env("HOME", context.allocator)
    defer delete(home_dir)
    path := fmt.tprintf("%s/.config/money_logger/settings.txt", home_dir)
    data, err := os.read_entire_file_from_path(path, context.allocator)
    defer delete(data)
    // is this really the right way to do this? It feels fucked up.

    if err != os.ERROR_NONE {
        fmt.print(GetColor(.RED))
        fmt.println("could not open ~/.config/money_logger/settings.txt\ndoes it exist?")
        fmt.print(GetColor(.RESET))
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
            defer delete(category.items)

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



SaveCategoryJson :: proc(category: ^Category, category_name: string) {

    // ensure that the last calculated sum is up to date
    category.last_calculated_sum = GetSumOfItemList(&category.items)
    
    // sort the item list according to the date of the items
    slice.sort_by(category.items[:], proc(a, b: Item) -> bool {
        return strings.compare(a.date, b.date) < 0
    })


    data, _ := json.marshal(
        category^,
        json.Marshal_Options{
            pretty = true,
        }
    )
    defer delete(data)

    _ = os.write_entire_file(GetCategoryPath(category_name), data)
}



LoadCategory :: proc(category_name: string) -> Category {

    json_string, err := os.read_entire_file_from_path(GetCategoryPath(category_name), context.allocator)
    if err != nil {
        fmt.print(GetColor(.RED))
        fmt.println(fmt.tprintf("error reading the json file %s.json:", category_name), err)
        fmt.print(GetColor(.RESET))
        os.exit(1)
    }
    defer delete(json_string)
    category: Category
    unmarshal_err := json.unmarshal(json_string, &category)
    if unmarshal_err != nil {
        fmt.print(GetColor(.RED))
        fmt.println(fmt.tprintf("error parsing the json file %s.json:", category_name), err)
        fmt.print(GetColor(.RESET))
        os.exit(1)
    }

    return category
}



MakeUserSelectCategory :: proc(instructions: string, show_multipliers: bool) -> string {

    for {
        fmt.println("\nexisting categories:")
        PrintExistingCategories(show_multipliers)
        fmt.print(instructions)

        buffer: [512]byte
        fmt.print(GetColor(.GREEN))
        bytes_read, _ := os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        if !os.exists(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1]))) {
            fmt.print(GetColor(.RED))
            fmt.println("category does not exist. try again.")
            fmt.print(GetColor(.RESET))
            continue
        }

        return strings.clone(string(buffer[:bytes_read-1]), context.allocator)
    }
}



// ask the user to fill in details about an item to be created, in regards to its money delta, date, and description
MakeUserChoseItemParameters :: proc() -> (f32, string, string) { // (money_delta, date, description)
    
    // get the money delta of the item
    money_delta: f32
    for {
        fmt.print("\nspecify money delta\nnegative values are used when you spend money\npositive values are used when gaining money\n[money delta]: ")

        buffer: [512]byte
        fmt.print(GetColor(.GREEN))
        bytes_read, _ := os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        s := string(buffer[:bytes_read-1])

        float_input, ok := strconv.parse_f32(s)
        if !ok {
            fmt.print(GetColor(.RED))
            fmt.println("not a valid float. try again.")
            fmt.print(GetColor(.RESET))
            continue
        }

        money_delta = float_input
        break
    }

    // get date for the item
    current_time := time.now()
    month1, month2 := IntToTwoRunes(int(time.month(time.now())))
    day1, day2 := IntToTwoRunes(int(time.day(time.now())))
    date: string = fmt.tprintf("%d-%c%c-%c%c", time.year(time.now()), month1, month2, day1, day2)
    outer: for {
        fmt.print("\nspecify date for the item. leave blank to automatically select today's date. make sure that the date is valid as idfk how to code this shit in Odin\n[YYYY-MM-DD]: ")

        buffer: [512]byte
        fmt.print(GetColor(.GREEN))
        bytes_read, _ := os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        input_date := string(buffer[:bytes_read-1])

        if input_date == "" {
            break
        }

        if bytes_read != 11 {
            fmt.print(GetColor(.RED))
            fmt.println("inputted date is in the incorrect format. try again.")
            fmt.print(GetColor(.RESET))
            continue
        }

        // very basic validation of date
        for letter, i in input_date {
            if i == 4 || i == 7 {
                if letter != '-' {
                    fmt.print(GetColor(.RED))
                    fmt.println("inputted date is in the incorrect format. try again.")
                    fmt.print(GetColor(.RESET))
                    continue outer
                }
            } else {
                // (expert coding)
                if letter != '0' && letter != '1' && letter != '2' && letter != '3' && letter != '4' && letter != '5' && letter != '6' && letter != '7' && letter != '8' && letter != '9' {
                    fmt.print(GetColor(.RED))
                    fmt.println("inputted date is in the incorrect format. try again.")
                    fmt.print(GetColor(.RESET))
                    continue outer
                }
            }
        }

        date = input_date
        break
    }

    // get description for the item
    fmt.print("\nwrite a description for the item (optional)\n: ")

    buffer: [8192]byte
    fmt.print(GetColor(.GREEN))
    bytes_read, _ := os.read(os.stdin, buffer[:])
    fmt.print(GetColor(.RESET))
    description := string(buffer[:bytes_read-1])

    return money_delta, strings.clone(date, context.allocator), strings.clone(description, context.allocator)
}



IntToTwoRunes :: proc(num: int) -> (rune1, rune2: rune) {
    // wackass procudure for just making a number have a trailing 0 if <=9, for ISO date bullshit

    if num < 10 do return '0', '0' + rune(num)

    return '0' + rune(num / 10), '0' + rune(num % 10)
}



AddItemToCategoryAndSave :: proc(category: ^Category, category_name: string, date: string, money_delta: f32, description: string) {

    append(&category.items,
           Item{
               date,
               money_delta,
               description,
           }
          )

    SaveCategoryJson(category, category_name)
}



GetSumOfItemList :: proc(items: ^[dynamic]Item) -> f32 {
    sum: f32
    for item in items {
        sum += item.money_delta
    }

    return sum
}



ListItems :: proc(items: ^[dynamic]Item, include_item_index: bool) {

    for item, i in items {

        // print index
        if include_item_index {
            fmt.print(fmt.tprintf("[%s%d%s] ", GetColor(.BLUE), i, GetColor(.RESET)))
        }

        // print date and money delta
        fmt.print(fmt.tprintf("%s%s%s : %s%.2f%s", GetColor(.YELLOW), item.date, GetColor(.RESET), GetColor(.CYAN), item.money_delta, GetColor(.RESET)))
        
        // print description if there is one
        if item.description != "" {
            fmt.print(" :", item.description)
        }

        fmt.println()
    }
}



RemoveItemFromCategoryAndSave :: proc(category: ^Category, index_to_remove: int, category_name: string) {

    // some bullshit needed to have an ordered remove instead of unordered_remove()
    // gonna be honest I have no fucking idea how this works
    copy(category.items[index_to_remove:], category.items[index_to_remove+1:])
    resize(&category.items, len(category.items) - 1)

    SaveCategoryJson(category, category_name)
}
