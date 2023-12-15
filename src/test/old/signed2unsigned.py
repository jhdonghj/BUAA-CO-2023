enc = 'utf-16'
fin = open('data.in', 'r+', encoding=enc)
fout = open('converted.in', 'w')

fout.write(fin.read().replace('add', 'addu').replace('sub', 'subu'))

print('converted')

fin.close()
fout.close()