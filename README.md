# Lighthouse Checker Skill

An AI skill for running Google Lighthouse audits across websites. Automatically discovers pages via sitemap.xml and generates organized HTML reports with pass/fail classification.

## Features

- **Sitemap crawling** - Automatically discovers pages from sitemap.xml
- **Single page mode** - Check specific URLs directly
- **Category filtering** - Run only Performance, Accessibility, Best Practices, or SEO
- **Pass/Fail organization** - Reports sorted by score threshold
- **Interactive HTML dashboard** - Summary with links to all reports
- **AI Skill** - Works with Claude Code and other LLMs

---

## Installation

### Prerequisites

- **Node.js 14+** and npm
- **Python 3** (for score parsing)
- **Chrome/Chromium** browser

### For Claude Code

Add the skill directly from GitHub:

```bash
claude mcp add-skill https://github.com/YOUR_USERNAME/lighthouse-checker
```

The skill is now available and will be triggered automatically when you use relevant prompts.

### For Other LLMs (ChatGPT, Gemini, etc.)

**Option 1: System Prompt Integration**

Copy the contents of `SKILL.md` into your LLM's system prompt or custom instructions. This gives the LLM knowledge of the skill's capabilities and command syntax.

**Option 2: Tool/Function Definition**

Add as a tool definition in your LLM configuration:

```json
{
  "name": "lighthouse_checker",
  "description": "Run Google Lighthouse audits on websites for performance, accessibility, best practices, and SEO",
  "parameters": {
    "url": "URL to audit (required)",
    "categories": "perf, a11y, bp, seo (optional, comma-separated)",
    "max_urls": "Maximum pages to crawl (optional, default: 50)",
    "threshold": "Pass threshold 0-100 (optional, default: 90)"
  }
}
```

**Option 3: Local Setup**

Clone the repository and reference it in your LLM's workspace:

```bash
git clone https://github.com/YOUR_USERNAME/lighthouse-checker.git
```

Then instruct your LLM to use the script at `scripts/check_lighthouse.sh` when website auditing is requested.

---

## AI Prompts

Once installed, you can use natural language prompts to trigger the skill. The skill will be automatically detected when you use these phrases.

### Full Website Audit

Audit an entire website by crawling its sitemap:

| Prompt | Description |
|--------|-------------|
| "Check page speed for https://example.com" | Runs full Lighthouse audit on all pages found in sitemap |
| "Run a lighthouse audit on https://example.com" | Same as above - audits entire site |
| "Audit website https://example.com" | Comprehensive audit of all categories |
| "Test website performance for https://example.com" | Full site audit with focus on performance |
| "Generate lighthouse report for https://example.com" | Creates HTML reports for all discovered pages |
| "Analyze https://example.com for page speed issues" | Identifies performance bottlenecks across the site |
| "Check Core Web Vitals for https://example.com" | Audits LCP, FID, CLS metrics site-wide |

### Single Page Audit

Audit a specific page without crawling the sitemap:

| Prompt | Description |
|--------|-------------|
| "Check lighthouse score for https://example.com/about" | Audits only the /about page |
| "Audit this page: https://example.com/contact" | Single page audit with all categories |
| "Run performance test on https://example.com/pricing" | Tests one specific page |
| "Check https://example.com/blog/my-post for accessibility" | Single page accessibility check |
| "How fast is https://example.com/products loading?" | Performance audit for one page |
| "Test https://example.com/checkout page speed" | Audit checkout page performance |

### Accessibility Audits

Focus specifically on accessibility (WCAG compliance):

| Prompt | Description |
|--------|-------------|
| "Check accessibility for https://example.com" | Full site accessibility audit |
| "Run a11y check on https://example.com" | Same as above using shorthand |
| "Check WCAG compliance for https://example.com" | Audits against WCAG guidelines |
| "Is https://example.com accessible?" | Accessibility score and issues |
| "Find accessibility issues on https://example.com" | Lists a11y violations |
| "Check screen reader compatibility for https://example.com" | Focuses on assistive technology support |
| "Audit https://example.com for accessibility violations" | Detailed a11y issue report |
| "Does https://example.com/signup meet accessibility standards?" | Single page a11y check |

### Performance Audits

Focus specifically on speed and Core Web Vitals:

| Prompt | Description |
|--------|-------------|
| "Test performance of https://example.com" | Performance-only audit |
| "Check Core Web Vitals for https://example.com" | LCP, FID, CLS metrics |
| "Analyze site speed for https://example.com" | Detailed speed analysis |
| "Why is https://example.com slow?" | Identifies performance bottlenecks |
| "Check load time for https://example.com" | Time-to-interactive metrics |
| "Run performance audit on https://example.com" | Full perf category audit |
| "How can I speed up https://example.com?" | Performance recommendations |
| "Check render blocking resources on https://example.com" | Specific perf issue |

### SEO Audits

Focus specifically on search engine optimization:

| Prompt | Description |
|--------|-------------|
| "Check SEO score for https://example.com" | SEO-only audit |
| "Audit SEO for https://example.com" | Full SEO category check |
| "Is https://example.com SEO optimized?" | SEO score and issues |
| "Check meta tags on https://example.com" | SEO metadata audit |
| "Find SEO issues on https://example.com" | Lists SEO violations |
| "Is https://example.com mobile friendly?" | Mobile SEO check |
| "Check https://example.com crawlability" | Search engine crawl audit |
| "How can I improve SEO for https://example.com?" | SEO recommendations |

