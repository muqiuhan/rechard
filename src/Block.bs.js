// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Int32 = require("rescript/lib/js/int32.js");
var $$String = require("rescript/lib/js/string.js");
var CryptoJs = require("crypto-js");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");

var Crypto_JS = {};

function create(index, previous_hash, timestamp, data, hash) {
  return {
          index: index,
          previous_hash: previous_hash,
          timestamp: timestamp,
          data: data,
          hash: hash
        };
}

function calculate_hash(index, previous_hash, timestamp, data) {
  var index$1 = Int32.to_string(index);
  var timestamp$1 = Int32.to_string(timestamp);
  return CryptoJs.SHA256($$String.concat("-", {
                  hd: index$1,
                  tl: {
                    hd: previous_hash,
                    tl: {
                      hd: timestamp$1,
                      tl: {
                        hd: data,
                        tl: /* [] */0
                      }
                    }
                  }
                }));
}

var genesis = {
  index: 0,
  previous_hash: "0",
  timestamp: 1465154705,
  data: "my genesis block!!",
  hash: "816534932c2b7154836da6afc367695e6337db8a921823784c14378abed4f7d7"
};

function calculate_hash_for(block) {
  return calculate_hash(block.index, block.previous_hash, block.timestamp, block.data);
}

function valid(new_block, previous_block) {
  var new_block_hash = calculate_hash_for(new_block);
  if ((previous_block.index + 1 | 0) !== new_block.index) {
    console.log("invalid index");
    return false;
  } else if (previous_block.hash !== new_block.previous_hash || previous_block.hash !== new_block.previous_hash) {
    console.log("invalid previous hash");
    return false;
  } else if (new_block_hash !== new_block.hash) {
    console.log("invalid hash: " + new_block_hash + " <-> " + new_block.hash);
    return false;
  } else {
    return true;
  }
}

var Block = {
  create: create,
  calculate_hash: calculate_hash,
  genesis: genesis,
  calculate_hash_for: calculate_hash_for,
  valid: valid
};

var Http_Server = {};

var main_chain = {
  contents: [genesis]
};

function get_latest(param) {
  var chain = main_chain.contents;
  return Belt_Option.getExn(Belt_Array.get(chain, chain.length - 1 | 0));
}

function generate(data) {
  var previous_block = get_latest(undefined);
  var index = previous_block.index + 1 | 0;
  var timestamp = (new Date().getTime() | 0) / 1000 | 0;
  var previous_hash = previous_block.hash;
  return create(index, previous_hash, timestamp, data, calculate_hash(index, previous_block.hash, timestamp, data));
}

function valid_gensis(chain) {
  return Belt_Option.eq(JSON.stringify(Belt_Array.get(chain, 0)), JSON.stringify(genesis), (function (original_genesis, new_genesis) {
                return original_genesis === new_genesis;
              }));
}

function valid$1(chain) {
  if (!valid_gensis(chain)) {
    return false;
  }
  var temp_chain = [Belt_Option.getExn(Belt_Array.get(chain, 0))];
  return Belt_Array.every2(chain, temp_chain, (function (b1, b2) {
                if (valid(b1, b2)) {
                  temp_chain.push(b1);
                  return true;
                } else {
                  return false;
                }
              }));
}

function replace(new_chain) {
  if (valid$1(new_chain) && new_chain.length > main_chain.contents.length) {
    console.log("Received blockchain is valid. Replacing current blockchain with received blockchain");
    main_chain.contents = new_chain;
  } else {
    console.log("Received blockchain invalid");
  }
}

exports.Crypto_JS = Crypto_JS;
exports.Block = Block;
exports.Http_Server = Http_Server;
exports.main_chain = main_chain;
exports.get_latest = get_latest;
exports.generate = generate;
exports.valid_gensis = valid_gensis;
exports.valid = valid$1;
exports.replace = replace;
/* crypto-js Not a pure module */