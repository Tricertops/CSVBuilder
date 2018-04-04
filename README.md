Build CSV files easily
==============================

Complete solution for producing CSV files (comma-separated values).

- Separate entries using comma, semicolon, or tab.
- Automatically handles escaping and quoting values, to avoid conflicts with separators.
- Supports optional column titles as the first table row.
- Closure-based or Array-based initializers.

Written in Swift, **not** compatible with Objective-C.

How to use
------------------------------

1. Create and configure instance of `CSVTable` using provided `init()` or by setting values directly.
    - The `CSVTable` needs a closure that will return raw string value for any given column and row.
    - If you have the titles and data in Arrays of Strings, you can pass them directly to the specialized `init()`.
    
2. Call `CSVBuilder.buildCSV(from: table)` to get final CSV string, which you can then write to a file.
    - Your closure for titles and values will be invoked during this process for each row and column.
    - You return raw un-escaped String values, the `CSVBuilder` will handle escaping for each of the 3 separator options.
