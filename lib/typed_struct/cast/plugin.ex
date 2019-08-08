defmodule TypedStruct.Cast.Plugin do
  @behaviour TypedStruct.Plugin

  @impl true
  def init(_opts) do
    quote do
    end
  end

  @impl true
  def field(name, _type, opts) do
    opts =
      case Keyword.get(opts, :cast, {nil, []}) do
        {cast_type, cast_opts} -> {cast_type, cast_opts}
        cast_type -> {cast_type, []}
      end

    quote do
      unquote(def_field_cast(name, opts))
    end
  end

  @impl true
  def after_definition(_opts) do
    quote do
      unquote(def_struct_cast())

      if Module.get_attribute(__MODULE__, :__typed_struct_cast_define_helpers__) do
        unquote(def_helpers())
      end
    end
  end

  @doc false
  def cast(struct, params) when is_map(struct) do
    module = Map.get(struct, :__struct__)
    do_cast(module, struct, params)
  end

  def cast(module, params) when is_atom(module) do
    do_cast(module, %{}, params)
  end

  defp do_cast(module, dest, params) do
    if Kernel.function_exported?(module, :__typed_struct_cast__, 2) do
      module.__typed_struct_cast__(dest, params)
    else
      raise ArgumentError, message: "passed uncastable struct"
    end
  end

  @doc false
  def access_param(params, field, _field_permutations) when is_list(params) do
    Keyword.fetch(params, field)
  end

  def access_param(params, field, field_permutations) when is_map(params) do
    with :error <- Map.fetch(params, field) do
      field_permutations
      |> Stream.map(&Map.fetch(params, &1))
      |> Enum.find(:error, fn
        :error -> false
        _ -> true
      end)
    end
  end

  defp def_field_cast(field_name, {cast_type, cast_opts}) do
    field_name_string = Atom.to_string(field_name)
    # TODO: support field name transforms
    field_name_permutations = [field_name_string]

    quote do
      def __typed_struct_cast_field__(dest, unquote(field_name), params) do
        result =
          unquote(__MODULE__).access_param(
            params,
            unquote(field_name),
            unquote(field_name_permutations)
          )

        case result do
          {:ok, value} ->
            case TypedStruct.Cast.Type.cast(unquote(cast_type), value, unquote(cast_opts)) do
              {:ok, value} -> {:ok, Map.put(dest, unquote(field_name), value)}
              {:error, error} -> {:error, unquote(field_name_string) <> ": " <> error}
            end

          :error ->
            if unquote(field_name) in @keys_to_enforce do
              if Map.has_key?(dest, unquote(field_name)) do
                {:ok, dest}
              else
                {:error, unquote(field_name_string) <> " not specified"}
              end
            else
              {:ok, dest}
            end
        end
      end
    end
  end

  defp def_struct_cast() do
    quote do
      def __typed_struct_cast__(dest, params) do
        result =
          Enum.reduce_while(__MODULE__.__keys__(), dest, fn field_name, acc ->
            case __MODULE__.__typed_struct_cast_field__(acc, field_name, params) do
              {:ok, acc} -> {:cont, acc}
              {:error, err} -> {:halt, {:error, err}}
            end
          end)

        case result do
          {:error, err} -> {:error, err}
          struct -> {:ok, Map.put(struct, :__struct__, __MODULE__)}
        end
      end
    end
  end

  defp def_helpers() do
    quote do
      @spec cast(TypedStruct.Cast.params()) :: {:ok, t()} | {:error, any()}
      def cast(params) do
        TypedStruct.Cast.cast(__MODULE__, params)
      end

      @spec cast!(TypedStruct.Cast.params()) :: t()
      def cast!(params) do
        TypedStruct.Cast.cast!(__MODULE__, params)
      end

      @spec cast(t(), TypedStruct.Cast.params()) :: {:ok, t()} | {:error, any()}
      def cast(struct = %__MODULE__{}, params) do
        TypedStruct.Cast.cast(struct, params)
      end

      @spec cast!(t(), TypedStruct.Cast.params()) :: t()
      def cast!(struct = %__MODULE__{}, params) do
        TypedStruct.Cast.cast!(struct, params)
      end
    end
  end
end
