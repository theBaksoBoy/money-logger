package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:strconv"
import "core:time"
import "core:slice"


// graph_width and graph_height are assigned in main.odin


GraphChar :: struct {
    char: rune,
    color: Color,
}

PrintGraph :: proc(category: ^Category, start_date, end_date: string) {
    // if start_date and end_date should be automaticaly chosen then they will be == ""
    
    start_date := start_date
    end_date := end_date
    
    SortCategory(category)
    
    if start_date == "" || strings.compare(start_date, category.items[0].date) < 0 {
        start_date = category.items[0].date
    }
    if end_date == "" || strings.compare(end_date, category.items[len(category.items)-1].date) > 0 {
        end_date = category.items[len(category.items)-1].date
    }

    if strings.compare(start_date, end_date) >= 0 {
        fmt.print(GetColor(.RED))
        fmt.println("start date can not be later than end date")
        fmt.print(GetColor(.RESET))
        os.exit(1)
    }


    // get the current sum for each day between the start date and the end date.
    // note that the sums array has more days than are between those two dates, as all months are counted as having 31 days
    sums := make([dynamic]f32)
    unique_sums := make([dynamic]f32)
    current_sum: f32 = 0
    date := start_date
    item_list_i: int = 0
    for strings.compare(date, end_date) <= 0 { // repeat until the date has exceeded the end date
        if item_list_i < len(category.items) && strings.compare(date, category.items[item_list_i].date) == 0 { // if the dates are the same
            current_sum += category.items[item_list_i].money_delta
            append(&unique_sums, current_sum)
            item_list_i += 1
        } else {
            append(&sums, current_sum)
            date = IncrementedDate(&date)
        }
    }


    lower_sum_bound: f32 = 100000000000000
    upper_sum_bound: f32 = -100000000000000
    for sum in unique_sums {
        if sum < lower_sum_bound do lower_sum_bound = sum
        if sum > upper_sum_bound do upper_sum_bound = sum
    }
    if lower_sum_bound > 0 do lower_sum_bound = 0 // the horizontal line for a sum of 0 should always be visible


    graph_matrix := make([]GraphChar, graph_width * graph_height)
    defer delete(graph_matrix)

    // initially set all chars as spaces
    for i in 0..<graph_width*graph_height {
        graph_matrix[i] = GraphChar{
            ' ',
            Color.RESET,
        }
    }
    

    // figure out and what height the horizontal bar should be at
    bar_height1: f32 = 10
    bar_height2: f32 = 5
    for {
        if bar_height1 * 2 > upper_sum_bound do break
        bar_height1 *= 2
        bar_height2 *= 2
        if bar_height1 * 2.5 > upper_sum_bound do break
        bar_height1 *= 2.5
        bar_height2 *= 2.5
        if bar_height1 * 2 > upper_sum_bound do break
        bar_height1 *= 2
        bar_height2 *= 2
    }

    AddHorizontalLineToGraph(&graph_matrix, 0, lower_sum_bound, upper_sum_bound)
    AddHorizontalLineToGraph(&graph_matrix, bar_height1, lower_sum_bound, upper_sum_bound)
    AddHorizontalLineToGraph(&graph_matrix, bar_height2, lower_sum_bound, upper_sum_bound)

    
    // create the points of the graph showing the sum over time
    for sum, i in sums {
        x := int(f32(i) / f32(len(sums)) * f32(graph_width))
        color: Color
        if sum >= 0 {
            color = .GREEN
        } else {
            color = .RED
        }
        graph_matrix[GetGraphMatrixIndex(x, GetLineIndex(sum, lower_sum_bound, upper_sum_bound))] = GraphChar{
            '#',
            color,
        }
    }


    // render the graph
    for y := graph_height-1; y >= 0; y -= 1 {
        for x in 0..<graph_width {
            char := graph_matrix[GetGraphMatrixIndex(x, y)]
            if char.char == ' ' {
                fmt.print(' ')
            } else {
                fmt.print(GetColor(char.color))
                fmt.print(char.char)
            }
        }
        fmt.println()
    }
}



// a very rudimentary way for increminting a date string by one day, where each month is assumed to have 31 days
IncrementedDate :: proc(date: ^string) -> string {
    
    year, _ := strconv.parse_int(date[0:4])
    month, _ := strconv.parse_int(date[5:7])
    day, _ := strconv.parse_int(date[8:10])

    day += 1

    if day > 31 {
        day = 1
        month += 1
    }

    if month > 12 {
        month = 1
        year += 1
    }

    month1, month2 := IntToTwoRunes(month)
    day1, day2 := IntToTwoRunes(day)

    return strings.clone(fmt.tprintf("%d-%c%c-%c%c", year, month1, month2, day1, day2))
}



GetGraphMatrixIndex :: proc(x, y: int) -> int {
    return x + y * graph_width
}



GetLineIndex :: proc(value, lower, upper: f32) -> int {
    height := int((value - lower) / (upper - lower) * f32(graph_height) + 0.5)
    return min(max(height, 0), graph_height-1)
}



AddHorizontalLineToGraph :: proc(graph_matrix: ^[]GraphChar, value: f32, lower, upper: f32) {
    row := GetLineIndex(value, lower, upper)

    for x in 0..<graph_width {
        graph_matrix[GetGraphMatrixIndex(x, row)] = GraphChar{
            '-',
            Color.RESET
        }
    }


    value_string: string = fmt.tprintf("%d", int(value))

    for char, i in value_string {

        graph_matrix[GetGraphMatrixIndex(i, row)] = GraphChar{
            char,
            Color.RESET
        }

        graph_matrix[GetGraphMatrixIndex(graph_width - len(value_string) + i, row)] = GraphChar{
            char,
            Color.RESET
        }
    }
}
