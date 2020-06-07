//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/9/20.
//

#include "LinkedList.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>

void LinkedList_make(LinkedList *self) {
    self->idleList = NULL;
    self->head.next = &self->head;
    self->head.previous = &self->head;
    //self->head.data = NULL;
    self->length = 0;
}

void LinkedList_release(LinkedList *self) {
    LinkedListElem *it = LinkedList_first(self);
    LinkedListElem *end = LinkedList_end(self);
    LinkedListElem *temp = NULL;
    while (it != end) {
        temp = it;
        it = it->next;
        temp->next = NULL;
        temp->previous = NULL;
        free(temp);
    }
    it = self->idleList;
    while (it) {
        temp = it;
        it = it->next;
        temp->next = NULL;
        free(temp);
    }
    
    self->head.next = &self->head;
    self->head.previous = &self->head;
    self->idleList = NULL;
    self->length = 0;
}

void LinkedList_add(LinkedList *self, LinkedListElem *elem) {
    LinkedListElem *tail = self->head.previous;
    LinkedListElem *left = tail->previous;
    LinkedListElem *right = left->next;
    
    elem->next = right;
    right->previous = elem;
    elem->previous = left;
    left->next = elem;
    ++self->length;
}

void LinkedList_insertFirst(LinkedList *self, LinkedListElem *elem) {
    LinkedListElem *left = &self->head;
    LinkedListElem *right = left->next;
    
    elem->next = right;
    right->previous = elem;
    elem->previous = left;
    left->next = elem;
    ++self->length;
}

void LinkedList_insertBefore(LinkedList *self, LinkedListElem *elem, LinkedListElem *pos) {
    assert(pos);
    assert(elem);
    
    LinkedListElem *left = pos->previous;
    LinkedListElem *right = pos;
    elem->next = right;
    right->previous = elem;
    elem->previous = left;
    left->next = elem;
    ++self->length;
}

LinkedListElem *LinkedList_getAt(LinkedList *self, int index) {
    LinkedListElem *elem;
    int i = 0;
    elem = self->head.next;
    while (elem != &self->head) {
      if (i == index) {
        return elem;
      }
      elem = elem->next;
      ++i;
    }
    return NULL;
}

LinkedListElem *LinkedList_first(LinkedList *self) {
    return self->head.next;
}

LinkedListElem *LinkedList_last(LinkedList *self) {
    return self->head.previous;
}

LinkedListElem *LinkedList_end(LinkedList *self) {
    return &self->head;
}

bool LinkedList_isEmpty(LinkedList *self) {
    return self->head.next == &self->head;
}

bool LinkedList_remove(LinkedList *self, LinkedListElem *elem) {
    if (elem == NULL) return false;
    elem->previous->next = elem->next;
    elem->next->previous = elem->previous;
    --self->length;
    return true;
}

LinkedListElem *LinkedList_popIdleElem(LinkedList *self) {
    LinkedListElem *elem = NULL;
    if (self->idleList) {
        elem = self->idleList;
        self->idleList = elem->next;
        elem->next = NULL;
    }
    return elem;
}

LinkedListElem *LinkedList_newElem(LinkedList *self, size_t size) {
    LinkedListElem *elem = LinkedList_popIdleElem(self);
    if (elem == NULL) {
        if (size == 0) {
            size = sizeof(LinkedListElem);
        }
        elem = (LinkedListElem*)malloc(size);
    }
    return elem;
}

void LinkedList_freeElem(LinkedList *self, LinkedListElem *elem) {
    elem->previous = NULL;
    elem->next = self->idleList;
    self->idleList = elem;
}
