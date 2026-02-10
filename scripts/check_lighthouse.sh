#!/bin/bash

# Page Speed & Performance Checker Script
# Uses Lighthouse to crawl and check all page metrics:
# - Performance
# - Accessibility
# - Best Practices
# - SEO
# Outputs HTML reports organized into pass/fail folders

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="./lighthouse-reports"
MAX_URLS=50
PASS_THRESHOLD=90  # Score >= 90 is considered pass
CATEGORIES=""      # Empty means all categories

usage() {
    echo "Usage: $0 -u <url> [-c <categories>] [-o <output_dir>] [-m <max_urls>] [-p <pass_threshold>]"
    echo ""
    echo "Options:"
    echo "  -u    URL to check (required)"
    echo "        - Domain (e.g., https://example.com) → crawls sitemap.xml"
    echo "        - Specific URL (e.g., https://example.com/about) → checks only that page"
    echo "  -c    Categories to check (comma-separated, default: all)"
    echo "        Options: performance, accessibility, best-practices, seo"
    echo "        Short: perf, a11y, bp, seo"
    echo "  -o    Output directory for reports (default: ./lighthouse-reports)"
    echo "  -m    Maximum URLs to check from sitemap (default: 50)"
    echo "  -p    Pass threshold score 0-100 (default: 90)"
    echo ""
    echo "Examples:"
    echo "  $0 -u https://example.com                      # All categories, entire site"
    echo "  $0 -u https://example.com/about                # All categories, single page"
    echo "  $0 -u https://example.com -c accessibility     # Accessibility only"
    echo "  $0 -u https://example.com -c perf,seo          # Performance and SEO only"
    echo "  $0 -u https://example.com -c a11y,bp           # Accessibility and Best Practices"
    exit 1
}

# Normalize category names (convert short forms to full Lighthouse names)
normalize_categories() {
    local input=$1
    local normalized=""

    # Split by comma and process each
    IFS=',' read -ra cats <<< "$input"
    for cat in "${cats[@]}"; do
        # Trim whitespace and convert to lowercase
        cat=$(echo "$cat" | tr '[:upper:]' '[:lower:]' | xargs)

        case "$cat" in
            perf|performance)
                normalized="${normalized},performance"
                ;;
            a11y|accessibility)
                normalized="${normalized},accessibility"
                ;;
            bp|best-practices|bestpractices)
                normalized="${normalized},best-practices"
                ;;
            seo)
                normalized="${normalized},seo"
                ;;
            *)
                echo -e "${RED}Unknown category: $cat${NC}" >&2
                echo -e "${YELLOW}Valid options: performance (perf), accessibility (a11y), best-practices (bp), seo${NC}" >&2
                exit 1
                ;;
        esac
    done

    # Remove leading comma
    echo "${normalized:1}"
}

check_dependencies() {
    local missing=()

    if ! command -v npx &> /dev/null; then
        missing+=("npx (install Node.js)")
    fi

    if ! command -v lighthouse &> /dev/null; then
        echo -e "${YELLOW}Installing lighthouse...${NC}"
        npm install -g lighthouse
    fi

    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing[*]}${NC}"
        exit 1
    fi
}

# Check if URL is a domain (root) or a specific page
is_domain_url() {
    local url=$1
    # Extract path from URL (everything after the domain)
    local path=$(echo "$url" | sed -E 's|^https?://[^/]+||')

    # It's a domain if path is empty, just "/", or just "/"
    if [[ -z "$path" || "$path" == "/" ]]; then
        return 0  # true - it's a domain
    else
        return 1  # false - it's a specific page
    fi
}

crawl_sitemap() {
    local base_url=$1
    local urls=()

    # Try to fetch sitemap.xml
    local sitemap_url="${base_url%/}/sitemap.xml"
    echo -e "${YELLOW}Attempting to fetch sitemap: $sitemap_url${NC}" >&2

    local sitemap_content=$(curl -sL "$sitemap_url" 2>/dev/null || echo "")

    if [[ -n "$sitemap_content" && "$sitemap_content" == *"<loc>"* ]]; then
        echo -e "${GREEN}Found sitemap.xml${NC}" >&2
        # macOS compatible: use sed instead of grep -P
        urls=($(echo "$sitemap_content" | sed -n 's:.*<loc>\([^<]*\)</loc>.*:\1:p' | head -n "$MAX_URLS"))
    else
        echo -e "${YELLOW}No sitemap found, using base URL only${NC}" >&2
        urls=("$base_url")
    fi

    printf '%s\n' "${urls[@]}"
}

