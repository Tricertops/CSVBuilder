//
//  CSVBuilder.swift
//  CSVBuilder
//
//  Created by Martin Kiss on 25 Mar 2018.
//  https://github.com/Tricertops/CSVBuilder
//
//  The MIT License (MIT)
//  Copyright © Martin Kiss
//

import Foundation


/// Description of CSV table with dimensions, separator type, cell content provider, and optional titles.
public struct CSVTable {
    
    public typealias Column = Int
    public typealias Row = Int
    public typealias Title = String
    public typealias Content = String
    
    /// Type of separator to be used. Affects escaping of the content and titles.
    public var separator: Separator
    /// Width of the table.
    public var numberOfColumns: Column
    /// Height of the table. Does NOT include titles.
    public var numberOfRows: Row
    /// Optional provider for titles that will be put above the first content row. Returned values will be escaped.
    public var titleForColumn: ((Column) -> Title)?
    /// Provider of cell content strings. Returned values will be escaped.
    public var contentForCell: (Column, Row) -> Content
    
    /// CSV apps generally supports these 3 separators.
    public enum Separator: String {
        case comma = ","
        case semicolon = ";"
        case tab = "\t"
    }
    
    /// Creates empty table descriptor. Configure before use.
    public init() {
        self.init(
            separator: .comma,
            columns: 0,
            rows: 0,
            titles: nil,
            content: {_, _ in ""})
    }
    
    /// Creates fully configured table descriptor.
    public init(separator: Separator = .comma, columns: Column, rows: Row, titles: ((Column) -> Title)? = nil, content:@escaping (Column, Row) -> Content) {
        self.separator = separator
        self.numberOfColumns = columns
        self.numberOfRows = rows
        self.titleForColumn = titles
        self.contentForCell = content
    }
    
    /// Creates table descriptor from 2D array of content and optional array of titles.
    public init(separator: Separator = .comma, titles: [Title]?, content columns: [[Content]]) {
        // Enforce equal row counts:
        let numberOfRows = columns.first?.count ?? 0
        var index = 0
        for column in columns {
            precondition(column.count == numberOfRows,
                         "Number of rows in column \(index) must be equal to number of rows in first column (\(numberOfRows)).")
            index += 1
        }
        // Optional titles provider from array:
        var titlesBlock: ((Column) -> Title)? = nil
        if let titles = titles {
            precondition(columns.count == titles.count,
                         "Number of titles (\(titles.count)) must be equal to the number of columns (\(columns.count)).")
            titlesBlock = { columnIndex in
                return titles[columnIndex]
            }
        }
        // Content provider frm array:
        let contentBlock: (Column, Row) -> Content = { columnIndex, rowIndex in
            return columns[columnIndex][rowIndex]
        }
        
        self.init(
            separator: separator,
            columns: columns.count,
            rows: numberOfRows,
            titles: titlesBlock,
            content: contentBlock)
    }
}


/// Converter of table descriptors to CSV strings.
public class CSVBuilder {
    
    /// Builds CSV string from table descriptor.
    public class func buildCSV(from table: CSVTable) -> String {
        var CSV: String = ""
        let separator = table.separator
        let newLine = "\n"
        
        // Helper function that removes trailing separator.
        func finishRow() {
            CSV.remove(at: CSV.index(before: CSV.endIndex))
            CSV += newLine
        }
        
        // Title row:
        if let titleForColumn = table.titleForColumn {
            for column in 0 ..< table.numberOfColumns {
                let title = titleForColumn(column)
                CSV += separator.escape(title) + separator.rawValue
            }
            finishRow()
        }
        
        // Content rows:
        let contentForCell = table.contentForCell
        for row in 0 ..< table.numberOfRows {
            for column in 0 ..< table.numberOfColumns {
                let content = contentForCell(column, row)
                CSV += separator.escape(content) + separator.rawValue
            }
            finishRow()
        }
        
        return CSV
    }
}


extension CSVTable.Separator {
    
    /// Seperator defines how the content should be escaped and quoted.
    func escape(_ original: String) -> String {
        switch self {
        case .comma, .semicolon:
            let quote = "\""
            // One quote needs to be escaped using two characters.
            let escaped = original.replacingOccurrences(of: quote, with: quote+quote)
            // If content contains this separator, it need to be quoted.
            if escaped.contains(self.rawValue) {
                return quote + escaped + quote
            }
            return escaped
            
        case .tab:
            // Tabs are not allowed when tab is used as separator.
            return original.replacingOccurrences(of: self.rawValue, with: " ")
        }
    }
}


