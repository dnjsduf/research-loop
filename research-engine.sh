#!/bin/bash
# research-engine.sh — 학술 논문 자동 탐색 엔진 v2
# =================================================
# 사용법:
#   ./research-engine.sh "주제"
#   ./research-engine.sh "주제" --max-results 30 --depth 1 --slug my-slug
#   ./research-engine.sh "주제" --hops 2          # 멀티홉 반복 탐색
#
# v2 개선점 (Deep Research 논문 기반):
#   - 멀티홉 반복 탐색: 1차 결과 → 갭 분석 → 재검색 (WebThinker/DeepResearcher 패턴)
#   - 적응형 쿼리 리파인먼트: 초록 분석으로 누락 키워드 자동 발견
#   - 클러스터링: 논문을 하위 주제별로 그룹화하여 커버리지 맵 생성
#   - 증거 스코어링: 다중 신호(인용, 관련도, 최신성, OA, 교차검증) 통합
#
# 학술 API (OpenAlex, Semantic Scholar, CrossRef)를 체계적으로 검색하고
# 인용 체인을 탐색하여 관련 논문을 발견, 랭킹, queue.md에 추가한다.
# PDF 다운로드는 하지 않음 (fetch-sources.sh가 담당).

set -e

# Python 자동 감지
source "$(dirname "$0")/detect-python.sh" || exit 1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── 인자 파싱 ────────────────────────────────────────────────
TOPIC=""
MAX_RESULTS=30
DEPTH=1
SLUG=""
HOPS=2

while [[ $# -gt 0 ]]; do
  case $1 in
    --max-results) MAX_RESULTS="$2"; shift 2 ;;
    --depth)       DEPTH="$2"; shift 2 ;;
    --slug)        SLUG="$2"; shift 2 ;;
    --hops)        HOPS="$2"; shift 2 ;;
    --*)           echo -e "${RED}알 수 없는 옵션: $1${NC}"; exit 1 ;;
    *)
      if [ -z "$TOPIC" ]; then TOPIC="$1"; fi
      shift ;;
  esac
done

if [ -z "$TOPIC" ]; then
  echo -e "${BLUE}Research Engine — 학술 논문 탐색${NC}"
  echo ""
  echo "사용법:"
  echo "  ./research-engine.sh \"주제 또는 논문 제목\""
  echo "  ./research-engine.sh \"deep RL\" --max-results 30 --depth 1"
  echo "  ./research-engine.sh \"game AI\" --slug game-ai"
  echo ""
  exit 0
fi

mkdir -p docs/research

echo -e "${CYAN}=== Research Engine v2: 멀티홉 학술 탐색 ===${NC}"
echo -e "주제: ${GREEN}$TOPIC${NC}"
echo -e "최대 수집: ${GREEN}${MAX_RESULTS}개${NC} | 인용 깊이: ${GREEN}${DEPTH}${NC} | 탐색 홉: ${GREEN}${HOPS}${NC}"
echo ""

# ── 메인 Python 블록 ─────────────────────────────────────────
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8 - "$TOPIC" "$MAX_RESULTS" "$DEPTH" "$SLUG" "$HOPS" << 'PYEOF'
import sys, json, re, os, time, hashlib
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')
from urllib.request import urlopen, Request
from urllib.parse import quote
from datetime import datetime
from collections import Counter

topic = sys.argv[1]
max_results = int(sys.argv[2])
depth = int(sys.argv[3])
slug_override = sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] else ""
num_hops = int(sys.argv[5]) if len(sys.argv) > 5 else 2

# ── 유틸리티 ──────────────────────────────────────────────────

def make_slug(text):
    # 한글 주제면 영어 변환 시도
    kr_slug_map = {
        '게임 자동화': 'game-automation',
        '강화학습': 'reinforcement-learning',
        '딥러닝': 'deep-learning',
        '자연어처리': 'nlp',
        '컴퓨터 비전': 'computer-vision',
        '객체 탐지': 'object-detection',
        '동작 인식': 'action-recognition',
        '자율 주행': 'autonomous-driving',
    }
    s = text.strip()
    if s in kr_slug_map:
        return kr_slug_map[s]
    s = s.lower()
    s = re.sub(r'[^a-z0-9\s-]', '', s)
    s = re.sub(r'[\s-]+', '-', s)
    result = s[:60].strip('-')
    # 빈 문자열이면 해시로 대체
    if not result:
        result = 'research-' + hashlib.md5(text.encode()).hexdigest()[:8]
    return result

