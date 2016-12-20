# textfile to markdown

def read_f2arr (fname)
  arr = []
  File.open(fname, "r") do |f|
    f.each_line do |line|
      arr.push(line)
    end
  end  
  return arr
end

def write_arr2f(arr, fname)
  File.open(fname, "w") do |f|
    arr.each{|s|
      f.print(s)
    }
  end
end

def cb2arr()
  arr = []
  text = `pbpaste`
  text = text  + "\n"
  text.each_line do |line|
    arr.push(line)
  end
  return arr
end

def arr2cb(arr)
  tmp = "tmptmp"
  write_arr2f(arr, tmp)
  `pbcopy < #{tmp}`
  `rm #{tmp}`
end

def add_space (arr)
  newarr = []
  arr.each{|s|
    str = s.dup
    str.gsub!(/([^\s{2,}])\n/){"#{$1}\s\s\n"}
    str.gsub!(/^\s?\n/, "\s\s\n")
    newarr.push(str)
  }
  return newarr
end

def remove_space (arr)
  newarr = []
  arr.each{|s|
    str = s.dup
    str.gsub!(/  \n/, "\n") 
    newarr.push(str)
  }
  return newarr
end

# fname = ARGV[0]
# read_f2arr(fname)

arr = cb2arr()
newarr = add_space(arr)
arr2cb(newarr)
