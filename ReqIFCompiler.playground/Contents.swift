import UIKit

enum Token{
    case ROOT //Nonterminal
    case CONTENT //Nonterminal
    case VCONTENT //Nonterminal
    case AVSCONTENT //Nonterminal
    case DCONTENT //Nonterminal
    case TCONTENT //Nonterminal
    case ERROR //Nonterminal
    case SPEC_OBJECT(String, Bool) //SPEC_OBJECT(value, isOpeningTag)
    case SPEC_OBJECT_TYPE_REF(String, Bool) //SPEC_OBJECT_TYPE_REF(Value, isOpeningTag)
    case VALUES(Bool) //VALUES(isOpeningTag)
    case TYPE(Bool) //TYPE(isOpeningTag)
    case ATTRIBUTE_VALUE_STRING(String, Bool) //ATTRIBUTE_VALUE_STRING(value,isOpeningTag)
    case DEFINITION(Bool) //DEFINITION(isOpeningTag)
    case ATTRIBUTE_DEFINITION_STRING_REF(String, Bool) //ATTRIBUTE_DEFINITION_STRING_REF(value,isOpeningTag)
}

struct ASTNode{
    var value: Token
    var children: [ASTNode]
}

class Lexer{
    let tokens: [Token]
    var counter = 0
    
    init(tokens: [Token]){
        self.tokens = tokens
    }
    
    func getNextToken() -> Token{
        let token = tokens[counter]
        counter += 1
        return token
    }
    
    func hasNextToken() -> Bool{
        if counter < tokens.count{
            return true
        }
        return false
    }
}

class Parser{
    var lexer: Lexer
    var lookahead: Token
    
    
    init(lexer: Lexer){
        self.lexer = lexer
        lookahead = lexer.getNextToken()
    }
    
    func advance(){
        if lexer.hasNextToken(){
            lookahead = lexer.getNextToken()
        }
    }
    
    func eat(_ e: Token) -> ASTNode{
        if tokensAreEqual(e, lookahead){
            advance()
        }else{
            print("Syntaxerror in eat(): \(e) != \(lookahead)")
        }
        return ASTNode(value: e,children: [])
    }
    func parse() -> ASTNode{
        // return AST from Startsymbol
        return S()
    }
    
    // S -> <spec_object> CONTENT </spec_object>
    func S() -> ASTNode{
        switch lookahead {
        case .SPEC_OBJECT(let specObjectValue, true):
            let child1 = eat(.SPEC_OBJECT(specObjectValue, true))
            let child2 = Content()
            let child3 = eat(.SPEC_OBJECT("", false))
            return ASTNode(value: Token.ROOT,children: [child1, child2, child3])
        default:
            print("Syntaxerror in S()")
        }
        
        return ASTNode(value: Token.ERROR, children: [])
    }
    
    /*
     CONTENT -> <values> VCONTENT </values> <type> TCONTENT </type>
                | ε
     */
    func Content() -> ASTNode{
        switch lookahead {
        case .VALUES(true):
            let child1 = eat(.VALUES(true))
            let child2 = VContent()
            let child3 = eat(.VALUES(false))
            let child4 = eat(.TYPE(true))
            let child5 = TContent()
            let child6 = eat(.TYPE(false))
            return ASTNode(value: Token.CONTENT, children: [child1, child2, child3, child4, child5, child6])
        case .SPEC_OBJECT(_, false):
            break
        default:
            print("Syntaxerror in Content()")
        }
        
        return ASTNode(value: Token.ERROR, children: [])
    }
    
    /*
     VCONTENT -> <attribute-value-string> AVSCONTENT </attribute-value-string> VCONTENT
                | ε
     */
    func VContent() -> ASTNode{
        switch lookahead {
        case .ATTRIBUTE_VALUE_STRING(let attributeValue, true):
            let child1 = eat(.ATTRIBUTE_VALUE_STRING(attributeValue, true))
            let child2 = AVSContent()
            let child3 = eat(.ATTRIBUTE_VALUE_STRING("", false))
            let child4 = VContent()
            return ASTNode(value: Token.VCONTENT, children: [child1, child2, child3, child4])
        case .VALUES(false):
            break
        default:
            print("Syntaxerror in VContent()")
        }
        
        return ASTNode(value: Token.ERROR, children: [])
    }
    
    // TCONTENT -> <spec-object-ref-type> </spec-object-ref-type>
    func TContent() -> ASTNode{
        switch lookahead {
        case .SPEC_OBJECT_TYPE_REF(let specObjectValue, true):
            let child1 = eat(.SPEC_OBJECT_TYPE_REF(specObjectValue, true))
            let child2 = eat(.SPEC_OBJECT_TYPE_REF("", false))
            return ASTNode(value: Token.TCONTENT, children: [child1, child2])
        default:
            print("Syntaxerror in TConent()")
        }
        
        return ASTNode(value: Token.ERROR, children: [])
    }
    
