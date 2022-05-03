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

  override Str toStr() {
    "-$val"
  }
}

**
** Doubly-linked list implementation
**
virtual class LinkedList {
  protected LinkedElem? head
  protected LinkedElem? tail
  protected Int _size := 0

  new make() {
  }

  ** Remove all items from the list and set size to 0
  Void clear() {
    head = null
    tail = null
    _size = 0
  }

  ** Remove the item in list
  ** if item is null do nothing.
  Void remove(LinkedElem? e) {
    if (e == null) return
    
    prev := e.previous
    next := e.next

    if (prev == null && next == null && e != head) {
      return
    }

    if (prev != null) {
      prev.next = next
      e.previous = null
    }
    else {
      head = next
    }

    if (next != null) {
      next.previous = prev
      e.next = null
    }
    else {
      tail = prev
    }

    --_size
  }

  ** Return the first item, or if empty return null.
  LinkedElem? first() {
    head
  }

  ** Return the last item, or if empty return null.
  LinkedElem? last() {
    tail
  }

  ** Remove the first item
  LinkedElem? poll() {
    removeFirst
  }

  ** Remove the first item
  LinkedElem? removeFirst() {
    e := head
    remove(e)
    return e
  }

  ** Remove the last item
  LinkedElem? pop() {
    e := last
    remove(e)
    return e
  }

  ** Add the specified item to the end of the list
  Void add(LinkedElem e) {
    if (tail == null) {
      head = e
      tail = e
      e.next = null
      e.previous = null
    }
    else {
      tail.next = e
      e.previous = tail
      e.next = null
      tail = e
    }
    ++_size
  }

  **
  ** Insert the item before specified item
  **
  Void insertBefore(LinkedElem e, LinkedElem? other := null) {
    if (head == null) {
      head = e
      tail = e
      e.next = null
      e.previous = null
    }
    else {
      if (other == null) {
        other = head
      }
      e.next = other
      e.previous = other.previous
      if (other.previous != null) {
        other.previous.next = e
      }
      other.previous = e
      if (other === head) head = e
    }
    ++_size
  }

  ** size is 0
  Bool isEmpty() { head == null }


  ** The number of items in the list.
  Int size() { _size }

  **
  ** Return a string representation the list.
  **
  override Str toStr() {
    buf := StrBuf().add("LinkList[")
    itr := first
    while (itr !== null) {
      if (itr !== first) buf.addChar(',')
      buf.add(itr)
      itr = itr.next
    }
    buf.addChar(']')
    return buf.toStr
  }

}

