#!/usr/bin/env python
# -*- coding: utf-8 -*-
from PIL import Image, ImageDraw
import math, json, random

fname = "findtrianglesecond.json"

# screen length
screen_width = 400
screen_height = 300

# number of buttons
button_num_width = 6
button_num_height = 6
button_num = button_num_width * button_num_height

# color, design
white = 'white'
moji_color = 'black'
used_button_color = 'black'
ans_button_color = '#ff0000'
unused_button_color = '#ddd'
line_color = 'black'
button_radius = 3

ippen = 42.0
takasa = ippen * math.sqrt(3) / 2
block_width = (button_num_width - 1) * ippen + (button_num_height - 1) * ippen / 2
block_height = (button_num_height - 1) * takasa
margin_left = (screen_width - block_width) / 2
margin_top = (screen_height - block_height) / 2

button_positions = []
questions = []

# ################################################
# draw functions
# ################################################
def draw_button(draw, n, color):
    pos = button_positions[n]
    x = pos[0]
    y = pos[1]
    draw.text((x + button_radius, y - button_radius), str(n), fill=moji_color)
    draw.ellipse((x - button_radius, y - button_radius,
                  x + button_radius, y + button_radius),
                 fill=color, outline=color)
    return 0

def draw_default_buttons(draw):
    for n in xrange(len (button_positions)):
        draw_button(draw, n, unused_button_color)
    return 0

def draw_line(draw, n1, n2):
    pos1 = button_positions[n1]
    pos2 = button_positions[n2]
    x1 = pos1[0]
    y1 = pos1[1]
    x2 = pos2[0]
    y2 = pos2[1]
    draw.line((x1, y1, x2, y2), fill=line_color, width=2)
    return 0

def draw_question(draw, question):
    point = question["point"]
    for p in point:
        draw_button(draw, p, used_button_color)
    line = question["line"]
    for pair in line:
        draw_line(draw, pair[0], pair[1])
    ans = question["ans"]
    draw_button(draw, ans[0], ans_button_color)
    draw_button(draw, ans[1], ans_button_color)
    draw_button(draw, ans[2], ans_button_color)
    return 0

def make_question_image(question):
    image = Image.new('RGBA', (screen_width, screen_height))
    draw = ImageDraw.Draw(image)
    # paint background with white
    draw.rectangle((0, 0, screen_width, screen_height), fill=white, outline=white)
    draw_default_buttons(draw)

    draw_question(draw, question)
    name = question["name"]
    image.save('%s.png' % name)
    print "generated " + name + ".png"
    return 0

# ################################################
# for making new question automatically
# ################################################
def randbutton_avoid(lst):
    if len (lst) == 0:
        return random.randint(0, button_num - 1)
    n = lst[0]
    while(n in lst):
        n = random.randint(0, button_num - 1)
    return n

def is_on_straight(x, y, z):
    posx = button_positions[x]
    posy = button_positions[y]
    posz = button_positions[z]
    if posy[0] == posx[0] and posz[0] == posy[0]:
        return True
    elif posy[0] == posx[0]:
        return posy[1] == posx[1]
    elif posz[0] == posy[0]:
        return posz[1] == posy[1]
    katamuki_xy = (posy[1] - posx[1]) / (posy[0] - posx[0])
    katamuki_yz = (posz[1] - posy[1]) / (posz[0] - posy[0])
    return (math.pow (katamuki_xy - katamuki_yz, 2) < 0.01)

def is_extension(pair1, pair2):
    b1 = is_on_straight(pair1[0], pair1[1], pair2[0])
    b2 = is_on_straight(pair1[0], pair1[1], pair2[1])
    if b1 and b2:
        pair1.sort()
        pair2.sort()
        return pair1[0] == pair2[1] or pair1[1] == pair2[0]
    else:
        return False

def have_deplicate_line(line, pair):
    for p in line:
        b1 = is_on_straight(p[0], p[1], pair[0])
        b2 = is_on_straight(p[0], p[1], pair[1])
        if (b1 and b2) and (not is_extension(p, pair)):
            return True
    return False

def get_dist(n1, n2):
    pos1 = button_positions[n1]
    pos2 = button_positions[n2]
    return math.sqrt (math.pow(pos1[0] - pos2[0], 2) +
                      math.pow(pos1[1] - pos2[1], 2))

