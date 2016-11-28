{
  var mkfunc = function (name) {
    return { type: 'evaluation', func: name, args: Array.prototype.slice.call(arguments, 1) }
  };

  var mkfuncArgs = function (name, args) {
    return { type: 'evaluation', func: name, args: args }
  };

  var lmb = function (value) {
    return { type: 'lambda', value: value };
  };
}

main = ws r:Events ws { return r; }

/********** HELPERS *******************/

space = [ \n\r\t\v\uFEFF]+ { return text(); }

ws = [ \n\r\t\v\uFEFF]* { return text(); }

digit = [0-9]

identifier = [a-z_$A-Z][a-z_$A-Z0-9]* { return text(); }

integer = '-'?[0-9]+ { return parseInt(text(), 10); }

hex = [0-9a-fA-F]

/********** SYNTAX ********************/

Events = h:Flow t:(ws ',' ws Flow)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[i][3]);
  return { type: 'events', list: list };
}

Flow = h:Value t:(ws ('|' / '|=') ws Value)* {
  if (t.length == 0) return h;
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[i][3]);
  return { type: 'flow', list: list };
}

Value = Value_Compound / Value_Simple

Value_Compound = a:Value_Simple ws f:Operator ws b:Value {
  return { type: 'evaluation', func: f, args: [a, b] }
}

Value_Simple = Path / Field / Production / Evaluation / Condition / Function / Primitive / Dot

Path = l:('.' identifier)+ {
  var list = [];
  for (var i = 0; i < l.length; i++) list.push(l[i][1]);
  return mkfunc('_path', lmb(list));
}

Field = '.[' ws f:(Field_Offset / Field_Name / Field_Range) ws ']' { return f; }

Field_Offset = o:integer { return mkfunc('_field_offset', o); }
Field_Name = s:JSON_String { return mkfunc('_field_name', s); }
Field_Range = b:integer ':' e:integer { return mkfunc('_field_range', b, e); }

Production = Production_Array / Production_Object

Production_Array = '[' ws e:Events ws ']' { return mkfunc('_production_array', e); }
Production_Object = '{' ws e:Object_Values ws '}' { return mkfunc('_production_object', e); }

Object_Values = h:Object_Value t:(ws ',' ws Object_Value)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[i][3]);
  return list;
}

Object_Value = k:Object_Key ws ':' v:Flow { return { key: k, value: v }; }
             / k:Object_Key { return { key: k, value: { type: 'path', list: [k] } }; }
             / k:Evaluation ws ':' v:Flow { return { key: k, value: v }; }

Object_Key = identifier / JSON_String

Evaluation = '(' ws v:Flow ws ')' { return v; }

Condition = 'if' space c:Flow space 'then' space t:Flow space 'else' space o:Flow space 'end' {
  return mkfunc('_condition', c, t, o);
}

Primitive = v:(JSON_String / JSON_Number / JSON_Primitives) { return lmb(v); }

Dot = '.' { return mkfunc('_identity'); }

Operator = '//' { return '_alternative' }
         / '+' { return '_operator_plus' }
         / '-' { return '_operator_minus' }
         / '*' { return '_operator_multiply' }
         / '/' { return '_operator_divide' }
         / '%' { return '_operator_modulo' }
         / '<' { return '_comparison_less' }
         / '<=' { return '_comparison_less_or_equal' }
         / '>' { return '_comparison_more' }
         / '>=' { return '_comparison_more_or_equal' }
         / '==' { return '_comparison_equal' }
         / '!=' { return '_comparison_not_equal' }
         / 'and' { return '_comparison_and' }
         / 'or' { return '_comparison_or' }

/********** BUILTINS ******************/

Function = Function_WithArgs
         / Function_WithLambdas
         / Function_WithoutArgs

