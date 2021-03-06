defmodule Bullets do
  @doc """
  Chunks the `enumerable` with fine grained control when every chunk is emitted.
  `chunk_fun` receives the current element and the accumulator and must return:

    * `{:cont, chunk, acc}` to emit a chunk and continue with the accumulator
      line wraps are fine too.
    * `{:cont, acc}` to not emit any chunk and continue with the accumulator
      * nested bullet points are cool
    * `{:halt, acc}` to halt chunking over the `enumerable`.
      what about linew wraps AND
      * nested bullet points??? a mad mad
        wrapped nested bullet point. what a time.
    * guess again

  `after_fun` is invoked with the final accumulator when iteration is
  finished (or `halt`ed) to handle any trailing elements that were returned
  as part of an accumulator, but were not emitted as a chunk by `chunk_fun`.
  It must return:

    * `{:cont, chunk, acc}` to emit a chunk. The chunk will be appended to the
      list of already emitted chunks.
    * `{:cont, acc}` to not emit a chunk

  The `acc` in `after_fun` is required in order to mirror the tuple format
  from `chunk_fun` but it will be discarded since the traversal is complete.

  Returns a list of emitted chunks.

  ## Examples

      iex> chunk_fun = fn element, acc ->
      ...>   if rem(element, 2) == 0 do
      ...>     {:cont, Enum.reverse([element | acc]), []}
      ...>   else
      ...>     {:cont, [element | acc]}
      ...>   end
      ...> end
      iex> after_fun = fn
      ...>   [] -> {:cont, []}
      ...>   acc -> {:cont, Enum.reverse(acc), []}
      ...> end
      iex> Enum.chunk_while(1..10, [], chunk_fun, after_fun)
      [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]
      iex> Enum.chunk_while([1, 2, 3, 5, 7], [], chunk_fun, after_fun)
      [[1, 2], [3, 5, 7]]

  """
  def test_fun, do: 1
end
