//
//  MyTests.swift
//  TestProjectTests
//
//  Created by Yura B on 22.10.2024.
//

import XCTest
@testable import OAA_Task1

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


