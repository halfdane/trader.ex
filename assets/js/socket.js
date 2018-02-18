// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.
let candleContainer = document.querySelector("#candle")
let candle_date_time = document.querySelector("#candle_date_time")
let candle_high_price = document.querySelector("#candle_high_price")
let candle_low_price = document.querySelector("#candle_low_price")
let candle_open_price = document.querySelector("#candle_open_price")
let candle_close_price = document.querySelector("#candle_close_price")

let order_buy_price = document.querySelector("#order_buy_price")
socket.connect()

// Now that you are connected, you can join channels with a topic:
let symbol = candleContainer.dataset.symbol;
let channel = socket.channel(`candle:${symbol}`, {})

channel.on("candle_update", candle => {
  const date = new Date(candle.event_time)

  candle_date_time.innerText = `${date.toLocaleDateString('de-DE')} ${date.toLocaleTimeString('de-DE')}`
  candle_high_price.innerText = candle.high_price
  candle_low_price.innerText = candle.low_price
  candle_open_price.innerText = candle.open_price
  candle_close_price.innerText = candle.close_price

  order_buy_price.value = candle.low_price
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
