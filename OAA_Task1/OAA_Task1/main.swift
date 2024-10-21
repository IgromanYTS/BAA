//
//  main.swift
//  OAA_Task1
//
//  Created by Yura B on 20.10.2024.
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
    else if command.uppercased().starts(with: "SELECT * FROM") {
        database.selectFrom(command: command)
    }
    else {
        print("Незнайома команда")
    }
}

