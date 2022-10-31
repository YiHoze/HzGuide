-- require"xindex-ko"
--[[
-- xindex-ko.lua
--    written by Dohyun Kim
--    license: LPPL
--    reference: KS X 1026-1:2007
--
--    usage: xindex -c ko -l ko file.idx
--
--]]

local function is_hangul (c)
  return c >= 0xAC00 and c <= 0xD7A3
end

local function is_jamoL (c)
  return c >= 0x1100 and c <= 0x115F
  or     c >= 0xA960 and c <= 0xA97C
end

local function is_jamoV (c)
  return c >= 0x1160 and c <= 0x11A7
  or     c >= 0xD7B0 and c <= 0xD7C6
end

local function is_jamoT (c)
  return c >= 0x11A8 and c <= 0x11FF
  or     c >= 0xD7CB and c <= 0xD7FB
end

local function is_cpjamo (c)
  return c >= 0x3131 and c <= 0x318E
end

local hanja_hangul_tab = {
  { "hanja_hangul.tab",    0x4E00, 0x9FA5, },
  { "hanjacom_hangul.tab", 0xF900, 0xFA2D, },
  { "hanjaexa_hangul.tab", 0x3400, 0x4DB5, },
}

local hanja2hangul = {}

local function add_to_hanja2hangul (filename, i, last)
  local f = kpse.find_file(filename)
  if f then
    for c in io.lines(f) do
      hanja2hangul[i] = tonumber(c)
      i = i + 1
    end
  else
    writeLog(2, string.format("xindex-ko.lua Warning: cannot find %s.", filename), 0)
    for c = i, last do
      hanja2hangul[c] = c
    end
  end
end

local function convert_hanja_hangul (c)
  if hanja2hangul[c] then
    return hanja2hangul[c]
  end

  for i = 1, 3 do
    local t = hanja_hangul_tab[i]
    if c >= t[2] and c <= t[3] then
      add_to_hanja2hangul(table.unpack(t))
      if hanja2hangul[c] then
        return hanja2hangul[c]
      end
      break
    end
  end

  return c
end

-- a transformation table from Hangul Compatibility Letters (0x3131..0x318E)
-- to Johab Hangul Letters (0x1100..0x11FF)
local cpjamo2jamo = { [0]=
          0x1100, 0x1101, 0x11AA, 0x1102, 0x11AC, 0x11AD, 0x1103,
  0x1104, 0x1105, 0x11B0, 0x11B1, 0x11B2, 0x11B3, 0x11B4, 0x11B5,
  0x111A, 0x1106, 0x1107, 0x1108, 0x1121, 0x1109, 0x110A, 0x110B,
  0x110C, 0x110D, 0x110E, 0x110F, 0x1110, 0x1111, 0x1112, 0x1161,
  0x1162, 0x1163, 0x1164, 0x1165, 0x1166, 0x1167, 0x1168, 0x1169,
  0x116A, 0x116B, 0x116C, 0x116D, 0x116E, 0x116F, 0x1170, 0x1171,
  0x1172, 0x1173, 0x1174, 0x1175, 0x1160, 0x1114, 0x1115, 0x11C7,
  0x11C8, 0x11CC, 0x11CE, 0x11D3, 0x11D7, 0x11D9, 0x111C, 0x11DD,
  0x11DF, 0x111D, 0x111E, 0x1120, 0x1122, 0x1123, 0x1127, 0x1129,
  0x112B, 0x112C, 0x112D, 0x112E, 0x112F, 0x1132, 0x1136, 0x1140,
  0x1147, 0x114C, 0x11F1, 0x11F2, 0x1157, 0x1158, 0x1159, 0x1184,
  0x1185, 0x1188, 0x1191, 0x1192, 0x1194, 0x119E, 0x11A1,
}

