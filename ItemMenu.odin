package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"
import "core:time"



ItemMenu :: proc() {

    for {
        fmt.print("\n" +
            "[1] add an item to a category\n" +
            "[2] auto-add an item to all categories\n" +
            "[3] delete an item from a category\n" +
            "[1/2/3]: "
        )

        // get user's answer
        buffer: [128]byte
        fmt.print(GetColor(.GREEN))
        _, _ = os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        // parse user's answer
        if buffer[0] == byte('1') {
            AddItemMenu()
            break
        } else if buffer[0] == byte('2') {
            AutoAddItemMenu()
            break
        } else if buffer[0] == byte('3') {
            DeleteItemMenu()
            break
        } else {
            fmt.print(GetColor(.RED))
            fmt.println("invalid selection. try again.")
            fmt.print(GetColor(.RESET))
        }
    }
}



AddItemMenu :: proc() {

    // get what category to add the item to
    selected_category := MakeUserSelectCategory("add the item to which category?\ncategory: ", false)
    defer delete(selected_category)

    money_delta, date, description := MakeUserChoseItemParameters()

    category := LoadCategory(selected_category)
    defer delete(category.items)

    AddItemToCategoryAndSave(&category, selected_category, date, money_delta, description)

    fmt.println("\nitem added")
}



AutoAddItemMenu :: proc() {
    
    money_delta, date, description := MakeUserChoseItemParameters()

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

            // skip category if it's auto-add multiplier is 0, as items don't need to be auto-added to these categories
            if category.auto_add_multiplier == 0 do continue

            money_in_item := money_delta * category.auto_add_multiplier
            AddItemToCategoryAndSave(&category, base, date, money_in_item, description)
            remaining_multiplier -= category.auto_add_multiplier

            fmt.println(fmt.tprintf("    %s: %s%.2f%s", base, GetColor(.CYAN), money_in_item, GetColor(.RESET)))
        }
    }

    fmt.println(fmt.tprintf("    (in total %s%.2f%s was dispursed to categories. %s%.2f%s remains, and goes into savings)", GetColor(.CYAN), money_delta * (1-remaining_multiplier), GetColor(.RESET), GetColor(.CYAN), money_delta * remaining_multiplier, GetColor(.RESET)))
}



DeleteItemMenu :: proc() {

    selected_category := MakeUserSelectCategory("delete items in which category?\ncategory: ", false)
    defer delete(selected_category)
    category := LoadCategory(selected_category)
    defer delete(category.items)

    fmt.println()
    ListItems(&category.items, true)

    index_to_remove: int
    for {
        fmt.print("\nspecify index of item to delete\n[index]: ")

        buffer: [512]byte
        fmt.print(GetColor(.GREEN))
        bytes_read, _ := os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        s := string(buffer[:bytes_read-1])

        int_input, ok := strconv.parse_int(s)
        if !ok {
            fmt.print(GetColor(.RED))
            fmt.println("not a valid integer. try again.")
            fmt.print(GetColor(.RESET))
            continue
        }
        if int_input < 0 || int_input >= len(category.items) {
            fmt.print(GetColor(.RED))
            fmt.println("specified index is out of bounds. try again.")
            fmt.print(GetColor(.RESET))
            continue
        }

        index_to_remove = int_input
        break
    }

    RemoveItemFromCategoryAndSave(&category, index_to_remove, selected_category)

    fmt.println("\nitem removed")
}
