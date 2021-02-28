//
//  ValidatorType.swift
//  
//
//  Created by hien.tran on 2/13/21.
//

typealias ValidationResult = Result<Void, Swift.Error>

protocol ValidatorType {
    associatedtype Input

    func validate(_ input: Input) -> ValidationResult
}

struct AnyValidator<Input> {
    private let _validate: (Input) -> ValidationResult

    init<V: ValidatorType>(_ validator: V) where V.Input == Input {
        self._validate = validator.validate
    }

    func validate(_ input: Input) -> ValidationResult {
        return _validate(input)
    }
}

enum ValidationError: Swift.Error {
    case unknown
}


