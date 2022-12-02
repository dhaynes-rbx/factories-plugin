-- This module based on https://raw.githubusercontent.com/Egor-Skriptunoff/pure_lua_SHA/221fdad4f58187b3a8b0269b2aafbf2c65473137/sha2.lua
-- All portable codepaths removed except for the ones used in Roblox

--------------------------------------------------------------------------------------------------------------------------
-- SHA2
--------------------------------------------------------------------------------------------------------------------------
-- MODULE: sha2
--
-- VERSION: 3 (2018-11-02)
--
-- DESCRIPTION:
--    This module contains functions to calculate SHA2 digest:
--       SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224, SHA-512/256
--    Written in pure Lua.
--    Compatible with:
--       Lua 5.1, Lua 5.2, Lua 5.3, Lua 5.4, Fengari, LuaJIT 2.0/2.1 (any CPU endianness).
--    Main feature of this module: it is heavily optimized for speed.
--    For every Lua version the module contains particular implementation branch to get benefits from version-specific features.
--       - branch for Lua 5.1 (emulating bitwise operators using look-up table)
--       - branch for Lua 5.2 (using bit32/bit library), suitable for both Lua 5.2 with native "bit32" and Lua 5.1 with external library "bit"
--       - branch for Lua 5.3/5.4 (using native 64-bit bitwise operators)
--       - branch for Lua 5.3/5.4 (using native 32-bit bitwise operators) for Lua built with LUA_INT_TYPE=LUA_INT_INT
--       - branch for LuaJIT without FFI library (useful in a sandboxed environment)
--       - branch for LuaJIT x86 without FFI library (LuaJIT x86 has oddity because of lack of CPU registers)
--       - branch for LuaJIT 2.0 with FFI library (bit.* functions work only with Lua numbers)
--       - branch for LuaJIT 2.1 with FFI library (bit.* functions can work with "int64_t" arguments)
--
-- USAGE:
--    Input data should be provided as a binary string: either as a whole string or as a sequence of substrings (chunk-by-chunk loading, total length < 9*10^15 bytes).
--    Result (SHA2 digest) is returned in hexadecimal representation as a string of lowercase hex digits.
--    Simplest usage example:
--       local sha2 = require("sha2")
--       local your_hash = sha2.sha256("your string")
--    See file "sha2_test.lua" for more examples.
--
-- AUTHOR: Egor (egor.skriptunoff(at)gmail.com)
-- This module is released under the MIT License (the same license as Lua itself).
--
-- CHANGELOG:
--  version     date      description
--     1     2018-10-06   First release
--     2     2018-10-07   Decreased module loading time in Lua 5.1 implementation branch (thanks to Peter Melnichenko for giving a hint)
--     3     2018-11-02   Bug fixed: incorrect hashing of long (2 GByte) data streams on Lua built with "int32" integers

-----------------------------------------------------------------------------

local print_debug_messages = false -- set to true to view some messages about your system's abilities and which implementation branch was chosen for your system

local unpack, table_concat, byte, char, string_rep, sub, string_format, floor, ceil, tonumber = table.unpack
    or unpack
, table.concat
, string.byte
, string.char
, string.rep
, string.sub
, string.format
, math.floor
, math.ceil
, tonumber

--------------------------------------------------------------------------------
-- EXAMINING YOUR SYSTEM
--------------------------------------------------------------------------------

local function get_precision(one)
    -- "one" must be either float 1.0 or integer 1
    -- returns bits_precision, is_integer
    -- This function works correctly with all floating point datatypes (including non-IEEE-754)
    local k, n, m, prev_n = 0, one, one, nil
    while true do
        k, prev_n, n, m = k + 1, n, n + n + 1, m + m + k % 2
        if k > 256 or n - (n - 1) ~= 1 or m - (m - 1) ~= 1 or n == m then
            return k, false -- floating point datatype
        elseif n == prev_n then
            return k, true -- integer datatype
        end
    end
end

-- Make sure Lua has "double" numbers
local x = 2 / 3
local Lua_has_double = x * 5 > 3 and x * 4 < 3 and get_precision(1.0) >= 53
assert(Lua_has_double, "at least 53-bit floating point numbers are required")

