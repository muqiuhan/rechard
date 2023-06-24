open Third_Party

type t = {
  /// The height of the block in the blockchain
  index: int,
  /// A reference to the hash of the previous block. This value explicitly defines the previous block.
  previous_hash: string,
  /// A timestamp
  timestamp: int,
  /// Any data that is included in the block.
  data: string,
  /// A sha256 hash taken from the content of the block
  hash: string,
}

/// Create a block
let create = (~index, ~previous_hash, ~timestamp, ~data, ~hash) => {
  index,
  previous_hash,
  timestamp,
  data,
  hash,
}

let calculate_hash = (~index, ~previous_hash, ~timestamp, ~data) => {
  let index = Int32.to_string(index)
  let timestamp = Int32.to_string(timestamp)

  list{index, previous_hash, timestamp, data}
  ->(block_str => String.concat("-", block_str))
  ->Crypto_JS.sha256
}

/// Genesis block is the first block in the blockchain.
/// It is the only block that has no previousHash.
/// Hard code the genesis block to the source code:
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
  calculate_hash(
    ~index=block.index,
    ~previous_hash=block.previous_hash,
    ~timestamp=block.timestamp,
    ~data=block.data,
  )
}

/// At any given time we must be able to validate if a block or a chain of blocks are valid in terms of integrity.
/// For a block to be valid the following must apply:
///  1. The index of the block must be one number larger than the previous
///  2. The previousHash of the block match the hash of the previous block
///  3. The hash of the block itself must be valid
let valid = (new_block: t, previous_block: t) => {
  if previous_block.index + 1 !== new_block.index {
    Js.Console.error("invalid index")
    false
  } else if previous_block.hash !== previous_block.hash {
    Js.Console.error("invalid previous hash")
    false
  } else if calculate_hash_for(new_block) !== new_block.hash {
    Js.Console.error("invalid hash: " ++ calculate_hash_for(new_block) ++ "!==" ++ new_block.hash)
    false
  } else {
    true
  }
}
