//
//  RegexValidatorType.swift
//  
//
//  Created by hien.tran on 2/13/21.
//

import Foundation

protocol RegexValidatorType: ValidatorType where Input == String {
    var regex: NSRegularExpression { get }
}
