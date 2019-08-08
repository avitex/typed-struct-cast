defmodule TestStruct do
  use TypedStruct
  use TypedStruct.Cast

  typedstruct do
    plugin(TypedStruct.Cast.Plugin)

    field(:foobar, integer())
    field(:foobar_enforced, integer(), enforced: true)
    field(:foobar_casted, integer(), cast: :integer)
    field(:foobar_casted_enforced, integer(), enforced: true, cast: :integer)
  end
end

defmodule TypedStruct.CastTest do
  use ExUnit.Case

  doctest TypedStruct.Cast

  @test_struct %TestStruct{
    foobar: 1,
    foobar_enforced: 1,
    foobar_casted: 1,
    foobar_casted_enforced: 1
  }

  test "standard construction" do
    assert @test_struct
  end

  test "cast from map with string keys" do
    {:ok, @test_struct} =
      TypedStruct.Cast.cast(TestStruct, %{
        "foobar" => 1,
        "foobar_enforced" => 1,
        "foobar_casted" => "1",
        "foobar_casted_enforced" => "1"
      })
  end

  test "cast from map with atom keys" do
    {:ok, @test_struct} =
      TypedStruct.Cast.cast(TestStruct, %{
        foobar: 1,
        foobar_enforced: 1,
        foobar_casted: "1",
        foobar_casted_enforced: "1"
      })
  end

  test "cast from keyword" do
    {:ok, @test_struct} =
      TypedStruct.Cast.cast(TestStruct,
        foobar: 1,
        foobar_enforced: 1,
        foobar_casted: "1",
        foobar_casted_enforced: "1"
      )
  end

  test "cast with helper function" do
    {:ok, @test_struct} =
      TestStruct.cast(
        foobar: 1,
        foobar_enforced: 1,
        foobar_casted: "1",
        foobar_casted_enforced: "1"
      )
  end

  test "invalid cast fails" do
    {:error, _} =
      TypedStruct.Cast.cast(TestStruct,
        foobar: 1,
        foobar_enforced: 1,
        foobar_casted: {"invalid"},
        foobar_casted_enforced: {"invalid"}
      )
  end
end
