main = ws Events ws

/********** HELPERS *******************/

ws = [ \n\r\t\v\uFEFF]* { return text(); }

identifier = [a-z_$A-Z][a-z_$A-Z0-9]* { return text(); }

integer = '-'?[0-9]+ { return parseInt(text(), 10); }

/********** SYNTAX ********************/

Events = h:Flow t:(ws ',' ws Flow)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[3]);
  return { type: 'events', list: list };
}

Flow = h:Value t:(ws ('|' / '|=') ws Value)* {
  var list = [h];
  for (var i = 0; i < t.length; i++) list.push(t[3]);
  return { type: 'flow', list: list };
}

Value = Value_Compound / Value_Simple

Value_Compound = Value_Simple ws Operator ws Value

Value_Simple = Path / Field / Production / Group / Builtin / Primitive / Dot

Dot = '.' { return { type: 'dot' } }

Path = l:('.' identifier)+ {
  var list = [];
  for (var i = 0; i < l.length; i++) list.push(l[1]);
  return { type: 'path', list: list };
}

Field = '.[' ws f:(Field_Offset / Field_Name / Field_Range) ws ']' {
  return f;
}

Field_Offset = o:integer {
  return { type: 'field-offset', offset: o };
}

Field_Name = s:JSON_String {
  return { type: 'field-name', name: s };
}

Field_Range = b:integer ':' e:integer {
  return { type: 'field-range', range: { begin: b, end: e } };
}

Production = Production_Array / Production_Object

Production_Array = '[' ws e:Events ws ']' {
  return { type: 'production-array', elements: e };
}

Production_Object = '{' /* TODO */ '}' {
  /* TODO */
}

Group = '(' ws v:Value ws ')' {
  return v;
}

Builtin = Function

Primitive = JSON_String / JSON_Number / JSON_Boolean / JSON_Null

Dot = '.' { return { type: 'dot' } }

Operator = /* TODO */

/********** BUILTINS ******************/

/********** JSON **********************/

/********** REGEXP ********************/