-- The order values for Johab Hangul Letters 0x1100..0x11FF
local index1100 = { [0]=
    1,  2, 12, 24, 26, 36, 70, 86, 93,109,118,138,161,165,171,176,
  177,179,185, 13, 14, 15, 17, 25, 41, 45, 66, 69, 77, 85, 87, 88,
   89, 94, 95, 96, 97, 98, 99,101,102,104,105,107,108,110,111,112,
  113,114,115,116,122,124,125,126,127,128,129,130,131,132,133,134,
  135,139,140,142,143,144,145,146,147,148,149,150,152,164,167,168,
  169,170,172,173,174,175,180,184,191,192,  4, 18, 20, 23, 28,194,
    0,  1,  5,  6, 10, 11, 15, 16, 20, 21, 22, 23, 33, 34, 43, 46,
   48, 52, 54, 64, 71, 73,  2,  3,  7,  8, 12, 13, 14, 18, 19, 26,
   27, 29, 30, 32, 37, 38, 40, 41, 42, 44, 45, 47, 50, 51, 55, 57,
   58, 59, 60, 62, 63, 69, 70, 72, 74, 75, 80, 83, 85, 87, 88, 90,
   92, 93, 94,  4,  9, 17, 24, 25,  1,  2,  7, 12, 20, 23, 24, 36,
   37, 47, 51, 58, 64, 65, 66, 70, 86, 94,109,118,138,161,171,176,
  177,179,185,  5,  8, 13, 15, 18, 19, 22, 25, 28, 39, 41, 42, 44,
   45, 48, 49, 54, 56, 57, 59, 60, 63, 67, 71, 75, 77, 79, 80, 81,
   83, 84, 85, 90,105,106,107,110,112,113,115,135,153,154,158,159,
  152,156,157,180,184,186,187,188,189,192,  3,  6,  9, 10, 11, 14,
}

-- The order values for Johab Hangul Syllable-Initial Letters 0xA960..0xA97C
local indexA960 = { [0]=
   29, 30, 31, 33, 37, 38, 42, 43, 47, 51, 53, 57, 58, 62, 63, 71,
   74, 79,100,103,106,121,141,151,166,178,183,190,193,
}

--  The order values for Johab Hangul Syllable-Peak Letters 0xD7B0..0xD7C6
local indexD7B0 = { [0]=
   28, 31, 35, 36, 39, 49, 53, 56, 61, 65, 66, 67, 68, 76, 77, 78,
   79, 81, 82, 84, 86, 89, 91,
}

--  The order values for Johab Hangul Syllable-Final Letters 0xD7CB..0xD7FB
local indexD7CB = { [0]=
                                               16, 21, 26, 27, 30,
   31, 32, 33, 34, 35, 38, 40, 46, 50, 52, 55, 61, 68, 69, 72, 73,
   76, 78, 82, 89, 91, 92, 93, 96,101,102,114,117,119,120,123,125,
  126,128,130,136,137,155,160,162,163,165,181,182,
}

local weight_group = {
  index1100[0x00], index1100[0x02], index1100[0x03], index1100[0x05],
  index1100[0x06], index1100[0x07], index1100[0x09], index1100[0x0B],
  index1100[0x0C], index1100[0x0E], index1100[0x0F], index1100[0x10],
  index1100[0x11], index1100[0x12], index1100[0x5F],
}

local jamo_header = {
  0x3131, 0x3134, 0x3137, 0x3139, 0x3141, 0x3142, 0x3145, 0x3147,
  0x3148, 0x314A, 0x314B, 0x314C, 0x314D, 0x314E, 0x314F,
}

local function LWgroup (w)
  for i=#weight_group, 1, -1 do
    if w >= weight_group[i] then
      return jamo_header[i]
    end
  end
end

local SBase = 0xAC00
local LBase = 0x1100
local VBase = 0x1161
local TBase = 0x11A7
local VCount = 21
local TCount = 28
local NCount = VCount * TCount

--[[
Table C.3 Weights for each Hangul Letter or Syllable Block for sorting
+----------------------------------------------+---------+
| An Order Value for a Syllable-Initial Letter | 0 - 255 |
| An Order Value for a Syllable-Peak Letter    | 0 - 255 |
| An Order Value for a Syllable-Final Letter   | 0 - 255 |
| A Type Value for Character Class             | 0 - 255 |
+----------------------------------------------+---------+

A Weight is a 32-bit unsigned integer as shown in Table C.3 and is
composed of four values. ... The final (i.e., fourth) byte is
used for ordering characters based on character types and ...
is assigned the following values as an example.

0 is assigned to a Johab/Wanseong Hangul Syllable Block.
1 is assigned when there is only a Syllable-Final Letter.
2 is assigned to a Halfwidth Hangul Letter.
3 is assigned to a Hangul Compatibility Letter.
4 is assigned to a Parenthesized Hangul Letter/Syllable Block.
5 is assigned to a Circled Hangul Letter/Syllable Block.
--]]