def normalize_title(title):
    return re.sub(r'[^a-z0-9 ]', '', title.lower()).strip()

_last_api_call = 0  # 마지막 API 호출 시간

def adaptive_sleep(min_interval=0.3):
    """이전 API 호출로부터 min_interval 미만이면 그만큼만 대기"""
    global _last_api_call
    now = time.time()
    elapsed = now - _last_api_call
    if elapsed < min_interval:
        time.sleep(min_interval - elapsed)
    _last_api_call = time.time()

def api_get(url, timeout=15):
    """URL에서 JSON을 가져온다. 실패하면 None."""
    adaptive_sleep(0.3)
    try:
        req = Request(url, headers={
            'User-Agent': 'research-engine/2.0 (academic-search)',
            'Accept': 'application/json'
        })
        with urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode('utf-8'))
    except Exception as e:
        print(f"  [WARN] API 실패: {url[:60]}... ({e})", file=sys.stderr)
        return None

# ── Stage 1: 키워드 확장 ─────────────────────────────────────

def expand_keywords(topic):
    variants = [topic]

    # 영어 변환 (한글 주제인 경우 기본 매핑)
    kr_en_map = {
        '게임 자동화': 'game automation',
        '강화학습': 'reinforcement learning',
        '딥러닝': 'deep learning',
        '자연어처리': 'natural language processing',
        '컴퓨터 비전': 'computer vision',
        '객체 탐지': 'object detection',
        '동작 인식': 'action recognition',
        '자율 주행': 'autonomous driving',
    }

    # 한글이 포함된 경우 영어 변환 추가
    if re.search(r'[가-힣]', topic):
        for kr, en in kr_en_map.items():
            if kr in topic:
                en_topic = topic.replace(kr, en)
                variants.append(en_topic)
                variants.append(en)
        # 매핑에 없으면 원본만 사용 (Claude가 나중에 웹검색으로 보완)
    else:
        # 영어 주제: 약어/동의어 확장
        abbrev_map = {
            'reinforcement learning': ['RL', 'deep reinforcement learning', 'deep RL'],
            'natural language processing': ['NLP'],
            'computer vision': ['CV'],
            'game automation': ['game AI', 'game bot', 'automated game playing'],
            'object detection': ['object recognition'],
            'action recognition': ['activity recognition', 'human action recognition'],
            'autonomous driving': ['self-driving', 'autonomous vehicles'],
            'generative adversarial': ['GAN'],
            'large language model': ['LLM'],
            'graph neural network': ['GNN'],
        }
        topic_lower = topic.lower()
        for key, expansions in abbrev_map.items():
            if key in topic_lower:
                variants.extend(expansions)

        # 단어가 3개 이상이면 핵심 바이그램 추가
        words = topic.split()
        if len(words) >= 3:
            variants.append(' '.join(words[:2]))
            variants.append(' '.join(words[-2:]))

    # 중복 제거, 최대 5개
    seen = set()
    unique = []
    for v in variants:
        v = v.strip()
        if v.lower() not in seen and v:
            seen.add(v.lower())
            unique.append(v)
    return unique[:5]

# ── Stage 2: API 검색 ────────────────────────────────────────

def search_openalex(query, per_page=10):
    """OpenAlex 검색 (무료, API키 불필요)"""
    url = f"https://api.openalex.org/works?search={quote(query)}&per_page={per_page}&sort=cited_by_count:desc"
    data = api_get(url)
    if not data or 'results' not in data:
        return []

    papers = []
    for w in data['results']:
        title = w.get('title', '')
        if not title:
            continue

        # DOI에서 URL 추출
        doi = (w.get('doi') or '').replace('https://doi.org/', '')

        # 오픈 액세스 URL
        oa_url = ''
        oa = w.get('open_access', {})
        if oa.get('oa_url'):
            oa_url = oa['oa_url']

        # 저자
        authors = []
        for a in (w.get('authorships') or [])[:5]:
            name = (a.get('author') or {}).get('display_name', '')
            if name:
                authors.append(name)

        # 초록 복원 (inverted index → 텍스트)
        abstract = ''
        inv_idx = w.get('abstract_inverted_index')
        if inv_idx:
            try:
                word_pos = []
                for word, positions in inv_idx.items():
                    for pos in positions:
                        word_pos.append((pos, word))
                word_pos.sort()
                abstract = ' '.join(w for _, w in word_pos)[:500]
            except:
                pass

        # best URL 결정
        best_url = oa_url or (f"https://doi.org/{doi}" if doi else '')

        papers.append({
            'title': title,
            'authors': authors,
            'year': w.get('publication_year') or 0,
            'doi': doi,
            'url': best_url,
            'abstract': abstract,
            'citation_count': w.get('cited_by_count') or 0,
            'open_access': bool(oa_url),
            'open_access_url': oa_url,
            'source_api': 'openalex',
            'found_via': 'direct_search',
            'external_id': w.get('id', ''),
        })
    return papers

