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
            ListItemsInCategoryMenu()
            break
        } else if buffer[0] == byte('2') {
            GetSumMenu()
            break
        } else if buffer[0] == byte('3') {
            GraphMenu()
            break
        } else if buffer[0] == byte('4') {
            PrintExistingCategories(true)
            break
        } else {
            fmt.print(GetColor(.RED))
            fmt.println("invalid selection. try again.")
            fmt.print(GetColor(.RESET))
        }
    }
}



ListItemsInCategoryMenu :: proc() {
    
    selected_category := MakeUserSelectCategory("view items in which category?\ncategory: ", false)
    defer delete(selected_category)
    category := LoadCategory(selected_category)
    defer delete(category.items)

    fmt.println()
    ListItems(&category.items, false)
}



GetSumMenu :: proc() {
    
    selected_category := MakeUserSelectCategory("view remaining funds of which category?\ncategory: ", false)
    defer delete(selected_category)
    category := LoadCategory(selected_category)
    defer delete(category.items)

    fmt.println(fmt.tprintf("    remaining sum: %s%.2f%s", GetColor(.CYAN), GetSumOfItemList(&category.items), GetColor(.RESET)))
}



GraphMenu :: proc() {

    selected_category := MakeUserSelectCategory("show graph of which category?\ncategory: ", false)
    defer delete(selected_category)
    category := LoadCategory(selected_category)
    defer delete(category.items)

    start_date := MakeUserChoseDate("\nspecify starting date for the graph. leave blank to select the first item. make sure that the date is valid as idfk how to code this shit in Odin\n[YYYY-MM-DD]: ", "")
    defer delete(start_date)
    end_date := MakeUserChoseDate("\nspecify end date for the graph. leave blank to select the last item. make sure that the date is valid as idfk how to code this shit in Odin\n[YYYY-MM-DD]: ", "")
    defer delete(end_date)

    PrintGraph(&category, start_date, end_date)
}
