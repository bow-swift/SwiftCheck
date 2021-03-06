//
//  WitnessedArbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 12/15/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

extension Array : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `Array`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Array<Element>> {
		return Element.arbitrary.proliferate
	}

	/// The default shrinking function for `Array`s of arbitrary `Element`s.
	public static func shrink(_ bl : Array<Element>) -> [[Element]] {
		let rec : [[Element]] = shrinkOne(bl)
		return Int.shrink(bl.count).reversed().flatMap({ k in removes((k + 1), n: bl.count, xs: bl) }) + rec
	}
}

extension AnyBidirectionalCollection : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `AnyBidirectionalCollection`s of arbitrary `Element`s.
	public static var arbitrary : Gen<AnyBidirectionalCollection<Element>> {
		return [Element].arbitrary.map(AnyBidirectionalCollection.init)
	}

	/// The default shrinking function for `AnyBidirectionalCollection`s of arbitrary `Element`s.
	public static func shrink(_ bl : AnyBidirectionalCollection<Element>) -> [AnyBidirectionalCollection<Element>] {
		return [Element].shrink([Element](bl)).map(AnyBidirectionalCollection.init)
	}
}

extension AnySequence : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `AnySequence`s of arbitrary `Element`s.
	public static var arbitrary : Gen<AnySequence<Element>> {
		return [Element].arbitrary.map(AnySequence.init)
	}

	/// The default shrinking function for `AnySequence`s of arbitrary `Element`s.
	public static func shrink(_ bl : AnySequence<Element>) -> [AnySequence<Element>] {
		return [Element].shrink([Element](bl)).map(AnySequence.init)
	}
}

extension ArraySlice : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `ArraySlice`s of arbitrary `Element`s.
	public static var arbitrary : Gen<ArraySlice<Element>> {
		return [Element].arbitrary.map(ArraySlice.init)
	}

	/// The default shrinking function for `ArraySlice`s of arbitrary `Element`s.
	public static func shrink(_ bl : ArraySlice<Element>) -> [ArraySlice<Element>] {
		return [Element].shrink([Element](bl)).map(ArraySlice.init)
	}
}

extension CollectionOfOne : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `CollectionOfOne`s of arbitrary `Element`s.
	public static var arbitrary : Gen<CollectionOfOne<Element>> {
		return Element.arbitrary.map(CollectionOfOne.init)
	}
}

/// Generates an Optional of arbitrary values of type A.
extension Optional : Arbitrary where Wrapped : Arbitrary {
	/// Returns a generator of `Optional`s of arbitrary `Wrapped` values.
	public static var arbitrary : Gen<Optional<Wrapped>> {
		return Gen<Optional<Wrapped>>.frequency([
			(1, Gen<Optional<Wrapped>>.pure(.none)),
			(3, liftM(Optional<Wrapped>.some, Wrapped.arbitrary)),
		])
	}

	/// The default shrinking function for `Optional`s of arbitrary `Wrapped`s.
	public static func shrink(_ bl : Optional<Wrapped>) -> [Optional<Wrapped>] {
		if let x = bl {
			let rec : [Optional<Wrapped>] = Wrapped.shrink(x).map(Optional<Wrapped>.some)
			return [.none] + rec
		}
		return []
	}
}

extension ContiguousArray : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `ContiguousArray`s of arbitrary `Element`s.
	public static var arbitrary : Gen<ContiguousArray<Element>> {
		return [Element].arbitrary.map(ContiguousArray.init)
	}

	/// The default shrinking function for `ContiguousArray`s of arbitrary `Element`s.
	public static func shrink(_ bl : ContiguousArray<Element>) -> [ContiguousArray<Element>] {
		return [Element].shrink([Element](bl)).map(ContiguousArray.init)
	}
}

/// Generates an dictionary of arbitrary keys and values.
extension Dictionary : Arbitrary where Key : Arbitrary, Value : Arbitrary {
	/// Returns a generator of `Dictionary`s of arbitrary `Key`s and `Value`s.
	public static var arbitrary : Gen<Dictionary<Key, Value>> {
		return [Key].arbitrary.flatMap { (k : [Key]) in
			return [Value].arbitrary.flatMap { (v : [Value]) in
				return Gen.pure(Dictionary(zip(k, v)) { $1 })
			}
		}
	}

