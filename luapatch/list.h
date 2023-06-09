#ifndef UC_LLIST_H
#define UC_LLIST_H

#define bool unsigned char

struct list_item {
    struct list_item *next;
    void *data;
};

struct list {
    struct list_item *head, *tail;
};

// create a new list
struct list *list_new(void);

// removed linked list nodes but does not free their content
void list_clear(struct list *list);

// insert a new item at the begin of the list.
void *list_insert(struct list *list, void *data);

// append a new item at the end of the list.
void *list_append(struct list *list, void *data);

// returns true if entry was removed, false otherwise
bool list_remove(struct list *list, void *data);

bool list_isempty(struct list* list);
#endif