def search_semantic_scholar(query, limit=10):
    """Semantic Scholar 검색"""
    fields = "title,abstract,year,citationCount,authors,openAccessPdf,externalIds,url"
    url = f"https://api.semanticscholar.org/graph/v1/paper/search?query={quote(query)}&fields={fields}&limit={limit}"
    data = api_get(url)
    if not data or 'data' not in data:
        return []

    papers = []
    for p in data['data']:
        title = p.get('title', '')
        if not title:
            continue

        doi = (p.get('externalIds') or {}).get('DOI', '')
        arxiv_id = (p.get('externalIds') or {}).get('ArXiv', '')
        oa_pdf = (p.get('openAccessPdf') or {}).get('url', '')

        # best URL
        if arxiv_id:
            best_url = f"https://arxiv.org/abs/{arxiv_id}"
        elif doi:
            best_url = f"https://doi.org/{doi}"
        else:
            best_url = p.get('url', '')

        authors = [a.get('name', '') for a in (p.get('authors') or [])[:5] if a.get('name')]

        papers.append({
            'title': title,
            'authors': authors,
            'year': p.get('year') or 0,
            'doi': doi,
            'url': best_url,
            'abstract': (p.get('abstract') or '')[:500],
            'citation_count': p.get('citationCount') or 0,
            'open_access': bool(oa_pdf),
            'open_access_url': oa_pdf,
            'source_api': 'semantic_scholar',
            'found_via': 'direct_search',
            'external_id': p.get('paperId', ''),
        })
    return papers

def search_crossref(query, rows=10):
    """CrossRef 검색"""
    url = f"https://api.crossref.org/works?query={quote(query)}&rows={rows}&sort=is-referenced-by-count&order=desc"
    data = api_get(url, timeout=20)
    if not data or 'message' not in data:
        return []

    papers = []
    for item in (data['message'].get('items') or []):
        titles = item.get('title', [])
        title = titles[0] if titles else ''
        if not title:
            continue

        doi = item.get('DOI', '')

        # 연도 추출
        year = 0
        published = item.get('published-print') or item.get('published-online') or {}
        parts = published.get('date-parts', [[]])
        if parts and parts[0]:
            year = parts[0][0] if parts[0][0] else 0

        # 저자
        authors = []
        for a in (item.get('author') or [])[:5]:
            name = f"{a.get('given', '')} {a.get('family', '')}".strip()
            if name:
                authors.append(name)

        # 초록
        abstract = ''
        if item.get('abstract'):
            abstract = re.sub(r'<[^>]+>', '', item['abstract'])[:500]

        best_url = f"https://doi.org/{doi}" if doi else ''

        papers.append({
            'title': title,
            'authors': authors,
            'year': year,
            'doi': doi,
            'url': best_url,
            'abstract': abstract,
            'citation_count': item.get('is-referenced-by-count') or 0,
            'open_access': False,
            'open_access_url': '',
            'source_api': 'crossref',
            'found_via': 'direct_search',
            'external_id': doi,
        })
    return papers

# ── Stage 3: 인용 체인 탐색 ──────────────────────────────────