### Best Practices Audits

Focus on security, modern APIs, and code quality:

| Prompt | Description |
|--------|-------------|
| "Check best practices for https://example.com" | Best practices audit |
| "Run bp check on https://example.com" | Same using shorthand |
| "Check security issues on https://example.com" | Security-focused audit |
| "Does https://example.com use HTTPS?" | Security check |
| "Find console errors on https://example.com" | JavaScript error detection |
| "Check https://example.com for deprecated APIs" | Modern standards audit |
| "Is https://example.com using modern web practices?" | Full BP category |

### Multi-Category Audits

Combine multiple categories in one audit:

| Prompt | Description |
|--------|-------------|
| "Check performance and SEO for https://example.com" | Two categories |
| "Run accessibility and best practices audit on https://example.com" | a11y + bp |
| "Test a11y and performance for https://example.com" | Using shorthand |
| "Check perf, seo, and a11y for https://example.com" | Three categories |
| "Audit https://example.com for performance and accessibility" | perf + a11y |
| "Run SEO and best practices check on https://example.com" | seo + bp |

### Advanced Options

Customize the audit with specific parameters:

| Prompt | Description |
|--------|-------------|
| "Audit https://example.com with 80% pass threshold" | Custom pass/fail threshold |
| "Check https://example.com, max 20 pages" | Limit sitemap crawl |
| "Run lighthouse on https://example.com, save to ./my-reports" | Custom output directory |
| "Audit https://example.com with 70% threshold and max 10 pages" | Multiple options |
| "Check top 5 pages of https://example.com for performance" | Limited crawl + category |
| "Quick audit of https://example.com (5 pages only)" | Fast limited check |
| "Full deep audit of https://example.com (100 pages)" | Extended crawl |

### Comparative & Follow-up Prompts

| Prompt | Description |
|--------|-------------|
| "Re-run the lighthouse audit" | Repeat last audit |
| "Check if https://example.com improved" | Compare to previous run |
| "Show me the failed pages from the last audit" | Review failures |
| "What pages failed accessibility?" | Filter by category failure |
| "Open the lighthouse summary report" | View generated dashboard |
| "Which pages have the lowest performance scores?" | Analyze results |

---

## Script Usage

### Basic Commands

```bash
# Check entire website (crawls sitemap.xml)
./scripts/check_lighthouse.sh -u https://example.com

# Check single page
./scripts/check_lighthouse.sh -u https://example.com/about

# Check accessibility only
./scripts/check_lighthouse.sh -u https://example.com -c a11y

# Check performance only
./scripts/check_lighthouse.sh -u https://example.com -c perf
```

### Full Syntax

```
./scripts/check_lighthouse.sh -u <url> [-c <categories>] [-o <output_dir>] [-m <max_urls>] [-p <pass_threshold>]

Options:
  -u    URL to check (required)
        Domain (https://example.com) → crawls sitemap.xml
        Specific page (https://example.com/about) → checks only that page

  -c    Categories to check (comma-separated, default: all)
        performance (perf), accessibility (a11y), best-practices (bp), seo

  -o    Output directory (default: ./lighthouse-reports)

  -m    Maximum URLs from sitemap (default: 50)

  -p    Pass threshold 0-100 (default: 90)
```

### Script Examples

```bash
# All categories, entire site
./scripts/check_lighthouse.sh -u https://mysite.com

# Accessibility only
./scripts/check_lighthouse.sh -u https://mysite.com -c accessibility

# Performance and SEO
./scripts/check_lighthouse.sh -u https://mysite.com -c perf,seo

# Single page, all categories
./scripts/check_lighthouse.sh -u https://mysite.com/contact

# Custom threshold and limit
./scripts/check_lighthouse.sh -u https://mysite.com -m 20 -p 80
```

---

## Output

Reports are saved to a timestamped folder (e.g., `./lighthouse-reports-2024-01-15_14-30-22/`):

```
lighthouse-reports-2024-01-15_14-30-22/
├── summary.html      # Dashboard with all results
├── pass/             # Pages scoring >= threshold
│   ├── page1.html
│   └── page1.score
└── fail/             # Pages scoring < threshold
    ├── page2.html
    └── page2.score
```

Each run creates a new timestamped folder, preserving previous reports for comparison.

Open `summary.html` in a browser to view all reports with scores for each category.

---

## Categories

| Category | Short | What It Measures |
|----------|-------|------------------|
| performance | perf | Core Web Vitals, load times, rendering |
| accessibility | a11y | WCAG compliance, screen reader support |
| best-practices | bp | Security, modern APIs, console errors |
| seo | seo | Meta tags, crawlability, mobile-friendly |

---

## Score Interpretation

| Score | Rating |
|-------|--------|
| 90-100 | Good (green) |
| 50-89 | Needs Improvement (orange) |
| 0-49 | Poor (red) |

---

## Project Structure

```
lighthouse-checker/
├── README.md                 # This file
├── SKILL.md                  # AI skill definition
├── scripts/
│   └── check_lighthouse.sh   # Main executable
├── references/
│   └── wcag-quick-ref.md     # WCAG accessibility guide
└── .claude/
    └── settings.local.json   # Claude Code settings
```

---

## License

MIT
