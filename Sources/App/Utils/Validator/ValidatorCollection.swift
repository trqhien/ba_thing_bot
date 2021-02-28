//
//  ValidatorCollection.swift
//  
//
//  Created by hien.tran on 2/13/21.
//

struct ValidatorCollection<Input> {

    private var validators = [AnyValidator<Input>]()

    init() {}

    mutating func add<V: ValidatorType>(_ validator: V) where V.Input == Input {
        validators.append(AnyValidator(validator))
    }

    func validate(_ input: Input) -> [ValidationResult] {
        return validators.map { $0.validate(input) }
    }

    func checkIfValid(_ input: Input) -> Bool {
        let validationResult = validate(input)
        return _checkIfValid(validationResult)
    }

    func analyze(_ input: Input) -> ValidationResult {
        let validationResult = validate(input)

        if self._checkIfValid(validationResult) {
            return validationResult.first {
                switch $0 {
                case .success:
                    return true
                case .failure:
                    return false
                }
            }!
        }

        let errorOnlyResult = validationResult.filter {
            switch $0 {
            case .success:
                return false
            case .failure:
                return true
            }
        }

        return errorOnlyResult.first!
    }

    private func _checkIfValid(_ results: [ValidationResult]) -> Bool {
        let filteredValid = results.filter {
            switch $0 {
            case .success:
                return true
            case .failure:
                return false
            }
        }

        // The input is valid ONLY if all validators return valid result
        return filteredValid.count == results.count
    }
}

/*
extension ValidatorCollection {
    static var emailValidatorSet: ValidatorCollection<String> {
        let lengthValidator = LengthValidator(minCharacters: 0, maxCharacters: 128)
        let emailValidator = EmailValidator()

        var validatorCollection = ValidatorCollection<String>()
        validatorCollection.add(emailValidator)
        validatorCollection.add(lengthValidator)

        return validatorCollection
    }

    /// A password validators collection
    ///
    /// Password validators collection contains the following rules:
    /// - Password must have at least 8 chracters and at most 99 characters
    /// - Require at least 1 number
    /// - Require at least one special character from this set: ^ $ * . [ ] { } ( ) ? - " ! @ # % & / \ , > < ' : ; | _ ~ `
    /// - Require at least an uppercase letter
    /// - Require at lease a lowercase letter
    static var passwordValidatorsSet: ValidatorCollection<String> {
        let lengthValidator = LengthValidator(minCharacters: 8, maxCharacters: 99)
        let requireNumber = AtLeastOneNumericLetterValidator()
        let requireSpecialCharacter = AtLeastOneSpecialCharacterValidator()
        let requireUppercase = AtLeastOneUppercaseLetterValidator()
        let requireLowercase = AtLeastOneLowercaseLetterValidator()

        var validatorsCollection = ValidatorCollection<String>()
        validatorsCollection.add(lengthValidator)
        validatorsCollection.add(requireNumber)
        validatorsCollection.add(requireSpecialCharacter)
        validatorsCollection.add(requireUppercase)
        validatorsCollection.add(requireLowercase)

        return validatorsCollection
    }
}
*/
