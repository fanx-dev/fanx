//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/9/20.
//

#ifndef __runtime__LinkedList__
#define __runtime__LinkedList__

#include "miss.h"

CF_BEGIN

#define SingleLinked_insert(elem, head, fnext) do {\
    elem->fnext = head;\
    head = elem;\
  } while(0);

#define SingleLinked_popFirst(outNode, head, fnext) do {\
  if (head) {\
    outNode = head;\
    head = head->fnext;\
    outNode->fnext = NULL;\
  }\
} while(0);

#define Linked_insert(elem, head, fnext, fprevious) do {\
    elem->fnext = head;\
    if (head) {\
      head->fprevious = elem;\
    }\
    elem->fprevious = NULL;\
    head = elem;\
  } while(0);

#define Linked_remove(elem, head, fnext, fprevious) do {\
    if (elem->fprevious) {\
      elem->fprevious->fnext = elem->fnext;\
    }\
    if (elem->fnext) {\
      elem->fnext->fprevious = elem->fprevious;\
    }\
    if (elem == head) {\
      head = elem->fnext;\
    }\
    elem->fnext = NULL;\
    elem->fprevious = NULL;\
  } while(0);

#define SingleLinked_forEach(type, head, fnext, callback) do {\
    type *temp_ = NULL;\
    type *elem_ = head;\
    while (elem_) {\
      temp_ = elem_;\
      elem_ = elem_->fnext;\
      callback\
    }\
  }while(0);

typedef struct LinkedListElem_ {
    struct LinkedListElem_ *previous;
    struct LinkedListElem_ *next;
    void *data;
} LinkedListElem;

typedef struct LinkedList_ {
    struct LinkedListElem_ head;
    struct LinkedListElem_ *idleList;
    size_t length;
} LinkedList;

void LinkedList_make(LinkedList *self);

void LinkedList_release(LinkedList *self);

void LinkedList_add(LinkedList *self, LinkedListElem *elem);

void LinkedList_insertFirst(LinkedList *self, LinkedListElem *elem);

void LinkedList_insertBefore(LinkedList *self, LinkedListElem *elem, LinkedListElem *pos);

LinkedListElem *LinkedList_getAt(LinkedList *self, int index);

LinkedListElem *LinkedList_first(LinkedList *self);

LinkedListElem *LinkedList_last(LinkedList *self);

/**
 * after last elem
 */
LinkedListElem *LinkedList_end(LinkedList *self);

bool LinkedList_isEmpty(LinkedList *self);

bool LinkedList_remove(LinkedList *self, LinkedListElem *elem);

LinkedListElem *LinkedList_popIdleElem(LinkedList *self);

LinkedListElem *LinkedList_newElem(LinkedList *self, size_t size);

void LinkedList_freeElem(LinkedList *self, LinkedListElem *elem);

CF_END

#endif /* defined(__runtime__LinkedList__) */