def fetch_citation_chain(paper_id, direction='references', limit=10):
    """Semantic Scholar에서 인용/피인용 논문 가져오기.
    S2 API는 citedPaper/citingPaper가 None인 경우가 있음 (미등록 논문).
    entry 자체가 None이거나 필드가 비정상인 경우도 방어.
    Ref: github.com/danielnsilva/semanticscholar/issues/80
    """
    fields = "title,abstract,year,citationCount,authors,openAccessPdf,externalIds,url"
    url = f"https://api.semanticscholar.org/graph/v1/paper/{paper_id}/{direction}?fields={fields}&limit={limit}"

    try:
        data = api_get(url)
    except Exception:
        return []

    if not data or not isinstance(data, dict) or 'data' not in data:
        return []

    entries = data['data']
    if not isinstance(entries, list):
        return []

    papers = []
    key = 'citedPaper' if direction == 'references' else 'citingPaper'

    for entry in entries:
        # entry 자체가 None이거나 dict가 아닌 경우
        if not entry or not isinstance(entry, dict):
            continue

        p = entry.get(key)
        # citedPaper/citingPaper가 None인 경우 (S2 미등록)
        if not p or not isinstance(p, dict) or not p.get('title'):
            continue

        try:
            ext_ids = p.get('externalIds') or {}
            if not isinstance(ext_ids, dict):
                ext_ids = {}
            doi = ext_ids.get('DOI', '')
            arxiv_id = ext_ids.get('ArXiv', '')

            oa_obj = p.get('openAccessPdf') or {}
            if not isinstance(oa_obj, dict):
                oa_obj = {}
            oa_pdf = oa_obj.get('url', '')

            if arxiv_id:
                best_url = f"https://arxiv.org/abs/{arxiv_id}"
            elif doi:
                best_url = f"https://doi.org/{doi}"
            else:
                best_url = p.get('url', '') or ''

            author_list = p.get('authors') or []
            if not isinstance(author_list, list):
                author_list = []
            authors = [a.get('name', '') for a in author_list[:5]
                       if isinstance(a, dict) and a.get('name')]

            papers.append({
                'title': p['title'],
                'authors': authors,
                'year': p.get('year') or 0,
                'doi': doi,
                'url': best_url,
                'abstract': (p.get('abstract') or '')[:500],
                'citation_count': p.get('citationCount') or 0,
                'open_access': bool(oa_pdf),
                'open_access_url': oa_pdf,
                'source_api': 'semantic_scholar',
                'found_via': f'citation_chain_{direction}',
                'external_id': p.get('paperId', ''),
            })
        except Exception:
            # 개별 항목 파싱 실패 시 건너뛰기 (루프 중단 방지)
            continue

    return papers

# ── Stage 3.5: GitHub/공개 코드 탐색 (Papers With Code API) ───

def search_github_repos(papers):
    """Papers With Code API로 논문에 연결된 GitHub 레포 탐색"""
    print("🔧 공개 코드 탐색 중...")
    found = 0
    consecutive_fails = 0

    for p in papers[:15]:  # 상위 15개만
        title = p.get('title', '')
        if not title:
            continue

        # 연속 3회 실패하면 PwC API 문제로 판단하고 중단
        if consecutive_fails >= 3:
            print("  PwC API 불안정 — 탐색 중단")
            break

        # Papers With Code API 검색
        pwc_url = f"https://paperswithcode.com/api/v1/papers/?q={quote(title[:80])}"
        data = api_get(pwc_url, timeout=10)
        if not data or 'results' not in data or not data['results']:
            consecutive_fails += 1
            continue
        consecutive_fails = 0  # 성공하면 리셋

        # 첫 번째 결과에서 레포 정보
        paper_id = data['results'][0].get('id', '')
        if not paper_id:
            continue

        repos_url = f"https://paperswithcode.com/api/v1/papers/{paper_id}/repositories/"
        repos_data = api_get(repos_url, timeout=10)
        if not repos_data or 'results' not in repos_data:
            continue

        repos = []
        for r in repos_data['results'][:3]:
            repo_info = {
                'url': r.get('url', ''),
                'stars': r.get('stars', 0),
                'framework': r.get('framework', ''),
                'is_official': r.get('is_official', False),
            }
            if repo_info['url']:
                repos.append(repo_info)

        if repos:
            p['github_repos'] = repos
            found += 1
            best = repos[0]
            tag = "★공식" if best['is_official'] else ""
            print(f"  ✓ {title[:50]}... → {best['url']} ({best['stars']}★) {tag}")

        adaptive_sleep(0.3)

    print(f"  공개 코드 발견: {found}개 논문")
    print()
    return papers

# ── Stage 4: 중복 제거 + 랭킹 ────────────────────────────────

def deduplicate(papers):
    seen_titles = set()
    seen_dois = set()
    unique = []
    for p in papers:
        norm = normalize_title(p['title'])
        doi = p.get('doi', '')

        if norm in seen_titles:
            # 기존 항목에 메타데이터 보강
            for u in unique:
                if normalize_title(u['title']) == norm:
                    if not u['abstract'] and p['abstract']:
                        u['abstract'] = p['abstract']
                    if not u['open_access'] and p['open_access']:
                        u['open_access'] = True
                        u['open_access_url'] = p['open_access_url']
                    if p['citation_count'] > u['citation_count']:
                        u['citation_count'] = p['citation_count']
                    if 'source_apis' not in u:
                        u['source_apis'] = [u['source_api']]
                    if p['source_api'] not in u['source_apis']:
                        u['source_apis'].append(p['source_api'])
                    break
            continue

        if doi and doi in seen_dois:
            continue

        seen_titles.add(norm)
        if doi:
            seen_dois.add(doi)
        p['source_apis'] = [p['source_api']]
        unique.append(p)
    return unique