-- Q:
--    SHA2 was designed for FPU-less machines.
--    So, why floating point numbers are needed for this module?
-- A:
--    53-bit "double" numbers are useful to calculate "magic numbers" used in SHA2.
--    I prefer to write 50 LOC "magic numbers calculator" instead of storing 184 constants explicitly in this source file.

local int_prec, Lua_has_integers = get_precision(1)
local Lua_has_int64 = Lua_has_integers and int_prec == 64
local Lua_has_int32 = Lua_has_integers and int_prec == 32
assert(
    Lua_has_int64 or Lua_has_int32 or not Lua_has_integers,
    "Lua integers must be either 32-bit or 64-bit"
)

-- Q:
--    Does it mean that almost all non-standard configurations are not supported?
-- A:
--    Yes.  Sorry, too many problems to support all possible Lua numbers configurations.
--       Lua 5.1/5.2    with "int32"               will not work.
--       Lua 5.1/5.2    with "int64"               will not work.
--       Lua 5.1/5.2    with "int128"              will not work.
--       Lua 5.1/5.2    with "float"               will not work.
--       Lua 5.1/5.2    with "double"              is OK.          (default config for Lua 5.1, Lua 5.2, LuaJIT)
--       Lua 5.3/5.4    with "int32"  + "float"    will not work.
--       Lua 5.3/5.4    with "int64"  + "float"    will not work.
--       Lua 5.3/5.4    with "int128" + "float"    will not work.
--       Lua 5.3/5.4    with "int32"  + "double"   is OK.          (config used by Fengari)
--       Lua 5.3/5.4    with "int64"  + "double"   is OK.          (default config for Lua 5.3, Lua 5.4)
--       Lua 5.3/5.4    with "int128" + "double"   will not work.
--   Using floating point numbers better than "double" instead of "double" is OK (non-IEEE-754 floating point implementation are allowed).
--   Using "int128" instead of "int64" is not OK: "int128" would require different branch of implementation for optimized SHA512.

-- Check for LuaJIT and 32-bit bitwise libraries
local is_LuaJIT = ({ false, [1] = true })[1]
    and (type(jit) ~= "table" or jit.version_num >= 20000) -- LuaJIT 1.x.x is treated as vanilla Lua 5.1
local is_LuaJIT_21 -- LuaJIT 2.1+
local LuaJIT_arch
local ffi -- LuaJIT FFI library (as a table)
local b -- 32-bit bitwise library (as a table)
local library_name

is_LuaJIT = false -- Force disable JIT for roblox
if is_LuaJIT then
    -- Assuming "bit" library is always available on LuaJIT
    b = require("bit")
    library_name = "bit"
    -- "ffi" is intentionally disabled on some systems for safety reason
    local LuaJIT_has_FFI, result = pcall(require, "ffi")
    if LuaJIT_has_FFI then
        ffi = result
    end
    is_LuaJIT_21 = not not loadstring("b=0b0")
    LuaJIT_arch = type(jit) == "table" and jit.arch or ffi and ffi.arch or nil
else
    -- For vanilla Lua, "bit"/"bit32" libraries are searched in global namespace only.  No attempt is made to load a library if it's not loaded yet.
    if type(bit) == "table" and bit.bxor then
        b = bit
        library_name = "bit"
    elseif type(bit32) == "table" and bit32.bxor then
        b = bit32
        library_name = "bit32"
    end
end

--------------------------------------------------------------------------------
-- You can disable here some of your system's abilities (for testing purposes)
--------------------------------------------------------------------------------
-- is_LuaJIT = nil
-- is_LuaJIT_21 = nil
-- ffi = nil
-- Lua_has_int32 = nil
-- Lua_has_int64 = nil
-- b, library_name = nil
--------------------------------------------------------------------------------

if print_debug_messages then
    -- Printing list of abilities of your system
    print("Abilities:")
    print("   Lua version:               " .. (is_LuaJIT and "LuaJIT " .. (is_LuaJIT_21 and "2.1 " or "2.0 ") .. (LuaJIT_arch or "") .. (ffi and " with FFI" or " without FFI") or _VERSION))
    print("   Integer bitwise operators: " .. (Lua_has_int64 and "int64" or Lua_has_int32 and "int32" or "no"))
    print("   32-bit bitwise library:    " .. (library_name or "not found"))
