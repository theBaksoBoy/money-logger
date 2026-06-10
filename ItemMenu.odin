package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"
import "core:time/datetime"



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
