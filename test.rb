# test.rb
# Copyright (C) 2003-2006  K.Kosako (sndgk393 AT ybb DOT ne DOT jp)

$SILENT = false
if (ARGV.size > 0 and ARGV[0] == '-s')
  $SILENT = true
end

def pr(result, reg, str, n = 0, *range)
  printf("%s /%s/:'%s'", result, reg.source, str)
  if (n.class == Fixnum)
    printf(":%d", n) if n != 0
    if (range.size > 0)
      if (range[3].nil?)
	printf(" (%d-%d : X-X)", range[0], range[1])
      else
	printf(" (%d-%d : %d-%d)", range[0], range[1], range[2], range[3])
      end
    end
  else
    printf("  %s", n)
  end
  printf("\n")
end

def rok(result_opt, reg, str, n = 0, *range)
  result = "OK" + result_opt
  result += " " * (7 - result.length) 
  pr(result, reg, str, n, *range) unless $SILENT
  $rok += 1
end

def rfail(result_opt, reg, str, n = 0, *range)
  result = "FAIL" + result_opt
  result += " " * (7 - result.length) 
  pr(result, reg, str, n, *range)
  $rfail += 1
end

def x(reg, str, s, e, n = 0)
  m = reg.match(str)
  if m
    if (m.size() <= n)
      rfail("(%d)" % (m.size()-1), reg, str, n)
    else
      if (m.begin(n) == s && m.end(n) == e)
	rok("", reg, str, n)
      else
	rfail("", reg, str, n, s, e, m.begin(n), m.end(n))
      end
    end
  else
    rfail("", reg, str, n)
  end
end

def n(reg, str)
  m = reg.match(str)
  if m
    rfail("(N)", reg, str, 0)
  else
    rok("(N)", reg, str, 0)
  end
end

def r(reg, str, index, pos = nil)
  if (pos)
    res = str.rindex(reg, pos)
  else
    res = str.rindex(reg)
  end
  if res
    if (res == index)
      rok("(r)", reg, str)
    else
      rfail("(r)", reg, str, [res, '-', index])
    end
  else
    rfail("(r)", reg, str)
  end
end

def i(reg, str, s = 0, e = 0, n = 0)
  # ignore
end

### main ###
$rok = $rfail = 0


x(/\M-Z/n, "\xDA", 0, 1)

