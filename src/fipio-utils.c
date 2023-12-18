#include "fipio-utils.h"

#if defined(__has_builtin) & __has_builtin(__builtin_round)
#define FIPIO_ROUND __builtin_round
#else
#include <math.h>
#define FIPIO_ROUND round
#endif

#if defined(__has_builtin) & __has_builtin(__builtin_pow)
#define FIPIO_POW __builtin_pow
#else
#include <math.h>
#define FIPIO_POW pow
#endif

fipio_int_t fipio_round(double x, fipio_size_t precision)
{
    return FIPIO_ROUND(x * FIPIO_POW(10, precision));
}

fipio_size_t fipio_varint_encode(fipio_uint_t value, fipio_byte_t* output)
{
    fipio_size_t size = 0;
    while (value > 127) {
        output[size] = (fipio_byte_t)(value & 127) | 128;
        value >>= 7;
        size++;
    }
    output[size++] = (fipio_byte_t)(value) & 127;
    return size;
}

fipio_uint_t fipio_varint_decode(fipio_byte_t* input, fipio_size_t n)
{
    fipio_uint_t result = 0;
    for (fipio_size_t i = 0; i < n; i++) {
        result |= (input[i] & 127) << (7 * i);
        if (!(input[i] & 128))
            break;
    }
    return result;
}

fipio_uint_t fipio_zigzag_encode(fipio_int_t x)
{
    return (2 * x) ^ (x >> 63);
}

fipio_int_t fipio_zigzag_decode(fipio_uint_t x)
{
    return (x >> 1) ^ -(x & 1);
}