Function_WithArgs
  = f:'has' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'in' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'getpath' ws '(' ws a:Events ws ')' { return mkfuncArgs(f, a.list); }
  / f:'setpath' ws '(' ws a:Events ws ';' ws b:Flow ws ')' { return mkfunc(f, a.list, b); }
  / f:'flatten' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'range' ws '(' ws a:Flow ws ';' ws b:Flow ws ';' ws c:Flow ws ')' { return mkfunc(f, a, b, c); }
  / f:'range' ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfunc(f, a, b); }
  / f:'range' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'indices' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'index' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'rindex' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'startswith' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'endswith' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'combinations' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'ltrimstr' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'rtrimstr' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'split' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'join' ws '(' ws a:Flow ws ')' { return mkfunc(f, a); }
  / f:'test' ws '(' ws a:RegExp ws ')' { return mkfunc(f, a); }
  / f:'match' ws '(' ws a:RegExp ws ')' { return mkfunc(f, a); }
  / f:'sub' ws '(' ws a:RegExp ws ';' ws b:Flow ws ')' { return mkfunc(f, a, b); }

Function_WithLambdas
  = f:'map' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'map_values' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'path' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'del' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'with_entries' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'select' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'paths' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:('any' / 'all') ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfunc(f, lmb(a), lmb(b)); }
  / f:('any' / 'all') ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'sort_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'group_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'min_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'max_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'unique_by' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'while' ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfunc(f, lmb(a), lmb(b)); }
  / f:'until' ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfunc(f, lmb(a), lmb(b)); }
  / f:'recurse' ws '(' ws a:Flow ws ';' ws b:Flow ws ')' { return mkfunc(f, lmb(a), lmb(b)); }
  / f:'recurse' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }
  / f:'walk' ws '(' ws a:Flow ws ')' { return mkfunc(f, lmb(a)); }

Function_WithoutArgs
  = ( 'length' / 'utf8bytelength'
    / 'keys' / 'keys_unsorted'
    / 'to_entries' / 'from_entries'
    / 'arrays' / 'objects' / 'iterables' / 'booleans' / 'numbers'
    / 'normals' / 'finites' / 'strings' / 'nulls' / 'values' / 'scalars'
    / 'empty' / 'not'
    / 'paths' / 'leaf_paths'
    / 'add' / 'any' / 'all'
    / 'flatten' / 'reverse'
    / 'floor' / 'sqrt'
    / 'tonumber' / 'tostring' / 'type' / 'tojson' / 'fromjson'
    / 'infinite' / 'nan' / 'isinfinite' / 'isnan' / 'isfinite' / 'isnormal'
    / 'sort' / 'min' / 'max' / 'unique'
    / 'combinations' / 'explode' / 'implode'
    / 'ascii_downcase' / 'ascii_upcase'
    / 'recurse' / 'recurse_down' / '..'
    / 'transpose'
    ) { return mkfunc(text()); }

/********** JSON **********************/

JSON = JSON_Value { return text(); }

JSON_Object = '{' ws JSON_Object_fields? ws '}'

JSON_Object_fields = JSON_Object_field ws (',' ws JSON_Object_field ws)*

JSON_Object_field = JSON_String ws ':' ws JSON_Value

JSON_Array = '[' ws JSON_Array_values? ws ']'

JSON_Array_values = JSON_Value ws (',' ws JSON_Value ws)*

JSON_Value = JSON_Primitives / JSON_Number / JSON_String / JSON_Array / JSON_Object

JSON_String = '"' JSON_Character* '"' { return JSON.parse(text()); }

JSON_Character = JSON_Character_unicode / JSON_Character_escaped

JSON_Character_unicode = !'\n' [^\\"]

JSON_Character_escaped = '\\' (["\\/bfnrt] / ('u' hex hex hex hex))

JSON_Number = '-' ? JSON_Number_digit JSON_Number_decimal ? JSON_Number_tenp ? {
  return parseInt(text(), 10);
}

JSON_Number_digit = '0' / ([1-9] digit*)

JSON_Number_decimal = '.' digit+

JSON_Number_tenp = [eE] ('+' / '-') ? digit+

JSON_Primitives = 'null' / 'false' / 'true'

/********** REGEXP ********************/

RegExp = '/' s:(RegExp_character) + '/' f:RegExp_flag ?
  { return { source: s.join(''), flag: f }; }

RegExp_character = [^/] / '\\\\' / '\\/'

RegExp_flag
  = ( 'gim' / 'gmi' / 'img' / 'igm' / 'mig' / 'mgi'
    / 'gi' / 'gm' / 'im' / 'ig' / 'mi' / 'mg'
    / 'g' / 'i' / 'm'
    )
  { return text(); }
