import Token from "./Token.js";

export default class Error extends Token {
  /**
   * @param {any} lexeme
   * @param {string} message
   * @param {number} line
   * @param {number} column
   */
  constructor(lexeme, message, line, column) {
    super("error", lexeme, line, column);
    this.message = message;
  }
}