    // AVSCONTENT -> <definition> DCONTENT </definition>
    func AVSContent() -> ASTNode{
        switch lookahead {
        case .DEFINITION(true):
            let child1 = eat(.DEFINITION(true))
            let child2 = DContent()
            let child3 = eat(.DEFINITION(false))
            return ASTNode(value: Token.AVSCONTENT, children: [child1, child2, child3])
        default:
            print("Syntaxerror in AVSContent()")
        }
        
        return ASTNode(value: Token.ERROR, children: [])
    }
    
    // DCONTENT -> <attribute-definition-string-ref>  </attribute-definition-string-ref>
    func DContent() -> ASTNode{
        switch lookahead {
        case .ATTRIBUTE_DEFINITION_STRING_REF(let attributeValue, true):
            let child1 = eat(.ATTRIBUTE_DEFINITION_STRING_REF(attributeValue, true))
            let child2 = eat(.ATTRIBUTE_DEFINITION_STRING_REF("", false))
            return ASTNode(value: Token.DCONTENT, children: [child1, child2])
        default:
            print("Syntaxerror in DContent()")
        }
        
        return ASTNode(value: Token.ERROR, children: [])
    }
    
    func tokensAreEqual(_ token1: Token, _ token2: Token) -> Bool{
        switch (token1, token2){
        case (.SPEC_OBJECT(let token1Value, let token1Tag), .SPEC_OBJECT(let token2Value, let token2Tag)), // SPEC_OBJECT
             (.SPEC_OBJECT_TYPE_REF(let token1Value, let token1Tag), .SPEC_OBJECT_TYPE_REF(let token2Value, let token2Tag)), // SPEC_OBJECT_TYPE_REF
             (.ATTRIBUTE_VALUE_STRING(let token1Value, let token1Tag), .ATTRIBUTE_VALUE_STRING(let token2Value, let token2Tag)), // ATTRIBUTE_VALUE_STRING
             (.ATTRIBUTE_DEFINITION_STRING_REF(let token1Value, let token1Tag), .ATTRIBUTE_DEFINITION_STRING_REF(let token2Value, let token2Tag)): // ATTRIBUTE_DEFINITION_STRING_REF
            return (token1Value == token2Value) && (token1Tag == token2Tag)
        case (.VALUES(let token1Tag), .VALUES(let token2Tag)), // VALUES
             (.TYPE(let token1Tag), .TYPE(let token2Tag)), // TYPE
             (.DEFINITION(let token1Tag), .DEFINITION(let token2Tag)): // DEFINITION
            return token1Tag == token2Tag

        default:
            return false
        }
    }
}

// tokenized example
let tokens = [Token.SPEC_OBJECT("_fdb3", true), Token.VALUES(true), Token.ATTRIBUTE_VALUE_STRING("headline", true), Token.DEFINITION(true), Token.ATTRIBUTE_DEFINITION_STRING_REF("_7257", true), Token.ATTRIBUTE_DEFINITION_STRING_REF("", false), Token.DEFINITION(false), Token.ATTRIBUTE_VALUE_STRING("", false), Token.ATTRIBUTE_VALUE_STRING("", true), Token.DEFINITION(true), Token.ATTRIBUTE_DEFINITION_STRING_REF("_15e0", true), Token.ATTRIBUTE_DEFINITION_STRING_REF("", false), Token.DEFINITION(false), Token.ATTRIBUTE_VALUE_STRING("", false), Token.VALUES(false), Token.TYPE(true), Token.SPEC_OBJECT_TYPE_REF("_4638", true), Token.SPEC_OBJECT_TYPE_REF("", false), Token.TYPE(false), Token.SPEC_OBJECT("", false)]
let lexer = Lexer(tokens: tokens)
let parser = Parser(lexer: lexer)
let ast = parser.parse()
print(ast)

/*
Input:
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
 */

/*
Output:
ASTNode(value: __lldb_expr_88.Token.ROOT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.SPEC_OBJECT("_fdb3", true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.CONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.VALUES(true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.VCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_VALUE_STRING("headline", true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.AVSCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.DEFINITION(true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.DCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_DEFINITION_STRING_REF("_7257", true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_DEFINITION_STRING_REF("", false), children: [])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.DEFINITION(false), children: [])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_VALUE_STRING("", false), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.VCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_VALUE_STRING("", true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.AVSCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.DEFINITION(true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.DCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_DEFINITION_STRING_REF("_15e0", true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_DEFINITION_STRING_REF("", false), children: [])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.DEFINITION(false), children: [])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ATTRIBUTE_VALUE_STRING("", false), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.ERROR, children: [])])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.VALUES(false), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.TYPE(true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.TCONTENT, children: [__lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.SPEC_OBJECT_TYPE_REF("_4638", true), children: []), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.SPEC_OBJECT_TYPE_REF("", false), children: [])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.TYPE(false), children: [])]), __lldb_expr_88.ASTNode(value: __lldb_expr_88.Token.SPEC_OBJECT("", false), children: [])])
 */
