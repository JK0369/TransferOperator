import Combine

let publisher1 = [1, 2, 3].publisher
let cancellable1 = publisher1
  .map { $0 + 2 }
  .sink(receiveValue: { print($0) })
/*
 3
 4
 5
*/

enum SomeError: Error {
  case zero
}
let publisher2 = [2, 1, 0].publisher
let cancellable2 = publisher2
  .tryMap {
    guard $0 != 0 else { throw SomeError.zero }
    return 10 / $0
  }
  .sink(
    receiveCompletion: { result in
      switch result {
      case let .failure(error):
        print("failure: \(error)")
      case .finished:
        print("finished")
      }
    },
    receiveValue: { value in
      print(value)
    }
  )
/*
 5
 10
 failure: zero
*/


let publisher3 = [2, 1, 0].publisher
let cancellable3 = publisher3
  .flatMap { value -> AnyPublisher<Int, Never> in
    Future { promise in
      promise(.success(value + 10))
    }
    .eraseToAnyPublisher()
  }
  .sink(receiveValue: { print($0) } )
/*
 12
 11
 10
*/

enum MyError: Error {
  case zero
  case other
}
enum GeneralError: Error {
  case first
}
let publisher4 = [2, 1, 0].publisher
let cancellable4 = publisher4
  .tryMap { try divideValue($0) }
  .mapError { _ in return GeneralError.first }
  .sink(
    receiveCompletion: { result in
      switch result {
      case let .failure(error):
        print("failure: \(error)")
      case .finished:
        print("finished")
      }
    },
    receiveValue: { value in
      print(value)
    }
  )

func divideValue(_ value: Int) throws -> Int {
  guard value != 0 else { throw MyError.zero }
  return 10 / value
}
/*
 5
 10
 failure: first
*/

let publisher5 = [2, nil, 0].publisher
let cancellable5 = publisher5
  .replaceNil(with: -1)
  .sink { print($0) }
/*
 Optional(2)
 Optional(-1)
 Optional(0)
*/

let publisher6 = [1, 2, 3].publisher
let cancellable6 = publisher6
  .scan(10, { $0 + $1 })
  .sink { print($0) }
/*
 11
 13
 16
*/

enum NilError: Error {
  case isNil
}
let publisher7 = [0, nil, 2].publisher
let cancellable7 = publisher7
  .tryScan(0) { try handleSomeValue(lhs: $0, rhs: $1) }
  .sink(
    receiveCompletion: { print("receiveCompletion: \($0)") },
    receiveValue: { print("receiveValue: \($0)") }
  )
func handleSomeValue(lhs: Int?, rhs: Int?) throws -> Int {
  guard
    let lhs = lhs,
    let rhs = rhs
  else { throw NilError.isNil }
  return lhs + rhs
}
/*
 receiveValue: 0
 receiveCompletion: failure(__lldb_expr_24.NilError.isNil)
*/

enum SomeErrroType: Error {
  case some
}
let publisher8 = [0, nil, 2].publisher // 타입: Publishers.Sequence<[Int?], Never>
let cancellable8 = publisher8
  .setFailureType(to: SomeErrroType.self)
  .sink(
    receiveCompletion: { print($0) },
    receiveValue: { print($0) }
  )
/*
 Optional(0)
 nil
 Optional(2)
 finished
*/
