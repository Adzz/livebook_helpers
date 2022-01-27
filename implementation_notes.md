# TODO

Test a module with typedocs (think the reduce will fail).
~Hexdocs expects code to be indented by 4 spaces, so we should also make them be elixir sections.~
Handle a 4 space code block or a doctest that has brackets... Eg:

@moduledoc """
  Exposes some helpers useful for interfacing with Link offers in an IEX console.
  Automatically included in iex sessions as CancelOrder

  Example usage:

    {:ok, offers} = (
      Search.new()
      |> H.with_agreement(:american_airlines)
      |> Search.slices([%{origin: "LON", destination: "JFK", departure_date: "2021-07-01"}])
      |> Search.passengers([%{type: "adult"}])
      |> Search.run()
    )

    {:ok, offers} = (
      OfferPrice.new()
      |> H.with_agreement(:american_airlines)
      |> OfferPrice.offer(List.first(offers))
      |> OfferPrice.run()
    )

    {:ok, order} = (
      Order.new()
      |> H.with_agreement(:american_airlines)
      |> Order.offer(List.first(offers))
      |> Order.run()
    )

    {:ok, refund_quote} = (
      OrderRefundQuote.new()
      |> H.with_agreement(:american_airlines)
      |> OrderRefundQuote.order(order)
      |> OrderRefundQuote.run()
    )

    (
      CancelOrder.new()
      |> H.with_agreement(:american_airlines)
      |> CancelOrder.order(order)
      |> CancelOrder.refund_quote(refund_quote)
      |> CancelOrder.run()
    )
"""

CAN WE parse straight from a string to a struct without SweetXML in data schema?
Using nimble parsec? And IO data? And stuff.

Do you create parsecs from the schemas, that would involve introspecting the fields
(at compile time for speed) and using the path to create our parsers.

But essentially the data_accessor would need to


## impl notes

When we had an acc that looked like this: {acc, four_space_code_block, iex_code_block}
it was interesting because it forced us to handle all the cases but did it buy us something?
Like i feel like we could type that acc and then parallelize it because you know what each
type needs to do.
meh.
