# Swift ReqIFCompiler

## Funktionen
- Implementierung eines Recursive-Descent-Parsers in Swift.
- Analyse von Eingaben anhand unten beschriebener Grammatik.
- Erzeugung eines abstrakten Syntaxbaums (AST) als Ergebnis der Analyse.

## Was ist ReqIF?
Das ReqIF-Format (Requirements Interchange Format) ist ein standardisiertes Dateiformat für den Austausch von Anforderungen zwischen verschiedenen Anforderungsmanagement-Tools. Es wurde vom Object Management Group (OMG) entwickelt und ist in der Spezifikation [Requirements Interchange Format (ReqIF)](https://www.omg.org/spec/ReqIF/1.2/PDF) definiert.

## ReqIF Grammatik
Es handelt sich dabei um eine stark vereinfachte Variante des ReqIF Formats.
```
S → <spec_object> CONTENT </spec_object>
CONTENT → <values> VCONTENT </values> <type> TCONTENT </type>
VCONTENT → <attribute-value-string> AVSCONTENT </attribute-value-string> VCONTENT
TCONTENT → <spec-object-ref-type> </spec-object-ref-type>
AVSCONTENT → <definition> DCONTENT </definition>
DCONTENT → <attribute-definition-string-ref> </attribute-definition-string-ref>
```

## FIRST & FOLLOW Mengen
Die nachfolgende Tabelle gibt die FIRST & FOLLOW Mengen für die oben beschriebene Grammatik an.
Dabei sind **S**, **CONTENT**, **VCONTENT**, **TCONTENT**, **AVSCONTENT**, **DCONTENT** die Nichtterminale.

|              | ε-ableitbar? | FIRST                         | FOLLOW  |
|--------------|--------------|-------------------------------|----------|
| S            | Nein         | ```<spec_object>```           | ```$```   |
| CONTENT      | Nein         | ```<values>```                | ```</spec_object>```   |
| VCONTENT     | Nein         | ```<attribute-value-string>```| ```<attribute-value-string>, </values>```   |
| TCONTENT     | Nein         | ```<spec-object-ref-type>```  | ```</type>```   |
| AVSCONTENT   | Nein         | ```<definition>```            | ```</attribute-value-string>```   |
| DCONTENT     | Nein         | ```<attribute-definition-string-ref>```   | ```</definition>```   |

## Beispiel

Input:
````
<SPEC-OBJECT IDENTIFIER="_fdb3b9c524293d8db815f37a0cfe702b" LAST-CHANGE="2023-04-14T18:26:07">
    <VALUES>
        <ATTRIBUTE-VALUE-STRING THE-VALUE="headline">
            <DEFINITION>
                <ATTRIBUTE-DEFINITION-STRING-REF>_725727464b9438ec9e7c29b54be86be7</ATTRIBUTE-DEFINITION-STRING-REF>
            </DEFINITION>
        </ATTRIBUTE-VALUE-STRING>
        <ATTRIBUTE-VALUE-STRING THE-VALUE="">
            <DEFINITION>
                <ATTRIBUTE-DEFINITION-STRING-REF>_15e0b45774a13dd98e91c63c19626f96</ATTRIBUTE-DEFINITION-STRING-REF>
            </DEFINITION>
        </ATTRIBUTE-VALUE-STRING>
    </VALUES>
    <TYPE>
        <SPEC-OBJECT-TYPE-REF>_4638af0928883542b467fc2c70bb89bc</SPEC-OBJECT-TYPE-REF>
    </TYPE>
</SPEC-OBJECT>
````

Output:
```
ASTNode(value: __lldb_expr_1.Token.ROOT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.SPEC_OBJECT("_fdb3", true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.CONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.VALUES(true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.VCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_VALUE_STRING("headline", true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.AVSCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.DEFINITION(true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.DCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_DEFINITION_STRING_REF("_7257", true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_DEFINITION_STRING_REF("", false), children: [])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.DEFINITION(false), children: [])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_VALUE_STRING("", false), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.VCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_VALUE_STRING("", true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.AVSCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.DEFINITION(true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.DCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_DEFINITION_STRING_REF("_15e0", true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_DEFINITION_STRING_REF("", false), children: [])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.DEFINITION(false), children: [])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ATTRIBUTE_VALUE_STRING("", false), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.ERROR, children: [])])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.VALUES(false), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.TYPE(true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.TCONTENT, children: [__lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.SPEC_OBJECT_TYPE_REF("_4638", true), children: []), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.SPEC_OBJECT_TYPE_REF("", false), children: [])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.TYPE(false), children: [])]), __lldb_expr_1.ASTNode(value: __lldb_expr_1.Token.SPEC_OBJECT("", false), children: [])])
```