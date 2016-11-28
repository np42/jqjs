'use strict';

module.exports = function (selector, options) {
  const ast = parser.parse(selector);
  return new Processor(builtins, ast, options);
};

const Processor = function (builtins, ast, options) {
  this.builtins = builtins;
  this.ast = ast;
  this.options = options || {};
  if (this.options.methods == null) this.options.methods = {};
};

Processor.prototype.first = function (data) {
  var result = this.exec(data);
  if (result != null && result.length > 0) return result[0];
  return null;
};

Processor.prototype.exec = function (data) {
  return this._execute(this.ast, data);
};

Processor.prototype._execute = function (ast, data) {
  if (('__' + ast.type) in this)
    return this['__' + ast.type](ast, data);
  console.log('Unknown ast:', ast);
  process.exit();
};

Processor.prototype._type = function (data) {
  const objtype = Object.prototype.toString.call(data);
  return objtype.substring(8, objtype.length - 1).toLowerCase();
};

Processor.prototype.__EMPTY__ = new function () {};

Processor.prototype.__events = function (ast, data) {
  const result = [];
  for (var i = 0; i < ast.list.length; i++) {
    var value = this._execute(ast.list[i], data);
    if (value === this.__EMPTY__) continue ;
    result.push(value);
  }1
  return result;
};

Processor.prototype.__flow = function (ast, data) {
  var result = data;
  for (var i = 0; i < ast.list.length; i++)
    result = this._execute(ast.list[i], result);
  return result;
};

Processor.prototype.__evaluation = function (ast, data) {
  if (this.options.methods.hasOwnProperty(ast.func)) {
    console.log('TODO: permit custom functions');
    process.exit();
  } else if (this.builtins.hasOwnProperty(ast.func)) {
    const args = [data];
    for (var i = 0; i < ast.args.length; i++)
      args.push(this._execute(ast.args[i], data));
    return this.builtins[ast.func].apply(this, args);
  } else {
    throw new Error('Unknown function: ' + ast.func);
  }
};

Processor.prototype.__lambda = function (ast, data) {
  return ast.value;
};

