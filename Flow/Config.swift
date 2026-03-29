//
//  Config.swift
//  Flow
//
//  Created by Ethan Wu on 3/28/26.
//


import Foundation

enum Config {
    static var openAIKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = dict["OPENAI_API_KEY"] as? String else {
            fatalError("🚨 Error: Missing Secrets.plist or OPENAI_API_KEY not found.")
        }
        return key
    }
}