run_lighthouse() {
    local url=$1
    local json_file=$2

    local category_flag=""
    if [[ -n "$CATEGORIES" ]]; then
        category_flag="--only-categories=$CATEGORIES"
    fi

    lighthouse "$url" \
        $category_flag \
        --output=json,html \
        --output-path="$json_file" \
        --chrome-flags="--headless --no-sandbox" \
        --quiet 2>/dev/null || true
}

get_scores() {
    local json_file=$1
    python3 -c "
import json
try:
    with open('$json_file') as f:
        data = json.load(f)
    categories = data.get('categories', {})
    perf = int(categories.get('performance', {}).get('score', 0) * 100) if categories.get('performance', {}).get('score') else -1
    a11y = int(categories.get('accessibility', {}).get('score', 0) * 100) if categories.get('accessibility', {}).get('score') else -1
    bp = int(categories.get('best-practices', {}).get('score', 0) * 100) if categories.get('best-practices', {}).get('score') else -1
    seo = int(categories.get('seo', {}).get('score', 0) * 100) if categories.get('seo', {}).get('score') else -1
    print(f'{perf}|{a11y}|{bp}|{seo}')
except:
    print('-1|-1|-1|-1')
"
}

get_average_score() {
    local scores=$1
    python3 -c "
scores = '$scores'.split('|')
valid = [int(s) for s in scores if int(s) >= 0]
if valid:
    print(int(sum(valid) / len(valid)))
else:
    print(-1)
"
}

get_failed_audits() {
    local json_file=$1
    python3 -c "
import json
try:
    with open('$json_file') as f:
        data = json.load(f)
    failed = []
    for audit_id, audit in data['audits'].items():
        if audit.get('score') == 0 and audit.get('scoreDisplayMode') == 'binary':
            failed.append(audit['title'])
    print('|'.join(failed[:5]) if failed else 'None')  # Limit to 5 issues
except:
    print('Error reading report')
"
}

