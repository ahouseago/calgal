import argv
import birl
import birl/duration
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/string_builder

const line_len = 20

pub fn main() {
  let now =
    birl.now()
    |> birl.set_time_of_day(birl.TimeOfDay(0, 0, 0, 0))
  let birl.Day(year, current_month, _date) = birl.get_day(now)

  case argv.load().arguments {
    [] -> {
      let assert Some(month) = month_from_int(current_month)
      print_month(year, month)
    }
    ["--prev"] -> {
      let assert Some(month) = month_from_int(current_month - 1)
      print_month(year, month)
    }
    ["--next"] -> {
      let assert Some(month) = month_from_int(current_month + 1)
      print_month(year, month)
    }
    ["--year"] ->
      iterator.range(1, 12)
      |> iterator.each(fn(month) {
        let assert Some(month) = month_from_int(month)
        print_month(year, month)
        io.println("")
      })
    _ -> io.println("Invalid usage. TODO: help")
  }
}

fn print_month(year: Int, month: birl.Month) {
  let now =
    birl.now()
    |> birl.set_time_of_day(birl.TimeOfDay(0, 0, 0, 0))
  let first_of_month = new_date(birl.Day(year, int_from_month(month), 1))

  // Centred "Month Year"
  let month_year_string =
    string_builder.from_strings([
      " ",
      birl.string_month(first_of_month),
      " ",
      int.to_string(year),
      " ",
    ])
    |> string_builder.to_string
  let title_len = string.length(month_year_string)
  let pad_char = case birl.month(now) == month {
    True -> "_"
    False -> " "
  }
  io.println(
    " "
    <> month_year_string
    |> string.pad_left(
      to: title_len + { line_len - title_len } / 2,
      with: pad_char,
    )
    |> string.pad_right(line_len, pad_char),
  )

  // TODO: support non-Monday start?
  io.println(" Mo Tu We Th Fr Sa Su")

  let offset_to_first =
    case birl.weekday(first_of_month) {
      birl.Mon -> 0
      birl.Tue -> 3
      birl.Wed -> 6
      birl.Thu -> 9
      birl.Fri -> 12
      birl.Sat -> 15
      birl.Sun -> 18
    }
    |> string.repeat(" ", _)

  let days =
    string_builder.from_string(offset_to_first)
    |> iterator.fold(
      birl.range(
        from: first_of_month,
        to: Some(last_of_month(first_of_month)),
        step: duration.days(1),
      ),
      _,
      fn(builder, day) {
        string_builder.concat([
          builder,
          case birl.difference(now, day) {
            duration.Duration(0) -> {
              string_builder.from_string("(")
              |> string_builder.append(
                get_date(day)
                |> int.to_string,
              )
              |> string_builder.append(")")
            }
            duration.Duration(-86_400_000_000) ->
              string_builder.from_string(
                get_date(day)
                |> int.to_string
                |> string.pad_left(2, " "),
              )
            _ ->
              string_builder.from_string(
                get_date(day)
                |> int.to_string
                |> string.pad_left(3, " "),
              )
          },
        ])
      },
    )
    |> string_builder.to_string
    |> split_into_chunks(line_len)
    |> string.join("\n")

  io.println(days)
}

fn split_into_chunks(str: String, chunk_len: Int) -> List(String) {
  do_split_into_chunks(string.to_graphemes(str), chunk_len + 1, [])
}

fn do_split_into_chunks(chars: List(String), len: Int, acc: List(String)) {
  case list.split(chars, len) {
    #([], _) -> list.reverse(acc)
    #(chunk, rest) ->
      do_split_into_chunks(rest, len, [string.concat(chunk), ..acc])
  }
}

/// Returns a birl.Time representing midnight on the given day.
fn new_date(day: birl.Day) -> birl.Time {
  let assert Ok(template) = birl.parse("2000-01-01+0000")
  birl.set_day(template, day)
}

fn get_date(day: birl.Time) -> Int {
  let birl.Day(_, _, date) = birl.get_day(day)
  date
}

fn last_of_month(time: birl.Time) {
  let birl.Day(year, month, _) = birl.get_day(time)
  birl.set_day(time, birl.Day(year, month + 1, 1))
  |> birl.subtract(duration.days(1))
  |> birl.set_time_of_day(birl.TimeOfDay(0, 0, 0, 0))
}

fn month_from_int(month: Int) -> Option(birl.Month) {
  case month {
    // Useful for wrapping around to previous month from Jan
    0 -> Some(birl.Dec)
    1 -> Some(birl.Jan)
    2 -> Some(birl.Feb)
    3 -> Some(birl.Mar)
    4 -> Some(birl.Apr)
    5 -> Some(birl.May)
    6 -> Some(birl.Jun)
    7 -> Some(birl.Jul)
    8 -> Some(birl.Aug)
    9 -> Some(birl.Sep)
    10 -> Some(birl.Oct)
    11 -> Some(birl.Nov)
    12 -> Some(birl.Dec)
    // Useful for wrapping around to next month from Dec
    13 -> Some(birl.Jan)
    _ -> None
  }
}

fn int_from_month(month: birl.Month) -> Int {
  case month {
    birl.Jan -> 1
    birl.Feb -> 2
    birl.Mar -> 3
    birl.Apr -> 4
    birl.May -> 5
    birl.Jun -> 6
    birl.Jul -> 7
    birl.Aug -> 8
    birl.Sep -> 9
    birl.Oct -> 10
    birl.Nov -> 11
    birl.Dec -> 12
  }
}