local function append_weight (L, V, T, genera, t, head)
  local LW, VW, TW = 0, 0, 0

  LW = L <= 0x11FF and index1100[L-0x1100] or indexA960[L-0xA960]
  VW = V <= 0x11FF and index1100[V-0x1100] or indexD7B0[V-0xD7B0]
  if T ~= 0 then
    TW = T <= 0x11FF and index1100[T-0x1100] or indexD7CB[T-0xD7CB]
  end

  -- If there is only a Hangul Syllable-Final Letter,
  -- compute a weight as if it were a Syllable-Initial Letter.
  if L == 0x115F and V == 0x1160 and T ~= 0 then
    LW, TW, genera = TW, 0, 1
  end

  for _, w in ipairs{ LW+LBase, VW+LBase, TW+LBase, genera } do
    table.insert(t, w)
  end

  return {}, #t == 4 and LW or head
end

function SORTprehook (data)
  for _, v in ipairs(data) do

    if type(xindexko_DataHook) == "function" then
      xindexko_DataHook(v)
    end

    v.origEntry = v.Entry

    local t, lvt, head = {}, {}

    for _, c in utf8.codes(v.Entry) do

      c = convert_hanja_hangul(c) -- hanja to hangul

      if #lvt == 2 and not is_jamoT(c) then
        table.insert(lvt, 0)
      end
      if #lvt == 3 then
        lvt, head = append_weight(lvt[1], lvt[2], lvt[3], 0, t, head)
      end

      if is_jamoL(c) and #lvt == 0 then
        table.insert(lvt, c)
      elseif is_jamoV(c) and #lvt == 1 then
        table.insert(lvt, c)
      elseif is_jamoT(c) and #lvt == 2 then
        table.insert(lvt, c)

      elseif is_hangul(c) then
        local SIndex = c - SBase
        local L = SIndex // NCount + LBase
        local V = SIndex % NCount // TCount + VBase
        local T = SIndex % TCount + TBase
        if T == TBase then
          T = 0
        end
        lvt, head = append_weight(L, V, T, 0, t, head)

      elseif is_cpjamo(c) then
        local L, V, T = 0x115F, 0x1160, 0
        local j = cpjamo2jamo[c-0x3131]
        if is_jamoL(j) then
          L = j
        elseif is_jamoV(j) then
          V = j
        elseif is_jamoT(j) then
          T = j
        end
        lvt, head = append_weight(L, V, T, 3, t, head)

      else
        table.insert(t, c)
      end
    end
    if #lvt == 2 then
      table.insert(lvt, 0)
    end
    if #lvt == 3 then
      lvt, head = append_weight(lvt[1], lvt[2], lvt[3], 0, t, head)
    end
    v.Entry = utf8.char(table.unpack(t))

    if head then
      v.sortChar = utf8.char( LWgroup(head) )
    end
  end

  return data
end

function SORTposthook (data)
  for _, v in ipairs(data) do
    v.Entry = v.origEntry
    v.origEntry = nil
  end

  return data
end

function SORTendhook (data)
  local en_begin, ko_begin

  for i, v in ipairs(data) do
    if not en_begin and string.find(v.sortChar, "%a") then
      en_begin = i
    elseif utf8.codepoint(v.sortChar) >= LBase then
      ko_begin = i
      break
    end
  end

  if en_begin and ko_begin then
    local t = {}
    table.move(data, 1, en_begin-1, 1, t)
    table.move(data, ko_begin, #data, #t+1, t)
    table.move(data, en_begin, ko_begin-1, #t+1, t)
    return t
  end

  return data
end

local indexheader = indexheader or {}
indexheader.ko = { "기호", "숫자" }

--[[
-- load xindex-cfg.lua; change some global variables
--]]

require"xindex-cfg"

fCompress   = false
minCompress = 2
sublabels   = {"", "", "", ""}

-- end of xindex-ko 

idxnewletter = "\\lettergroup"