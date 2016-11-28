const pegjs = require('pegjs');
const fs    = require('fs');
const path  = require('path');

const pkg = require(path.join(__dirname, 'package.json'));

const parser_path = path.join(__dirname, 'lib/parser.pegjs');
const grammar = fs.readFileSync(parser_path).toString();
const options = { cache: false, format: 'commonjs', optimize: 'speed', output: 'source', trace: false };
const parser_str = pegjs.generate(grammar, options);

const sources = [ { source: parser_str, path: parser_path, name: 'parser' }
                , { path: path.join(__dirname, 'lib/builtins.js'), name: 'builtins' }
                , { path: path.join(__dirname, 'lib/index.js'), name: 'jq' }
                ];

const content = [];
content.push('(function (VERSION) {');
content.push('var __modules = {};');
for (var i = 0; i < sources.length; i++) {
  if (sources[i].name == null) continue ;
  var key = '__modules[' + JSON.stringify(sources[i].name) + ']';
  content.push('  ' + key + ' = { exports: {} };');
  content.push('  (function (module, __filename, __dirname) {');
  if (sources[i].source)
    content.push(sources[i].source);
  else
    content.push(fs.readFileSync(sources[i].path).toString());
  var _filename = JSON.stringify(sources[i].path.substr(__dirname.length + 1));
  var _dirname = JSON.stringify(path.dirname(sources[i].path.substr(__dirname.length + 1)));
  content.push('  })('+key+', '+_filename+', '+_dirname+');');
  content.push('  var ' + sources[i].name + ' = ' + key + '.exports;');
}
content.push('  if (typeof exports !== "undefined") {');
content.push('    if (typeof module !== "undefined" && module.exports) {');
content.push('      exports = module.exports = jq;');
content.push('    }');
content.push('    exports.jq = jq');
content.push('  } else {');
content.push('    this.jq = jq');
content.push('  }');
content.push('  if (typeof define === "function" && define.amd)');
content.push('    define("jq", [], function() { return jq; });');
content.push('}.call(this, "'+pkg.version+'"));');

const filename = 'jq-' + pkg.version + '.js';
const output = path.join(__dirname, 'dist', filename);
fs.writeFileSync(output, content.join('\n'));
const mainfile = path.join(__dirname, 'dist', 'jq.js');
if (fs.existsSync(mainfile)) fs.unlinkSync(mainfile);
fs.symlinkSync(filename, mainfile);
