# 'is Substring'
# 2016-10-21

def isSubstring_re (str, patn)
  return str.match(/.*#{patn}.*/) != nil
end

def isSubstring_sf (str, patn)
  diffl = str.length - patn.length
  p1 = p2 = 0
  while p1 <= diffl do
    p1_tmp = p1
    while str[p1] == patn[p2] do
      p1 += 1
      p2 += 1
      return true if p2 == patn.length
    end
    p1, p2 = p1_tmp + 1, 0
  end
  return false
end

def test
  str = "hogehogehogehogehoge2"
  patn = "ge2"
  puts (isSubstring_re(str, patn))
  puts (isSubstring_sf(str, patn))
end

test()
