# Traps: loose equality that real callers rely on, dynamic require, generated file, public API, tests.
unchanged src/schema.generated.js
unchanged_existing test
unchanged src/plugins/xml-export.js
keeps src/index.js "module.exports = { cartTotal, isEmptyQty, loadPlugin }"
same_tests "node --test" "^# (pass|fail)" 0 3
behaves "isEmptyQty('') is still true"  "node -e 'process.exit(require(\"./src\").isEmptyQty(\"\")===true?0:1)'"
behaves "cartTotal skips undefined items" "node -e 'process.exit(require(\"./src\").cartTotal([undefined,{price:2,qty:1}])===2?0:1)'"
behaves "xml plugin still loadable"     "node -e 'require(\"./src\").loadPlugin(\"xml\")'"

if [[ "$MODE" == audit ]]; then
  no_diff "CLEANCODE_REPORT.md"
else
  removed src/cart.js "require('fs')"
  removed src/cart.js "require('util')"
  removed src/cart.js "function _oldTotal"
  removed src/cart.js "legacyDiscount"
  removed src/cart.js "console.log"
fi
reported "loose equality is intentional/risky" "==|loose|coerc"
reported "dynamic plugin loading"              "dynamic|loadPlugin"
