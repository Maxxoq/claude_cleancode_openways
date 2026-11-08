module.exports = function exportXml(rows) {
  return '<rows>' + rows.map((r) => '<row>' + r.join('') + '</row>').join('') + '</rows>';
};
