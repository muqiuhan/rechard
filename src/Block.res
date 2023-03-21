open Third_Party

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