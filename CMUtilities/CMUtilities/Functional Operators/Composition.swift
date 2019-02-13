//
//  Composition.swift
//
//    MIT License
//
//    Copyright (c) 2017 Point-Free
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import Foundation

precedencegroup ForwardApplication {
    associativity: left
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: SingleTypeComposition
}

precedencegroup SingleTypeComposition {
    associativity: right
    higherThan: ForwardApplication
}

///Pipe the item on the left into the function on the right
infix operator |>: ForwardApplication
public func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

///Compose 2 functions f(B) -> C and g(A) -> B such that the resulting function is g(f(A)) -> C
infix operator >>>: ForwardComposition
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

///This overload of the diamond operator composes operations on an object type that return void by performing f then g functions sequentially.
func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

///This overload of the diamond operator forward composes (f >>> g) functions that operate on the same type.
infix operator <>: SingleTypeComposition
public func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
    return f >>> g
}

///This overload of the diamond operator composes mutating operations on structs by performing f then g functions sequentially.
public func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}
