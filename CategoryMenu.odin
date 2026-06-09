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
        _, _ = os.read(os.stdin, buffer[:])

        // parse user's answer
        if buffer[0] == byte('1') {
            CreateCategory()
            break
        } else if buffer[0] == byte('2') {
            DeleteCategory()
            break
        } else if buffer[0] == byte('3') {
            ChangeCategoryAutoAddMultiplier()
            break
        } else {
            fmt.println("invalid selection. try again.")
        }
    }
}



CreateCategory :: proc() {

    for {
        fmt.println("\nexisting categories:")
        PrintExistingCategories()
        fmt.print("specify the name of the new category. note that it has to be a valid file name, so no special characters like slashes\nname: ")
        buffer: [512]byte
        bytes_read, _ := os.read(os.stdin, buffer[:])

        if buffer[0] == byte('\n') {
            fmt.println("category name can not be empty. try again.")
            continue
        }

        if os.exists(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1]))) {
            fmt.println("category with specified name already exists. try again.")
            continue
        }

        new_category := Category{0, {}, 0}
        SaveCategoryJson(new_category, string(buffer[:bytes_read-1]))
        fmt.println("category created.")
        break
    }
}



DeleteCategory :: proc() {

    for {
        fmt.println("\nexisting categories:")
        PrintExistingCategories()
        fmt.print("specify what category to delete.\ndelete: ")

        buffer: [512]byte
        bytes_read, _ := os.read(os.stdin, buffer[:])

        if !os.exists(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1]))) {
            fmt.println("category does not exist. try again.")
            continue
        }

        os.remove(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1])))
        fmt.println(string(buffer[:bytes_read-1]), "deleted.")
        break
    }
}




ChangeCategoryAutoAddMultiplier :: proc() {
    for {
        fmt.println("\nexisting categories:")
        PrintExistingCategoriesWithMultiplier()
        fmt.print("specify what category to change the auto-add multiplier of.\ncategory: ")

        buffer: [512]byte
        bytes_read, _ := os.read(os.stdin, buffer[:])

        if !os.exists(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1]))) {
            fmt.println("category does not exist. try again.")
            continue
        }

        for {
            fmt.print("\nwhat should the multiplier be changed to?\n[0-1]: ")

            buffer2: [512]byte
            bytes_read2, _ := os.read(os.stdin, buffer2[:])

            s := string(buffer2[:bytes_read2-1])
            multiplier, ok := strconv.parse_f32(s)
            if !ok {
                fmt.println("not a valid float. try again.")
                continue
            }

            // load file, change the value, write file

            json_string, _ := os.read_entire_file_from_path(fmt.tprintf("%s%s.json", category_directory, string(buffer[:bytes_read-1])), context.allocator)
            defer delete(json_string)
            category: Category
            _ = json.unmarshal(json_string, &category)

            category.auto_add_multiplier = multiplier

            SaveCategoryJson(category, string(buffer[:bytes_read-1]))

            fmt.println("multiplier edited.")
            break
        }

        break
    }
}
