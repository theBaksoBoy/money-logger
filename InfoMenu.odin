package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"



InfoMenu :: proc() {

    for {
        fmt.print("\n" +
            "[1] list all items in a category\n" +
            "[2] get remaining funds in a category\n" +
            "[3] create graph of a category's funds\n" +
            "[4] see all categories auto-add percentage\n" +
            "[1/2/3/4]: "
        )

        // get user's answer
        buffer: [128]byte
        fmt.print(GetColor(.GREEN))
        _, _ = os.read(os.stdin, buffer[:])
        fmt.print(GetColor(.RESET))

        // parse user's answer
        if buffer[0] == byte('1') {
            fmt.println("WIP---------------------")
            break
        } else if buffer[0] == byte('2') {
            GetSumMenu()
            break
        } else if buffer[0] == byte('3') {
            fmt.println("WIP---------------------")
            break
        } else if buffer[0] == byte('4') {
            PrintExistingCategories(true)
            break
        } else {
            fmt.println("invalid selection. try again.")
        }
    }
}



GetSumMenu :: proc() {
    
    selected_category := MakeUserSelectCategory("view remaining funds of which category?\ncategory: ", false)
    defer delete(selected_category)
    category := LoadCategory(selected_category)
    defer delete(category.items)

    fmt.println(fmt.tprintf("    remaining sum: %s%.2f%s", GetColor(.CYAN), GetSumOfItemList(&category.items), GetColor(.RESET)))
}