end

-- Selecting the most suitable implementation for given set of abilities
local method, branch
method = "Using '" .. library_name .. "' library"
branch = "LIB32"

if print_debug_messages then
    -- Printing the implementation selected to be used on your system
    print("Implementation selected:")
    print("   " .. method)
end

--------------------------------------------------------------------------------
-- BASIC BITWISE FUNCTIONS
--------------------------------------------------------------------------------

-- 32-bit bitwise functions
local AND, OR, XOR, SHL, SHR, ROL, ROR, NORM, HEX
-- Only low 32 bits of function arguments matter, high bits are ignored
-- The result of all functions (except HEX) is an integer inside "correct range":
--    for "bit" library:    (-2^31)..(2^31-1)
--    for "bit32" library:        0..(2^32-1)

-- Your system has 32-bit bitwise library (either "bit" or "bit32")
AND = b.band -- 2 arguments
OR = b.bor -- 2 arguments
XOR = b.bxor -- 2 or 3 arguments
SHL = b.lshift -- second argument is integer 0..31
SHR = b.rshift -- second argument is integer 0..31
ROL = b.rol
    or b.lrotate -- second argument is integer 0..31
ROR = b.ror
    or b.rrotate -- second argument is integer 0..31
NORM = b.tobit
HEX = b.tohex -- returns string of 8 lowercase hexadecimal digits
assert(
    AND and OR and XOR and SHL and SHR and ROL and ROR,
    "Library '" .. library_name .. "' is incomplete"
)

HEX = HEX
    or function(x) -- returns string of 8 lowercase hexadecimal digits
    return string_format("%08x", x % 4294967296)
end

local function XOR32A5(x)
    return XOR(x, 0xA5A5A5A5) % 4294967296
end

--------------------------------------------------------------------------------
-- CREATING OPTIMIZED INNER LOOP
--------------------------------------------------------------------------------

-- Inner loop functions
local sha256_feed_64, sha512_feed_128

-- Arrays of SHA2 "magic numbers" (in "INT64" and "FFI" branches "*_lo" arrays contain 64-bit values)
local sha2_K_lo, sha2_K_hi, sha2_H_lo, sha2_H_hi = {}, {}, {}, {}
local sha2_H_ext256 = { [224] = {}, [256] = sha2_H_hi }
local sha2_H_ext512_lo, sha2_H_ext512_hi = { [384] = {}, [512] = sha2_H_lo }, { [384] = {}, [512] = sha2_H_hi }

local HEX64, XOR64A5 -- defined only for branches that internally use 64-bit integers: "INT64" and "FFI"
local common_W = {} -- temporary table shared between all calculations (to avoid creating new temporary table every time)
local K_lo_modulo, hi_factor = 4294967296, 0

-- implementation of both SHA256 and SHA512 for Lua 5.1/5.2 (with or without bitwise library available)

function sha256_feed_64(H, K, str, offs, size)
    -- offs >= 0, size >= 0, size is multiple of 64
    local W = common_W
    local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
    for pos = offs, offs + size - 1, 64 do
        for j = 1, 16 do
            pos = pos + 4
            local a, b, c, d = byte(str, pos - 3, pos)
            W[j] = ((a * 256 + b) * 256 + c) * 256 + d
        end
        for j = 17, 64 do
            local a, b = W[j - 15], W[j - 2]
            W[j] = XOR(ROR(a, 7), ROL(a, 14), SHR(a, 3))
                + XOR(ROL(b, 15), ROL(b, 13), SHR(b, 10))
                + W[j - 7]
                + W[j - 16]
        end
        local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8
        for j = 1, 64 do
            local z = XOR(ROR(e, 6), ROR(e, 11), ROL(e, 7)) + AND(e, f) + AND(-1 - e, g) + h + K[j] + W[j]
            h = g
            g = f
            f = e
            e = z + d
            d = c
            c = b
            b = a
            a = z + AND(d, c) + AND(a, XOR(d, c)) + XOR(ROR(a, 2), ROR(a, 13), ROL(a, 10))
        end
        h1, h2, h3, h4 = (a + h1) % 4294967296, (b + h2) % 4294967296, (c + h3) % 4294967296, (d + h4) % 4294967296
        h5, h6, h7, h8 = (e + h5) % 4294967296, (f + h6) % 4294967296, (g + h7) % 4294967296, (h + h8) % 4294967296
    end
    H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
