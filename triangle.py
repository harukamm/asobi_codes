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

def randint_avoid(max_, lst):
    if len (lst) == 0:
        return random.randint(0, max_)
    n = lst[0]
    while(n in lst):
        n = random.randint(0, max_)
    return n

def generate_equilateral_triangle(length_side):
    if length_side <= 0 or button_num_width <= length_side:
        print "invalid length_side in generate_equilateral_triangle."
        return []
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
        c = a + (button_num_width - 1) * lengthSide;
        if button_num <= c: break
    return [a, b, c]

def generate_question():
    max_ = len (button_positions) - 1
    length_side = random.randint(1, button_num_width - 1)
    ans = generate_equilateral_triangle(length_side)
    appeared_lst = ans
    point = [[ans[0], ans[1]], [ans[0], ans[2]], [ans[1], ans[2]]]
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

make_question_image(generate_question())
