package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"



CategoryMenu :: proc() {

    for {
        fmt.print("\n" +
            "[1] create a category\n" +
            "[2] delete a category\n" +
            "[3] change the auto-add multiplier for a category\n" +
            "[1/2/3]: "
        )

        // get user's answer
        buffer: [128]byte
        fmt.print(GetColor(.GREEN))
        _, _ = os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        // parse user's answer
        if buffer[0] == byte('1') {
            CreateCategoryMenu()
            break
        } else if buffer[0] == byte('2') {
            DeleteCategoryMenu()
            break
        } else if buffer[0] == byte('3') {
            ChangeCategoryAutoAddMultiplierMenu()
            break
        } else {
            fmt.println("invalid selection. try again.")
        }
    }
}



CreateCategoryMenu :: proc() {

    for {
        fmt.println("\nexisting categories:")
        PrintExistingCategories(false)
        fmt.print("specify the name of the new category. note that it has to be a valid file name, so no special characters like slashes\nname: ")
        buffer: [512]byte
        fmt.print(GetColor(.GREEN))
        bytes_read, _ := os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        if buffer[0] == byte('\n') {
            fmt.println("category name can not be empty. try again.")
            continue
        }

        if os.exists(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1]))) {
            fmt.println("category with specified name already exists. try again.")
            continue
        }

        new_category := Category{0, {}, 0}
        SaveCategoryJson(&new_category, string(buffer[:bytes_read-1]))
        fmt.println("category created.")
        break
    }
}



DeleteCategoryMenu :: proc() {

    selected_category := MakeUserSelectCategory("specify what category to delete.\ndelete: ", false)
    defer delete(selected_category)
    os.remove(fmt.tprintf("%s%s.json", category_directory, selected_category))
    fmt.println(selected_category, "deleted.")
}




ChangeCategoryAutoAddMultiplierMenu :: proc() {

    selected_category := MakeUserSelectCategory("specify what category to change the auto-add multiplier of.\ncategory: ", true)
    defer delete(selected_category)

    for {
        fmt.print("\nwhat should the multiplier be changed to?\n[0-1]: ")

        buffer: [512]byte
        fmt.print(GetColor(.GREEN))
        bytes_read, _ := os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        s := string(buffer[:bytes_read-1])
        multiplier, ok := strconv.parse_f32(s)
        if !ok {
            fmt.println("not a valid float. try again.")
            continue
        }

        // load file, change the value, write file

        json_string, _ := os.read_entire_file_from_path(fmt.tprintf("%s%s.json", category_directory, selected_category), context.allocator)
        defer delete(json_string)
        category: Category
        _ = json.unmarshal(json_string, &category)

        category.auto_add_multiplier = multiplier

        SaveCategoryJson(&category, selected_category)

        fmt.println("multiplier edited.")
        break
    }
}
