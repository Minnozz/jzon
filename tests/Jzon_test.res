open Test

module Assert = {
  let okOf = (~message=?, left, right) =>
    assertion(
      (left, right) => left == Ok(right),
      left,
      right,
      ~operator="left == Ok(right)",
      ~message?,
    )

  let errorOf = (~message=?, left, right) =>
    assertion(
      (left, right) => left == Error(right),
      left,
      right,
      ~operator="left == Error(right)",
      ~message?,
    )
}

type look = {
  color: string,
  size: float,
}

type vertex = {
  x: float,
  y: float,
  look: look,
}

module JsonCodecs = {
  let look = Jzon.record2(
    ((color, size)) => {color: color, size: size},
    ({color, size}) => (color, size),
    Jzon.field("color", Jzon.string),
    Jzon.field("size", Jzon.float),
  )

  let vertex = Jzon.record3(
    ((x, y, look)) => {x: x, y: y, look: look},
    ({x, y, look}) => (x, y, look),
    Jzon.field("x", Jzon.float),
    Jzon.field("y", Jzon.float),
    Jzon.field("look", look),
  )
}

test("Vertex decode (nested record)", () => {
  let json = `{"x": 10, "y": 20, "look": {"color": "#09a", "size": 5.0}}`
  let result = Jzon.decodeString(json, JsonCodecs.vertex)
  result->Assert.okOf(
    {x: 10.0, y: 20.0, look: {color: "#09a", size: 5.0}},
    ~message="decodes correctly",
  )
})
