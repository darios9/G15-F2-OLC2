{{ /**************** GRAMATICA DE PRUEBAS **************/
    import {Token} from './compiler/Token.js';
    import {Error} from './compiler/Error.js';
    import { ids, usos} from '../index.js';
    import { ErrorReglas } from './error.js';
    import { errores } from '../index.js';
}}

gramatica = _ p:producciones+ _ {

    let duplicados = ids.filter((item, index) => ids.indexOf(item) !== index);
    if (duplicados.length > 0) {
        errores.push(new ErrorReglas("Regla duplicada: " + duplicados[0]));
    }

    // Validar que todos los usos están en ids
    let noEncontrados = usos.filter(item => !ids.includes(item));
    if (noEncontrados.length > 0) {
        errores.push(new ErrorReglas("Regla no encontrada: " + noEncontrados[0]));
    }
    return new Token("gramatica", {producciones: p}, location.start.line, location.start.column);
}

producciones = _ id:identificador _ lit:(literales)? _ "=" _ ops:opciones (_";")? { 
        ids.push(id);
        return new Token("produccion", {
            id: id, literales: lit, opciones: ops
        }, location.start.line, location.start.column);
    }

opciones = a:union b:(_ "/" _ union)*{
    return new Token("opciones", {
        opciones: [a, ...b.map(([_, _, union])=> union)] //lista de opciones
    }, location.start.line, location.start.column);
}

union = a: expresion b:(_ expresion !(_ literales? _ "=") )*{
    return new Token("union", {
        expresiones: [a, ...b.map(([_, expresion])=> expresion)] // lista de expresiones
    }, location.start.line, location.start.column);
}

expresion  = d:(etiqueta/varios)? _ e: expresiones _ c:([?+*]/conteo)? {
    return new Token("expresion", {tagVar: d, expresiones: e, conteo: c}, location.start.line, location.start.column);
}

etiqueta = a:("@")? _ id:identificador _ ":" v:(varios)? {return new Token("etiqueta",{
    arroba: a, id: id, varios: v},
    location.start.line, location.start.column
)}

varios = ("!"/"$"/"@"/"&") { return text(); }

expresiones  =  identificador
                / literales "i"? { return new Token("expresiones1", literales, location.start.line, location.start.column);}
                / "(" _ opciones _ ")" { return opciones; }
                / corchetes "i"?  { return new Token("expresion2", corchetes, location.start.line, location.start.column); }
                / "." { return new Token("expresion", text(), location.start.line, location.start.column); }
                / "!." { return new Token("expresion", text(), location.start.line, location.start.column); }

conteo = "|" _ lex:(numero/identificador) _ "|"{
            return new Token("conteo", lex, location.start.line, location.start.column);
        }
        / "|" _ incio:(numero / id:identificador)? _ ".." _ fin:(numero / id2:identificador)? _ "|"{
            return new Token("conteo", (inicio?inicio.lexeme:"")+".."+(fin?fin.lexeme:""),
                location.start.line, location.start.column);
        }
        / "|" _ inicio:(numero / id:identificador)? _ "," _ opciones _ "|"{
            return new Token("conteo", )
        }
        / "|" _ (numero / id:identificador)? _ ".." _ (numero / id2:identificador)? _ "," _ opciones _ "|"{

        }


// Regla principal que analiza corchetes con contenido
corchetes
    = "[" contenido:(rango / contenido)+ "]" {
       return new Token("corchetes", contenido, location.start.line, location.start.column);
        //return `Entrada válida: [${input}]`;
    }

// Regla para validar un rango como [A-Z]
rango
    = inicio:caracter "-" fin:caracter {
        if (inicio.charCodeAt(0) > fin.charCodeAt(0)) {
            throw new Error(`Rango inválido: [${inicio}-${fin}]`);
        }
        return new Token("rango", `${inicio}-${fin}`, location.start.line, location.start.column);
    }

// Regla para caracteres individuales
caracter
    = [a-zA-Z0-9_ ] { return text(); }

// Coincide con cualquier contenido que no incluya "]"
contenido
    = c:(corchete / texto)+ { /*return content.map(c=>c);*/
            return new Token("contenido", c, location.start.line, location.start.column);
     }

corchete
    = "[" contenido "]" { 
        return new Token("corchete", contenido, location.start.line, location.start.column); }

texto
    = [^\[\]]+ { 
        return new Token("texto", text(), location.start.line, location.start.column); }

literales = '"' chars:stringDobleComilla* '"' {
    return new Token("literal", chars.join(''), location.start.line, location.start.column); }
            / "'" chars:stringSimpleComilla* "'" { 
    return new Token("literal", chars.join(''), location.start.line, location.start.column); }

stringDobleComilla = !('"' / "\\" / finLinea) . { 
    return text(); }
                    / "\\" escape { 
                        return escape; }
                    / continuacionLinea { 
                        return ""; }

stringSimpleComilla = !("'" / "\\" / finLinea) . { 
    return text(); }
                    / "\\" escape { 
                        return escape; }
                    / continuacionLinea { 
                        return ""; }

continuacionLinea = "\\" secuenciaFinLinea { 
    return  ""; }

finLinea = [\n\r\u2028\u2029] { return text(); }

escape = ("'"
        / '"'
        / "\\"
        / "b"
        / "f"
        / "n"
        / "r"
        / "t"
        / "v"
        / "u") {
    const escapeMap = {
        "'": "'",
        '"': '"',
        "\\": "\\",
        "b": "\b",
        "f": "\f",
        "n": "\n",
        "r": "\r",
        "t": "\t",
        "v": "\v",
        "u": "\\u", 
    };
    return escapeMap[text()] || text();
}

secuenciaFinLinea = "\r\n" / "\n" / "\r" / "\u2028" / "\u2029"

numero = [0-9]+ { 
    return new Token("numero", Number(text()), location.start.line, location.start.column); }

identificador = [_a-z]i[_a-z0-9]i* { 
    return new Token("identificador", text(), location.start.line, location.start.column); }


_ = (Comentarios /[ \t\n\r])*


Comentarios = 
    "//" [^\n]* 
    / "/*" (!"*/" .)* "*/"
