const test = require('node:test');
const assert = require('node:assert');
const { cartTotal, isEmptyQty, loadPlugin } = require('../src');

test('total', () => {
  assert.strictEqual(cartTotal([{ price: 10, qty: 2 }, null, { price: 5, qty: '0' }]), 20);
});

test('empty qty accepts form values', () => {
  assert.strictEqual(isEmptyQty(0), true);
  assert.strictEqual(isEmptyQty('0'), true);
  assert.strictEqual(isEmptyQty(''), true);
  assert.strictEqual(isEmptyQty(3), false);
});

test('csv plugin', () => {
  assert.strictEqual(loadPlugin('csv')([[1, 2], [3, 4]]), '1,2\n3,4');
});
