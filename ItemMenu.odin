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
        _, _ = os.read(os.stdin, buffer[:])

        // parse user's answer
        if buffer[0] == byte('1') {
            AddItemMenu()
            break
        } else if buffer[0] == byte('2') {
            fmt.println("WIP--------------------------------------------------")
            break
        } else if buffer[0] == byte('3') {
            fmt.println("WIP--------------------------------------------------")
            break
        } else {
            fmt.println("invalid selection. try again.")
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

    AddItemToCategory(&category, selected_category, date, money_delta, description)
}
