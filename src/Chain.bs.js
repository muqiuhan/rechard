// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Block = require("./Block.bs.js");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");

var main_chain = {
  contents: [Block.genesis]
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
  return Block.create(index, previous_hash, timestamp, data, Block.calculate_hash(index, previous_block.hash, timestamp, data));
}

function valid_gensis(chain) {
  return Belt_Option.eq(JSON.stringify(Belt_Array.get(chain, 0)), JSON.stringify(Block.genesis), (function (original_genesis, new_genesis) {
                return original_genesis === new_genesis;
              }));
}

function valid(chain) {
  if (!valid_gensis(chain)) {
    return false;
  }
  var temp_chain = [Belt_Option.getExn(Belt_Array.get(chain, 0))];
  return Belt_Array.every2(chain, temp_chain, (function (b1, b2) {
                if (Block.valid(b1, b2)) {
                  temp_chain.push(b1);
                  return true;
                } else {
                  return false;
                }
              }));
}

function replace(new_chain) {
  if (valid(new_chain) && new_chain.length > main_chain.contents.length) {
    console.log("Received blockchain is valid. Replacing current blockchain with received blockchain");
    main_chain.contents = new_chain;
  } else {
    console.log("Received blockchain invalid");
  }
}

function add(new_block) {
  if (Block.valid(new_block, get_latest(undefined))) {
    main_chain.contents.push(new_block);
    return ;
  }
  
}

exports.main_chain = main_chain;
exports.get_latest = get_latest;
exports.generate = generate;
exports.valid_gensis = valid_gensis;
exports.valid = valid;
exports.replace = replace;
exports.add = add;
/* Block Not a pure module */