end

function sha512_feed_128(H_lo, H_hi, K_lo, K_hi, str, offs, size)
    -- offs >= 0, size >= 0, size is multiple of 128
    -- W1_hi, W1_lo, W2_hi, W2_lo, ...   Wk_hi = W[2*k-1], Wk_lo = W[2*k]
    local W = common_W
    local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1]
, H_lo[2]
, H_lo[3]
, H_lo[4]
, H_lo[5]
, H_lo[6]
, H_lo[7]
, H_lo[8]
    local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1]
, H_hi[2]
, H_hi[3]
, H_hi[4]
, H_hi[5]
, H_hi[6]
, H_hi[7]
, H_hi[8]
    for pos = offs, offs + size - 1, 128 do
        for j = 1, 16 * 2 do
            pos = pos + 4
            local a, b, c, d = byte(str, pos - 3, pos)
            W[j] = ((a * 256 + b) * 256 + c) * 256 + d
        end
        for jj = 17 * 2, 80 * 2, 2 do
            local a_lo, a_hi, b_lo, b_hi = W[jj - 30], W[jj - 31], W[jj - 4], W[jj - 5]
            local tmp1 = XOR(
                SHR(a_lo, 1) + SHL(a_hi, 31),
                SHR(a_lo, 8) + SHL(a_hi, 24),
                SHR(a_lo, 7) + SHL(a_hi, 25)
            ) % 4294967296 + XOR(
                SHR(b_lo, 19) + SHL(b_hi, 13),
                SHL(b_lo, 3) + SHR(b_hi, 29),
                SHR(b_lo, 6) + SHL(b_hi, 26)
            ) % 4294967296 + W[jj - 14] + W[jj - 32]
            local tmp2 = tmp1 % 4294967296
            W[jj - 1] = XOR(SHR(a_hi, 1) + SHL(a_lo, 31), SHR(a_hi, 8) + SHL(a_lo, 24), SHR(a_hi, 7))
                + XOR(SHR(b_hi, 19) + SHL(b_lo, 13), SHL(b_hi, 3) + SHR(b_lo, 29), SHR(b_hi, 6))
                + W[jj - 15]
                + W[jj - 33]
                + (tmp1 - tmp2)
                / 4294967296
            W[jj] = tmp2
        end
        local a_lo, b_lo, c_lo, d_lo, e_lo, f_lo, g_lo, h_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
        local a_hi, b_hi, c_hi, d_hi, e_hi, f_hi, g_hi, h_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
        for j = 1, 80 do
            local jj = 2 * j
            local tmp1 = XOR(
                SHR(e_lo, 14) + SHL(e_hi, 18),
                SHR(e_lo, 18) + SHL(e_hi, 14),
                SHL(e_lo, 23) + SHR(e_hi, 9)
            ) % 4294967296 + (AND(e_lo, f_lo) + AND(-1 - e_lo, g_lo)) % 4294967296 + h_lo + K_lo[j] + W[jj]
            local z_lo = tmp1 % 4294967296
            local z_hi = XOR(
                SHR(e_hi, 14) + SHL(e_lo, 18),
                SHR(e_hi, 18) + SHL(e_lo, 14),
                SHL(e_hi, 23) + SHR(e_lo, 9)
            ) + AND(e_hi, f_hi) + AND(-1 - e_hi, g_hi) + h_hi + K_hi[j] + W[jj - 1] + (tmp1 - z_lo) / 4294967296
            h_lo = g_lo
            h_hi = g_hi
            g_lo = f_lo
            g_hi = f_hi
            f_lo = e_lo
            f_hi = e_hi
            tmp1 = z_lo + d_lo
            e_lo = tmp1 % 4294967296
            e_hi = z_hi + d_hi + (tmp1 - e_lo) / 4294967296
            d_lo = c_lo
            d_hi = c_hi
            c_lo = b_lo
            c_hi = b_hi
            b_lo = a_lo
            b_hi = a_hi
            tmp1 = z_lo + (AND(d_lo, c_lo) + AND(b_lo, XOR(d_lo, c_lo))) % 4294967296 + XOR(
                SHR(b_lo, 28) + SHL(b_hi, 4),
                SHL(b_lo, 30) + SHR(b_hi, 2),
                SHL(b_lo, 25) + SHR(b_hi, 7)
            ) % 4294967296
            a_lo = tmp1 % 4294967296
            a_hi = z_hi + (AND(d_hi, c_hi) + AND(b_hi, XOR(d_hi, c_hi))) + XOR(
                SHR(b_hi, 28) + SHL(b_lo, 4),
                SHL(b_hi, 30) + SHR(b_lo, 2),
                SHL(b_hi, 25) + SHR(b_lo, 7)
            ) + (tmp1 - a_lo) / 4294967296
        end
        a_lo = h1_lo + a_lo
        h1_lo = a_lo % 4294967296
        h1_hi = (h1_hi + a_hi + (a_lo - h1_lo) / 4294967296) % 4294967296
        a_lo = h2_lo + b_lo
        h2_lo = a_lo % 4294967296
        h2_hi = (h2_hi + b_hi + (a_lo - h2_lo) / 4294967296) % 4294967296
        a_lo = h3_lo + c_lo
        h3_lo = a_lo % 4294967296
        h3_hi = (h3_hi + c_hi + (a_lo - h3_lo) / 4294967296) % 4294967296
        a_lo = h4_lo + d_lo
        h4_lo = a_lo % 4294967296
        h4_hi = (h4_hi + d_hi + (a_lo - h4_lo) / 4294967296) % 4294967296
        a_lo = h5_lo + e_lo
        h5_lo = a_lo % 4294967296
        h5_hi = (h5_hi + e_hi + (a_lo - h5_lo) / 4294967296) % 4294967296
        a_lo = h6_lo + f_lo
        h6_lo = a_lo % 4294967296
        h6_hi = (h6_hi + f_hi + (a_lo - h6_lo) / 4294967296) % 4294967296
        a_lo = h7_lo + g_lo
        h7_lo = a_lo % 4294967296
        h7_hi = (h7_hi + g_hi + (a_lo - h7_lo) / 4294967296) % 4294967296
        a_lo = h8_lo + h_lo
        h8_lo = a_lo % 4294967296
        h8_hi = (h8_hi + h_hi + (a_lo - h8_lo) / 4294967296) % 4294967296
    end
    H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo
