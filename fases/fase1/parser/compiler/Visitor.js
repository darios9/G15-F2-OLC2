import Token from "./Token.js";
import Error from "./Error.js";
export default class Visitor {
  constructor() {}
  /**
   *
   * @param {Token} token
   */
  visit(token) {
    switch (token.lexeme) {
      case "identificador":
        return this.visitIdentificador(token);
      case "numero":
        return this.visitNumero(token);
      case "literal":
        return this.visitLiteral(token);
      case "text":
        return this.visitTexto(token);
      case "corchete":
        return this.visitCorchete(token);
      case "rango":
        return this.visitRango(token);
      default:
        console.error(`TOKEN DESCONOCIDO: ${JSON.stringify(node, null, 2)}`);
        break;
    }
  }
  /**
   * @param {Token} token
   */
  visitRango(token) {
    /*** GENERAR CODIGO PARA INTERPRETAR EL RANGO A FORTRAN */
  }
  /**
   * @param {Token} token
   */
  visitCorchete(token) {
    contenido = [];
    for (var t of token.lexeme) {
      contenido.push(this.visit(t));
    }
    return contenido;
  }
  /**
   * @param {Token} token
   */
  visitTexto(token) {
    return token.lexeme;
  }
  /**
   * @param {Token} token
   */
  visitLiteral(token) {
    return token.lexeme;
  }
  /**
   * @param {Token} token
   */
  visitNumero(token) {
    return token.lexeme;
  }
  /**
   * @param {Token} token
   */
  visitIdentificador(token) {
    return token.lexeme;
  }
}
