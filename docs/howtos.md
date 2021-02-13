# Jzon How-To Guides

This document list common JSON coding tasks and how they could be solved with Jzon.

## How to encode/decode a record

```rescript
// The record to encode/decode
type point = {
  x: float,
  y: float,
  z: float,
  color: string,
}

module Codecs = {
  // The codec for the record. There’s no requirement to put it
  // into a sub-module, but groupping all the codecs with the same
  // names as their respective types in a dedicated module is
  // a good idea for code organization
  let point = Jzon.object4(
    ({x, y, z, color}) => (x, y, z, color),
    ((x, y, z, color)) => {x: x, y: y, z: z, color: color}->Ok,
    Jzon.field("x", Jzon.float),
    Jzon.field("y", Jzon.float),
    Jzon.field("z", Jzon.float),
    Jzon.field("color", Jzon.string),
  )
}

test("Record encoding", () => {
  Codecs.point
  ->Jzon.encodeString({x: 1.0, y: 2.0, z: 3.0, color: "#fda"})
  ->Assert.equals(`{"x":1,"y":2,"z":3,"color":"#fda"}`)
})

test("Record decoding", () => {
  Codecs.point
  ->Jzon.decodeString(`{"x":1,"y":2,"z":3,"color":"#fda"}`)
  ->Assert.equals(Ok({x: 1.0, y: 2.0, z: 3.0, color: "#fda"}))

  // Missing some required fields
  Codecs.point->Jzon.decodeString(`{"x":1,"y":2}`)
  ->Assert.equals(Error(#MissingField([], "z")))
})
```

## How to make some fields optional

Jzon supports two flavors of the optionality: fallback to a default value and lifting to `option`. In the first case you always get your value while decoding and don’t even know whether the field was in JSON or not. And in the latter case you deal with `None` or `Some(...)` explicitly. The example below demonstrates both ways.

```rescript
type point = {
  x: float,
  y: float,
  z: float,
  color: option<string>,
}

module Codecs = {
  let point = Jzon.object4(
    ({x, y, z, color}) => (x, y, z, color),
    ((x, y, z, color)) => {x: x, y: y, z: z, color: color}->Ok,
    Jzon.field("x", Jzon.float),
    Jzon.field("y", Jzon.float),
    // Use Jzon.default adapter to provide a fallback value in case
    // the field is missing
    Jzon.field("z", Jzon.float)->Jzon.default(0.0),
    // Use Jzon.optional adapter to make the value indeed option’al
    Jzon.field("color", Jzon.string)->Jzon.optional,
  )
}

test("Optional/default encoding", () => {
  Codecs.point
  ->Jzon.encodeString({x: 1.0, y: 2.0, z: 3.0, color: Some("#fda")})
  ->Assert.equals(`{"x":1,"y":2,"z":3,"color":"#fda"}`)

  // Optional fields are omitted in output if `None` and fields
  // with default values are always encoded, even if match the
  // fallback value
  Codecs.point
  ->Jzon.encodeString({x: 1.0, y: 2.0, z: 0.0, color: None})
  ->Assert.equals(`{"x":1,"y":2,"z":0}`)
})

test("Optional/default decoding", () => {
  Codecs.point
  ->Jzon.decodeString(`{"x":1,"y":2,"z":3,"color":"#fda"}`)
  ->Assert.equals(Ok({x: 1.0, y: 2.0, z: 3.0, color: Some("#fda")}))

  Codecs.point
  ->Jzon.decodeString(`{"x":1,"y":2}`)
  ->Assert.equals(Ok({x: 1.0, y: 2.0, z: 0.0, color: None}))
})
```