//
//  main.swift
//  OAA_Task1
//
//  
//

import Foundation

var db = Database()

print("Вітаємо у нашій базі данних! Підтримуються команди (CREATE, INSERT INTO, SELECT та exit)")

while true {
    print("> ", terminator: "")
    if let input = readLine() {
        if input.lowercased() == "exit" {
            print("Вихід з БД")
            break
        }
        parseSQLCommand(input, in: db)
    }
}

func parseSQLCommand(_ command: String, in database: Database) {
    if command.uppercased().starts(with: "CREATE") {
        database.createTable(command: command)
    }
    else if command.uppercased().starts(with: "INSERT INTO") {
        database.insertInto(command: command)
    }
    else if let _ = command.range(of: #"^SELECT (?:\w+\([\w_]+\)(?:, )?)* FROM \w+ WHERE \w+ < ['"]?([^'";]+)['"]? GROUP_BY (?:\w+, )*\w+;"#, options: .regularExpression) {
        database.selectGroupByWhere(command: command)
    }
    else if let _ = command.range(of: #"^SELECT (?:\w+\([\w_]+\)(?:, )?)* FROM \w+ GROUP_BY (?:\w+, )*\w+;"#, options: .regularExpression) {
        database.selectGroupBy(command: command)
    }
    else if let _ = command.range(of: #"^SELECT FROM \w+ WHERE \w+ < "#, options: .regularExpression) {
        database.selectFromWhere(command: command)
    }
    else if command.uppercased().starts(with: "SELECT FROM") {
        database.selectFrom(command: command)
    }
    else {
        print("Незнайома команда 1")
    }
}

