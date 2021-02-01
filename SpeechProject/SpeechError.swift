//
//  SpeechError.swift
//  SpeechProject
//
//  Created by Angie Mugo on 02/02/2021.
//

import Foundation

enum SpeechError: Error {
    case AudioEngineError(message: String)
    case SpeechSynthesizorError(message: String)
}
