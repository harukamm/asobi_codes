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

# draw functions
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
        draw_button(draw, p[0], used_button_color)
        draw_button(draw, p[1], used_button_color)
        draw_line(draw, p[0], p[1])
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

# for making new question automatically
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
    if (posy[0] - posx[0]) == 0 or (posz[0] - posy[0]) == 0:
        return posy[0] == posx[0] == posz[0]
    katamuki_xy = (posy[1] - posx[1]) / (posy[0] - posx[0])
    katamuki_yz = (posz[1] - posy[1]) / (posz[0] - posy[0])
    return (math.pow (katamuki_xy - katamuki_yz, 2) < 0.1)

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

def contain_single_eqtriangle(point):
    eqtriangle_num = 0
    for i, pair in enumerate(point):
        n1 = pair[0]
        n2 = pair[1]
        linked_n1 = [False] * button_num
        linked_n2 = [False] * button_num
        for x in range(i, len (point)):
            pair_2 = point[x]
            if pair_2[0] == n1:
                linked_n1[pair_2[1]] = True
            elif pair_2[0] == n2:
                linked_n2[pair_2[1]] = True
            elif pair_2[1] == n1:
                linked_n1[pair_2[0]] = True
            elif pair_2[1] == n2:
                linked_n2[pair_2[0]] = True
        for x in xrange(button_num):
            if linked_n1[x] and linked_n2[x]:
                if is_eqtriangle(x, n1, n2):
                    eqtriangle_num += 1
    return eqtriangle_num == 1

def generate_ans(length_side):
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

def generate_ans_and_point(dammy_line_num):
    length_side = random.randint(1, button_num_width - 1)
    ans = generate_ans(length_side)
    appeared_lst = ans
    point = [[ans[0], ans[1]], [ans[0], ans[2]], [ans[1], ans[2]]]
    diff = c = 0
    while c < dammy_line_num:
        new_point = []
        i = randbutton_avoid(appeared_lst)
        if False: #c == dammy_line_num - 1:
            j = appeared_lst[random.randint(0, len (appeared_lst) - 1)]
            new_point = point + [[i, j]]
            diff = 1
        else:
            pair = point[random.randint(0, len (point) - 1)]
            if is_on_straight(i, pair[0], pair[1]):
                continue
            new_point = point + [[i, pair[0]], [i, pair[1]]]
            diff = 2
        if contain_single_eqtriangle(new_point):
            point[:] = new_point
            appeared_lst.append(i)
            c += diff
        else: print "no!"
    print point
    return [ans, point]

def generate_question():
    ps = generate_ans_and_point(9)
    ans = ps[0]
    point = ps[1]
    return { "name": "test", "level": 10, "ans": ans, "point": point }

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

q = generate_question()
make_question_image(q)
# print (is_on_straight(2, 13, 24))
