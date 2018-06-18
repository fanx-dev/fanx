//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

class LinkedElem {
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

class LinkedList {
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
}

