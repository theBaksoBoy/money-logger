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

    // get the money delta of the item
    money_delta: f32
    for {
        fmt.print("\nspecify money delta\nnegative values are used when you spend money\npositive values are used when gaining money\nmoney delta: ")

        buffer: [512]byte
        bytes_read, _ := os.read(os.stdin, buffer[:])

        s := string(buffer[:bytes_read-1])

        float_input, ok := strconv.parse_f32(s)
        if !ok {
            fmt.println("not a valid float. try again.")
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
        bytes_read, _ := os.read(os.stdin, buffer[:])

        input_date := string(buffer[:bytes_read-1])

        if input_date == "" {
            break
        }

        if bytes_read != 11 {
            fmt.println("inputted date is in the incorrect format. try again.")
            continue
        }

        // very basic validation of date
        for letter, i in input_date {
            if i == 4 || i == 7 {
                if letter != '-' {
                    fmt.println("inputted date is in the incorrect format. try again.")
                    continue outer
                }
            } else {
                // (expert coding)
                if letter != '0' && letter != '1' && letter != '2' && letter != '3' && letter != '4' && letter != '5' && letter != '6' && letter != '7' && letter != '8' && letter != '9' {
                    fmt.println("inputted date is in the incorrect format. try again.")
                    continue outer
                }
            }
        }

        date = input_date
        break
    }

    // get description for the item
    fmt.print("\nwrite the description for the item\n: ")

    buffer: [8192]byte
    bytes_read, _ := os.read(os.stdin, buffer[:])
    description := string(buffer[:bytes_read-1])

    category := LoadCategory(selected_category)
    defer delete(category.items)

    AddItemToCategory(&category, selected_category, date, money_delta, description)
}