def rank_papers(papers, query):
    current_year = datetime.now().year
    query_words = set(query.lower().split())

    for p in papers:
        # 인용 점수 (최대 1.0)
        cite_score = min((p['citation_count'] or 0) / 200, 1.0)

        # 최신성 점수
        year = p.get('year') or 0
        if year > 0:
            age = current_year - year
            recency = max(0, 1.0 - age / 20)  # 20년 이상이면 0
        else:
            recency = 0.3

        # 제목 관련도
        title_words = set(p['title'].lower().split())
        if query_words and title_words:
            overlap = len(query_words & title_words)
            relevance = overlap / len(query_words)
        else:
            relevance = 0.0

        # 초록 관련도 (키워드가 초록에 포함되는지)
        abstract_lower = (p.get('abstract') or '').lower()
        abstract_relevance = 0.0
        if abstract_lower and query_words:
            abs_hits = sum(1 for w in query_words if w in abstract_lower)
            abstract_relevance = abs_hits / len(query_words)

        # 오픈 액세스 보너스
        oa_bonus = 1.0 if p.get('open_access') else 0.0

        # 초록 존재 보너스
        abstract_bonus = 1.0 if p.get('abstract') else 0.0

        # 다중 API 발견 보너스
        multi_api = min(len(p.get('source_apis', [1])) / 2, 1.0)

        p['score'] = round(
            0.20 * cite_score +
            0.15 * recency +
            0.30 * relevance +
            0.15 * abstract_relevance +
            0.05 * oa_bonus +
            0.05 * abstract_bonus +
            0.10 * multi_api,
            4
        )

    papers.sort(key=lambda p: p['score'], reverse=True)
    return papers

# ── Stage 5: 출력 + queue 업데이트 ────────────────────────────

def add_to_queue(papers, parent_slug, max_add=10):
    """상위 논문을 queue.md에 배치 추가 (1회 읽기/쓰기)"""
    if not os.path.exists('queue.md'):
        return 0

    with open('queue.md', 'r', encoding='utf-8') as f:
        content = f.read()

    # 중복 체크용 set (정규화된 제목)
    main_text_lower = re.sub(r'```.*?```', '', content, flags=re.DOTALL).lower()
    existing_titles = set()
    for line in main_text_lower.split('\n'):
        m = re.search(r'title:\s*["\']?(.+?)["\']?\s*$', line)
        if m:
            existing_titles.add(normalize_title(m.group(1)))

    today = datetime.now().strftime('%Y-%m-%d')
    batch_items = []

    for p in papers[:max_add]:
        norm = normalize_title(p['title'])
        if norm in existing_titles:
            continue
        if not p.get('url') or p['url'] == 'null':
            continue

        batch_items.append(
            f'  - title: "{p["title"]}"\n'
            f'    slug: ""\n'
            f'    url: "{p["url"]}"\n'
            f'    local_path: null\n'
            f'    access_type: url\n'
            f'    pre_research: pending\n'
            f'    fetch_requested: false\n'
            f'    priority: 2\n'
            f'    status: pending\n'
            f'    source_of: "{parent_slug}"\n'
            f'    added: "{today}"\n'
        )
        existing_titles.add(norm)

    if not batch_items:
        return 0

    # 배치 삽입 (1회 쓰기)
    all_items = ''.join(batch_items)
    if re.search(r'^papers:\s*$', content, re.MULTILINE):
        content = re.sub(
            r'^(papers:\s*)$',
            r'\1\n' + all_items,
            content,
            flags=re.MULTILINE
        )
    else:
        content += f"\npapers:\n{all_items}"

    with open('queue.md', 'w', encoding='utf-8') as f:
        f.write(content)

    return len(batch_items)

# ── 멀티홉 갭 분석 (WebThinker/DeepResearcher 패턴) ───────────

