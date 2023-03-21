module Crypto_JS = {
  /// The block needs to be hashed to keep the integrity of the data.
  /// A SHA-256 is taken over the content of the block:
  @module("crypto-js") external sha256: string => string = "SHA256"
}

module Body_Parser = {
  @module("body-parser") external json: 'a => 'b = "json"
}

module WebSocket = {
  @module("ws") external ws: 'a => 'b = "WebSocket"
}
