export default class Token {
  /**
   * @param {string} type
   * @param {any} lexeme
   * @param {number} line
   * @param {number} column
   */
  constructor(type, lexeme, line, column) {
    this.lexeme = lexeme;
    this.line = line;
    this.column = column;
  }
}
