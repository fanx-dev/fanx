//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

virtual class LinkedElem {
  LinkedElem? next
  LinkedElem? previous
  Obj? val

  new make(Obj? v:=null) { val = v }

  internal Void remove() {
    previous.next = next
    next.previous = previous

    next = null
    previous = null
  }

  override Str toStr() {
    "-$val"
  }
}

virtual class LinkedList {
  protected LinkedElem head := LinkedElem("LinkedList.head")

  new make() {
    head.previous = head
    head.next = head
  }

  Void clear() {
    head.previous = head
    head.next = head
  }

  Void remove(LinkedElem e) {
    if (e === head) throw ArgErr("Try remove a invalide LinkedElem: $e.val")
    e.remove
  }

  LinkedElem first() { head.next }

  LinkedElem last() { head.previous }

  **
  ** Returns an element following the last element of the container.
  ** This element acts as a placeholder
  **
  LinkedElem end() { head }

  Void add(LinkedElem e) {
    last := head.previous

    last.next = e
    e.previous = last

    e.next = head
    head.previous = e
  }

  Void insertBefore(LinkedElem e, LinkedElem other := first) {
    e.next = other
    other.previous = e

    head.next = e
    e.previous = head
  }

  Bool isEmpty() { head.next == head }


  override Str toStr() {
    buf := StrBuf().add("LinkList[")
    itr := first
    while (itr != end) {
      if (itr != first) buf.addChar(',')
      buf.add(itr)
      itr = itr.next
    }
    buf.addChar(']')
    return buf.toStr
  }
}