# from URI::ABS_URI
n(/^
        ([a-zA-Z][-+.a-zA-Z\d]*):                     (?# 1: scheme)
        (?:
           ((?:[-_.!~*'()a-zA-Z\d;?:@&=+$,]|%[a-fA-F\d]{2})(?:[-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]]|%[a-fA-F\d]{2})*)              (?# 2: opaque)
        |
           (?:(?:
             \/\/(?:
                 (?:(?:((?:[-_.!~*'()a-zA-Z\d;:&=+$,]|%[a-fA-F\d]{2})*)@)?  (?# 3: userinfo)
                   (?:((?:(?:(?:[a-zA-Z\d](?:[-a-zA-Z\d]*[a-zA-Z\d])?)\.)*(?:[a-zA-Z](?:[-a-zA-Z\d]*[a-zA-Z\d])?)\.?|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|\[(?:(?:[a-fA-F\d]{1,4}:)*(?:[a-fA-F\d]{1,4}|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|(?:(?:[a-fA-F\d]{1,4}:)*[a-fA-F\d]{1,4})?::(?:(?:[a-fA-F\d]{1,4}:)*(?:[a-fA-F\d]{1,4}|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))?)\]))(?::(\d*))?))?(?# 4: host, 5: port)
               |
                 ((?:[-_.!~*'()a-zA-Z\d$,;+@&=+]|%[a-fA-F\d]{2})+)           (?# 6: registry)
               )
             |
             (?!\/\/))                              (?# XXX: '\/\/' is the mark for hostport)
             (\/(?:[-_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*(?:;(?:[-_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*)*(?:\/(?:[-_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*(?:;(?:[-_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*)*)*)?              (?# 7: path)
           )(?:\?((?:[-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]]|%[a-fA-F\d]{2})*))?           (?# 8: query)
        )
        (?:\#((?:[-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]]|%[a-fA-F\d]{2})*))?            (?# 9: fragment)
      $/xn, "http://example.org/Andr\xC3\xA9")


def test_sb(enc)
$KCODE = enc

x(//, '', 0, 0)
x(/^/, '', 0, 0)
x(/$/, '', 0, 0)
x(/\G/, '', 0, 0)
x(/\A/, '', 0, 0)
x(/\Z/, '', 0, 0)
x(/\z/, '', 0, 0)
x(/^$/, '', 0, 0)
x(/\ca/, "\001", 0, 1)
x(/\C-b/, "\002", 0, 1)
x(/\c\\/, "\034", 0, 1)
x(/q[\c\\]/, "q\034", 0, 2)
x(//, 'a', 0, 0)
x(/a/, 'a', 0, 1)
x(/\x61/, 'a', 0, 1)
x(/aa/, 'aa', 0, 2)
x(/aaa/, 'aaa', 0, 3)
x(/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 0, 35)
x(/ab/, 'ab', 0, 2)
x(/b/, 'ab', 1, 2)
x(/bc/, 'abc', 1, 3)
x(/(?i:#RET#)/, '#INS##RET#', 5, 10)
x(/\17/, "\017", 0, 1)
x(/\x1f/, "\x1f", 0, 1)
x(/a(?#....\\JJJJ)b/, 'ab', 0, 2)
x(Regexp.new("(?x)\ta .\n+b"), '0a123b4', 1, 6)
x(/(?x)  G (o O(?-x)oO) g L/, "GoOoOgLe", 0, 7)
x(/./, 'a', 0, 1)
n(/./, '')
x(/../, 'ab', 0, 2)
x(/\w/, 'e', 0, 1)
n(/\W/, 'e')
x(/\s/, ' ', 0, 1)
x(/\S/, 'b', 0, 1)
x(/\d/, '4', 0, 1)
n(/\D/, '4')
x(/\b/, 'z ', 0, 0)
x(/\b/, ' z', 1, 1)
x(/\B/, 'zz ', 1, 1)
x(/\B/, 'z ', 2, 2)
x(/\B/, ' z', 0, 0)
x(/[ab]/, 'b', 0, 1)
n(/[ab]/, 'c')
x(/[a-z]/, 't', 0, 1)
n(/[^a]/, 'a')
x(/[^a]/, "\n", 0, 1)
x(/[]]/, ']', 0, 1)
n(/[^]]/, ']')
x(/[\^]+/, '0^^1', 1, 3)
x(/[b-]/, 'b', 0, 1)
x(/[b-]/, '-', 0, 1)
x(/[\w]/, 'z', 0, 1)
n(/[\w]/, ' ')
x(/[\W]/, 'b$', 1, 2)
x(/[\d]/, '5', 0, 1)
n(/[\d]/, 'e')
x(/[\D]/, 't', 0, 1)
n(/[\D]/, '3')
x(/[\s]/, ' ', 0, 1)
n(/[\s]/, 'a')
x(/[\S]/, 'b', 0, 1)
n(/[\S]/, ' ')
x(/[\w\d]/, '2', 0, 1)
n(/[\w\d]/, ' ')
x(/[[:upper:]]/, 'B', 0, 1)
x(/[*[:xdigit:]+]/, '+', 0, 1)
x(/[*[:xdigit:]+]/, 'GHIKK-9+*', 6, 7)
x(/[*[:xdigit:]+]/, '-@^+', 3, 4)
n(/[[:upper]]/, 'A')
x(/[[:upper]]/, ':', 0, 1)
x(/[\044-\047]/, "\046", 0, 1)
x(/[\x5a-\x5c]/, "\x5b", 0, 1)
x(/[\x6A-\x6D]/, "\x6c", 0, 1)
n(/[\x6A-\x6D]/, "\x6E")
n(/^[0-9A-F]+ 0+ UNDEF /, '75F 00000000 SECT14A notype ()    External    | _rb_apply')
x(/[\[]/, '[', 0, 1)
x(/[\]]/, ']', 0, 1)
x(/[&]/, '&', 0, 1)
x(/[[ab]]/, 'b', 0, 1)
x(/[[ab]c]/, 'c', 0, 1)
n(/[[^a]]/, 'a')
n(/[^[a]]/, 'a')
x(/[[ab]&&bc]/, 'b', 0, 1)
n(/[[ab]&&bc]/, 'a')
n(/[[ab]&&bc]/, 'c')
x(/[a-z&&b-y&&c-x]/, 'w', 0, 1)
n(/[^a-z&&b-y&&c-x]/, 'w')
x(/[[^a&&a]&&a-z]/, 'b', 0, 1)
n(/[[^a&&a]&&a-z]/, 'a')
x(/[[^a-z&&bcdef]&&[^c-g]]/, 'h', 0, 1)
n(/[[^a-z&&bcdef]&&[^c-g]]/, 'c')
x(/[^[^abc]&&[^cde]]/, 'c', 0, 1)
x(/[^[^abc]&&[^cde]]/, 'e', 0, 1)
n(/[^[^abc]&&[^cde]]/, 'f')
x(/[a-&&-a]/, '-', 0, 1)
n(/[a\-&&\-a]/, '&')
n(/\wabc/, ' abc')
x(/a\Wbc/, 'a bc', 0, 4)
x(/a.b.c/, 'aabbc', 0, 5)
x(/.\wb\W..c/, 'abb bcc', 0, 7)
x(/\s\wzzz/, ' zzzz', 0, 5)
x(/aa.b/, 'aabb', 0, 4)
n(/.a/, 'ab')
x(/.a/, 'aa', 0, 2)
x(/^a/, 'a', 0, 1)
x(/^a$/, 'a', 0, 1)
x(/^\w$/, 'a', 0, 1)
n(/^\w$/, ' ')
x(/^\wab$/, 'zab', 0, 3)
x(/^\wabcdef$/, 'zabcdef', 0, 7)
x(/^\w...def$/, 'zabcdef', 0, 7)
x(/\w\w\s\Waaa\d/, 'aa  aaa4', 0, 8)
x(/\A\Z/, '', 0, 0)
x(/\Axyz/, 'xyz', 0, 3)
x(/xyz\Z/, 'xyz', 0, 3)
x(/xyz\z/, 'xyz', 0, 3)
x(/a\Z/, 'a', 0, 1)
x(/\Gaz/, 'az', 0, 2)
n(/\Gz/, 'bza')
n(/az\G/, 'az')
n(/az\A/, 'az')
n(/a\Az/, 'az')
x(/\^\$/, '^$', 0, 2)
x(/^x?y/, 'xy', 0, 2)
x(/^(x?y)/, 'xy', 0, 2)
x(/\w/, '_', 0, 1)
n(/\W/, '_')
x(/(?=z)z/, 'z', 0, 1)
n(/(?=z)./, 'a')
x(/(?!z)a/, 'a', 0, 1)
n(/(?!z)a/, 'z')
x(/(?i:a)/, 'a', 0, 1)
x(/(?i:a)/, 'A', 0, 1)
x(/(?i:A)/, 'a', 0, 1)
n(/(?i:A)/, 'b')
x(/(?i:[A-Z])/, 'a', 0, 1)
x(/(?i:[f-m])/, 'H', 0, 1)
x(/(?i:[f-m])/, 'h', 0, 1)
n(/(?i:[f-m])/, 'e')
x(/(?i:[A-c])/, 'D', 0, 1)
#n(/(?i:[a-C])/, 'D')   # changed spec.(error) 2003/09/17
#n(/(?i:[b-C])/, 'A')
#x(/(?i:[a-C])/, 'B', 0, 1)
#n(/(?i:[c-X])/, '[')
n(/(?i:[^a-z])/, 'A')
n(/(?i:[^a-z])/, 'a')
x(/(?i:[!-k])/, 'Z', 0, 1)
x(/(?i:[!-k])/, '7', 0, 1)
x(/(?i:[T-}])/, 'b', 0, 1)
x(/(?i:[T-}])/, '{', 0, 1)
x(/(?i:\?a)/, '?A', 0, 2)
x(/(?i:\*A)/, '*a', 0, 2)
n(/./, "\n")
x(/(?m:.)/, "\n", 0, 1)
x(/(?m:a.)/, "a\n", 0, 2)
x(/(?m:.b)/, "a\nb", 1, 3)
x(/.*abc/, "dddabdd\nddabc", 8, 13)
x(/(?m:.*abc)/, "dddabddabc", 0, 10)
n(/(?i)(?-i)a/, "A")
n(/(?i)(?-i:a)/, "A")
x(/a?/, '', 0, 0)
x(/a?/, 'b', 0, 0)
x(/a?/, 'a', 0, 1)
x(/a*/, '', 0, 0)
x(/a*/, 'a', 0, 1)
x(/a*/, 'aaa', 0, 3)
x(/a*/, 'baaaa', 0, 0)
n(/a+/, '')
x(/a+/, 'a', 0, 1)
x(/a+/, 'aaaa', 0, 4)
x(/a+/, 'aabbb', 0, 2)
x(/a+/, 'baaaa', 1, 5)
x(/.?/, '', 0, 0)
x(/.?/, 'f', 0, 1)
x(/.?/, "\n", 0, 0)
x(/.*/, '', 0, 0)
x(/.*/, 'abcde', 0, 5)
x(/.+/, 'z', 0, 1)
x(/.+/, "zdswer\n", 0, 6)
x(/(.*)a\1f/, "babfbac", 0, 4)
x(/(.*)a\1f/, "bacbabf", 3, 7)
x(/((.*)a\2f)/, "bacbabf", 3, 7)
x(/(.*)a\1f/, "baczzzzzz\nbazz\nzzzzbabf", 19, 23)
x(/a|b/, 'a', 0, 1)
x(/a|b/, 'b', 0, 1)
x(/|a/, 'a', 0, 0)
x(/(|a)/, 'a', 0, 0)
x(/ab|bc/, 'ab', 0, 2)
x(/ab|bc/, 'bc', 0, 2)
x(/z(?:ab|bc)/, 'zbc', 0, 3)
x(/a(?:ab|bc)c/, 'aabc', 0, 4)
x(/ab|(?:ac|az)/, 'az', 0, 2)
x(/a|b|c/, 'dc', 1, 2)
x(/a|b|cd|efg|h|ijk|lmn|o|pq|rstuvwx|yz/, 'pqr', 0, 2)
n(/a|b|cd|efg|h|ijk|lmn|o|pq|rstuvwx|yz/, 'mn')
x(/a|^z/, 'ba', 1, 2)
x(/a|^z/, 'za', 0, 1)
x(/a|\Gz/, 'bza', 2, 3)
x(/a|\Gz/, 'za', 0, 1)
x(/a|\Az/, 'bza', 2, 3)
x(/a|\Az/, 'za', 0, 1)
x(/a|b\Z/, 'ba', 1, 2)
x(/a|b\Z/, 'b', 0, 1)
x(/a|b\z/, 'ba', 1, 2)
x(/a|b\z/, 'b', 0, 1)
x(/\w|\s/, ' ', 0, 1)
n(/\w|\w/, ' ')
x(/\w|%/, '%', 0, 1)
x(/\w|[&$]/, '&', 0, 1)
x(/[b-d]|[^e-z]/, 'a', 0, 1)
x(/(?:a|[c-f])|bz/, 'dz', 0, 1)
x(/(?:a|[c-f])|bz/, 'bz', 0, 2)
x(/abc|(?=zz)..f/, 'zzf', 0, 3)
x(/abc|(?!zz)..f/, 'abf', 0, 3)
x(/(?=za)..a|(?=zz)..a/, 'zza', 0, 3)
n(/(?>a|abd)c/, 'abdc')
x(/(?>abd|a)c/, 'abdc', 0, 4)
x(/a?|b/, 'a', 0, 1)
x(/a?|b/, 'b', 0, 0)
x(/a?|b/, '', 0, 0)
x(/a*|b/, 'aa', 0, 2)
x(/a*|b*/, 'ba', 0, 0)
x(/a*|b*/, 'ab', 0, 1)
x(/a+|b*/, '', 0, 0)
x(/a+|b*/, 'bbb', 0, 3)
x(/a+|b*/, 'abbb', 0, 1)
n(/a+|b+/, '')
x(/(a|b)?/, 'b', 0, 1)
x(/(a|b)*/, 'ba', 0, 2)
x(/(a|b)+/, 'bab', 0, 3)
x(/(ab|ca)+/, 'caabbc', 0, 4)
x(/(ab|ca)+/, 'aabca', 1, 5)
x(/(ab|ca)+/, 'abzca', 0, 2)
x(/(a|bab)+/, 'ababa', 0, 5)
x(/(a|bab)+/, 'ba', 1, 2)
x(/(a|bab)+/, 'baaaba', 1, 4)
x(/(?:a|b)(?:a|b)/, 'ab', 0, 2)
x(/(?:a*|b*)(?:a*|b*)/, 'aaabbb', 0, 3)
x(/(?:a*|b*)(?:a+|b+)/, 'aaabbb', 0, 6)
x(/(?:a+|b+){2}/, 'aaabbb', 0, 6)
x(/h{0,}/, 'hhhh', 0, 4)
x(/(?:a+|b+){1,2}/, 'aaabbb', 0, 6)
n(/ax{2}*a/, '0axxxa1')
n(/a.{0,2}a/, "0aXXXa0")
n(/a.{0,2}?a/, "0aXXXa0")
n(/a.{0,2}?a/, "0aXXXXa0")
x(/^a{2,}?a$/, "aaa", 0, 3)
x(/^[a-z]{2,}?$/, "aaa", 0, 3)
x(/(?:a+|\Ab*)cc/, 'cc', 0, 2)
n(/(?:a+|\Ab*)cc/, 'abcc')
x(/(?:^a+|b+)*c/, 'aabbbabc', 6, 8)
x(/(?:^a+|b+)*c/, 'aabbbbc', 0, 7)
x(/a|(?i)c/, 'C', 0, 1)
x(/(?i)c|a/, 'C', 0, 1)
i(/(?i)c|a/, 'A', 0, 1)  # different spec.
x(/(?i:c)|a/, 'C', 0, 1)
n(/(?i:c)|a/, 'A')
x(/[abc]?/, 'abc', 0, 1)
x(/[abc]*/, 'abc', 0, 3)
x(/[^abc]*/, 'abc', 0, 0)
n(/[^abc]+/, 'abc')
x(/a??/, 'aaa', 0, 0)
x(/ba??b/, 'bab', 0, 3)
x(/a*?/, 'aaa', 0, 0)
x(/ba*?/, 'baa', 0, 1)
x(/ba*?b/, 'baab', 0, 4)
x(/a+?/, 'aaa', 0, 1)
x(/ba+?/, 'baa', 0, 2)
x(/ba+?b/, 'baab', 0, 4)
x(/(?:a?)??/, 'a', 0, 0)
x(/(?:a??)?/, 'a', 0, 0)
x(/(?:a?)+?/, 'aaa', 0, 1)
x(/(?:a+)??/, 'aaa', 0, 0)
x(/(?:a+)??b/, 'aaab', 0, 4)
i(/(?:ab)?{2}/, '', 0, 0)   # GNU regex bug
x(/(?:ab)?{2}/, 'ababa', 0, 4)
x(/(?:ab)*{0}/, 'ababa', 0, 0)
x(/(?:ab){3,}/, 'abababab', 0, 8)
n(/(?:ab){3,}/, 'abab')
x(/(?:ab){2,4}/, 'ababab', 0, 6)
x(/(?:ab){2,4}/, 'ababababab', 0, 8)
x(/(?:ab){2,4}?/, 'ababababab', 0, 4)
x(/(?:ab){,}/, 'ab{,}', 0, 5)
x(/(?:abc)+?{2}/, 'abcabcabc', 0, 6)
x(/(?:X*)(?i:xa)/, 'XXXa', 0, 4)
x(/(d+)([^abc]z)/, 'dddz', 0, 4)
x(/([^abc]*)([^abc]z)/, 'dddz', 0, 4)
x(/(\w+)(\wz)/, 'dddz', 0, 4)
x(/(a)/, 'a', 0, 1, 1)
x(/(ab)/, 'ab', 0, 2, 1)
x(/((ab))/, 'ab', 0, 2)
x(/((ab))/, 'ab', 0, 2, 1)
x(/((ab))/, 'ab', 0, 2, 2)
x(/((((((((((((((((((((ab))))))))))))))))))))/, 'ab', 0, 2, 20)
x(/(ab)(cd)/, 'abcd', 0, 2, 1)
x(/(ab)(cd)/, 'abcd', 2, 4, 2)
x(/()(a)bc(def)ghijk/, 'abcdefghijk', 3, 6, 3)
x(/(()(a)bc(def)ghijk)/, 'abcdefghijk', 3, 6, 4)
x(/(^a)/, 'a', 0, 1)
x(/(a)|(a)/, 'ba', 1, 2, 1)
x(/(^a)|(a)/, 'ba', 1, 2, 2)
x(/(a?)/, 'aaa', 0, 1, 1)
x(/(a*)/, 'aaa', 0, 3, 1)
x(/(a*)/, '', 0, 0, 1)
x(/(a+)/, 'aaaaaaa', 0, 7, 1)
x(/(a+|b*)/, 'bbbaa', 0, 3, 1)
x(/(a+|b?)/, 'bbbaa', 0, 1, 1)
x(/(abc)?/, 'abc', 0, 3, 1)
x(/(abc)*/, 'abc', 0, 3, 1)
x(/(abc)+/, 'abc', 0, 3, 1)
x(/(xyz|abc)+/, 'abc', 0, 3, 1)
x(/([xyz][abc]|abc)+/, 'abc', 0, 3, 1)
x(/((?i:abc))/, 'AbC', 0, 3, 1)
x(/(abc)(?i:\1)/, 'abcABC', 0, 6)
x(/((?m:a.c))/, "a\nc", 0, 3, 1)
x(/((?=az)a)/, 'azb', 0, 1, 1)
x(/abc|(.abd)/, 'zabd', 0, 4, 1)
x(/(?:abc)|(ABC)/, 'abc', 0, 3)
x(/(?i:(abc))|(zzz)/, 'ABC', 0, 3, 1)
x(/a*(.)/, 'aaaaz', 4, 5, 1)
x(/a*?(.)/, 'aaaaz', 0, 1, 1)
x(/a*?(c)/, 'aaaac', 4, 5, 1)
x(/[bcd]a*(.)/, 'caaaaz', 5, 6, 1)
x(/(\Abb)cc/, 'bbcc', 0, 2, 1)
n(/(\Abb)cc/, 'zbbcc')
x(/(^bb)cc/, 'bbcc', 0, 2, 1)
n(/(^bb)cc/, 'zbbcc')
x(/cc(bb$)/, 'ccbb', 2, 4, 1)
n(/cc(bb$)/, 'ccbbb')
#n(/\1/, 'a')     # compile error on Oniguruma
n(/(\1)/, '')
n(/\1(a)/, 'aa')
n(/(a(b)\1)\2+/, 'ababb')
n(/(?:(?:\1|z)(a))+$/, 'zaa')
x(/(?:(?:\1|z)(a))+$/, 'zaaa', 0, 4)
x(/(a)(?=\1)/, 'aa', 0, 1)
n(/(a)$|\1/, 'az')
x(/(a)\1/, 'aa', 0, 2)
n(/(a)\1/, 'ab')
x(/(a?)\1/, 'aa', 0, 2)
x(/(a??)\1/, 'aa', 0, 0)
x(/(a*)\1/, 'aaaaa', 0, 4)
x(/(a*)\1/, 'aaaaa', 0, 2, 1)
x(/a(b*)\1/, 'abbbb', 0, 5)
x(/a(b*)\1/, 'ab', 0, 1)
x(/(a*)(b*)\1\2/, 'aaabbaaabb', 0, 10)
x(/(a*)(b*)\2/, 'aaabbbb', 0, 7)
x(/(((((((a*)b))))))c\7/, 'aaabcaaa', 0, 8)
x(/(((((((a*)b))))))c\7/, 'aaabcaaa', 0, 3, 7)
x(/(a)(b)(c)\2\1\3/, 'abcbac', 0, 6)
x(/([a-d])\1/, 'cc', 0, 2)
x(/(\w\d\s)\1/, 'f5 f5 ', 0, 6)
n(/(\w\d\s)\1/, 'f5 f5')
x(/(who|[a-c]{3})\1/, 'whowho', 0, 6)
x(/...(who|[a-c]{3})\1/, 'abcwhowho', 0, 9)
x(/(who|[a-c]{3})\1/, 'cbccbc', 0, 6)
x(/(^a)\1/, 'aa', 0, 2)
n(/(^a)\1/, 'baa')
n(/(a$)\1/, 'aa')
n(/(ab\Z)\1/, 'ab')
x(/(a*\Z)\1/, 'a', 1, 1)
x(/.(a*\Z)\1/, 'ba', 1, 2)
x(/(.(abc)\2)/, 'zabcabc', 0, 7, 1)
x(/(.(..\d.)\2)/, 'z12341234', 0, 9, 1)
x(/((?i:az))\1/, 'AzAz', 0, 4)
n(/((?i:az))\1/, 'Azaz')
x(/(?<=a)b/, 'ab', 1, 2)
n(/(?<=a)b/, 'bb')
x(/(?<=a|b)b/, 'bb', 1, 2)
x(/(?<=a|bc)b/, 'bcb', 2, 3)
x(/(?<=a|bc)b/, 'ab', 1, 2)
x(/(?<=a|bc||defghij|klmnopq|r)z/, 'rz', 1, 2)
x(/(a)\g<1>/, 'aa', 0, 2)
x(/(?<!a)b/, 'cb', 1, 2)
n(/(?<!a)b/, 'ab')
x(/(?<!a|bc)b/, 'bbb', 0, 1)
n(/(?<!a|bc)z/, 'bcz')
x(/(?<name1>a)/, 'a', 0, 1)
x(/(?<name_2>ab)\g<name_2>/, 'abab', 0, 4)
x(/(?<name_3>.zv.)\k<name_3>/, 'azvbazvb', 0, 8)
x(/(?<=\g<ab>)|-\zEND (?<ab>XyZ)/, 'XyZ', 3, 3)
x(/(?<n>|a\g<n>)+/, '', 0, 0)
x(/(?<n>|\(\g<n>\))+$/, '()(())', 0, 6)
x(/\g<n>(?<n>.){0}/, 'X', 0, 1, 1)
x(/\g<n>(abc|df(?<n>.YZ){2,8}){0}/, 'XYZ', 0, 3)
x(/\A(?<n>(a\g<n>)|)\z/, 'aaaa', 0, 4)
x(/(?<n>|\g<m>\g<n>)\z|\zEND (?<m>a|(b)\g<m>)/, 'bbbbabba', 0, 8)
x(/(?<name1240>\w+\sx)a+\k<name1240>/, '  fg xaaaaaaaafg x', 2, 18)
x(/(z)()()(?<_9>a)\g<_9>/, 'zaa', 2, 3, 1)
x(/(.)(((?<_>a)))\k<_>/, 'zaa', 0, 3)
x(/((?<name1>\d)|(?<name2>\w))(\k<name1>|\k<name2>)/, 'ff', 0, 2)
x(/(?:(?<x>)|(?<x>efg))\k<x>/, '', 0, 0)
x(/(?:(?<x>abc)|(?<x>efg))\k<x>/, 'abcefgefg', 3, 9)
n(/(?:(?<x>abc)|(?<x>efg))\k<x>/, 'abcefg')
x(/(?:(?<n1>.)|(?<n1>..)|(?<n1>...)|(?<n1>....)|(?<n1>.....)|(?<n1>......)|(?<n1>.......)|(?<n1>........)|(?<n1>.........)|(?<n1>..........)|(?<n1>...........)|(?<n1>............)|(?<n1>.............)|(?<n1>..............))\k<n1>$/, 'a-pyumpyum', 2, 10)
x(/(?:(?<n1>.)|(?<n1>..)|(?<n1>...)|(?<n1>....)|(?<n1>.....)|(?<n1>......)|(?<n1>.......)|(?<n1>........)|(?<n1>.........)|(?<n1>..........)|(?<n1>...........)|(?<n1>............)|(?<n1>.............)|(?<n1>..............))\k<n1>$/, 'xxxxabcdefghijklmnabcdefghijklmn', 4, 18, 14)
x(/(?<name1>)(?<name2>)(?<name3>)(?<name4>)(?<name5>)(?<name6>)(?<name7>)(?<name8>)(?<name9>)(?<name10>)(?<name11>)(?<name12>)(?<name13>)(?<name14>)(?<name15>)(?<name16>aaa)(?<name17>)$/, 'aaa', 0, 3, 16)
x(/(?<foo>a|\(\g<foo>\))/, 'a', 0, 1)
x(/(?<foo>a|\(\g<foo>\))/, '((((((a))))))', 0, 13)
x(/(?<foo>a|\(\g<foo>\))/, '((((((((a))))))))', 0, 17, 1)
x(/\g<bar>|\zEND(?<bar>.*abc$)/, 'abcxxxabc', 0, 9)
x(/\g<1>|\zEND(.a.)/, 'bac', 0, 3)
x(/\g<_A>\g<_A>|\zEND(.a.)(?<_A>.b.)/, 'xbxyby', 3, 6, 1)
x(/\A(?:\g<pon>|\g<pan>|\zEND  (?<pan>a|c\g<pon>c)(?<pon>b|d\g<pan>d))$/, 'cdcbcdc', 0, 7)
x(/\A(?<n>|a\g<m>)\z|\zEND (?<m>\g<n>)/, 'aaaa', 0, 4)
x(/(?<n>(a|b\g<n>c){3,5})/, 'baaaaca', 1, 5)
x(/(?<n>(a|b\g<n>c){3,5})/, 'baaaacaaaaa', 0, 10)
x(/(?<pare>\(([^\(\)]++|\g<pare>)*+\))/, '((a))', 0, 5)
x(/()*\1/, '', 0, 0)
x(/(?:()|())*\1\2/, '', 0, 0)
x(/(?:\1a|())*/, 'a', 0, 0, 1)
x(/x((.)*)*x/, '0x1x2x3', 1, 6)
x(/x((.)*)*x(?i:\1)\Z/, '0x1x2x1X2', 1, 9)
x(/(?:()|()|()|()|()|())*\2\5/, '', 0, 0)
x(/(?:()|()|()|(x)|()|())*\2b\5/, 'b', 0, 1)

r(//, '', 0)
r(/a/, 'a', 0)
r(/a/, 'a', 0, 1)
r(/b/, 'abc', 1)
r(/b/, 'abc', 1, 2)
r(/./, 'a', 0)
r(/.*/, 'abcde fgh', 9)
r(/a*/, 'aaabbc', 6)
r(/a+/, 'aaabbc', 2)
r(/a?/, 'bac', 3)
r(/a??/, 'bac', 3)
r(/abcde/, 'abcdeavcd', 0)
r(/\w\d\s/, '  a2 aa $3 ', 2)
r(/[c-f]aa[x-z]/, '3caaycaaa', 1)
r(/(?i:fG)g/, 'fGgFggFgG', 3)
r(/a|b/, 'b', 0)
r(/ab|bc|cd/, 'bcc', 0)
r(/(ffy)\1/, 'ffyffyffy', 3)
r(/|z/, 'z', 1)
r(/^az/, 'azaz', 0)
r(/az$/, 'azaz', 2)
r(/(((.a)))\3/, 'zazaaa', 0)
r(/(ac*?z)\1/, 'aacczacczacz', 1)
r(/aaz{3,4}/, 'bbaabbaazzzaazz', 6)
r(/\000a/, "b\000a", 1)
r(/ff\xfe/, "fff\xfe", 1)
r(/...abcdefghijklmnopqrstuvwxyz/, 'zzzzzabcdefghijklmnopqrstuvwxyz', 2)
end

def test_euc(enc)
$KCODE = enc

x(/\xED\xF2/, "\xed\xf2", 0, 2)
x(//, 'あ', 0, 0)
x(/あ/, 'あ', 0, 2)
n(/い/, 'あ')
x(/うう/, 'うう', 0, 4)
x(/あいう/, 'あいう', 0, 6)
x(/こここここここここここここここここここここここここここここここここここ/, 'こここここここここここここここここここここここここここここここここここ', 0, 70)
x(/あ/, 'いあ', 2, 4)
x(/いう/, 'あいう', 2, 6)
x(/\xca\xb8/, "\xca\xb8", 0, 2)
x(/./, 'あ', 0, 2)
x(/../, 'かき', 0, 4)
x(/(?u)\w/, 'お', 0, 2)
n(/(?u)\W/, 'あ')
x(/(?u)[\W]/, 'う$', 2, 3)
x(/\S/, 'そ', 0, 2)
x(/\S/, '漢', 0, 2)
x(/\b/, '気 ', 0, 0)
x(/\b/, ' ほ', 1, 1)
x(/\B/, 'せそ ', 2, 2)
x(/\B/, 'う ', 3, 3)
x(/\B/, ' い', 0, 0)
x(/[たち]/, 'ち', 0, 2)
n(/[なに]/, 'ぬ')
x(/[う-お]/, 'え', 0, 2)
n(/[^け]/, 'け')
x(/(?u)[\w]/, 'ね', 0, 2)
n(/[\d]/, 'ふ')
x(/[\D]/, 'は', 0, 2)
n(/[\s]/, 'く')
x(/[\S]/, 'へ', 0, 2)
x(/(?u)[\w\d]/, 'よ', 0, 2)
x(/(?u)[\w\d]/, '   よ', 3, 5)
#x(/[\xa4\xcf-\xa4\xd3]/, "\xa4\xd0", 0, 2)  # diff spec with GNU regex.
#n(/[\xb6\xe7-\xb6\xef]/, "\xb6\xe5")        # diff spec with GNU regex.
n(/(?u)\w鬼車/, ' 鬼車')
x(/(?u)鬼\W車/, '鬼 車', 0, 5)
x(/あ.い.う/, 'ああいいう', 0, 10)
x(/(?u).\wう\W..ぞ/, 'えうう うぞぞ', 0, 13)
x(/(?u)\s\wこここ/, ' ここここ', 0, 9)
x(/ああ.け/, 'ああけけ', 0, 8)
n(/.い/, 'いえ')
x(/.お/, 'おお', 0, 4)
x(/^あ/, 'あ', 0, 2)
x(/^む$/, 'む', 0, 2)
x(/(?u)^\w$/, 'に', 0, 2)
x(/(?u)^\wかきくけこ$/, 'zかきくけこ', 0, 11)
x(/(?u)^\w...うえお$/, 'zあいううえお', 0, 13)
x(/(?u)\w\w\s\Wおおお\d/, 'aお  おおお4', 0, 12)
x(/\Aたちつ/, 'たちつ', 0, 6)
x(/むめも\Z/, 'むめも', 0, 6)
x(/かきく\z/, 'かきく', 0, 6)
x(/かきく\Z/, "かきく\n", 0, 6)
x(/\Gぽぴ/, 'ぽぴ', 0, 4)
n(/\Gえ/, 'うえお')
n(/とて\G/, 'とて')
n(/まみ\A/, 'まみ')
n(/ま\Aみ/, 'まみ')
x(/(?=せ)せ/, 'せ', 0, 2)
n(/(?=う)./, 'い')
x(/(?!う)か/, 'か', 0, 2)
n(/(?!と)あ/, 'と')
x(/(?i:あ)/, 'あ', 0, 2)
x(/(?i:ぶべ)/, 'ぶべ', 0, 4)
n(/(?i:い)/, 'う')
x(/(?m:よ.)/, "よ\n", 0, 3)
x(/(?m:.め)/, "ま\nめ", 2, 5)
x(/あ?/, '', 0, 0)
x(/変?/, '化', 0, 0)
x(/変?/, '変', 0, 2)
x(/量*/, '', 0, 0)
x(/量*/, '量', 0, 2)
x(/子*/, '子子子', 0, 6)
x(/馬*/, '鹿馬馬馬馬', 0, 0)
n(/山+/, '')
x(/河+/, '河', 0, 2)
x(/時+/, '時時時時', 0, 8)
x(/え+/, 'ええううう', 0, 4)
x(/う+/, 'おうううう', 2, 10)
x(/.?/, 'た', 0, 2)
x(/.*/, 'ぱぴぷぺ', 0, 8)
x(/.+/, 'ろ', 0, 2)
x(/.+/, "いうえか\n", 0, 8)
x(/あ|い/, 'あ', 0, 2)
x(/あ|い/, 'い', 0, 2)
x(/あい|いう/, 'あい', 0, 4)
x(/あい|いう/, 'いう', 0, 4)
x(/を(?:かき|きく)/, 'をかき', 0, 6)
x(/を(?:かき|きく)け/, 'をきくけ', 0, 8)
x(/あい|(?:あう|あを)/, 'あを', 0, 4)
x(/あ|い|う/, 'えう', 2, 4)
x(/あ|い|うえ|おかき|く|けこさ|しすせ|そ|たち|つてとなに|ぬね/, 'しすせ', 0, 6)
n(/あ|い|うえ|おかき|く|けこさ|しすせ|そ|たち|つてとなに|ぬね/, 'すせ')
x(/あ|^わ/, 'ぶあ', 2, 4)
x(/あ|^を/, 'をあ', 0, 2)
x(/鬼|\G車/, 'け車鬼', 4, 6)
x(/鬼|\G車/, '車鬼', 0, 2)
x(/鬼|\A車/, 'b車鬼', 3, 5)
x(/鬼|\A車/, '車', 0, 2)
x(/鬼|車\Z/, '車鬼', 2, 4)
x(/鬼|車\Z/, '車', 0, 2)
x(/鬼|車\Z/, "車\n", 0, 2)
x(/鬼|車\z/, '車鬼', 2, 4)
x(/鬼|車\z/, '車', 0, 2)
x(/(?u)\w|\s/, 'お', 0, 2)
x(/(?u)\w|%/, '%お', 0, 1)
x(/(?u)\w|[&$]/, 'う&', 0, 2)
x(/[い-け]/, 'う', 0, 2)
x(/[い-け]|[^か-こ]/, 'あ', 0, 2)
x(/[い-け]|[^か-こ]/, 'か', 0, 2)
x(/[^あ]/, "\n", 0, 1)
x(/(?:あ|[う-き])|いを/, 'うを', 0, 2)
x(/(?:あ|[う-き])|いを/, 'いを', 0, 4)
x(/あいう|(?=けけ)..ほ/, 'けけほ', 0, 6)
x(/あいう|(?!けけ)..ほ/, 'あいほ', 0, 6)
x(/(?=をあ)..あ|(?=をを)..あ/, 'ををあ', 0, 6)
x(/(?<=あ|いう)い/, 'いうい', 4, 6)
n(/(?>あ|あいえ)う/, 'あいえう')
x(/(?>あいえ|あ)う/, 'あいえう', 0, 8)
x(/あ?|い/, 'あ', 0, 2)
x(/あ?|い/, 'い', 0, 0)
x(/あ?|い/, '', 0, 0)
x(/あ*|い/, 'ああ', 0, 4)
x(/あ*|い*/, 'いあ', 0, 0)
x(/あ*|い*/, 'あい', 0, 2)
x(/[aあ]*|い*/, 'aあいいい', 0, 3)
x(/あ+|い*/, '', 0, 0)
x(/あ+|い*/, 'いいい', 0, 6)
x(/あ+|い*/, 'あいいい', 0, 2)
x(/あ+|い*/, 'aあいいい', 0, 0)
n(/あ+|い+/, '')
x(/(あ|い)?/, 'い', 0, 2)
x(/(あ|い)*/, 'いあ', 0, 4)
x(/(あ|い)+/, 'いあい', 0, 6)
x(/(あい|うあ)+/, 'うああいうえ', 0, 8)
x(/(あい|うえ)+/, 'うああいうえ', 4, 12)
x(/(あい|うあ)+/, 'ああいうあ', 2, 10)
x(/(あい|うあ)+/, 'あいをうあ', 0, 4)
x(/(あい|うあ)+/, '$$zzzzあいをうあ', 6, 10)
x(/(あ|いあい)+/, 'あいあいあ', 0, 10)
x(/(あ|いあい)+/, 'いあ', 2, 4)
x(/(あ|いあい)+/, 'いあああいあ', 2, 8)
x(/(?:あ|い)(?:あ|い)/, 'あい', 0, 4)
x(/(?:あ*|い*)(?:あ*|い*)/, 'あああいいい', 0, 6)
x(/(?:あ*|い*)(?:あ+|い+)/, 'あああいいい', 0, 12)
x(/(?:あ+|い+){2}/, 'あああいいい', 0, 12)
x(/(?:あ+|い+){1,2}/, 'あああいいい', 0, 12)
x(/(?:あ+|\Aい*)うう/, 'うう', 0, 4)
n(/(?:あ+|\Aい*)うう/, 'あいうう')
x(/(?:^あ+|い+)*う/, 'ああいいいあいう', 12, 16)
x(/(?:^あ+|い+)*う/, 'ああいいいいう', 0, 14)
x(/う{0,}/, 'うううう', 0, 8)
x(/あ|(?i)c/, 'C', 0, 1)
x(/(?i)c|あ/, 'C', 0, 1)
x(/(?i:あ)|a/, 'a', 0, 1)
n(/(?i:あ)|a/, 'A')
x(/[あいう]?/, 'あいう', 0, 2)
x(/[あいう]*/, 'あいう', 0, 6)
x(/[^あいう]*/, 'あいう', 0, 0)
n(/[^あいう]+/, 'あいう')
x(/あ??/, 'あああ', 0, 0)
x(/いあ??い/, 'いあい', 0, 6)
x(/あ*?/, 'あああ', 0, 0)
x(/いあ*?/, 'いああ', 0, 2)
x(/いあ*?い/, 'いああい', 0, 8)
x(/あ+?/, 'あああ', 0, 2)
x(/いあ+?/, 'いああ', 0, 4)
x(/いあ+?い/, 'いああい', 0, 8)
x(/(?:天?)??/, '天', 0, 0)
x(/(?:天??)?/, '天', 0, 0)
x(/(?:夢?)+?/, '夢夢夢', 0, 2)
x(/(?:風+)??/, '風風風', 0, 0)
x(/(?:雪+)??霜/, '雪雪雪霜', 0, 8)
i(/(?:あい)?{2}/, '', 0, 0)   # GNU regex bug
x(/(?:鬼車)?{2}/, '鬼車鬼車鬼', 0, 8)
x(/(?:鬼車)*{0}/, '鬼車鬼車鬼', 0, 0)
x(/(?:鬼車){3,}/, '鬼車鬼車鬼車鬼車', 0, 16)
n(/(?:鬼車){3,}/, '鬼車鬼車')
x(/(?:鬼車){2,4}/, '鬼車鬼車鬼車', 0, 12)
x(/(?:鬼車){2,4}/, '鬼車鬼車鬼車鬼車鬼車', 0, 16)
x(/(?:鬼車){2,4}?/, '鬼車鬼車鬼車鬼車鬼車', 0, 8)
x(/(?:鬼車){,}/, '鬼車{,}', 0, 7)
x(/(?:かきく)+?{2}/, 'かきくかきくかきく', 0, 12)
x(/(火)/, '火', 0, 2, 1)
x(/(火水)/, '火水', 0, 4, 1)
x(/((時間))/, '時間', 0, 4)
x(/((風水))/, '風水', 0, 4, 1)
x(/((昨日))/, '昨日', 0, 4, 2)
x(/((((((((((((((((((((量子))))))))))))))))))))/, '量子', 0, 4, 20)
x(/(あい)(うえ)/, 'あいうえ', 0, 4, 1)
x(/(あい)(うえ)/, 'あいうえ', 4, 8, 2)
x(/()(あ)いう(えおか)きくけこ/, 'あいうえおかきくけこ', 6, 12, 3)
x(/(()(あ)いう(えおか)きくけこ)/, 'あいうえおかきくけこ', 6, 12, 4)
x(/.*(フォ)ン・マ(ン()シュタ)イン/, 'フォン・マンシュタイン', 10, 18, 2)
x(/(^あ)/, 'あ', 0, 2)
x(/(あ)|(あ)/, 'いあ', 2, 4, 1)
x(/(^あ)|(あ)/, 'いあ', 2, 4, 2)
x(/(あ?)/, 'あああ', 0, 2, 1)
x(/(ま*)/, 'ままま', 0, 6, 1)
x(/(と*)/, '', 0, 0, 1)
x(/(る+)/, 'るるるるるるる', 0, 14, 1)
x(/(ふ+|へ*)/, 'ふふふへへ', 0, 6, 1)
x(/(あ+|い?)/, 'いいいああ', 0, 2, 1)
x(/(あいう)?/, 'あいう', 0, 6, 1)
x(/(あいう)*/, 'あいう', 0, 6, 1)
x(/(あいう)+/, 'あいう', 0, 6, 1)
x(/(さしす|あいう)+/, 'あいう', 0, 6, 1)
x(/([なにぬ][かきく]|かきく)+/, 'かきく', 0, 6, 1)
x(/((?i:あいう))/, 'あいう', 0, 6, 1)
x(/((?m:あ.う))/, "あ\nう", 0, 5, 1)
x(/((?=あん)あ)/, 'あんい', 0, 2, 1)
x(/あいう|(.あいえ)/, 'んあいえ', 0, 8, 1)
x(/あ*(.)/, 'ああああん', 8, 10, 1)
x(/あ*?(.)/, 'ああああん', 0, 2, 1)
x(/あ*?(ん)/, 'ああああん', 8, 10, 1)
x(/[いうえ]あ*(.)/, 'えああああん', 10, 12, 1)
x(/(\Aいい)うう/, 'いいうう', 0, 4, 1)
n(/(\Aいい)うう/, 'んいいうう')
x(/(^いい)うう/, 'いいうう', 0, 4, 1)
n(/(^いい)うう/, 'んいいうう')
x(/ろろ(るる$)/, 'ろろるる', 4, 8, 1)
n(/ろろ(るる$)/, 'ろろるるる')
x(/(無)\1/, '無無', 0, 4)
n(/(無)\1/, '無武')
x(/(空?)\1/, '空空', 0, 4)
x(/(空??)\1/, '空空', 0, 0)
x(/(空*)\1/, '空空空空空', 0, 8)
x(/(空*)\1/, '空空空空空', 0, 4, 1)
x(/あ(い*)\1/, 'あいいいい', 0, 10)
x(/あ(い*)\1/, 'あい', 0, 2)
x(/(あ*)(い*)\1\2/, 'あああいいあああいい', 0, 20)
x(/(あ*)(い*)\2/, 'あああいいいい', 0, 14)
x(/(あ*)(い*)\2/, 'あああいいいい', 6, 10, 2)
x(/(((((((ぽ*)ぺ))))))ぴ\7/, 'ぽぽぽぺぴぽぽぽ', 0, 16)
x(/(((((((ぽ*)ぺ))))))ぴ\7/, 'ぽぽぽぺぴぽぽぽ', 0, 6, 7)
x(/(は)(ひ)(ふ)\2\1\3/, 'はひふひはふ', 0, 12)
x(/([き-け])\1/, 'くく', 0, 4)
x(/(?u)(\w\d\s)\1/, 'あ5 あ5 ', 0, 8)
n(/(?u)(\w\d\s)\1/, 'あ5 あ5')
x(/(誰？|[あ-う]{3})\1/, '誰？誰？', 0, 8)
x(/...(誰？|[あ-う]{3})\1/, 'あaあ誰？誰？', 0, 13)
x(/(誰？|[あ-う]{3})\1/, 'ういうういう', 0, 12)
x(/(^こ)\1/, 'ここ', 0, 4)
n(/(^む)\1/, 'めむむ')
n(/(あ$)\1/, 'ああ')
n(/(あい\Z)\1/, 'あい')
x(/(あ*\Z)\1/, 'あ', 2, 2)
x(/.(あ*\Z)\1/, 'いあ', 2, 4)
x(/(.(やいゆ)\2)/, 'zやいゆやいゆ', 0, 13, 1)
x(/(.(..\d.)\2)/, 'あ12341234', 0, 10, 1)
x(/((?i:あvず))\1/, 'あvずあvず', 0, 10)
x(/(?<愚か>変|\(\g<愚か>\))/, '((((((変))))))', 0, 14)
x(/\A(?:\g<阿_1>|\g<云_2>|\z終了  (?<阿_1>観|自\g<云_2>自)(?<云_2>在|菩薩\g<阿_1>菩薩))$/, '菩薩自菩薩自在自菩薩自菩薩', 0, 26)
x(/[[ひふ]]/, 'ふ', 0, 2)
x(/[[いおう]か]/, 'か', 0, 2)
n(/[[^あ]]/, 'あ')
n(/[^[あ]]/, 'あ')
x(/[^[^あ]]/, 'あ', 0, 2)
x(/[[かきく]&&きく]/, 'く', 0, 2)
n(/[[かきく]&&きく]/, 'か')
n(/[[かきく]&&きく]/, 'け')
x(/[あ-ん&&い-を&&う-ゑ]/, 'ゑ', 0, 2)
n(/[^あ-ん&&い-を&&う-ゑ]/, 'ゑ')
x(/[[^あ&&あ]&&あ-ん]/, 'い', 0, 2)
n(/[[^あ&&あ]&&あ-ん]/, 'あ')
x(/[[^あ-ん&&いうえお]&&[^う-か]]/, 'き', 0, 2)
n(/[[^あ-ん&&いうえお]&&[^う-か]]/, 'い')
x(/[^[^あいう]&&[^うえお]]/, 'う', 0, 2)
x(/[^[^あいう]&&[^うえお]]/, 'え', 0, 2)
n(/[^[^あいう]&&[^うえお]]/, 'か')
x(/[あ-&&-あ]/, '-', 0, 1)
x(/[^[^a-zあいう]&&[^bcdefgうえお]q-w]/, 'え', 0, 2)
x(/[^[^a-zあいう]&&[^bcdefgうえお]g-w]/, 'f', 0, 1)
x(/[^[^a-zあいう]&&[^bcdefgうえお]g-w]/, 'g', 0, 1)
n(/[^[^a-zあいう]&&[^bcdefgうえお]g-w]/, '2')
x(/a<b>バージョンのダウンロード<\/b>/, 'a<b>バージョンのダウンロード</b>', 0, 32)
x(/.<b>バージョンのダウンロード<\/b>/, 'a<b>バージョンのダウンロード</b>', 0, 32)

r(/あ/, 'あ', 0)
r(/あ/, 'あ', 0, 2)
r(/い/, 'あいう', 2)
r(/い/, 'あいう', 2, 4)
r(/./, 'あ', 0)
r(/.*/, 'あいうえお かきく', 17)
r(/.*えお/, 'あいうえお かきく', 6)
r(/あ*/, 'あああいいう', 12)
r(/あ+/, 'あああいいう', 4)
r(/あ?/, 'いあう', 6)
r(/全??/, '負全変', 6)
r(/a辺c漢e/, 'a辺c漢eavcd', 0)
r(/(?u)\w\d\s/, '  あ2 うう $3 ', 2)
r(/[う-お]ああ[と-ん]/, '3うああなうあああ', 1)
r(/あ|い/, 'い', 0)
r(/あい|いう|うえ/, 'いうう', 0)
r(/(ととち)\1/, 'ととちととちととち', 6)
r(/|え/, 'え', 2)
r(/^あず/, 'あずあず', 0)
r(/あず$/, 'あずあず', 4)
r(/(((.あ)))\3/, 'zあzあああ', 0)
r(/(あう*?ん)\1/, 'ああううんあううんあうん', 2)
r(/ああん{3,4}/, 'ててああいいああんんんああんああん', 12)
r(/\000あ/, "い\000あ", 2)
r(/とと\xfe\xfe/, "ととと\xfe\xfe", 2)
r(/...あいうえおかきくけこさしすせそ/, 'zzzzzあいうえおかきくけこさしすせそ', 2)
end

test_sb('ASCII')
test_sb('EUC')
test_sb('SJIS')
test_sb('UTF-8')
test_euc('EUC')


# UTF-8   (by UENO Katsuhiro)
$KCODE = 'UTF-8'

x(/\w/u, "\xc3\x81", 0, 2)
n(/\W/u, "\xc3\x81")
x(/[\w]/u, "\xc3\x81", 0, 2)
x(/./u, "\xfe", 0, 1)
x(/\xfe/u, "\xfe", 0, 1)
x(/\S*/u, "\xfe", 0, 1)
x(/\s*/u, "\xfe", 0, 0)
n(/\w+/u, "\xfe")
x(/\W+/u, "\xfe\xff", 0, 2)
x(/[\xfe]/u, "aaa\xfe", 3, 4)
x(/[\xff\xfe]/u, "\xff\xfe", 0, 1)
x(/[a-c\xff\xfe]+/u, "\xffabc\xfe", 0, 5)

s = "\xe3\x81\x82\xe3\x81\x81\xf0\x90\x80\x85\xe3\x81\x8a\xe3\x81\x85"
x(/[\xc2\x80-\xed\x9f\xbf]+/u, s, 0, 6)

s = "\xf0\x90\x80\x85\xe3\x81\x82"
x(/[\xc2\x80-\xed\x9f\xbf]/u, s, 4, 7)

s = "\xed\x9f\xbf"
n(/[\xc2\x80-\xed\x9f\xbe]/u, s)

s = "\xed\x9f\xbf"
n(/[\xc2\x80-\xed\x9f\xbe]/u, s)

s = "\xed\x9f\xbf"
n(/[\xc2\x80-\xed\x9f\xbe]/u, s)

s = "\xed\x9f\xbf"
n(/[\xc3\xad\xed\x9f\xbe]/u, s)

s = "\xed\x9f\xbf"
n(/[\xc4\x80-\xed\x9f\xbe]/u, s)

s = "\xed\x9f\xbf\xf0\x90\x80\x85\xed\x9f\xbf"
x(/[^\xc2\x80-\xed\x9f\xbe]/u, s, 0, 3)

s = "\xed\x9f\xbf"
x(/[^\xc3\xad\xed\x9f\xbe]/u, s, 0, 3)

s = "\xed\x9f\xbf\xf0\x90\x80\x85\xed\x9f\xbf"
x(/[^\xc4\x80-\xed\x9f\xbe]/u, s, 0, 3)

s = "\xc3\xbe\xc3\xbf"
n(/[\xfe\xff\xc3\x80]/u, s)

s = "\xc3\xbe"
x(/[\xc2\xa0-\xc3\xbe]/u, s, 0, 2)

s = "sssss"
x(/s+/iu, s, 0, 5)

s = "SSSSS"
x(/s+/iu, s, 0, 5)

reg = Regexp.new("\\x{fb40}", nil, 'u')
x(reg, "\357\255\200", 0, 3)
x(/\A\w\z/u, "\357\255\200", 0, 3)
x(/\A\W\z/u, "\357\255\202", 0, 3)
n(/\A\w\z/u, "\357\255\202")

x(/\303\200/iu, "\303\240", 0, 2)
x(/\303\247/iu, "\303\207", 0, 2)



# Japanese long text.
$KCODE = 'EUC'

s = <<EOS
戦後の日本においては、旧軍については調査に基づかぬ批判も許される風潮も生じ、
たとえば三十八年式歩兵銃の制定年が日露戦争の終った年であることをもって軽忽に
旧軍の旧式ぶりを誇張する論評がまかりとおっている。
有名な論者としては、故・司馬遼太郎を挙げることができるだろう。

兵頭二十八 「有坂銃」 四谷ラウンド (1998)
EOS

x(/\((.+)\)/, s, 305, 309, 1)
x(/司馬遼太郎/, s, 229, 239)
x(/。$/, s, 202, 204)
x(/(^兵頭..八)/, s, 269, 279, 1)
x(/^$/, s, 268, 268)


s = <<EOS
カナやローマ字は一体文字であろうか。
もしことばをしるすものが文字であるとすると、それはことばをしるすものではない。
本やbookはことばであるが、ホンやhonは音をならべただけで、十分な単語性を
もつものではない。
単語としての特定の形態をもたないからである。
「形による語」をアランは漢字に対する軽蔑的な意味に用いたが、
形のないものは本当は語ではありえないのである。

白川静 「漢字百話」
EOS

n(/\((.+)\)/, s)
x(/「(.*)」/, s, 254, 264, 1)
x(/。$/, s, 34, 36)
x(/(book)/, s, 120, 124, 1)
x(/^$/, s, 360, 360)


s = <<EOS
釈迦が叡山にくだってきたとすれば、そのおびただしい密教美術の量と、
その質の高さにおどろくにちがいない。
この覚者が、圧倒的な驚きをもつのは、お不動さんの像の前に立ったときだろう。
−− これは、ドラヴィダ人の少年奴隷ではないか。

司馬遼太郎 「叡山美術の展開−不動明王にふれつつ」 アサヒグラフ(1986)
EOS

x(/\((.+)\)/, s, 290, 296)
x(/「(.*)−(.+)」/, s, 257, 275, 2)
x(/^−− /, s, 179, 184)
x(/(釈迦)/, s, 0, 4, 1)
x(/\w、/, s, 30, 34)


s = <<EOS
かといって、所詮は、寺内君も、黒岩君も、そしてもう一人の人物も、口舌の徒にすぎないことを、この第七号は如実に物語っている。
かれら三人の小説は一行も出ていないのだ。
書くひまがなかったのであろう。
しかし、雑誌「近代説話」が、なお第八号も第九号も出つづけてゆくであろうことについては、私はぶきみなほどの確信をもっている。この雑誌には、事務能力の魔物のような人物が、三人もいる。
それを思うと、ときどきため息の出るようなおもいがするのである。

司馬遼太郎 「こんな雑誌やめてしまいたい」 近代説話 第七集 (1961)
EOS

x(/\((\d+)\)/, s, 496, 502)
x(/(「.+雑誌.*」)/, s, 449, 479, 1)
x(/第(.)号/, s, 96, 98, 1)
x(/。$/, s, 120, 122)
x(/近代説話/, s, 209, 217)


s = <<EOS
二十五倍を越える莫大な量の下り塩に対抗する手立てに心づもりがあったのは、生き残っていた四十軒の地廻り塩問屋のうち伊勢屋の巴屋伊兵衛ただ一人だった。
一口に地廻り塩といっても、江戸城御数寄屋に納入する御用塩と、江戸市中に流すものとは当然同じ物ではなかった。
そもそもが戦物資を前提として考えられた行徳塩は、輸送する折に苦汁分が溶けだし目減りしたのでは話にならない。そこで、江戸城に納めるものは、焼きあげた塩を一夏葦簾囲いにした小屋に積み上げ、苦汁分を抜いて真塩に仕立て上げたものだった。

飯嶋和一 「始祖鳥記」 (2000)
EOS

x(/\((\d+)\)/, s, 506, 512)
x(/(「.*」)/, s, 493, 505, 1)
x(/行徳塩/, s, 292, 298)


s = <<EOS
こうした日本人の武器に対する変わった態度の裏には、じつは、
一貫した選択基準が働いていた。
それは、その武器が「主兵を高級に見せるかどうか」であった。

兵頭二十八 「有坂銃」 四谷ラウンド (1998)
EOS

x(/\((\d+)\)/, s, 185, 191)
x(/(「.*」)/, s, 108, 138, 1)
x(/^それは/, s, 90, 96)
x(/^.*$/, s, 0, 58)

s = <<EOS
  稗は人も食い、馬の飼料にもしました。馬には稗一升に豆二合をたいてまぜたものを一日に一回はたべさせた。人間よりは上等のものをたべさせたもんであります。
  人間は日頃はヘズリ飯をたべた。乾菜をゆでて、ゆでじるを馬にやり、菜をこまかに切り、菜と稗と米をまぜてたいてたべた。ずっと昔は米と稗が半々ぐらいであったが、明治も二十年代になると、稗をつくるのがへって来て、稗は米の三分の一くらいになった。ヘズリ飯には塩を少しいれたもんです。

宮本常一 「忘れられた日本人」 (1960)
EOS

x(/(稗は米の三分の一くらいに)/, s, 357, 381, 1)
x(/あります。$/, s, 140, 150)
x(/  人間(.*)。/, s, 157, 423, 1)
x(/ヘズリ飯[をはで]/, s, 165, 175)

s = <<EOS
身はたとひ 武蔵の野辺に朽ぬとも 留置まし大和魂

吉田松蔭 「留魂録」 (1859)
EOS

x(/\((.+)\)/, s, 68, 74)
x(/「(.*)」/, s, 59, 65, 1)
x(/^(吉田松蔭)/, s, 48, 56, 1)

s = <<EOS
言ふまでもなく最初に漢字を借りて國語音韻を表記した上代人においても、
音韻は單に音節としてのみ捉へられてゐたのであり、したがつて文字は單に
音節を表記する音節文字として理解されてゐたわけです。それは一體どういふ
ことを意味するかといふと、それらの文字によつて表された音韻もまた曖昧、
不安定のものでしかありえないといふことを意味します。今日においても、
この國語音韻、かな文字の性格、及び兩者の関係は少しも變らず、依然として
かな文字は私たちの不安定な音韻を表記するのに最もふさはしい不安定な文字
であり、歴史的かなづかひはさういふ國語音韻の生理に最も適合した表記法で
あると言へます。つまり、歴史的かなづかひが表音的でないことに不平を
もらすまへに、人々はまづかな文字が表音に適さぬことに不平を言ふべきで
あり、さらに溯つて、國語音韻そのものが表音を拒否してゐることに着目す
べきであります。

福田恆存 「私の國語教室」
EOS

x(/國語教室/, s, 800, 808)
x(/ゐたわけです/, s, 176, 188)

s = <<EOS
ロジェストウェンスキーの日本海海戦について、公にされた説明は
これだけである。言外に、対馬東水道に、与えられた戦力で入る限り、
初めから勝利は不可能だった、と伝えている。
あるいはニコライ二世に対する厳しい非難を含むつもりだったのかも
しれない。
これ以降、ロシアの日本海海戦についての論評は、
「主砲発射速度」「下瀬火薬」「徹甲弾使用」などに、敗因を帰す
ようになった。

別宮暖朗 「「坂の上の雲」では分からない日本海海戦」 並木書房 (2005)
EOS

x(/\A(.*)の日本海海戦について/, s, 0, 22, 1)
x(/「(.*?)」[^「]*「(.+?)」[^「]*「(?:.*?)」/, s, 290, 332)
x(/海{1,2}(?=戦)/, s, 28, 32)

# result
printf("\n*** SUCCESS: %d,  FAIL: %d    Ruby %s (%s) [%s] ***\n",
       $rok, $rfail, RUBY_VERSION, RUBY_RELEASE_DATE, RUBY_PLATFORM)

# END.
