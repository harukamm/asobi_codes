# 'is Substring'
# 2016-10-21

def isSubstring_re (str, patn)
  return str.match(/.*#{patn}.*/) != nil
end

def isSubstring_sf (str, patn)
  diffl = str.length - patn.length
  p1 = 0
  while p1 <= diffl do
    i = 0
    while str[p1 + i] == patn[i] do
      i += 1
      return true if i == patn.length
    end
    p1 += 1
  end
  return false
end

def test
  str = "hohogehogehogehoge2"
  patn = "ge2"
  puts (isSubstring_re(str, patn))
  puts (isSubstring_sf(str, patn))
end

test()