def extract_gap_keywords(papers, original_keywords, top_n=3):
    """수집된 논문 초록에서 빈출 키워드를 추출하여 원래 쿼리에 없던 갭을 발견"""
    # 불용어 + 너무 일반적인 학술 용어
    stopwords = set('the a an in on of to for and or is are was were by with from at as it this that be has have had do does did will would could should may might shall can not no but if then than so very also each every all any some most other into about between through during before after above below up down out off over under again further once here there when where why how both few more most such only own same'.split())
    # 일반적 학술/ML 용어 (갭으로 잡히면 주제 이탈 유발)
    stopwords.update('deep learning model models neural network networks large scale image images data training train test performance based method methods approach results using proposed paper study show state propose novel framework systems system convolutional recurrent prediction recognition classification detection feature features layer layers attention transformer'.split())
    stopwords.update(w.lower() for kw in original_keywords for w in kw.split())

    word_freq = Counter()
    for p in papers[:20]:  # 상위 20개 논문만 분석
        text = f"{p.get('title', '')} {p.get('abstract', '')}".lower()
        words = re.findall(r'[a-z]{3,}', text)
        for w in words:
            if w not in stopwords and len(w) > 3:
                word_freq[w] += 1

    # 빈도 상위 단어에서 2-gram 패턴도 추출
    bigram_freq = Counter()
    for p in papers[:20]:
        text = f"{p.get('title', '')} {p.get('abstract', '')}".lower()
        words = re.findall(r'[a-z]{3,}', text)
        for i in range(len(words) - 1):
            bg = f"{words[i]} {words[i+1]}"
            if words[i] not in stopwords or words[i+1] not in stopwords:
                bigram_freq[bg] += 1

    # 이미 검색한 키워드와 겹치지 않는 것만
    existing = set(kw.lower() for kw in original_keywords)
    topic_words = set(topic.lower().split())

    gap_keywords = []
    for bg, count in bigram_freq.most_common(30):
        if count < 3:
            continue
        if bg in existing or any(bg in e for e in existing):
            continue
        # 갭 키워드가 원래 주제와 최소 1단어 겹치거나, 빈도가 매우 높아야 함
        bg_words = set(bg.split())
        topic_overlap = len(bg_words & topic_words)
        if topic_overlap == 0 and count < 5:
            continue  # 주제와 무관하고 빈도도 낮으면 스킵
        gap_keywords.append(bg)
        if len(gap_keywords) >= top_n:
            break

    return gap_keywords

def cluster_papers(papers):
    """논문을 하위 주제별로 간단히 클러스터링 (키워드 기반)"""
    clusters = {}
    for p in papers:
        text = f"{p.get('title', '')} {p.get('abstract', '')}".lower()

        # 간단한 주제 태그 추출
        tags = []
        tag_patterns = {
            'reinforcement_learning': r'\breinforcement\s+learning\b|\brl\b|\bppo\b|\breward',
            'web_search': r'\bweb\s+search\b|\bbrowsing\b|\bsearch\s+engine\b|\bretrieval',
            'reasoning': r'\breasoning\b|\bchain.of.thought\b|\bthinking\b',
            'evaluation': r'\bbenchmark\b|\bevaluat\b|\bmetric\b|\bscoring',
            'architecture': r'\barchitecture\b|\bframework\b|\bpipeline\b|\bsystem\s+design',
            'generation': r'\bgenerat\b|\bsynthesis\b|\breport\b|\bsummar',
            'tool_use': r'\btool\s+use\b|\btool\s+learning\b|\bfunction\s+call',
            'factuality': r'\bfactual\b|\bhallucin\b|\bverif\b|\bfact.check',
            'optimization': r'\boptimiz\b|\bspeedup\b|\blatency\b|\baccelerat',
        }
        for tag, pattern in tag_patterns.items():
            if re.search(pattern, text):
                tags.append(tag)

        if not tags:
            tags = ['general']

        for tag in tags:
            if tag not in clusters:
                clusters[tag] = []
            clusters[tag].append(p['title'][:60])

    return clusters

