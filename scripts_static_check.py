from pathlib import Path
import yaml
root=Path(__file__).parent
errors=[]
for p in root.rglob('*.dart'):
    s=p.read_text()
    stack=[]; quote=None; escape=False; line_comment=False; block_comment=0; i=0; line=1
    while i<len(s):
        ch=s[i]; nxt=s[i+1] if i+1<len(s) else ''
        if ch=='\n': line+=1; line_comment=False
        if line_comment: i+=1; continue
        if block_comment:
            if ch=='/' and nxt=='*': block_comment+=1;i+=2;continue
            if ch=='*' and nxt=='/': block_comment-=1;i+=2;continue
            i+=1;continue
        if quote:
            if escape: escape=False
            elif ch=='\\': escape=True
            elif ch==quote: quote=None
            i+=1;continue
        if ch=='/' and nxt=='/': line_comment=True;i+=2;continue
        if ch=='/' and nxt=='*': block_comment+=1;i+=2;continue
        if ch in "'\"": quote=ch;i+=1;continue
        if ch in '([{': stack.append((ch,line))
        if ch in ')]}':
            if not stack or '([{'.index(stack[-1][0])!=')]}'.index(ch): errors.append(f'{p.relative_to(root)}:{line}: mismatched {ch}')
            else: stack.pop()
        i+=1
    if stack:errors.append(f'{p.relative_to(root)}: unclosed delimiters {stack[-3:]}')
    if quote or block_comment:errors.append(f'{p.relative_to(root)}: unclosed quote/comment')
for y in [root/'pubspec.yaml',root/'.github/workflows/flutter.yml',root/'analysis_options.yaml']:
    try: yaml.safe_load(y.read_text())
    except Exception as exc: errors.append(f'{y.relative_to(root)} yaml {exc}')
print('Dart files',len(list(root.rglob('*.dart'))),'static delimiter checks:', 'PASSED' if not errors else 'FAILED')
print('YAML parse:', 'PASSED' if not errors else 'FAILED')
for error in errors:print(error)
raise SystemExit(bool(errors))
