defmodule ElmfolioWeb.PortfolioChannel do
  use Phoenix.Channel

  @channel_name "portfolio"

  def join(@channel_name <> ":lobby", _message, socket) do
    {:ok, socket}
  end

  def handle_in("get_items", _payload, socket) do
    Elmfolio.Portfolio.Server.get() |> respond(socket)
  end

  def handle_in(
        "like_item",
        %{"categoryId" => _categoryId, "itemId" => _itemId} = categoryAndItemId,
        socket
      ) do
    Elmfolio.Portfolio.Server
    |> GenServer.call({:like_item, categoryAndItemId})
    |> push_like_item_response(socket)

    {:noreply, socket}
  end

  def handle_in(
        "unlike_item",
        %{"categoryId" => _categoryId, "itemId" => _itemId} = categoryAndItemId,
        socket
      ) do
    Elmfolio.Portfolio.Server
    |> GenServer.call({:unlike_item, categoryAndItemId})
    |> push_like_item_response(socket)

    {:noreply, socket}
  end

  defp push_like_item_response({code, response}, socket) do
    broadcast!(socket, "get_items", %{
      code: code,
      response: response
    })
  end

  defp respond({200, items}, socket) do
    broadcast!(socket, "get_items", %{code: 200, response: items})
    {:noreply, socket}
  end

  defp respond({_, items}, socket) do
    broadcast!(socket, "get_items", %{code: 500, response: items})
    {:noreply, socket}
  end
end