def is_eqtriangle(x, y, z):
    dist1 = get_dist(x, y)
    dist2 = get_dist(y, z)
    dist3 = get_dist(x, z)
    return (math.pow(dist1 - dist2, 2) < 0.1 and
            math.pow(dist2 - dist3, 2) < 0.1 and
            math.pow(dist3 - dist1, 2) < 0.1)

def include_in_line(line, pair):
    pair.sort()
    for pair2 in line:
        pair2.sort()
        if pair2[0] <= pair[0] and pair[1] <= pair2[1]:
            b1 = is_on_straight(pair2[0], pair2[1], pair[0])
            b2 = is_on_straight(pair2[0], pair2[1], pair[1])
            if b1 and b2:
                return True
    return False

def include_triangle(line, triangle):
    if len(triangle) != 3:
        return False
    p1 = [triangle[0], triangle[1]]
    p2 = [triangle[1], triangle[2]]
    p3 = [triangle[0], triangle[2]]
    return include_in_line(line, p1) and \
        include_in_line(line, p2) and \
        include_in_line(line, p3)

def contain_single_eqtriangle(line, point):
    eqtriangle_num = 0
    length = len(point)
    for i in xrange(0, length):
        for j in xrange(i + 1, length):
            for k in xrange(j + 1, length):
                if is_eqtriangle(point[i], point[j], point[k]) and \
                   include_triangle(line, [point[i], point[j], point[k]]):
                    eqtriangle_num += 1
                    if 1 < eqtriangle_num:
                        return False
    return eqtriangle_num == 1

def generate_eqtriangle(length_side):
    a = b = c = -1
    while True:
        a = random.randint(0, button_num - 1)
        if a % button_num_width < length_side:
            continue
        b = a - length_side
        upward = random.randint(0, 1) == 0
        if upward:
            c = a - button_num_width * length_side
            if c >= 0: break
        c = a + (button_num_width - 1) * length_side;
        if c < button_num: break
    return [a, b, c]

def generate_noneqtriangle():
    a = b = c = -1
    while True:
        a = random.randint(0, button_num - 1)
        b = random.randint(0, button_num - 1)
        c = random.randint(0, button_num - 1)
        if not is_on_straight(a, b, c) and not is_eqtriangle(a, b, c):
            break
    return [a, b, c]

def de_duplicate(lst):
    lst2 = []
    for x in lst:
        if x not in lst2:
            lst2.append(x)
    return lst2

def get_common(lst1, lst2):
    lst_ = []
    for x in lst1:
        for y in lst2:
            if x == y:
                lst_.append(x)
    return de_duplicate(lst_)

def get_cross_buttons(pair):
    n1 = pair[1] if pair[0] > pair[1] else pair[0]
    n2 = pair[0] if pair[0] > pair[1] else pair[1]
    inters = []
    for x in xrange(n1 + 1, n2):
        if is_on_straight(n1, x, n2):
            inters.append(x)
    return inters

def get_intersec(line, pair):
    crossed = get_cross_buttons(pair)
    inters = []
    for pair2 in line:
        lst = get_cross_buttons(pair2)
        lst2 = get_common(crossed, lst)
        inters[:] = inters + lst2
    return inters

def generate_entries(dammy_line_num):
    length_side = random.randint(1, button_num_width - 1)
    ans = generate_eqtriangle(length_side)
    appeared_lst = ans[:]
    line = [[ans[0], ans[1]], [ans[0], ans[2]], [ans[1], ans[2]]]
    diff = c = 0
    while c < dammy_line_num:
        new_pairs = []
        new_points = []
        if False: # patten 1
            t = generate_noneqtriangle()
            new_pairs = [[t[0], t[1]], [t[0], t[2]], [t[1], t[2]]]
            new_points = [t[0], t[1], t[2]]
            diff = 3
        else: # patten 2
            i = randbutton_avoid(appeared_lst)
            pair = line[random.randint(0, len (line) - 1)]
            if is_on_straight(i, pair[0], pair[1]):
                continue
            new_pairs = [[i, pair[0]], [i, pair[1]]]
            new_points = [i]
            diff = 2

        have_dep = False
        for pair in new_pairs:
            have_dep = have_dep or have_deplicate_line(line, pair)
        if have_dep:
            continue
        inters = []
        for pair in new_pairs:
            inters[:] = inters + get_intersec(line, pair)

        # Add new points and pairs if num of equal triangle is single.
        if contain_single_eqtriangle(line + new_pairs, appeared_lst + inters + new_points):
            appeared_lst[:] = appeared_lst + inters + new_points
            line[:] = line + new_pairs
            c += diff
    return [ans, appeared_lst, line]

