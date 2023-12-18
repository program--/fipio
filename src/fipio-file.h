#pragma once

#include <stdbool.h>

#include "fipio-common.h"

typedef struct fipio_file     fipio_file;
typedef struct fipio_entry    fipio_entry;
typedef struct fipio_property fipio_property;

//! Initialize a fipio file
//! @return fipio_file struct
fipio_file* fipio_file_init(void);

//! Map a fipio file
//! @param path Path to file
//! @param file fipio_file struct
void fipio_file_mmap(const char* path, fipio_file** file);

//! Unmap a fipio file
//! @param file fipio_file struct
void fipio_file_munmap(fipio_file** file);

//! Get an entry from a fipio file
//! @param file fipio_file struct
//! @param id ID to search for
//! @return Pointer to a fipio_entry.
fipio_entry* fipio_file_entry(fipio_file* file, fipio_uint_t id);
void         fipio_file_add_entry(fipio_file* file, fipio_entry* entry);

//
// fipio_property* fipio_get_property(fipio_entry* entry, fipio_uint_t index);
