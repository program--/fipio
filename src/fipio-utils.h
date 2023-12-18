#pragma once

#include "fipio-common.h"

//! Round a double based on precision
//! @param x Double to round
//! @param precision Precision to round to
//! @return Signed integer rounded 10^precision
fipio_int_t fipio_round(double x, fipio_size_t precision);

//! Varint encode an unsigned integer
//! @param[in] value Unsigned integer to encode
//! @param[out] output Pointer to output buffer
//! @return Number of bytes written
fipio_size_t fipio_varint_encode(fipio_uint_t value, fipio_byte_t* output);

//! Varint decode a buffer
//! @param[in] input Pointer to input buffer
//! @param[in] n Number of bytes to read
//! @return Unsigned integer
fipio_uint_t fipio_varint_decode(fipio_byte_t* input, fipio_size_t n);

//! Zigzag encode a signed integer
//! @param x Signed integer
//! @return Unsigned integer
fipio_uint_t fipio_zigzag_encode(fipio_int_t x);

//! Zigzag decode a signed integer
//! @param x Unsigned integer
//! @return Signed integer
fipio_int_t fipio_zigzag_decode(fipio_uint_t x);
