//
//  JSONSyntaxHighlighter.swift
//  Mako
//

import SwiftUI

enum JSONSyntaxHighlighter {
    enum TokenKind {
        case key
        case string
        case number
        case bool
        case null
        case bracket
        case punctuation
        case whitespace
    }

    struct Token {
        let kind: TokenKind
        let text: String
    }

    static func highlight(_ json: String) -> AttributedString {
        let formatted = JSONFormatter.format(json)
        let tokens = tokenize(formatted)

        var result = AttributedString()
        for token in tokens {
            var attributed = AttributedString(token.text)
            attributed.foregroundColor = color(for: token.kind)
            result.append(attributed)
        }
        return result
    }

    static func color(for kind: TokenKind) -> Color {
        switch kind {
        case .key:
            return .cyan
        case .string:
            return Color(red: 0.98, green: 0.55, blue: 0.38) // Orange/salmon
        case .number:
            return .purple
        case .bool:
            return .blue
        case .null:
            return .gray
        case .bracket, .punctuation, .whitespace:
            return .primary
        }
    }

    static func tokenize(_ json: String) -> [Token] {
        var tokens: [Token] = []
        var index = json.startIndex
        var expectingKey = true

        while index < json.endIndex {
            let char = json[index]

            if char.isWhitespace || char.isNewline {
                let start = index
                while index < json.endIndex && (json[index].isWhitespace || json[index].isNewline) {
                    index = json.index(after: index)
                }
                tokens.append(Token(kind: .whitespace, text: String(json[start..<index])))
                continue
            }

            if char == "{" || char == "}" || char == "[" || char == "]" {
                tokens.append(Token(kind: .bracket, text: String(char)))
                if char == "{" || char == "[" {
                    expectingKey = (char == "{")
                }
                index = json.index(after: index)
                continue
            }

            if char == ":" {
                tokens.append(Token(kind: .punctuation, text: ":"))
                expectingKey = false
                index = json.index(after: index)
                continue
            }

            if char == "," {
                tokens.append(Token(kind: .punctuation, text: ","))
                expectingKey = true
                index = json.index(after: index)
                continue
            }

            if char == "\"" {
                let stringToken = parseString(json: json, from: &index)
                let kind: TokenKind = expectingKey ? .key : .string
                tokens.append(Token(kind: kind, text: stringToken))
                continue
            }

            if char == "t" || char == "f" {
                let boolToken = parseLiteral(json: json, from: &index)
                tokens.append(Token(kind: .bool, text: boolToken))
                continue
            }

            if char == "n" {
                let nullToken = parseLiteral(json: json, from: &index)
                tokens.append(Token(kind: .null, text: nullToken))
                continue
            }

            if char.isNumber || char == "-" {
                let numberToken = parseNumber(json: json, from: &index)
                tokens.append(Token(kind: .number, text: numberToken))
                continue
            }

            tokens.append(Token(kind: .punctuation, text: String(char)))
            index = json.index(after: index)
        }

        return tokens
    }

    private static func parseString(json: String, from index: inout String.Index) -> String {
        var result = "\""
        index = json.index(after: index)

        while index < json.endIndex {
            let char = json[index]
            result.append(char)
            index = json.index(after: index)

            if char == "\\" && index < json.endIndex {
                result.append(json[index])
                index = json.index(after: index)
            } else if char == "\"" {
                break
            }
        }

        return result
    }

    private static func parseLiteral(json: String, from index: inout String.Index) -> String {
        var result = ""
        while index < json.endIndex && json[index].isLetter {
            result.append(json[index])
            index = json.index(after: index)
        }
        return result
    }

    private static func parseNumber(json: String, from index: inout String.Index) -> String {
        var result = ""
        while index < json.endIndex {
            let char = json[index]
            if char.isNumber || char == "." || char == "-" || char == "+" || char == "e" || char == "E" {
                result.append(char)
                index = json.index(after: index)
            } else {
                break
            }
        }
        return result
    }
}
