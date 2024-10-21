//
//  Database.swift
//  OAA_Task1
//
//  Created by Yura B on 21.10.2024.
//

import Foundation

//var record = Record(columns: <#[String : String]#>)

class Database {
    private var tables : [String : Record] = [:]
    
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
        let selectTable = #"SELECT \* FROM (\w+);"#
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
    
}
