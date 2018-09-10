//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Mar 10  Brian Frank  Creation
//

**
** CsvInStream is used to read delimiter-separated values
** as specified by RFC 4180.  Format details:
**   - rows are delimited by a newline
**   - cells are separated by `delimiter` char
**   - cells may be quoted with '"' character
**   - quoted cells may contain the delimiter
**   - quoted cells may contain newlines (always normalized to "\n")
**   - quoted cells must escape '"' with '""'
**   - the `trim` flag trims leading/trailing whitespace from non-quoted
**     cells (note that RFC 4180 specifies that whitespace is significant)
**
** Also see `CsvOutStream`.
**
@Js
class CsvInStream : ProxyInStream
{

  **
  ** Wrap the underlying input stream.
  **
  new make(InStream in) : super(in) {}

  **
  ** Delimiter character; defaults to comma.
  **
  Int delimiter := ','

  **
  ** Configures whether unqualified whitespace around a cell
  ** is automatically trimmed.  If a field is enclosed by
  ** quotes then it is never trimmed.
  **
  Bool trim := true

  **
  ** Read the entire table of rows into memory.
  ** The input stream is guaranteed to be closed upon completion.
  **
  Str[][] readAllRows()
  {
    rows := Str[][,]
    eachRow |row| { rows.add(row) }
    return rows
  }

  **
  ** Iterate through all the lines parsing each one into
  ** delimited-separated strings and calling the given
  ** callback functions.  The input stream is guaranteed
  ** to be closed upon completion.
  **
  Void eachRow(|Str[]| f)
  {
    try
    {
      while (true)
      {
        row := readRow
        if (row == null) break
        f(row)
      }
    }
    finally close
  }

  **
  ** Read the next line as a row of delimiter-separated
  ** strings.  Return null if at end of stream.
  **
  virtual Str[]? readRow()
  {
    // read in next line
    this.line = readLine()
    if (line == null) return null

    // allocate cells based on last width
    cells := Str[,]
    cells.capacity = rowWidth

    // parse the cells
    this.pos = 0
    while (pos < line.size) cells.add(parseCell)

    // handle if last character was delimiter
    if (!line.isEmpty && line[line.size-1] == delimiter) cells.add("")

    // save away width and return cells
    this.rowWidth = cells.size
    return cells
  }

  private Str parseCell()
  {
    // if trim enabled, skip any leading whitespace
    if (trim)
    {
      while(pos < line.size && line[pos].isSpace) pos++
      if (pos >= line.size) return ""
    }

    // parse quoted or non-quoted cell
    if (line[pos] != '"')
      return parseNonQuotedCell
    else
      return parseQuotedCell
  }

  private Str parseNonQuotedCell()
  {
    // find pos of delimiter or end of line
    start := pos
    while (pos < line.size && line[pos] != delimiter) ++pos

    // if trimming, then backtrack to find last non-whitespace
    end := pos - 1
    if (trim)
    {
      while (end > start && line[end].isSpace) --end
    }

    // skip delimiter and return result
    ++pos
    if (end < start) return ""
    return line[start..end]
  }

  private Str parseQuotedCell()
  {
    s := StrBuf()
    pos += 1 // skip opening quote
    while (true)
    {
      // next char
      ch := line.getSafe(pos++, 0)

      // if we've reached the end of a line, then this quoted
      // cell spans multiple lines so consume all empty lines
      // and the next non-empty line
      while (ch == 0)
      {
        this.pos = 0
        this.line = readLine
        if (line == null) throw IOErr("Unexpected end of file in multi-line quoted cell")
        s.addChar('\n')
        ch = line.getSafe(pos++, 0)
      }

      // if not quote, add it to our cell string
      if (ch != '"') { s.addChar(ch); continue }

      // if its "" then add ", otherwise end of cell
      ch = line.getSafe(pos++)
      if (ch == '"') { s.addChar(ch); continue }

      // skip everything to next delimiter
      while (ch != delimiter) ch = line.getSafe(pos++, delimiter)
      break
    }
    return s.toStr
  }

  private Int rowWidth := 10
  private Str? line
  private Int pos

}