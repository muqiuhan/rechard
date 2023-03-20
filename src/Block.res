open Belt

module Crypto_JS = {
  /// The block needs to be hashed to keep the integrity of the data.
  /// A SHA-256 is taken over the content of the block:
  @module("crypto-js") external sha256: string => string = "SHA256"
}

module Block = {
  /// To keep things as simple as possible we include only the most necessary:
  /// index, timestamp, data, hash and previous hash.
  type t = {
    index: int,
    previous_hash: string,
    timestamp: int,
    data: string,
    hash: string,
  }

  let create = (index, previous_hash, timestamp, data, hash) => {
    index,
    previous_hash,
    timestamp,
    data,
    hash,
  }

  /// It should be noted that this hash has nothing to do with “mining”,
  /// since there is no Proof Of Work problem to solve.
  let calculate_hash = (index, previous_hash, timestamp, data) => {
    let index = Int32.to_string(index)
    let timestamp = Int32.to_string(timestamp)

    list{index, previous_hash, timestamp, data}
    |> (block_str => String.concat("-", block_str))
    |> Crypto_JS.sha256
  }

  /// The first block of the blockchain is always a so-called “genesis-block”, which is hard coded.
  let genesis = {
    {
      index: 0,
      previous_hash: "0",
      timestamp: 1465154705,
      data: "my genesis block!!",
      hash: "816534932c2b7154836da6afc367695e6337db8a921823784c14378abed4f7d7",
    }
  }

  let calculate_hash_for = block => {
    calculate_hash(block.index, block.previous_hash, block.timestamp, block.data)
  }

  /// At any given time we must be able to validate if a block or a chain of blocks are valid in terms of integrity.
  /// This is true especially when we receive new blocks from other nodes and must decide whether to accept them or not.
  let valid = (new_block, previous_block) => {
    let new_block_hash = calculate_hash_for(new_block)

    if previous_block.index + 1 !== new_block.index {
      Js.log("invalid index")
      false
    } else if previous_block.hash !== new_block.previous_hash {
      Js.log("invalid previous hash")
      false
    } else if previous_block.hash !== new_block.previous_hash {
      Js.log("invalid previous hash")
      false
    } else if new_block_hash !== new_block.hash {
      Js.log("invalid hash: " ++ new_block_hash ++ " <-> " ++ new_block.hash)
      false
    } else {
      true
    }
  }
}

module Http_Server = {

}

type t = array<Block.t>

/// A in-memory Javascript array is used to store the blockchain.
let main_chain = ref([Block.genesis])

/// Get latest block
let get_latest = () => {
  let chain = main_chain.contents
  chain[Array.length(chain) - 1] |> Option.getExn
}

/// To generate a block we must know the hash of the previous block and create the rest of the required content
/// (= index, hash, data and timestamp). Block data is something that is provided by the end-user.
let generate = data => {
  let previous_block: Block.t = get_latest()
  let index = previous_block.index + 1
  let timestamp =
    Js.Date.make() |> Js.Date.getTime |> Int32.of_float |> (timestamp => timestamp / 1000)
  let previous_hash = previous_block.hash

  Block.create(
    index,
    previous_hash,
    timestamp,
    data,
    Block.calculate_hash(index, previous_block.hash, timestamp, data),
  )
}

/// Determine whether the genesis block is the same
let valid_gensis = chain => {
  Option.eq(Js.Json.stringifyAny(chain[0]), Js.Json.stringifyAny(Block.genesis), (
    original_genesis,
    new_genesis,
  ) => {
    original_genesis === new_genesis
  })
}

let valid = (chain: t) => {
  if valid_gensis(chain) {
    let temp_chain: t = [Option.getExn(chain[0])]
    Array.every2(chain, temp_chain, (b1, b2) => {
      if Block.valid(b1, b2) {
        Array.push(temp_chain, b1)
        true
      } else {
        false
      }
    })
  } else {
    false
  }
}

/// There should always be only one explicit set of blocks in the chain at a given time.
/// In case of conflicts we choose the chain that has the longest number of blocks.
let replace = new_chain => {
  if valid(new_chain) && Array.length(new_chain) > Array.length(main_chain.contents) {
    Js.log("Received blockchain is valid. Replacing current blockchain with received blockchain")
    main_chain := new_chain
    // broadcast(response_latest_msg())
  } else {
    Js.log("Received blockchain invalid")
  }
}
