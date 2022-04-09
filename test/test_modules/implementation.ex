defmodule Implementation do
  @moduledoc """
  This is the actual moduledoc
  """
  defimpl ImplementedProto do
    @moduledoc """
    Doc for implementation.
    not sure you should do this but it probably works.
    """
    @doc "this is a doc"
    def thing(_), do: 1
  end
end
