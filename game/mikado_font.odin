package game

mikado := Font{
  size = 32,
  line_height = 43.125,
  base = 32.25,
  ascent = 25.3125,
  descent = -10.9375,
  width = 256,
  height = 512,
  characters = {
    32 = {x = 216, y = 260, width = 9, height = 9, xoffset = 0, yoffset = 32.25, xadvance = 6.912},
    33 = {x = 105, y = 204, width = 14, height = 31, xoffset = 1.6875, yoffset = 9.5, xadvance = 9.184},
    34 = {x = 138, y = 260, width = 18, height = 18, xoffset = 1.5625, yoffset = 8.9375, xadvance = 12.8},
    35 = {x = 183, y = 141, width = 26, height = 31, xoffset = 1, yoffset = 9.625, xadvance = 20},
    36 = {x = 133, y = 0, width = 25, height = 37, xoffset = 1.0625, yoffset = 6.9375, xadvance = 18.432},
    37 = {x = 73, y = 40, width = 33, height = 32, xoffset = 1, yoffset = 9.1875, xadvance = 26.208},
    38 = {x = 156, y = 76, width = 28, height = 32, xoffset = 1.875, yoffset = 9.375, xadvance = 21.76},
    39 = {x = 156, y = 260, width = 12, height = 18, xoffset = 1.5625, yoffset = 8.9375, xadvance = 6.528},
    40 = {x = 192, y = 0, width = 19, height = 36, xoffset = 1.25, yoffset = 8.875, xadvance = 12.096},
    41 = {x = 211, y = 0, width = 19, height = 36, xoffset = 0.5, yoffset = 8.875, xadvance = 12.064},
    42 = {x = 100, y = 260, width = 19, height = 19, xoffset = 1.3125, yoffset = 7.875, xadvance = 13.408},
    43 = {x = 44, y = 235, width = 24, height = 24, xoffset = 1, yoffset = 15.125, xadvance = 17.152},
    44 = {x = 86, y = 260, width = 14, height = 20, xoffset = 1.375, yoffset = 26.8125, xadvance = 8.608},
    45 = {x = 185, y = 260, width = 17, height = 12, xoffset = 1.8125, yoffset = 21.375, xadvance = 12.48},
    46 = {x = 202, y = 260, width = 14, height = 14, xoffset = 1.375, yoffset = 26.625, xadvance = 8.736},
    47 = {x = 17, y = 40, width = 22, height = 35, xoffset = 0.625, yoffset = 7.625, xadvance = 14.816},
    48 = {x = 163, y = 109, width = 25, height = 32, xoffset = 1.5, yoffset = 9.5, xadvance = 19.616},
    49 = {x = 87, y = 204, width = 18, height = 31, xoffset = 0.25, yoffset = 9.625, xadvance = 12.448},
    50 = {x = 44, y = 204, width = 22, height = 31, xoffset = 0.9375, yoffset = 9.5, xadvance = 16.448},
    51 = {x = 72, y = 141, width = 23, height = 32, xoffset = 0.875, yoffset = 9.5, xadvance = 17.12},
    52 = {x = 80, y = 109, width = 26, height = 32, xoffset = 0.4375, yoffset = 9.5625, xadvance = 18.752},
    53 = {x = 48, y = 141, width = 24, height = 32, xoffset = 0.75, yoffset = 9.5625, xadvance = 17.28},
    54 = {x = 24, y = 141, width = 24, height = 32, xoffset = 1.4375, yoffset = 9.4375, xadvance = 18.016},
    55 = {x = 22, y = 204, width = 22, height = 31, xoffset = 0.8125, yoffset = 9.8125, xadvance = 15.136},
    56 = {x = 106, y = 109, width = 25, height = 32, xoffset = 1.375, yoffset = 9.5, xadvance = 18.912},
    57 = {x = 0, y = 141, width = 24, height = 32, xoffset = 0.875, yoffset = 9.4375, xadvance = 17.952},
    58 = {x = 221, y = 235, width = 14, height = 24, xoffset = 1.6875, yoffset = 17.25, xadvance = 9.248},
    59 = {x = 132, y = 204, width = 14, height = 30, xoffset = 1.6875, yoffset = 17.25, xadvance = 9.376},
    60 = {x = 0, y = 260, width = 22, height = 22, xoffset = 1, yoffset = 16.25, xadvance = 15.552},
    61 = {x = 65, y = 260, width = 21, height = 17, xoffset = 1.9375, yoffset = 18.6875, xadvance = 16.544},
    62 = {x = 22, y = 260, width = 22, height = 22, xoffset = 1.5, yoffset = 16.4375, xadvance = 15.712},
    63 = {x = 95, y = 141, width = 21, height = 32, xoffset = 1, yoffset = 9.3125, xadvance = 14.56},
    64 = {x = 0, y = 0, width = 39, height = 40, xoffset = 1.1875, yoffset = 8.8125, xadvance = 32.864},
    65 = {x = 43, y = 76, width = 29, height = 32, xoffset = 0.75, yoffset = 9.5, xadvance = 22.304},
    66 = {x = 100, y = 173, width = 25, height = 31, xoffset = 2.375, yoffset = 9.8125, xadvance = 20.256},
    67 = {x = 211, y = 76, width = 27, height = 32, xoffset = 1.375, yoffset = 9.5, xadvance = 20.576},
    68 = {x = 129, y = 141, width = 27, height = 31, xoffset = 2.375, yoffset = 9.75, xadvance = 22.368},
    69 = {x = 220, y = 173, width = 23, height = 31, xoffset = 2.375, yoffset = 9.6875, xadvance = 18.464},
    70 = {x = 197, y = 173, width = 23, height = 31, xoffset = 2.375, yoffset = 9.75, xadvance = 18.144},
    71 = {x = 0, y = 109, width = 27, height = 32, xoffset = 1.375, yoffset = 9.5, xadvance = 21.76},
    72 = {x = 100, y = 76, width = 28, height = 32, xoffset = 2.375, yoffset = 9.5, xadvance = 24},
    73 = {x = 119, y = 204, width = 13, height = 31, xoffset = 2.4375, yoffset = 9.8125, xadvance = 9.536},
    74 = {x = 66, y = 204, width = 21, height = 31, xoffset = 0.25, yoffset = 9.5625, xadvance = 15.072},
    75 = {x = 54, y = 109, width = 26, height = 32, xoffset = 2.25, yoffset = 9.6875, xadvance = 20.672},
    76 = {x = 0, y = 204, width = 22, height = 31, xoffset = 2.375, yoffset = 9.625, xadvance = 17.024},
    77 = {x = 39, y = 40, width = 34, height = 32, xoffset = 1, yoffset = 9.5, xadvance = 27.968},
    78 = {x = 27, y = 109, width = 27, height = 32, xoffset = 2.375, yoffset = 9.5625, xadvance = 23.456},
    79 = {x = 13, y = 76, width = 30, height = 32, xoffset = 1.3125, yoffset = 9.4375, xadvance = 24.064},
    80 = {x = 75, y = 173, width = 25, height = 31, xoffset = 2.4375, yoffset = 9.75, xadvance = 19.904},
    81 = {x = 66, y = 0, width = 30, height = 38, xoffset = 1.375, yoffset = 9.4375, xadvance = 24.096},
    82 = {x = 209, y = 141, width = 26, height = 31, xoffset = 2.375, yoffset = 9.75, xadvance = 20.864},
    83 = {x = 50, y = 173, width = 25, height = 31, xoffset = 1.1875, yoffset = 9.5, xadvance = 18.464},
    84 = {x = 25, y = 173, width = 25, height = 31, xoffset = 0.5625, yoffset = 9.5625, xadvance = 17.888},
    85 = {x = 184, y = 76, width = 27, height = 32, xoffset = 2.125, yoffset = 9.375, xadvance = 22.944},
    86 = {x = 128, y = 76, width = 28, height = 32, xoffset = 0.75, yoffset = 9.4375, xadvance = 20.896},
    87 = {x = 96, y = 0, width = 37, height = 32, xoffset = 1.125, yoffset = 9.5, xadvance = 30.784},
    88 = {x = 156, y = 141, width = 27, height = 31, xoffset = 0.375, yoffset = 9.5, xadvance = 19.52},
    89 = {x = 72, y = 76, width = 28, height = 32, xoffset = 0.625, yoffset = 9.5, xadvance = 20.032},
    90 = {x = 125, y = 173, width = 24, height = 31, xoffset = 1.1875, yoffset = 9.6875, xadvance = 18.112},
    91 = {x = 0, y = 40, width = 17, height = 36, xoffset = 2.1875, yoffset = 9.3125, xadvance = 11.872},
    92 = {x = 223, y = 40, width = 21, height = 33, xoffset = 0.6875, yoffset = 8.4375, xadvance = 13.536},
    93 = {x = 230, y = 0, width = 18, height = 36, xoffset = 0.875, yoffset = 9.4375, xadvance = 11.84},
    94 = {x = 44, y = 260, width = 21, height = 18, xoffset = 0.9375, yoffset = 8.875, xadvance = 14.912},
    95 = {x = 119, y = 260, width = 19, height = 11, xoffset = 1.9375, yoffset = 33.6875, xadvance = 13.952},
    96 = {x = 168, y = 260, width = 17, height = 14, xoffset = 2, yoffset = 9.3125, xadvance = 12.8},
    97 = {x = 115, y = 235, width = 22, height = 24, xoffset = 1, yoffset = 16.4375, xadvance = 16.032},
    98 = {x = 131, y = 40, width = 24, height = 33, xoffset = 1.5625, yoffset = 8, xadvance = 18.784},
    99 = {x = 137, y = 235, width = 22, height = 24, xoffset = 1.125, yoffset = 16.625, xadvance = 15.232},
    100 = {x = 106, y = 40, width = 25, height = 33, xoffset = 1.125, yoffset = 8.0625, xadvance = 19.136},
    101 = {x = 92, y = 235, width = 23, height = 24, xoffset = 1.125, yoffset = 16.625, xadvance = 16.192},
    102 = {x = 201, y = 40, width = 22, height = 33, xoffset = 0.4375, yoffset = 8.125, xadvance = 12.608},
    103 = {x = 0, y = 173, width = 25, height = 31, xoffset = 1.125, yoffset = 16.6875, xadvance = 19.04},
    104 = {x = 155, y = 40, width = 23, height = 33, xoffset = 2, yoffset = 8.0625, xadvance = 18.4},
    105 = {x = 116, y = 141, width = 13, height = 32, xoffset = 1.625, yoffset = 9.0625, xadvance = 8},
    106 = {x = 39, y = 0, width = 16, height = 39, xoffset = -0.5625, yoffset = 9, xadvance = 8.064},
    107 = {x = 178, y = 40, width = 23, height = 33, xoffset = 1.6875, yoffset = 8.0625, xadvance = 17.088},
    108 = {x = 0, y = 76, width = 13, height = 33, xoffset = 1.9375, yoffset = 8.0625, xadvance = 7.968},
    109 = {x = 188, y = 109, width = 32, height = 24, xoffset = 1.875, yoffset = 16.6875, xadvance = 27.008},
    110 = {x = 0, y = 235, width = 23, height = 25, xoffset = 1.875, yoffset = 16.5, xadvance = 18.24},
    111 = {x = 68, y = 235, width = 24, height = 24, xoffset = 1.125, yoffset = 16.5625, xadvance = 17.792},
    112 = {x = 149, y = 173, width = 24, height = 31, xoffset = 1.8125, yoffset = 16.375, xadvance = 19.04},
    113 = {x = 173, y = 173, width = 24, height = 31, xoffset = 1.1875, yoffset = 16.5625, xadvance = 18.848},
    114 = {x = 179, y = 235, width = 18, height = 24, xoffset = 2, yoffset = 16.4375, xadvance = 12.256},
    115 = {x = 23, y = 235, width = 21, height = 25, xoffset = 1.0625, yoffset = 16.5, xadvance = 14.496},
    116 = {x = 146, y = 204, width = 20, height = 29, xoffset = 0.6875, yoffset = 12.4375, xadvance = 12.832},
    117 = {x = 213, y = 204, width = 23, height = 25, xoffset = 1.6875, yoffset = 16.5625, xadvance = 18.112},
    118 = {x = 166, y = 204, width = 24, height = 25, xoffset = 0.75, yoffset = 16.4375, xadvance = 16.992},
    119 = {x = 131, y = 109, width = 32, height = 25, xoffset = 0.875, yoffset = 16.1875, xadvance = 24.896},
    120 = {x = 190, y = 204, width = 23, height = 25, xoffset = 0.4375, yoffset = 16.25, xadvance = 16.096},
    121 = {x = 220, y = 109, width = 24, height = 32, xoffset = 0.625, yoffset = 16.375, xadvance = 16.608},
    122 = {x = 159, y = 235, width = 20, height = 24, xoffset = 1.125, yoffset = 16.625, xadvance = 13.984},
    123 = {x = 175, y = 0, width = 17, height = 37, xoffset = 0.75, yoffset = 9, xadvance = 10.24},
    124 = {x = 55, y = 0, width = 11, height = 39, xoffset = 2.125, yoffset = 8.4375, xadvance = 6.592},
    125 = {x = 158, y = 0, width = 17, height = 37, xoffset = 0.875, yoffset = 9, xadvance = 10.24},
    126 = {x = 197, y = 235, width = 24, height = 14, xoffset = 1.4375, yoffset = 19.125, xadvance = 18.016},
  }
}