def generate_question(str):
    ps = generate_entries(20)
    ans = ps[0]
    point = ps[1]
    line = ps[2]
    return { "name": str, "level": 10, "ans": ans,
             "point": point, "line": line }

# initialize button_positions
for num_y in xrange(button_num_height):
    x = margin_left + num_y * ippen / 2
    y = margin_top + num_y * takasa
    for num_x in xrange(button_num_width):
        button_positions.append([x, y])
        x += ippen

# initialize questions
f = open(fname)
data = json.load(f)
for d in data:
    questions.append(d)

q = { "name": "test", "level": 10, "ans": [7, 10, 25], "point": [7, 10, 25, 22, 33, 13], "line": [[7, 10], [7, 25], [10, 25], [7, 22], [22, 10], [33, 22], [33, 10], [13, 33], [13, 10]] }

q = { "name": "test", "level": 10, "ans": generate_noneqtriangle(), "point": [], "line": [] }

q = generate_question("test2")
print "------------------"
print q
make_question_image(q)
#print get_cross_buttons([1, 27])
#print (is_on_straight(1, 29, 29))
#print get_intersec ([[1, 27], [12, 26]], [4, 24])
#print get_intersec([[1, 17]], [7, 10])
#print is_on_straight(1, 9, 17) # excepted: False

#print get_intersec([[7, 10], [7, 25], [10, 25], [24, 25]], [0, 7])
#print is_extension([24, 20], [16, 20])


#print have_deplicate_line ([[7, 10], [7, 25], [10, 25], [24, 7], [24, 25], [0, 24], [0, 7]], [28, 7])

# {'point': [7, 10, 25, 22, 34, 13, 19, 1], 'line': [[7, 10], [7, 25], [10, 25], [7, 22], [22, 10], [7, 34], [34, 25], [1, 10], [1, 25]], 'ans': [7, 10, 25], 'name': 'test', 'level': 10}

#print have_deplicate_line([[7, 10], [7, 25], [10, 25], [7, 22], [22, 10], [7, 34], [34, 25], [1, 10]], [1, 25])

#print have_deplicate_line([[7, 10], [7, 25], [10, 25], [19, 10]], [19, 25])

'''
print is_on_straight(0, 20, 33)
print is_on_straight(0, 13, 33)
print is_on_straight(13, 20, 27)
print is_on_straight(30, 17, 21)
print is_on_straight(30, 17, 26)
'''

#{'point': [33, 30, 15, 22, 23, 16, 2, 12, 5, 18, 8, 35, 24], 'line': [[30, 33], [33, 15], [15, 30], [22, 30], [22, 15], [23, 30], [23, 15], [16, 30], [16, 33], [2, 22], [2, 15], [12, 16], [12, 30], [5, 23], [5, 15], [18, 16], [18, 33], [8, 12], [8, 30], [35, 18], [35, 16], [24, 16], [24, 33]], 'ans': [33, 30, 15], 'name': 'test2', 'level': 10}

#print contain_single_eqtriangle([[30, 33], [33, 15], [15, 30], [22, 30], [22, 15], [23, 30], [23, 15], [16, 30], [16, 33], [2, 22], [2, 15], [12, 16], [12, 30], [5, 23], [5, 15], [18, 16], [18, 33], [8, 12], [8, 30], [35, 18], [35, 16], [24, 16], [24, 33]], [33, 30, 15, 22, 23, 16, 2, 12, 5, 18, 8, 35, 24])
#print get_intersec([[24, 16]], [30, 15])


#print include_in_line([[30, 33], [33, 15], [15, 30], [22, 30], [22, 15], [23, 30], [23, 15], [16, 30], [16, 33], [2, 22], [2, 15], [12, 16], [12, 30], [5, 23], [5, 15], [18, 16], [18, 33], [8, 12], [8, 30], [35, 18], [35, 16], [24, 16], [24, 33]], [13, 14])
# print include_in_line([[12, 16]], [16, 12])
