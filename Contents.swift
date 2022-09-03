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

let publisher3 = [2, 1, 0].publisher
let cancellable3 = publisher3

/*
 5
 10
 failure: zero
*/
