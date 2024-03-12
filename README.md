# calgal

A gleam implementation of `cal` with Monday week start dates.

```sh
gleam run calgal
```

Arguments are not yet documented, but it supports:
 - `--year` - output every month of the current year, highlights the current month and date.
 - `--prev` - output the previous month
 - `--next` - output the next month

## Todo

 - [ ] allow passing a date in.
 - [ ] allow passing a year for `--year` option.
 - [ ] allow configuring first day of the week.
 - [ ] allow configuring whether it highlights the current month/date.
 - [ ] add shorthand arguments.
 - [ ] add colour output? I don't really need this for my xbar use-case.
 - [ ] implement the transposed `ncal` version with `--reverse` for silliness.
