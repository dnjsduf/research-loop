#!/usr/bin/env python3
"""queue.md 안전한 파싱/수정 유틸리티

사용법:
  python3 queue-util.py list                    # pending/in_progress 항목 JSON 출력
  python3 queue-util.py add "title" "url" 1     # 새 항목 추가 (title, url, priority)
  python3 queue-util.py get-item-info            # 현재 처리 항목의 local_path, pdf_dir 출력
  python3 queue-util.py count-pending            # pending 개수
  python3 queue-util.py update-field "title" "field" "value"  # 특정 항목 필드 업데이트
"""

import sys, re, json, os
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')

QUEUE_FILE = 'queue.md'

def read_queue():
    """queue.md를 읽어서 항목 리스트로 파싱"""
    if not os.path.exists(QUEUE_FILE):
        return [], ""

    with open(QUEUE_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    items = []
    # papers: 섹션 이후의 항목들을 파싱
    # 각 항목은 "  - title:" 로 시작
    blocks = re.split(r'\n  - title:\s*', content)

    if len(blocks) <= 1:
        return items, content

    header = blocks[0]  # papers: 이전 부분

    for block in blocks[1:]:
        item = {}
        lines = block.strip().split('\n')

        # 첫 줄은 title 값
        title_match = re.match(r'^["\']?(.*?)["\']?\s*$', lines[0])
        if title_match:
            item['title'] = title_match.group(1)
        else:
            item['title'] = lines[0].strip().strip('"\'')

        # 나머지 줄에서 key: value 파싱
        for line in lines[1:]:
            kv = re.match(r'^\s+(\w+):\s*(.+)$', line)
            if kv:
                key = kv.group(1)
                val = kv.group(2).strip().strip('"\'')
                if val in ('null', 'None', '~'):
                    val = None
                elif val == 'true':
                    val = True
                elif val == 'false':
                    val = False
                elif re.match(r'^\d+$', val):
                    val = int(val)
                item[key] = val

        if item.get('title'):
            items.append(item)

    return items, content

def write_queue(items, original_content=""):
    """항목 리스트를 queue.md에 쓰기"""
    # 헤더 보존
    header_match = re.match(r'(.*?papers:)\s*\n', original_content, re.DOTALL)
    if header_match:
        header = header_match.group(1)
    else:
        header = "# 지식 DB 처리 대기열 (queue.md)\n\n## 📋 대기 중 (Pending)\n\npapers:"

    # done/dropped 섹션 보존
    done_section = ""
    done_match = re.search(r'\n(## ✅ 완료.*)', original_content, re.DOTALL)
    if done_match:
        done_section = '\n' + done_match.group(1)

    lines = [header]
    for item in items:
        title = item.get('title', '')
        # 특수문자 이스케이프: 따옴표를 안전하게 처리
        safe_title = title.replace('"', '\\"')

        entry = f'  - title: "{safe_title}"'
        for key in ['slug', 'url', 'local_path', 'access_type', 'pre_research',
                     'fetch_requested', 'priority', 'status', 'source_of',
                     'added', 'completed', 'phase', 'verify_knowledge_score',
                     'verify_report_score', 'existing_analysis', 'pipeline_ref',
                     'pdf_dir', 'note']:
            if key in item and key != 'title':
                val = item[key]
                if val is None:
                    entry += f'\n    {key}: null'
                elif isinstance(val, bool):
                    entry += f'\n    {key}: {"true" if val else "false"}'
                elif isinstance(val, int):
                    entry += f'\n    {key}: {val}'
                else:
                    entry += f'\n    {key}: "{val}"'
        lines.append(entry)

    content = '\n'.join(lines) + '\n' + done_section

    with open(QUEUE_FILE, 'w', encoding='utf-8') as f:
        f.write(content)

def cmd_list():
    """pending/in_progress 항목 JSON 출력"""
    items, _ = read_queue()
    active = [i for i in items if i.get('status') in ('pending', 'in_progress')]
    print(json.dumps(active, ensure_ascii=False))

def cmd_add(title, url, priority):
    """새 항목 추가 (중복 체크 포함)"""
    items, content = read_queue()

    # 중복 체크 (title 정규화 비교)
    norm = re.sub(r'[^a-z0-9 ]', '', title.lower()).strip()
    for item in items:
        existing_norm = re.sub(r'[^a-z0-9 ]', '', item.get('title', '').lower()).strip()
        if norm == existing_norm:
            print("DUPLICATE")
            return

    new_item = {
        'title': title,
        'slug': '',
        'url': url if url != 'null' else None,
        'local_path': None,
        'access_type': 'url',
        'pre_research': 'pending',
        'fetch_requested': False,
        'priority': int(priority),
        'status': 'pending',
        'source_of': None,
        'added': datetime.now().strftime('%Y-%m-%d'),
    }
    items.append(new_item)
    write_queue(items, content)
    print("ADDED")

def cmd_get_item_info():
    """현재 처리 항목의 local_path, pdf_dir 출력 (2줄)"""
    items, _ = read_queue()
    local_path = ""
    pdf_dir = ""

    for item in items:
        if item.get('status') in ('in_progress', 'pending'):
            lp = item.get('local_path')
            if lp and lp not in ('null', 'None'):
                local_path = str(lp)
            pd = item.get('pdf_dir')
            if pd and pd not in ('null', 'None'):
                pdf_dir = str(pd)
            break

    print(local_path)
    print(pdf_dir)

def cmd_count_pending():
    """pending 개수"""
    items, _ = read_queue()
    count = sum(1 for i in items if i.get('status') == 'pending')
    print(count)

def cmd_update_field(title, field, value):
    """특정 항목의 필드 값 업데이트"""
    items, content = read_queue()
    found = False

    for item in items:
        if item.get('title', '').lower() == title.lower():
            # 타입 변환
            if value in ('null', 'None'):
                item[field] = None
            elif value == 'true':
                item[field] = True
            elif value == 'false':
                item[field] = False
            elif re.match(r'^\d+$', value):
                item[field] = int(value)
            else:
                item[field] = value
            found = True
            break

    if found:
        write_queue(items, content)
        print("UPDATED")
    else:
        print("NOT_FOUND")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("사용법: python3 queue-util.py <command> [args...]")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == 'list':
        cmd_list()
    elif cmd == 'add' and len(sys.argv) >= 4:
        priority = sys.argv[4] if len(sys.argv) > 4 else '1'
        cmd_add(sys.argv[2], sys.argv[3], priority)
    elif cmd == 'get-item-info':
        cmd_get_item_info()
    elif cmd == 'count-pending':
        cmd_count_pending()
    elif cmd == 'update-field' and len(sys.argv) >= 5:
        cmd_update_field(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        print(f"알 수 없는 명령: {cmd}", file=sys.stderr)
        sys.exit(1)