, h2_lo
, h3_lo
, h4_lo
, h5_lo
, h6_lo
, h7_lo
, h8_lo
    H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi
, h2_hi
, h3_hi
, h4_hi
, h5_hi
, h6_hi
, h7_hi
, h8_hi
end

--------------------------------------------------------------------------------
-- MAGIC NUMBERS CALCULATOR
--------------------------------------------------------------------------------
-- Q:
--    Is 53-bit "double" math enough to calculate square roots and cube roots of primes with 64 correct bits after decimal point?
-- A:
--    Yes, 53-bit "double" arithmetic is enough.
--    We could obtain first 40 bits by direct calculation of p^(1/3) and next 40 bits by one step of Newton's method.

do
    local function mul(src1, src2, factor, result_length)
        -- src1, src2 - long integers (arrays of digits in base 2^24)
        -- factor - small integer
        -- returns long integer result (src1 * src2 * factor) and its floating point approximation
        local result, carry, value, weight = {}, 0.0, 0.0, 1.0
        for j = 1, result_length do
            for k = math.max(1, j + 1 - #src2), math.min(j, #src1) do
                carry = carry
                    + factor
                    * src1[k]
                    * src2[j + 1 - k] -- "int32" is not enough for multiplication result, that's why "factor" must be of type "double"
            end
            local digit = carry % 2 ^ 24
            result[j] = floor(digit)
            carry = (carry - digit) / 2 ^ 24
            value = value + digit * weight
            weight = weight * 2 ^ 24
        end
        return result, value
    end

    local idx, step, p, one, sqrt_hi, sqrt_lo = 0, { 4, 1, 2, -2, 2 }, 4, { 1 }, sha2_H_hi, sha2_H_lo
    repeat
        p = p + step[p % 6]
        local d = 1
        repeat
            d = d + step[d % 6]
            if d * d > p then -- next prime number is found
                local root = p ^ (1 / 3)
                local R = root * 2 ^ 40
                R = mul({ R - R % 1 }, one, 1.0, 2)
                local _, delta = mul(R, mul(R, R, 1.0, 4), -1.0, 4)
                local hi = R[2] % 65536 * 65536 + floor(R[1] / 256)
                local lo = R[1] % 256 * 16777216 + floor(delta * (2 ^ -56 / 3) * root / p)
                if idx < 16 then
                    root = p ^ (1 / 2)
                    R = root * 2 ^ 40
                    R = mul({ R - R % 1 }, one, 1.0, 2)
                    _, delta = mul(R, R, -1.0, 2)
                    local hi = R[2] % 65536 * 65536 + floor(R[1] / 256)
                    local lo = R[1] % 256 * 16777216 + floor(delta * 2 ^ -17 / root)
                    local idx = idx % 8 + 1
                    sha2_H_ext256[224][idx] = lo
                    sqrt_hi[idx], sqrt_lo[idx] = hi, lo + hi * hi_factor
                    if idx > 7 then
                        sqrt_hi, sqrt_lo = sha2_H_ext512_hi[384], sha2_H_ext512_lo[384]
                    end
                end
                idx = idx + 1
                sha2_K_hi[idx], sha2_K_lo[idx] = hi, lo % K_lo_modulo + hi * hi_factor
                break
            end
        until p % d == 0
    until idx > 79
end

-- Calculating IVs for SHA512/224 and SHA512/256
for width = 224, 256, 32 do
    local H_lo, H_hi = {}, {}
    if XOR64A5 then
        for j = 1, 8 do
            H_lo[j] = XOR64A5(sha2_H_lo[j])
        end
    else
        H_hi = {}
        for j = 1, 8 do
            H_lo[j] = XOR32A5(sha2_H_lo[j])
            H_hi[j] = XOR32A5(sha2_H_hi[j])
        end
    end
    sha512_feed_128(
        H_lo,
        H_hi,
        sha2_K_lo,
        sha2_K_hi,
        "SHA-512/" .. tonumber(width) .. "\128" .. string_rep("\0", 115) .. "88",
        0,
        128
    )
    sha2_H_ext512_lo[width] = H_lo
    sha2_H_ext512_hi[width] = H_hi
end

--------------------------------------------------------------------------------
-- MAIN FUNCTIONS
--------------------------------------------------------------------------------

local function sha256ext(width, text)

    -- Create an instance (private objects for current calculation)
    local H, length, tail = { unpack(sha2_H_ext256[width]) }, 0.0, ""

    local function partial(text_part)
        if text_part then
            if tail then
                length = length + #text_part
                local offs = 0
                if tail ~= "" and #tail + #text_part >= 64 then
                    offs = 64 - #tail
                    sha256_feed_64(H, sha2_K_hi, tail .. sub(text_part, 1, offs), 0, 64)
                    tail = ""
                end
                local size = #text_part - offs
                local size_tail = size % 64
                sha256_feed_64(H, sha2_K_hi, text_part, offs, size - size_tail)
                tail = tail .. sub(text_part, #text_part + 1 - size_tail)
                return partial
            else
                error("Adding more chunks is not allowed after receiving the final result", 2)
            end
        else
            if tail then
                local final_blocks = { tail, "\128", string_rep("\0", (-9 - length) % 64 + 1) }
                tail = nil
                -- Assuming user data length is shorter than (2^53)-9 bytes
                -- Anyway, it looks very unrealistic that someone would spend more than a year of calculations to process 2^53 bytes of data by using this Lua script :-)
                -- 2^53 bytes = 2^56 bits, so "bit-counter" fits in 7 bytes
                length = length
                    * (8 / 256 ^ 7) -- convert "byte-counter" to "bit-counter" and move decimal point to the left
                for j = 4, 10 do
                    length = length % 1 * 256
                    final_blocks[j] = char(floor(length))
                end
                final_blocks = table_concat(final_blocks)
                sha256_feed_64(H, sha2_K_hi, final_blocks, 0, #final_blocks)
                local max_reg = width / 32
                for j = 1, max_reg do
                    H[j] = HEX(H[j])
                end
                H = table_concat(H, "", 1, max_reg)
            end
            return H
        end
    end

    if text then
        -- Actually perform calculations and return the SHA256 digest of a message
        return partial(text)()
    else
        -- Return function for chunk-by-chunk loading
        -- User should feed every chunk of input data as single argument to this function and finally get SHA256 digest by invoking this function without an argument
        return partial
    end

end

local function sha512ext(width, text)

    -- Create an instance (private objects for current calculation)
    local length, tail, H_lo, H_hi = 0.0
, ""
, {     unpack(sha2_H_ext512_lo[width]) }
, not HEX64
        and {     unpack(sha2_H_ext512_hi[width]) }

    local function partial(text_part)
        if text_part then
            if tail then
                length = length + #text_part
                local offs = 0
                if tail ~= "" and #tail + #text_part >= 128 then
                    offs = 128 - #tail
                    sha512_feed_128(H_lo, H_hi, sha2_K_lo, sha2_K_hi, tail .. sub(text_part, 1, offs), 0, 128)
                    tail = ""
                end
                local size = #text_part - offs
                local size_tail = size % 128
                sha512_feed_128(H_lo, H_hi, sha2_K_lo, sha2_K_hi, text_part, offs, size - size_tail)
                tail = tail .. sub(text_part, #text_part + 1 - size_tail)
                return partial
            else
                error("Adding more chunks is not allowed after receiving the final result", 2)
            end
        else
            if tail then
                local final_blocks = { tail, "\128", string_rep("\0", (-17 - length) % 128 + 9) }
                tail = nil
                -- Assuming user data length is shorter than (2^53)-17 bytes
                -- 2^53 bytes = 2^56 bits, so "bit-counter" fits in 7 bytes
                length = length
                    * (8 / 256 ^ 7) -- convert "byte-counter" to "bit-counter" and move floating point to the left
                for j = 4, 10 do
                    length = length % 1 * 256
                    final_blocks[j] = char(floor(length))
                end
                final_blocks = table_concat(final_blocks)
                sha512_feed_128(H_lo, H_hi, sha2_K_lo, sha2_K_hi, final_blocks, 0, #final_blocks)
                local max_reg = ceil(width / 64)
                if HEX64 then
                    for j = 1, max_reg do
                        H_lo[j] = HEX64(H_lo[j])
                    end
                else
                    for j = 1, max_reg do
                        H_lo[j] = HEX(H_hi[j]) .. HEX(H_lo[j])
                    end
                    H_hi = nil
                end
                H_lo = sub(table_concat(H_lo, "", 1, max_reg), 1, width / 4)
            end
            return H_lo
        end
    end

    if text then
        -- Actually perform calculations and return the SHA512 digest of a message
        return partial(text)()
    else
        -- Return function for chunk-by-chunk loading
        -- User should feed every chunk of input data as single argument to this function and finally get SHA512 digest by invoking this function without an argument
        return partial
    end

end

local sha2 = {
    sha256 = function(text)
        return sha256ext(256, text)
    end, -- SHA-256
    sha224 = function(text)
        return sha256ext(224, text)
    end, -- SHA-224
    sha512 = function(text)
        return sha512ext(512, text)
    end, -- SHA-512
    sha384 = function(text)
        return sha512ext(384, text)
    end, -- SHA-384
    sha512_224 = function(text)
        return sha512ext(224, text)
    end, -- SHA-512/224
    sha512_256 = function(text)
        return sha512ext(256, text)
    end, -- SHA-512/256
}

return sha2
