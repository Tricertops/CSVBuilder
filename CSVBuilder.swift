//
//  CSVBuilder.swift
//  CSVBuilder
//
//  Created by Martin Kiss on 25 Mar 2018.
//  https://github.com/Tricertops/CSVBuilder
//
//  The MIT License (MIT)
//  © Martin Kiss
//

import Foundation


public struct CSVContentProvider {
    public typealias Column = Int
    public typealias Row = Int
    public typealias Title = String
    public typealias Content = String
    
    public var separator: Separator = .comma
    public var numberOfColumns: Column = 0
    public var numberOfRows: Row = 0
    public var titleForColumn: ((Column) -> Title)? = nil
    public var contentForCell: (Column, Row) -> Content = {_, _ in ""}
    
    public enum Separator: String {
        case comma = ","
        case semicolon = ";"
        case tab = "\t"
    }
    
    public init() { }
    
    public init(separator: Separator = .comma, columns: Column, rows: Row, titles: ((Column) -> Title)? = nil, content:@escaping (Column, Row) -> Content) {
        self.separator = separator
        self.numberOfColumns = columns
        self.numberOfRows = rows
        self.titleForColumn = titles
        self.contentForCell = content
    }
    
    public init(separator: Separator = .comma, titles: [Title]?, content columns: [[Content]]) {
        let numberOfRows = columns.first?.count ?? 0
        
        var index = 0
        for column in columns {
            precondition(column.count == numberOfRows,
                         "Number of rows in column \(index) must be equal to number of rows in first column (\(numberOfRows)).")
            index += 1
        }
        
        var titlesBlock: ((Column) -> Title)? = nil
        if let titles = titles {
            precondition(columns.count == titles.count,
                         "Number of titles (\(titles.count)) must be equal to the number of columns (\(columns.count)).")
            titlesBlock = { columnIndex in
                return titles[columnIndex]
            }
        }
        
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


public class CSVBuilder {
    
    public class func buildCSV(from provider: CSVContentProvider) -> String {
        return CSVBuilder(contentProvider: provider).buildCSV()
    }
    
    let contentProvider: CSVContentProvider
    
    init(contentProvider: CSVContentProvider) {
        self.contentProvider = contentProvider
    }
    
    func buildCSV() -> String {
        var CSV: String = ""
        let separator = contentProvider.separator
        let newLine = "\n"
        let columns = contentProvider.numberOfColumns
        let rows = contentProvider.numberOfRows
        
        if let titleForColumn = contentProvider.titleForColumn {
            for column in 0 ..< columns {
                let title = titleForColumn(column)
                CSV += separator.escape(title) + separator.rawValue
            }
            CSV.remove(at: CSV.index(before: CSV.endIndex))
            CSV += newLine
        }
        
        let contentForCell = contentProvider.contentForCell
        for row in 0 ..< rows {
            for column in 0 ..< columns {
                let content = contentForCell(column, row)
                CSV += separator.escape(content) + separator.rawValue
            }
            CSV.remove(at: CSV.index(before: CSV.endIndex))
            CSV += newLine
        }
        
        return CSV
    }
}


extension CSVContentProvider.Separator {
    
    func escape(_ original: String) -> String {
        switch self {
        case .comma, .semicolon:
            let quote = "\""
            let escaped = original.replacingOccurrences(of: quote, with: quote+quote)
            if escaped.contains(self.rawValue) {
                return quote + escaped + quote
            }
            return escaped
            
        case .tab:
            return original.replacingOccurrences(of: self.rawValue, with: " ")
        }
    }
}


