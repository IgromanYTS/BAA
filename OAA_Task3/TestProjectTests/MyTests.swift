//
//  MyTests.swift
//  TestProjectTests
//
//  
//

import XCTest
@testable import OAA_Task1

extension XCTestCase {
    func loadCSV(from fileName: String) -> [[String]]? {
        guard let filePath = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "csv") else {
            XCTFail("CSV not found")
            return nil
        }
        do {
            let contents = try String(contentsOfFile: filePath)
            let rows = contents.split(separator: "\n").map{row in row.split(separator: ",").map{String($0)}}
            return rows
        } catch {
            XCTFail("Failed to load CSV \(error)")
            return nil
        }
    }
}

final class MyTests: XCTestCase {
    

    var database : Database!
    
    override func setUp() {
        super.setUp()
        database = Database()
    }
    
    override func tearDown() {
        database = nil
        super.tearDown()
    }
    
    func testCreatedTableCreate() {
        
        let catTable = "CREATE cats (id, name, favourite_food);"
        
        database.createTable(command: catTable)
        
        XCTAssertNotNil(database.getTable(name: "cats"))
        
        //XCTAssertEqual(database.getTable(name: "cats")?.columns, ["id", "name", "favourite_food"])
    }
    
    func testColumnsTableCreated() {
        
        let catTable = "CREATE cats (id, name, favourite_food);"
        
        database.createTable(command: catTable)
        
        XCTAssertEqual(database.getTable(name: "cats")?.columns, ["id", "name", "favourite_food"])
    }
    
    func testInsertFromCSVWithIndexed() {
        let createCommand = "CREATE cats (id INDEXED, name, favourite_food);"
        database.createTable(command: createCommand)
        guard let filePath = Bundle(for: type(of: self)).path(forResource: "generate_csv_file", ofType: "csv") else {
            XCTFail("CSV not found")
            return
        }
        
        do {
            let contents = try String(contentsOfFile: filePath)
            let rows = contents.split(separator: "\n").map{row in row.split(separator: ",").map{String($0)}}
            
            XCTAssertGreaterThan(rows.count, 1, "CSV file empty")
            
            let dataRows = rows.dropFirst()
            for row in dataRows {
                guard row.count == 4 else {
                    XCTFail("Row has inccorect: \(row)")
                    continue
                }
                let insertCommand = "INSERT INTO cats (\"\(row[1])\", \"\(row[2])\", \"\(row[3])\");"
                database.insertInto(command: insertCommand)
            }
            
            
            XCTAssertEqual(database.getTable(name: "cats")?.rows.count, dataRows.count, "Not all rows") }
        catch {
            XCTFail("Error: \(error)")
        }
        
        print("Count rows: ", (database.getTable(name: "cats")?.rows.count)!)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let add = "INSERT INTO cats (\"2\", \"Ata\", \"Fish\");"
        database.insertInto(command: add)
        let selectFromWhereWithIndexed = "SELECT FROM cats WHERE name < \"Murzik\";"
        database.selectFromWhere(command: selectFromWhereWithIndexed)
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        print("Время выполнения команды: \(executionTime) секунд")
    }
    
    func testInsertFromCSV() {
        let createCommand = "CREATE cats (id, name, favourite_food);"
        database.createTable(command: createCommand)
        guard let filePath = Bundle(for: type(of: self)).path(forResource: "generate_csv_file", ofType: "csv") else {
            XCTFail("CSV not found")
            return
        }
        
        do {
            let contents = try String(contentsOfFile: filePath)
            let rows = contents.split(separator: "\n").map{row in row.split(separator: ",").map{String($0)}}
            
            XCTAssertGreaterThan(rows.count, 1, "CSV file empty")
            
            let dataRows = rows.dropFirst()
            for row in dataRows {
                guard row.count == 4 else {
                    XCTFail("Row has inccorect: \(row)")
                    continue
                }
                let insertCommand = "INSERT INTO cats (\"\(row[1])\", \"\(row[2])\", \"\(row[3])\");"
                database.insertInto(command: insertCommand)
            }
            
            
            XCTAssertEqual(database.getTable(name: "cats")?.rows.count, dataRows.count, "Not all rows") }
        catch {
            XCTFail("Error: \(error)")
        }
        
        print("Count rows: ", (database.getTable(name: "cats")?.rows.count)!)
        let startTime = CFAbsoluteTimeGetCurrent()
        let add = "INSERT INTO cats (\"2\", \"Ata\", \"Fish\");"
        database.insertInto(command: add)
        let selectFromWhereWithIndexed = "SELECT FROM cats WHERE name < \"Murzik\";"
        database.selectFromWhere(command: selectFromWhereWithIndexed)
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        print("Время выполнения команды: \(executionTime) секунд")
    }
    
//    func testInsertInto() {
//        
//        let catTable = "CREATE cats (id, name, favourite_food);"
//        let insert = "INSERT INTO cats (\"1\", \"Murzik\", \"Sausages\");"
//        
//        database.createTable(command: catTable)
//        database.insertInto(command: insert)
//        
//        XCTAssertEqual(database.getTable(name: "cats")?.rows, [["1", "Murzik", "Sausages"]])
//    }
    
}

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }


