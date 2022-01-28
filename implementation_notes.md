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

## Testing the elixir cells in a livebook

When writing a livebook usually you interact with the cells and so know they are valid or not.

In the future the flow for creating docs could / should be "take a section from the livebook and create a fn doc out of it". You could generate doctests out of the elixir cells and the markdown would be the doc.

The benefit of going that way is what?

e can test livebook cells basically, but what is the point really.


