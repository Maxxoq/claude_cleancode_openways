module.exports = function exportCsv(rows) {
  return rows.map((r) => r.join(',')).join('\n');
};