def run_search_round(keywords, per_api, apis_used_ref, all_papers_ref):
    """1회 검색 라운드 실행. SS 실패 시 OA/CR 검색량 보상."""
    round_papers = []
    ss_failed = False

    for kw in keywords:
        print(f"  [{kw}]", end="", flush=True)

        # Semantic Scholar 먼저 시도 (실패 여부 확인용)
        adaptive_sleep(0.8)
        ss_results = search_semantic_scholar(kw, limit=per_api)
        if ss_results:
            round_papers.extend(ss_results)
            if 'semantic_scholar' not in apis_used_ref:
                apis_used_ref.append('semantic_scholar')
        else:
            ss_failed = True

        # SS 실패 시 OA/CR 검색량 2배로 보상
        oa_limit = per_api * 2 if ss_failed else per_api
        cr_limit = per_api * 2 if ss_failed else per_api

        results = search_openalex(kw, per_page=oa_limit)
        if results:
            round_papers.extend(results)
            if 'openalex' not in apis_used_ref:
                apis_used_ref.append('openalex')
        oa_count = len(results)

        results = search_crossref(kw, rows=cr_limit)
        if results:
            round_papers.extend(results)
            if 'crossref' not in apis_used_ref:
                apis_used_ref.append('crossref')
        cr_count = len(results)

        ss_count = len(ss_results) if ss_results else 0
        compensated = " [보상↑]" if ss_failed and ss_count == 0 else ""
        print(f" OA:{oa_count} SS:{ss_count} CR:{cr_count}{compensated}")

    all_papers_ref.extend(round_papers)
    return round_papers

# ══════════════════════════════════════════════════════════════
# 메인 실행 — 멀티홉 탐색 루프
# ══════════════════════════════════════════════════════════════

slug = slug_override or make_slug(topic)

# 캐시 확인: 24시간 이내 결과가 있으면 재사용
json_path = f"docs/research/{slug}.json"
if os.path.exists(json_path):
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            cached = json.load(f)
        cached_time = datetime.fromisoformat(cached.get('searched_at', '2000-01-01'))
        age_hours = (datetime.now() - cached_time).total_seconds() / 3600
        if age_hours < 24 and cached.get('total_ranked', 0) >= 10:
            print(f"CACHE_HIT")
            print(f"RESEARCH_COMPLETE")
            print(f"SLUG={slug}")
            print(f"PAPERS_FOUND={cached.get('total_deduped', 0)}")
            print(f"PAPERS_QUEUED=0")
            print(f"JSON_PATH={json_path}")
            print(f"CACHE_AGE={age_hours:.1f}h")
            os._exit(0)
    except:
        pass  # 캐시 파싱 실패 시 무시하고 계속

all_papers = []
apis_used = []
all_keywords_used = []

