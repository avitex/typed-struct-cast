defmodule TypedStruct.Cast.Type do
  @type t :: atom()
  @type opts :: any()

  @callback cast(any(), opts()) :: {:ok, any()} | {:error, any()}

  @builtin [
    Integer,
    Float,
    Date,
    Time,
    NaiveDateTime
  ]

  @spec is_builtin?(t()) :: boolean
  def is_builtin?(type) do
    type in @builtin
  end

  @spec cast(t() | nil, any(), opts()) :: {:ok, any()} | {:error, any()}
  def cast(nil, value, _opts) do
    {:ok, value}
  end

  def cast(_type, nil, _opts) do
    {:ok, nil}
  end

  #############################################################################
  # Integer

  def cast(Integer, value, _opts) when is_integer(value) do
    {:ok, value}
  end

  def cast(Integer, value, _opts) when is_binary(value) do
    case Integer.parse(value) do
      {value, ""} -> {:ok, value}
      _ -> {:error, "invalid integer"}
    end
  end

  #############################################################################
  # Float

  def cast(Float, value, _opts) when is_float(value) do
    {:ok, value}
  end

  def cast(Float, value, _opts) when is_binary(value) do
    case Float.parse(value) do
      {value, ""} -> {:ok, value}
      _ -> {:error, "invalid float"}
    end
  end

  def cast(Float, value, _opts) when is_integer(value) do
    {:ok, value / 1}
  end

  #############################################################################
  # Date

  def cast(Date, value = %Date{}, _opts) do
    {:ok, value}
  end

  def cast(Date, value, _opts) when is_binary(value) do
    Date.from_iso8601(value)
  end

  #############################################################################
  # Time

  def cast(Time, value = %Time{}, _opts) do
    {:ok, value}
  end

  def cast(Time, value, _opts) when is_binary(value) do
    Time.from_iso8601(value)
  end

  #############################################################################
  # NaiveDateTime

  def cast(NaiveDateTime, value = %NaiveDateTime{}, _opts) do
    {:ok, value}
  end

  def cast(NaiveDateTime, value, _opts) when is_binary(value) do
    with {:ok, dt} <- NaiveDateTime.from_iso8601(value) do
      {:ok, dt}
    end
  end

  #############################################################################
  # Fallback

  def cast(type, value, opts) do
    if is_builtin?(type) do
      {:error, "could not cast to #{type}"}
    else
      type.cast(value, opts)
    end
  end
end
