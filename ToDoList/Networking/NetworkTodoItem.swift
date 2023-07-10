struct NetworkTodoItem: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let createdAt: Int
    let changedAt: Int?
    let lastUpdatedBy: String
    
    init(id: String, text: String, importance: String, deadline: Int? = nil, done: Bool, createdAt: Int, changedAt: Int? = nil, lastUpdatedBy: String = "me") {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.lastUpdatedBy = lastUpdatedBy
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}

struct ListToDoItems: Codable {
    let revision: Int?
    let list: [NetworkTodoItem]
    init(revision: Int? = nil, list: [NetworkTodoItem]) {
        self.revision = revision
        self.list = list
    }
}

struct ElementToDoItem: Codable {
    let revision: Int?
    let element: NetworkTodoItem
    init(revision: Int? = nil, element: NetworkTodoItem) {
        self.revision = revision
        self.element = element
    }
}
