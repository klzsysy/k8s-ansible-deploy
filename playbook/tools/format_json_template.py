#!/usr/bin/python
import sys

strip=""
file_name=""

stdin=sys.stdin.read()

args=[x.strip() for x in sys.argv[1:]]

text_list=[]

for ar in args:
    if 'strip' in ar:
        strip=ar.split('=')[1]
    elif 'file' in ar:
        file_name=ar.split('=')[1]
    else:
        text_list.append(ar)
text='\n'.join(text_list)
text=text.strip(strip)
print stdin % text
