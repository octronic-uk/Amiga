README.md for the octronic 68k JSON parser.

The parser is implemented as a finite state machine.

Each element in the json string that to be parsed will create a JSON_ELEM data 
structure with the following data layout.

=====================+=======+========+=======================
 Name                | Width | Offset | Description
=====================+=======+========+=======================
JSON_ELEM_TYPE       | .w    | 0      | Element Type ID 
---------------------+-------+--------+-----------------------
JSON_ELEM_KEY        | .w    | 0      | index of key start
---------------------+-------+--------+-----------------------
JSON_ELEM_KEY_LEN    | .w    | 0      | length of key
---------------------+-------+--------+-----------------------
JSON_ELEM_VALUE      | .w    | 0      | index of value start
---------------------+-------+--------+-----------------------
JSON_ELEM_VALUE_LEN  | .w    | 0      | length of value
---------------------+-------+--------+-----------------------
JSON_ELEM_PARENT_PTR | .l    | 0      | Pointer to parent element, null if
                     |       |        | topmost element
---------------------+-------+--------+-----------------------
JSON_ELEM_NEXT_PTR   | .l    | 0      | Pointer to next sibling, or parent if 
                     |       |        | the element is at the end of list at the 
                     |       |        | current level
=====================+=======+========+=======================



; Types

This table describes the types that can be assigned to JSON elements.

===================+====+==============
 Type Name         | ID | Description
===================+====+==============
JSON_TYPE_INVALID  | 0  | Invalid Type
-------------------+----+--------------
JSON_TYPE_OBJECT   | 1  | Object Value
-------------------+----+--------------
JSON_TYPE_ARRAY    | 2  | Array Value
-------------------+----+--------------
JSON_TYPE_STRING   | 3  | String Value
-------------------+----+--------------
JSON_TYPE_BOOL     | 4  | Boolean Value
-------------------+----+--------------
JSON_TYPE_NULL     | 5  | Null Value
-------------------+----+--------------
JSON_TYPE_NUMBER   | 6  | Number Value
===================+====+==============