for hop in range(1, num_hops + 1):
    print(f"{'='*50}")
    print(f"  HOP {hop}/{num_hops}")
    print(f"{'='*50}")
    print()

    if hop == 1:
        # 첫 번째 홉: 기본 키워드 확장
        keywords = expand_keywords(topic)
    else:
        # 후속 홉: 갭 분석으로 새 키워드 발견
        print("  🔍 갭 분석: 수집된 논문에서 누락 키워드 탐색...")
        gap_kw = extract_gap_keywords(all_papers, all_keywords_used)
        if not gap_kw:
            print("  → 추가 갭 키워드 없음. 탐색 조기 종료.")
            break
        keywords = gap_kw
        print(f"  → 발견된 갭 키워드: {gap_kw}")
        print()

    all_keywords_used.extend(keywords)
    print(f"🔎 검색 키워드: {keywords}")
    print()

    per_api = max(5, max_results // (len(keywords) * 3))
    round_papers = run_search_round(keywords, per_api, apis_used, all_papers)

    print()
    print(f"  HOP {hop} 수집: {len(round_papers)}개")

    # 중간 중복 제거
    all_papers = deduplicate(all_papers)
    print(f"  누적 (중복 제거 후): {len(all_papers)}개")
    print()

total_raw = len(all_papers)

# 결과 0개 조기 경고
if total_raw == 0:
    print()
    print("⚠️ 논문 0개 수집 — 모든 API 실패 (네트워크 확인 필요)")
    print("   Claude가 웹 검색 전용 모드로 진행합니다.")
    print()
    # 빈 JSON 저장
    output = {
        'query': topic, 'slug': slug,
        'searched_at': datetime.now().isoformat(), 'version': 2,
        'keyword_variants': all_keywords_used, 'apis_used': [],
        'total_raw': 0, 'total_deduped': 0, 'total_ranked': 0,
        'coverage_map': {}, 'papers': [],
        'warning': 'all_apis_failed'
    }
    json_path = f"docs/research/{slug}.json"
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    print(f"RESEARCH_COMPLETE")
    print(f"SLUG={slug}")
    print(f"PAPERS_FOUND=0")
    print(f"PAPERS_QUEUED=0")
    print(f"JSON_PATH={json_path}")
    print(f"WARNING=all_apis_failed")
    os._exit(0)

# 인용 체인 탐색 (depth >= 1)
if depth >= 1 and all_papers:
    ranked_temp = rank_papers(all_papers[:], topic)
    top_for_chain = [p for p in ranked_temp[:5] if p.get('external_id')]

    if top_for_chain:
        print(f"🔗 인용 체인 탐색 (상위 {len(top_for_chain)}개)...")
        chain_papers = []

        for p in top_for_chain:
            pid = p['external_id']
            print(f"  [{p['title'][:50]}...]")

            adaptive_sleep(0.8)
            refs = fetch_citation_chain(pid, 'references', limit=5)
            print(f"    참조: {len(refs)}개")
            chain_papers.extend(refs)

            adaptive_sleep(0.8)
            cites = fetch_citation_chain(pid, 'citations', limit=5)
            print(f"    피인용: {len(cites)}개")
            chain_papers.extend(cites)

        all_papers.extend(chain_papers)
        print(f"  인용 체인 추가: {len(chain_papers)}개")

# 최종 중복 제거 + 랭킹
all_papers = deduplicate(all_papers)
all_papers = rank_papers(all_papers, topic)
total_deduped = len(all_papers)

# GitHub/공개 코드 탐색
top_for_github = all_papers[:max_results]
top_for_github = search_github_repos(top_for_github)
all_papers[:max_results] = top_for_github

top_papers = all_papers[:max_results]

# 클러스터링 — 커버리지 맵 생성
clusters = cluster_papers(top_papers)

print()
print(f"🏆 최종 결과: {len(top_papers)}개 (총 {total_deduped}개 중 상위)")
print()

# 커버리지 맵 출력
if clusters:
    print("📊 주제 커버리지 맵:")
    for tag, titles in sorted(clusters.items(), key=lambda x: -len(x[1])):
        print(f"  [{tag}] {len(titles)}편")
    print()

# 상위 10개 출력
for i, p in enumerate(top_papers[:10], 1):
    oa_mark = "OA" if p.get('open_access') else "  "
    year = p.get('year', '?')
    cites = p.get('citation_count', 0)
    print(f"  {i:2d}. [{oa_mark}] [{year}] (cite:{cites}) {p['title'][:65]}")
    if p.get('url'):
        print(f"      {p['url']}")

# JSON 출력 — 클러스터 + 멀티홉 메타데이터 포함
output = {
    'query': topic,
    'slug': slug,
    'searched_at': datetime.now().isoformat(),
    'version': 2,
    'keyword_variants': all_keywords_used,
    'hops_completed': min(num_hops, hop) if 'hop' in dir() else num_hops,
    'apis_used': apis_used,
    'total_raw': total_raw,
    'total_deduped': total_deduped,
    'total_ranked': len(top_papers),
    'coverage_map': {tag: len(titles) for tag, titles in clusters.items()},
    'papers': []
}

for i, p in enumerate(top_papers, 1):
    output['papers'].append({
        'rank': i,
        'score': p['score'],
        'title': p['title'],
        'authors': p.get('authors', []),
        'year': p.get('year', 0),
        'doi': p.get('doi', ''),
        'url': p.get('url', ''),
        'abstract': p.get('abstract', ''),
        'citation_count': p.get('citation_count', 0),
        'open_access': p.get('open_access', False),
        'open_access_url': p.get('open_access_url', ''),
        'source_apis': p.get('source_apis', []),
        'found_via': p.get('found_via', 'direct_search'),
        'github_repos': p.get('github_repos', []),
    })

json_path = f"docs/research/{slug}.json"
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print()
print(f"💾 결과 저장: {json_path}")

# queue.md pending 상한 체크 (30개 이상이면 추가 안 함)
pending_count = 0
if os.path.exists('queue.md'):
    with open('queue.md', 'r', encoding='utf-8') as f:
        pending_count = f.read().count('status: pending')

if pending_count >= 30:
    print(f"📋 pending {pending_count}개 — 상한(30) 도달, queue 추가 생략")
    added = 0
else:
    remaining = 30 - pending_count
    relevant_papers = [p for p in top_papers if p.get('score', 0) >= 0.5]
    added = add_to_queue(relevant_papers, slug, max_add=min(10, remaining))
print(f"📋 queue에 {added}개 논문 추가")

# ralph.sh가 파싱할 수 있는 요약 출력
print()
print(f"RESEARCH_COMPLETE")
print(f"SLUG={slug}")
print(f"PAPERS_FOUND={total_deduped}")
print(f"PAPERS_QUEUED={added}")
print(f"JSON_PATH={json_path}")

PYEOF

echo ""
echo -e "${CYAN}=== Research Engine 완료 ===${NC}"
