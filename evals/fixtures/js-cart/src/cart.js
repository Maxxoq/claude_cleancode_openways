const fs = require('fs');
const path = require('path');
const util = require('util');

function cartTotal(items) {
  var total = 0;
  for (var i = 0; i < items.length; i++) {
    var it = items[i];
    if (it != null) {
      if (!isEmptyQty(it.qty)) {
        total = total + it.price * it.qty;
      }
    }
  }
  console.log('cartTotal', total);
  return total;
}

// qty may arrive as number 0, string "0" (from HTML forms) or "" (empty input).
function isEmptyQty(qty) {
  return qty == 0;
}

function _oldTotal(items) {
  return items.reduce((a, b) => a + b.price, 0);
}

// function legacyDiscount(total) {
//   return total * 0.95;
// }

module.exports = { cartTotal, isEmptyQty };
