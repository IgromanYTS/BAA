//
//  Database.swift
//  OAA_Task1
//
//  
//

import Foundation

//var record = Record(columns: <#[String : String]#>)

public class Database {
    private var tables : [String : Record] = [:]
    
    func getTable(name: String) -> Record? {
        return tables[name]
    }
    
    func createTable(command: String) {
        let createTable = #"CREATE (\w+) \(([^)]+)\);"#
        if let createMatch = command.range(of: createTable, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: createTable)
            let match = regex.firstMatch(in: command, options: [], range: NSRange(location: 0, length: command.utf16.count) )
            
            if let match = match {
                let tableRange = Range(match.range(at: 1), in: command)!
                let tableName = String(command[tableRange])
                let columnsRange = Range(match.range(at: 2), in: command)!
                let columnsString = String(command[columnsRange])
                let columns = columnsString.split(separator: ",").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                
                let table = Record(name: tableName, columns: columns)
                tables[tableName] = table
                print("Таблиця '\(tableName)' була створена з колонками: \(columns)")
            }
            else {
                print("Невірна команда CREATE")
            }
        }
    }
    
    func insertInto(command : String) {
        let insertTable = #"INSERT INTO (\w+) \(([^)]+)\);"#
        if let insertMatch = command.range(of: insertTable, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: insertTable)
            let match = regex.firstMatch(in: command, options: [], range: NSRange(location: 0, length: command.utf16.count))
            if let match = match {
                let tableRange = Range(match.range(at: 1), in: command)!
                let tableName = String(command[tableRange])
                guard var table = tables[tableName] else {
                    print("Таблиці \(tableName) не існує")
                    return
                }
                let valuesRange = Range(match.range(at: 2), in: command)!
                let valuesString = String(command[valuesRange])
                let values = valuesString.split(separator: ",").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                
                guard values.count == table.columns.count else {
                    print("Помилкове значення")
                    return
                }
                table.rows.append(values)
                tables[tableName] = table
                print("1 колонка додана в \(tableName)")
            }
            else {
                print("Невірний INSERT")
            }
        }
    }
    
    func selectFrom(command : String) {
        let selectTable = #"SELECT FROM (\w+);"#
        if let selectMatch = command.range(of: selectTable, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: selectTable)
            let match = regex.firstMatch(in: command, options: [], range: NSRange(location: 0, length: command.utf16.count))
            
            if let match = match {
                let tableRange = Range(match.range(at: 1), in: command)!
                let tableName = String(command[tableRange])
                
                guard let table = tables[tableName] else {
                    print("Таблиця \(tableName) не знайдена")
                    return
                }
                print(table.columns.joined(separator: " | "))
                
                for row in table.rows {
                    print(row.joined(separator: " | "))
                }
                
                if table.rows.isEmpty {
                    print("Нема колонок в \(tableName)")
                }
            }
        }
        else {
            print("Неправильна команда SELECT")
        }
    }
    
    func selectFromWhere(command: String) {
        let selectTableWhere = #"SELECT FROM (\w+) WHERE (\w+) < ['"]([^'"]+)['"];"#
        if let selectMatchWhere = command.range(of: selectTableWhere, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: selectTableWhere)
            let match = regex.firstMatch(in: command, options: [], range: NSRange(location: 0, length: command.utf16.count))
            
            
            if let match = match {
                let tableRange = Range(match.range(at: 1), in: command)!
                let tableName = String(command[tableRange])
                
                guard let table = tables[tableName] else {
                    print("Таблиця \(tableName) не знайдена")
                    return
                }
                
                print(table.columns.joined(separator: " | "))
                
                let columnRange = Range(match.range(at: 2), in: command)!
                let columnName = String(command[columnRange])
                
                let variableRange = Range(match.range(at: 3), in: command)!
                let variableName = String(command[variableRange]).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                
                guard let indexColumn = table.columns.firstIndex(of: columnName) else {
                    print("Колонки \(columnName) не знайдена в таблиці \(tableName)")
                    return
                }
                
                let fRows = table.rows.filter {
                    row in return row[indexColumn].replacingOccurrences(of: "\"", with: "") < variableName
                }
                
                for row in fRows {
                    print(row.joined(separator: " | "))
                }
                
                if fRows.isEmpty {
                    print("Немає результатів для заданого фільтру")
                }
                
                }
            }
        }
    
    func selectGroupBy(command: String) {
        let selectTableGroupBy = #"SELECT ((?:\w+\([\w_]+\)(?:, )?)*) FROM (\w+) GROUP_BY ((?:\w+, )*\w+);"#
        if let selectMatchGroupBy = command.range(of: selectTableGroupBy, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: selectTableGroupBy)
            let match = regex.firstMatch(in: command, options: [], range: NSRange(location: 0, length: command.utf16.count))
            
            if let match = match {
                
                let aggregateFunRange = Range(match.range(at: 1), in: command)!
                let aggregateFunString = String(command[aggregateFunRange])
                let aggregateFunctions = aggregateFunString.split(separator: ",").map{$0.trimmingCharacters(in: .whitespaces)}
                
                let tableRange = Range(match.range(at: 2), in: command)!
                let tableName = String(command[tableRange])
                
                guard let table = tables[tableName] else {
                    print("Таблиця \(tableName) не знайдена")
                    return
                }
                let columnRange = Range(match.range(at: 3), in: command)!
                let columnName = String(command[columnRange]).split(separator: ",").map{$0.trimmingCharacters(in: .whitespaces)}
                
                var groupIndices = [Int]()
                for column in columnName {
                    guard let index = table.columns.firstIndex(of: column) else {
                        print("Колонки \(column) не існує в таблиці \(tableName)")
                        return
                    }
                    groupIndices.append(index)
                }
                
                
                var groupData = [String : [[String]]]()
//                print(table.columns.joined(separator: " | "))
                let groupColHead = columnName.joined(separator: " | ")
                let aggHead = aggregateFunctions.joined(separator: " | ")
                print("\(groupColHead) | \(aggHead)")
                for row in table.rows {
                    let groupKey = groupIndices.map{row[$0]}.joined(separator: "|")
                    groupData[groupKey, default: []].append(row)
                }
                
                for (groupKey, rows) in groupData {
                    let keyPart = groupKey.split(separator: "|").map{String($0)}
                    var resultRow = keyPart
                    
                    for function in aggregateFunctions {
                        if function.starts(with: "COUNT(") {
                            let count = rows.count
                            resultRow.append("\(count)")
                        }
                        else if function.starts(with: "MAX(") {
                            let columnName = function.dropFirst(4).dropLast(1)
                            if let columnIndex = table.columns.firstIndex(of: String(columnName)) {
                                let maxVal = rows.map{$0[columnIndex]}.max() ?? "nil"
                                resultRow.append("\(maxVal)")
                            }
                        }
                        else if function.starts(with: "LONGEST(") {
                            let columnName = function.dropFirst(8).dropLast(1)
                            if let columnIndex = table.columns.firstIndex(of: String(columnName)) {
                                let longValue = rows.map{$0[columnIndex]}.max(by: {$0.count<$1.count}) ?? "nil"
                                resultRow.append("\(longValue)")
                            }
                        }
                    }
                    print(resultRow.joined(separator: " | "))
                }
                
                
                
                
                
            }
        }
    }
    
    func selectGroupByWhere(command: String) {
        let selectTableGroupBy = #"SELECT ((?:\w+\([^)]+\)(?:, )?)*) FROM (\w+) WHERE (\w+) < ['"]?([^'";]+)['"]? GROUP_BY ((?:\w+(?:, )?)*)"#
        if let selectMatchGroupBy = command.range(of: selectTableGroupBy, options: .regularExpression) {
            let regex = try! NSRegularExpression(pattern: selectTableGroupBy)
            let match = regex.firstMatch(in: command, options: [], range: NSRange(location: 0, length: command.utf16.count))
            
            if let match = match {
                
                let aggregateFunRange = Range(match.range(at: 1), in: command)!
                let aggregateFunString = String(command[aggregateFunRange])
                let aggregateFunctions = aggregateFunString.split(separator: ",").map{$0.trimmingCharacters(in: .whitespaces)}
                
                let tableRange = Range(match.range(at: 2), in: command)!
                let tableName = String(command[tableRange])
                
                guard let table = tables[tableName] else {
                    print("Таблиця \(tableName) не знайдена")
                    return
                }
                
                let columnRange2 = Range(match.range(at: 3), in: command)!
                let columnName2 = String(command[columnRange2])
                
                let variableRange2 = Range(match.range(at: 4), in: command)!
                let variableName2 = String(command[variableRange2]).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                
                guard let indexColumn2 = table.columns.firstIndex(of: columnName2) else {
                    print("Колонки \(columnName2) не знайдена в таблиці \(tableName)")
                    return
                }
                
                let fRows = table.rows.filter {
                    row in return row[indexColumn2].replacingOccurrences(of: "\"", with: "") < variableName2
                }
                
                let columnRange = Range(match.range(at: 5), in: command)!
                let columnName = String(command[columnRange]).split(separator: ",").map{$0.trimmingCharacters(in: .whitespaces)}
                
                var groupIndices = [Int]()
                for column in columnName {
                    guard let index = table.columns.firstIndex(of: column) else {
                        print("Колонки \(column) не існує в таблиці \(tableName)")
                        return
                    }
                    groupIndices.append(index)
                }
                
                
                var groupData = [String : [[String]]]()
//                print(table.columns.joined(separator: " | "))
                let groupColHead = columnName.joined(separator: " | ")
                let aggHead = aggregateFunctions.joined(separator: " | ")
                print("\(groupColHead) | \(aggHead)")
                for row in fRows {
                    let groupKey = groupIndices.map{row[$0]}.joined(separator: "|")
                    groupData[groupKey, default: []].append(row)
                }
                
                for (groupKey, rows) in groupData {
                    let keyPart = groupKey.split(separator: "|").map{String($0)}
                    var resultRow = keyPart
                    
                    for function in aggregateFunctions {
                        if function.starts(with: "COUNT(") {
                            let count = rows.count
                            resultRow.append("\(count)")
                        }
                        else if function.starts(with: "MAX(") {
                            let columnName = function.dropFirst(4).dropLast(1)
                            if let columnIndex = table.columns.firstIndex(of: String(columnName)) {
                                let maxVal = rows.map{$0[columnIndex]}.max() ?? "nil"
                                resultRow.append("\(maxVal)")
                            }
                        }
                        else if function.starts(with: "LONGEST(") {
                            let columnName = function.dropFirst(8).dropLast(1)
                            if let columnIndex = table.columns.firstIndex(of: String(columnName)) {
                                let longValue = rows.map{$0[columnIndex]}.max(by: {$0.count<$1.count}) ?? "nil"
                                resultRow.append("\(longValue)")
                            }
                        }
                    }
                    print(resultRow.joined(separator: " | "))
                }
                
                
                
                
                
            }
        }
    }
        
        
    }
    

