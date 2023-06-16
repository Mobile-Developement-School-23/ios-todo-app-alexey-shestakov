
import XCTest
@testable import ToDoList

class ToDoListTests: XCTestCase {
    
    func testParseJSON() {
        //1
        let json1: [String: Any] = [
            "id": "123",
            "text": "Buy groceries",
            "importance": "важная",
            "deadline": 1654320000, // 01.06.2022
            "done": true,
            "dateCreation": 1652976000, // 18.05.2022
            "dateChanging": 1653667200 // 27.05.2022
        ]
        
        let todoItem1 = TodoItem.parse(json: json1)
        
        XCTAssertNotNil(todoItem1, "Failed to parse JSON")
        XCTAssertEqual(todoItem1?.id, "123")
        XCTAssertEqual(todoItem1?.text, "Buy groceries")
        XCTAssertEqual(todoItem1?.importance, .important)
        XCTAssertEqual(todoItem1?.deadline, Date(timeIntervalSince1970: 1654320000))
        XCTAssertTrue(todoItem1?.done ?? false)
        XCTAssertEqual(todoItem1?.dateCreation, Date(timeIntervalSince1970: 1652976000))
        XCTAssertEqual(todoItem1?.dateChanging, Date(timeIntervalSince1970: 1653667200))
        
        //2
        let json2: [String: Any] = [
            "id": "789",
            "text": "Finish homework",
            "deadline": 1670409600, // 06.01.2023
            "done": false,
            "dateCreation": 1668566400, // 16.03.2023
            "dateChanging": 1668921600 // 20.03.2023
        ]
        
        let todoItem2 = TodoItem.parse(json: json2)
        
        XCTAssertNotNil(todoItem2, "Failed to parse JSON")
        XCTAssertEqual(todoItem2?.id, "789")
        XCTAssertEqual(todoItem2?.text, "Finish homework")
        XCTAssertEqual(todoItem2?.importance, .normal)
        XCTAssertEqual(todoItem2?.deadline, Date(timeIntervalSince1970: 1670409600))
        XCTAssertFalse(todoItem2?.done ?? true)
        XCTAssertEqual(todoItem2?.dateCreation, Date(timeIntervalSince1970: 1668566400))
        XCTAssertEqual(todoItem2?.dateChanging, Date(timeIntervalSince1970: 1668921600))
    }
    
    func testJSON() {
        //1
        let todoItem1 = TodoItem(
            id: "456",
            text: "Finish project",
            importance: .normal,
            deadline: Date(timeIntervalSince1970: 1672560000), // 01.01.2023
            done: false,
            dateCreation: Date(timeIntervalSince1970: 1670486400), // 08.12.2022
            dateChanging: nil
        )
        let json1 = todoItem1.json as? [String: Any]
        
        XCTAssertNotNil(json1, "Failed to convert to JSON")
        XCTAssertEqual(json1?["id"] as? String, "456")
        XCTAssertEqual(json1?["text"] as? String, "Finish project")
        XCTAssertEqual(json1?["importance"] as? String, nil)
        XCTAssertEqual(json1?["deadline"] as? Int, 1672560000)
        XCTAssertFalse(json1?["done"] as? Bool ?? true)
        XCTAssertEqual(json1?["dateCreation"] as? Int, 1670486400)
        XCTAssertNil(json1?["dateChanging"])
        
        //2
        let todoItem2 = TodoItem(
            id: "456",
            text: "Read a book",
            importance: .important,
            deadline: Date(timeIntervalSince1970: 1672099200), // 26.01.2023
            done: true,
            dateCreation: Date(timeIntervalSince1970: 1669900800), // 01.03.2023
            dateChanging: nil
        )
        let json2 = todoItem2.json as? [String: Any]
        
        XCTAssertNotNil(json2, "Failed to convert to JSON")
        XCTAssertEqual(json2?["id"] as? String, "456")
        XCTAssertEqual(json2?["text"] as? String, "Read a book")
        XCTAssertEqual(json2?["importance"] as? String, "важная")
        XCTAssertEqual(json2?["deadline"] as? Int, 1672099200)
        XCTAssertTrue(json2?["done"] as? Bool ?? false)
        XCTAssertEqual(json2?["dateCreation"] as? Int, 1669900800)
        XCTAssertNil(json2?["dateChanging"])
    }
    
    func testParseCSV() {
        //1
        let csv1 = "789,Study for exam,неважная,1637126400,0,1636281600,"
        let todoItem1 = TodoItem.parse(csv: csv1)
        
        XCTAssertNotNil(todoItem1, "Failed to parse CSV")
        XCTAssertEqual(todoItem1?.id, "789")
        XCTAssertEqual(todoItem1?.text, "Study for exam")
        XCTAssertEqual(todoItem1?.importance, .unimportant)
        XCTAssertEqual(todoItem1?.deadline, Date(timeIntervalSince1970: 1637126400))
        XCTAssertFalse(todoItem1?.done ?? true)
        XCTAssertEqual(todoItem1?.dateCreation, Date(timeIntervalSince1970: 1636281600))
        XCTAssertNil(todoItem1?.dateChanging)
        
        //2
        let csv2 = "101,Write report,,1673414400,1,1672176000,1672483200"
        let todoItem2 = TodoItem.parse(csv: csv2)
        
        XCTAssertNotNil(todoItem2, "Failed to parse CSV")
        XCTAssertEqual(todoItem2?.id, "101")
        XCTAssertEqual(todoItem2?.text, "Write report")
        XCTAssertEqual(todoItem2?.importance, .normal)
        XCTAssertEqual(todoItem2?.deadline, Date(timeIntervalSince1970: 1673414400))
        XCTAssertTrue(todoItem2?.done ?? false)
        XCTAssertEqual(todoItem2?.dateCreation, Date(timeIntervalSince1970: 1672176000))
        XCTAssertEqual(todoItem2?.dateChanging, Date(timeIntervalSince1970: 1672483200))
    }
    
    func testCSV() {
        //1
        let todoItem1 = TodoItem(
            id: "101",
            text: "Exercise",
            importance: .important,
            deadline: nil,
            done: true,
            dateCreation: Date(timeIntervalSince1970: 1668038400), // 10.03.2023
            dateChanging: Date(timeIntervalSince1970: 1668235200) // 13.03.2023
        )
        let csv1 = todoItem1.csv
        XCTAssertEqual(csv1, "101,Exercise,важная,,1,1668038400.0,1668235200.0")
        
        //2
        let todoItem2 = TodoItem(
            id: "789",
            text: "Complete project",
            importance: .normal,
            deadline: Date(timeIntervalSince1970: 1671160400),
            done: false,
            dateCreation: Date(timeIntervalSince1970: 1671030400), // 14.02.2023
            dateChanging: Date(timeIntervalSince1970: 1671385600) // 18.02.2023
        )
        let csv2 = todoItem2.csv
        XCTAssertEqual(csv2, "789,Complete project,,1671160400.0,0,1671030400.0,1671385600.0")
    }
}

