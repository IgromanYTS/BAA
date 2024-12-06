//
//  Record.swift
//  OAA_Task1
//
//  
//

import Foundation

public struct Record {
    let name : String
    let columns: [String]
    var indexedColumns : Set<String> = []
    var rows : [[String]] = []
    var index : [String:[String:[Int]]] = [:]
}