	/// The default shrinking function for `Dictionary`s of arbitrary `Key`s and
	/// `Value`s.
	public static func shrink(_ d : Dictionary<Key, Value>) -> [Dictionary<Key, Value>] {
		return d.map { t in Dictionary(zip(Key.shrink(t.key), Value.shrink(t.value)), uniquingKeysWith: { (_, v) in v }) }
	}
}

extension EmptyCollection : Arbitrary {
	/// Returns a generator of `EmptyCollection`s of arbitrary `Element`s.
	public static var arbitrary : Gen<EmptyCollection<Element>> {
		return Gen.pure(EmptyCollection())
	}
}

extension Range : Arbitrary where Bound : Arbitrary {
	/// Returns a generator of `HalfOpenInterval`s of arbitrary `Bound`s.
	public static var arbitrary : Gen<Range<Bound>> {
		return Bound.arbitrary.flatMap { l in
			return Bound.arbitrary.flatMap { r in
				return Gen.pure((Swift.min(l, r) ..< Swift.max(l, r)))
			}
		}
	}

	/// The default shrinking function for `HalfOpenInterval`s of arbitrary `Bound`s.
	public static func shrink(_ bl : Range<Bound>) -> [Range<Bound>] {
		return zip(Bound.shrink(bl.lowerBound), Bound.shrink(bl.upperBound)).map(Range.init)
	}
}

extension LazySequence : Arbitrary where Base : Arbitrary {
	/// Returns a generator of `LazySequence`s of arbitrary `Base`s.
	public static var arbitrary : Gen<LazySequence<Base>> {
		return Base.arbitrary.map({ $0.lazy })
	}
}

extension Repeated : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `Repeat`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Repeated<Element>> {
		let constructor: (Element, Int) -> Repeated<Element> = { (element, count) in
			return repeatElement(element , count: count)
		}

		return Gen<(Element, Int)>.zip(Element.arbitrary, Int.arbitrary).map({ t in constructor(t.0, t.1) })
	}
}

extension Set : Arbitrary where Element : Arbitrary {
	/// Returns a generator of `Set`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Set<Element>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).flatMap { k in
				if k == 0 {
					return Gen.pure(Set([]))
				}

				return sequence(Array((0...k)).map { _ in Element.arbitrary }).map(Set.init)
			}
		}
	}

	/// The default shrinking function for `Set`s of arbitrary `Element`s.
	public static func shrink(_ s : Set<Element>) -> [Set<Element>] {
		return [Element].shrink([Element](s)).map(Set.init)
	}
}

extension Result : Arbitrary where Success : Arbitrary, Failure : Arbitrary {
	/// Returns a generator of `Result`s of arbitrary `Success` and
	/// `Failure` values.
	public static var arbitrary : Gen<Result<Success, Failure>> {
		return Gen<Result<Success, Failure>>.one(of: [
			Success.arbitrary.map(Result<Success, Failure>.success),
			Failure.arbitrary.map(Result<Success, Failure>.failure),
		])
	}

	/// The default shrinking function for `Result`s of arbitrary `Success` and
	/// `Failure` values.
	public static func shrink(_ bl : Result<Success, Failure>) -> [Result<Success, Failure>] {
		switch bl {
		case let .success(value):
			return Success.shrink(value).map(Result<Success, Failure>.success)
		case let .failure(value):
			return Failure.shrink(value).map(Result<Success, Failure>.failure)
		}
	}
}

// MARK: - Implementation Details

private func removes<A : Arbitrary>(_ k : Int, n : Int, xs : [A]) -> [[A]] {
	let xs2 : [A] = Array(xs.suffix(max(0, xs.count - k)))
	if k > n {
		return []
	} else if xs2.isEmpty {
		return [[]]
	} else {
		let xs1 : [A] = Array(xs.prefix(k))
		let rec : [[A]] = removes(k, n: n - k, xs: xs2).map({ xs1 + $0 })
		return [xs2] + rec
	}
}

private func shrinkOne<A : Arbitrary>(_ xs : [A]) -> [[A]] {
	guard let x : A = xs.first else {
		return [[A]]()
	}

	let xss = [A](xs[1..<xs.endIndex])
	let a : [[A]] = A.shrink(x).map({ [$0] + xss })
	let b : [[A]] = shrinkOne(xss).map({ [x] + $0 })
	return a + b
}

