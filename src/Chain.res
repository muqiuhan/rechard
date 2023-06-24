open Belt

type t = array<Block.t>

/// A in-memory Javascript array is used to store the blockchain.
let main_chain = ref([Block.genesis])

/// Get latest block
let get_latest = () => {
  let chain = main_chain.contents
  chain[Array.length(chain) - 1] |> Option.getExn
}

/// To generate a block we must know the hash of the previous block
/// and create the rest of the required content.
let generate = data => {
  let previous_block: Block.t = get_latest()
  let index = previous_block.index + 1
  let timestamp = Js.Date.make()->Js.Date.getTime->Int32.of_float->(timestamp => timestamp / 1000)
  let previous_hash = previous_block.hash

  Block.create(
    ~index,
    ~previous_hash,
    ~timestamp,
    ~data,
    ~hash=Block.calculate_hash(~index, ~previous_hash=previous_block.hash, ~timestamp, ~data),
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

let add = new_block => {
  if Block.valid(new_block, get_latest()) {
    Array.push(main_chain.contents, new_block)
  }
}
