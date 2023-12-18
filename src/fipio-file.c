#include "fipio-file.h"
#include "fipio-common.h"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <lzma.h>

struct fipio_file
{
    fipio_uint_t entries_count;
    fipio_entry* directory;
    lzma_index*  index;
};

struct fipio_entry
{
    fipio_uint_t id;
    fipio_uint_t properties_count;
    fipio_uint_t properties_offset;
};

struct fipio_property
{
    enum
    {
        property_int,
        property_dbl,
        property_chr,
        property_lgl,
        property_geom,
        property_offset
    } type;

    // lzma_vli index;
};

fipio_file* fipio_file_init(void)
{
    fipio_file* file = malloc(sizeof(fipio_file));

    if (file != NULL) {
        file->entries_count = 0;
        file->directory     = NULL;
    }

    return file;
}

void fipio_file_mmap(const char* path, fipio_file** file)
{
    FILE*        f = fopen(path, "r");
    fipio_byte_t chunk;
    fipio_uint_t len = 0;
    while (fread(&chunk, sizeof(fipio_byte_t), 1, f) > 0) {
        len++;
        if (chunk == '\x1C')
            break;
    }

    int fd             = open(path, O_RDONLY);
    (*file)->directory = mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd, 0);
}

void fipio_file_munmap(fipio_file** file)
{
    if (file != NULL)
        if ((*file)->directory != NULL)
            munmap(
              (*file)->directory, (*file)->entries_count * sizeof(fipio_entry)
            );
}

int fipio_file_entry_compare(const void* key, const void* entry)
{
    const fipio_uint_t* key_   = (const fipio_uint_t*)key;
    const fipio_entry*  entry_ = (const fipio_entry*)entry;
    return *key_ - entry_->id;
}

fipio_entry* fipio_file_entry(fipio_file* file, fipio_uint_t id)
{
    if (file == NULL)
        return NULL;

    return bsearch(
      &id,
      file->directory,
      file->entries_count,
      sizeof(fipio_entry),
      fipio_file_entry_compare
    );
}