generate_summary() {
    local output_dir=$1
    local summary_file="$output_dir/summary.html"
    local pass_dir="$output_dir/pass"
    local fail_dir="$output_dir/fail"

    # Count reports
    local pass_count=$(find "$pass_dir" -name "*.html" 2>/dev/null | wc -l | tr -d ' ')
    local fail_count=$(find "$fail_dir" -name "*.html" 2>/dev/null | wc -l | tr -d ' ')

    cat > "$summary_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lighthouse Report Summary</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 1400px; margin: 0 auto; padding: 20px; background: #f9f9f9; }
        h1 { color: #1a1a1a; border-bottom: 2px solid #0066cc; padding-bottom: 10px; }
        h2 { margin-top: 30px; }
        .stats { display: flex; gap: 20px; margin: 20px 0; flex-wrap: wrap; }
        .stat-box { padding: 20px 30px; border-radius: 8px; color: white; font-size: 24px; font-weight: bold; }
        .stat-box.pass { background: #4CAF50; }
        .stat-box.fail { background: #f44336; }
        .stat-label { font-size: 14px; font-weight: normal; opacity: 0.9; }
        .section { margin: 20px 0; }
        .section-header { display: flex; align-items: center; gap: 10px; cursor: pointer; }
        .section-header h2 { margin: 0; }
        .badge { padding: 4px 12px; border-radius: 20px; font-size: 14px; color: white; }
        .badge.pass { background: #4CAF50; }
        .badge.fail { background: #f44336; }
        .report-list { list-style: none; padding: 0; }
        .report-item { background: white; margin: 10px 0; padding: 15px; border-radius: 8px; border-left: 4px solid #ddd; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
        .report-item.pass { border-left-color: #4CAF50; }
        .report-item.fail { border-left-color: #f44336; }
        .report-item a { color: #0066cc; text-decoration: none; font-weight: 500; flex: 1; min-width: 200px; word-break: break-all; }
        .report-item a:hover { text-decoration: underline; }
        .scores { display: flex; gap: 8px; flex-wrap: wrap; }
        .score { font-weight: bold; padding: 4px 8px; border-radius: 4px; font-size: 12px; }
        .score.perf { background: #e3f2fd; color: #1565c0; }
        .score.a11y { background: #f3e5f5; color: #7b1fa2; }
        .score.bp { background: #fff3e0; color: #ef6c00; }
        .score.seo { background: #e8f5e9; color: #2e7d32; }
        .score.avg { font-size: 14px; padding: 4px 12px; }
        .score.avg.pass { background: #4CAF50; color: white; }
        .score.avg.fail { background: #f44336; color: white; }
        .timestamp { color: #666; font-size: 14px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; }
        .legend { display: flex; gap: 15px; margin: 10px 0; font-size: 12px; color: #666; flex-wrap: wrap; }
        .legend span { display: flex; align-items: center; gap: 4px; }
    </style>
</head>
<body>
    <h1>Lighthouse Report Summary</h1>
    <p>Reports organized by pass/fail status (threshold: ${PASS_THRESHOLD}/100 average)</p>
    <div class="legend">
        <span><span class="score perf">Perf</span> Performance</span>
        <span><span class="score a11y">A11y</span> Accessibility</span>
        <span><span class="score bp">BP</span> Best Practices</span>
        <span><span class="score seo">SEO</span> SEO</span>
    </div>

    <div class="stats">
        <div class="stat-box pass">
            ${pass_count}
            <div class="stat-label">Passed</div>
        </div>
        <div class="stat-box fail">
            ${fail_count}
            <div class="stat-label">Failed</div>
        </div>
    </div>

    <div class="section">
        <div class="section-header">
            <h2>Failed Pages</h2>
            <span class="badge fail">${fail_count}</span>
        </div>
        <ul class="report-list">
EOF

    # Add failed reports
    if [ -d "$fail_dir" ]; then
        shopt -s nullglob
        for report in "$fail_dir"/*.html; do
            local filename=$(basename "$report")
            local score_file="${report%.html}.score"
            local perf="-" a11y="-" bp="-" seo="-" avg="-"
            if [ -f "$score_file" ]; then
                IFS='|' read -r perf a11y bp seo avg < "$score_file"
            fi
            echo "            <li class=\"report-item fail\"><a href=\"fail/$filename\">$filename</a><div class=\"scores\"><span class=\"score perf\">${perf}</span><span class=\"score a11y\">${a11y}</span><span class=\"score bp\">${bp}</span><span class=\"score seo\">${seo}</span><span class=\"score avg fail\">${avg}</span></div></li>" >> "$summary_file"
        done
        shopt -u nullglob
    fi

    if [ "$fail_count" -eq 0 ]; then
        echo "            <li class=\"report-item\">No failed pages - great job!</li>" >> "$summary_file"
    fi

    cat >> "$summary_file" << EOF
        </ul>
    </div>

    <div class="section">
        <div class="section-header">
            <h2>Passed Pages</h2>
            <span class="badge pass">${pass_count}</span>
        </div>
        <ul class="report-list">
EOF

    # Add passed reports
    if [ -d "$pass_dir" ]; then
        shopt -s nullglob
        for report in "$pass_dir"/*.html; do
            local filename=$(basename "$report")
            local score_file="${report%.html}.score"
            local perf="-" a11y="-" bp="-" seo="-" avg="-"
            if [ -f "$score_file" ]; then
                IFS='|' read -r perf a11y bp seo avg < "$score_file"
            fi
            echo "            <li class=\"report-item pass\"><a href=\"pass/$filename\">$filename</a><div class=\"scores\"><span class=\"score perf\">${perf}</span><span class=\"score a11y\">${a11y}</span><span class=\"score bp\">${bp}</span><span class=\"score seo\">${seo}</span><span class=\"score avg pass\">${avg}</span></div></li>" >> "$summary_file"
        done
        shopt -u nullglob
    fi

    if [ "$pass_count" -eq 0 ]; then
        echo "            <li class=\"report-item\">No passed pages yet</li>" >> "$summary_file"
    fi

    cat >> "$summary_file" << EOF
        </ul>
    </div>

    <p class="timestamp">Generated: $(date)</p>
</body>
</html>
EOF

    echo -e "${GREEN}Summary report created: $summary_file${NC}"
}

main() {
    local base_url=""

    while getopts "u:c:o:m:p:h" opt; do
        case $opt in
            u) base_url="$OPTARG" ;;
            c) CATEGORIES=$(normalize_categories "$OPTARG") ;;
            o) OUTPUT_DIR="$OPTARG" ;;
            m) MAX_URLS="$OPTARG" ;;
            p) PASS_THRESHOLD="$OPTARG" ;;
            h) usage ;;
            *) usage ;;
        esac
    done

    if [[ -z "$base_url" ]]; then
        echo -e "${RED}Error: URL is required${NC}"
        usage
    fi

    echo -e "${GREEN}=== Lighthouse Page Speed Checker ===${NC}"
    echo "URL: $base_url"
    echo "Output: $OUTPUT_DIR"
    echo "Pass threshold: $PASS_THRESHOLD"
    if [[ -n "$CATEGORIES" ]]; then
        echo "Categories: $CATEGORIES"
    else
        echo "Categories: all (performance, accessibility, best-practices, seo)"
    fi
    echo ""

    check_dependencies

    # Create output directories
    mkdir -p "$OUTPUT_DIR/pass"
    mkdir -p "$OUTPUT_DIR/fail"

    # Determine if URL is a domain or specific page
    local urls=()
    if is_domain_url "$base_url"; then
        echo -e "${GREEN}Domain detected - crawling sitemap...${NC}"
        echo "Max URLs: $MAX_URLS"
        # macOS compatible way to read URLs into array
        local IFS=$'\n'
        urls=($(crawl_sitemap "$base_url"))
        unset IFS
        echo -e "Found ${#urls[@]} URL(s) to check"
    else
        echo -e "${GREEN}Specific URL detected - checking single page${NC}"
        urls=("$base_url")
    fi
    echo ""

    local count=0
    local pass_count=0
    local fail_count=0

    for url in "${urls[@]}"; do
        # Skip empty URLs
        [[ -z "$url" ]] && continue

        ((count++))
        echo -e "${GREEN}[$count/${#urls[@]}] Checking: $url${NC}"

        # Create safe filename from URL
        local safe_name=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g' | cut -c1-60)
        local temp_file="/tmp/${safe_name}"

        # Run Lighthouse (generates both .json and .html)
        echo -e "  ${YELLOW}Running Lighthouse...${NC}"
        run_lighthouse "$url" "$temp_file"

        # Get scores from JSON (format: perf|a11y|bp|seo)
        local scores=$(get_scores "${temp_file}.report.json")
        local avg_score=$(get_average_score "$scores")

        # Parse individual scores
        IFS='|' read -r perf_score a11y_score bp_score seo_score <<< "$scores"

        # Display scores (only show checked categories)
        local score_display=""
        if [[ -z "$CATEGORIES" || "$CATEGORIES" == *"performance"* ]]; then
            score_display+="Perf: $perf_score | "
        fi
        if [[ -z "$CATEGORIES" || "$CATEGORIES" == *"accessibility"* ]]; then
            score_display+="A11y: $a11y_score | "
        fi
        if [[ -z "$CATEGORIES" || "$CATEGORIES" == *"best-practices"* ]]; then
            score_display+="BP: $bp_score | "
        fi
        if [[ -z "$CATEGORIES" || "$CATEGORIES" == *"seo"* ]]; then
            score_display+="SEO: $seo_score | "
        fi
        # Remove trailing " | "
        score_display="${score_display% | }"
        echo -e "  ${BLUE}${score_display}${NC}"

        if [[ "$avg_score" -ge "$PASS_THRESHOLD" ]]; then
            echo -e "  ${GREEN}Average: $avg_score/100 - PASS${NC}"
            mv "${temp_file}.report.html" "$OUTPUT_DIR/pass/${safe_name}.html" 2>/dev/null || true
            echo "$scores|$avg_score" > "$OUTPUT_DIR/pass/${safe_name}.score"
            ((pass_count++))
        else
            echo -e "  ${RED}Average: $avg_score/100 - FAIL${NC}"
            local failed_audits=$(get_failed_audits "${temp_file}.report.json")
            if [[ "$failed_audits" != "None" ]]; then
                echo -e "  ${RED}Issues: ${failed_audits/|/, }${NC}"
            fi
            mv "${temp_file}.report.html" "$OUTPUT_DIR/fail/${safe_name}.html" 2>/dev/null || true
            echo "$scores|$avg_score" > "$OUTPUT_DIR/fail/${safe_name}.score"
            ((fail_count++))
        fi

        # Cleanup temp JSON
        rm -f "${temp_file}.report.json" 2>/dev/null

        echo ""
    done

    generate_summary "$OUTPUT_DIR"

    echo ""
    echo -e "${GREEN}=== Complete ===${NC}"
    echo -e "Passed: ${GREEN}$pass_count${NC}"
    echo -e "Failed: ${RED}$fail_count${NC}"
    echo ""
    echo "Reports saved to:"
    echo "  $OUTPUT_DIR/pass/  - Pages with score >= $PASS_THRESHOLD"
    echo "  $OUTPUT_DIR/fail/  - Pages with score < $PASS_THRESHOLD"
    echo ""
    echo "Open $OUTPUT_DIR/summary.html to view all reports"
}

main "$@"
