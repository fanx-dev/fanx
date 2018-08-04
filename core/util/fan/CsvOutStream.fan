//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Mar 10  Brian Frank  Creation
//

**
** CsvOutStream is used to write delimiter-separated values
** as specified by RFC 4180.  Format details:
**   - rows are delimited by a newline
**   - cells are separated by `delimiter` char
**   - cells containing the delimiter, '"' double quote, or
**     newline are quoted; quotes are escaped as '""'
**
** Also see `CsvInStream`.
**
@Js
class CsvOutStream : ProxyOutStream
{

  **
  ** Wrap the underlying output stream.
  **
  new make(OutStream out) : super(out) {}

  **
  ** Delimiter character; defaults to comma.
  **
  Int delimiter := ','

  **
  ** Write the row of cells with the configured delimiter.
  ** Also see `writeCell`.
  **
  virtual This writeRow(Str[] row)
  {
    row.each |cell, i|
    {
      if (i > 0) writeChar(delimiter)
      writeCell(cell)
    }
    return writeChar('\n')
  }

  **
  ** Write a single cell.  If `isQuoteRequired` returns true,
  ** then quote it.
  **
  virtual This writeCell(Str cell)
  {
    if (!isQuoteRequired(cell)) return print(cell)
    writeChar('"')
    cell.each |ch|
    {
      if (ch == '"') writeChar('"')
      writeChar(ch)
    }
    return writeChar('"')
  }

  **
  ** Return if the given cell string contains:
  **  - the configured delimiter
  **  - double quote '"' char
  **  - leading/trailing whitespace
  **  - newlines
  **
  Bool isQuoteRequired(Str cell)
  {
    if (cell.isEmpty) return true
    if (cell[0].isSpace || cell[-1].isSpace) return true
    return cell.any |ch| { ch == delimiter || ch == '"' || ch == '\n' || ch == '\r' }
  }

}