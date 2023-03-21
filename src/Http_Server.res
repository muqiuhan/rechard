/// The MIT License (MIT)
///
/// Copyright (c) 2022 Muqiu Han
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/// The user must be able to control the node in some way. This is done by setting up a HTTP server.

open Belt
open Third_Party

type socket = {
  remote_addr: string,
  remote_port: string,
}

let http_port = 3001

let sockets: array<socket> = []

let connect = peers => {
  Array.forEach(peers, _ => {
    ()
  })
}

/// The user is able to interact with the node in the following ways:
///   - List all blocks
///   - Create a new block with a content given by the user
///   - List or add peers
let init = () => {
  let app = Express.express()
  Express.use(app, Body_Parser.json)

  Express.get(app, "/chain", (_, response) => {
    Express.send(response, Js.Json.stringifyAny(Chain.main_chain)) |> ignore
  })

  Express.post(app, "/mine", (request, response) => {
    let new_block = Chain.generate(Express.body(request))
    Chain.add(new_block)
    // broadcast(response_last_msg())
    Js.log("Block added" ++ Option.getExn(Js.Json.stringifyAny(new_block)))
    Express.send(response, ()) |> ignore
  })

  Express.get(app, "/peers", (_, response) => {
    Express.send(
      response,
      Array.map(sockets, socket => {socket.remote_addr ++ ":" ++ socket.remote_port}),
    ) |> ignore
  })

  Express.post(app, "/add_peer", (_request, response) => {
    /// connect([Express.body(request).peer])
    Express.send(response, ()) |> ignore
  })

  Js.log("Listening http on port: " ++ Int.toString(http_port))
  Express.listen(app, http_port)
}
