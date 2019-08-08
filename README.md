# TypedStruct.Cast

**Casting plugin for [TypedStruct](https://hex.pm/packages/typed_struct)**

## TODO

- Documentation
- Remove requirement on development version of `typed_struct` that supports plugins.

## Installation

****

Add `typedstruct_cast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # NOTE: Currently not published on hex
    # {:typedstruct_cast, "~> 0.1.0"}
    {:typedstruct_cast, github: "avitex/typed-struct-cast"}
  ]
end
```

## Usage

```elixir
defmodule MyCustomType do
  @behaviour TypedStruct.Cast.Type

  @impl true
  def cast(_value, _opts) do
    {:ok, :custom}
  end
end

defmodule MyStruct do
  use TypedStruct
  use TypedStruct.Cast # optional

  typedstruct do
    plugin TypedStruct.Cast.Plugin

    field :foo, integer(), cast: :integer
    field :bar, MyCustomType.t(), cast: {MyCustomType, [foo: true]}
  end
end

# Create a new struct given a map
iex> MyStruct.cast(%{"foo" => "1"})
{:ok, %MyStruct{foo: 1, bar: nil}}

# Create a new struct given a keyword
iex> MyStruct.cast([foo: "1", bar: true])
{:ok, %MyStruct{foo: 1, bar: :custom}}

# Cast params into an existing struct
iex> MyStruct.cast(%MyStruct{bar: :hello}, {"foo" => "1"})
{:ok, %MyStruct{foo: 1, bar: :hello}}

# If you don't `use TypedStruct.Cast`, you can access
# the same functions like so:
iex> TypedStruct.Cast.cast(MyStruct, %{"foo" => "1"})
{:ok, %MyStruct{foo: 1, bar: nil}}
```
