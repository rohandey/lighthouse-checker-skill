# Lighthouse Checker

A CLI tool for running Google Lighthouse audits across entire websites or single pages. Automatically discovers URLs via sitemap.xml and generates organized HTML reports.

## Features

- **Sitemap crawling** - Automatically discovers pages from sitemap.xml
- **Single page mode** - Check specific URLs directly
- **Category filtering** - Run only Performance, Accessibility, Best Practices, or SEO
- **Pass/Fail organization** - Reports sorted by score threshold
- **HTML summary** - Interactive dashboard linking all reports

## Installation

Requires Node.js and npm.

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/lighthouse-checker.git
cd lighthouse-checker

# Make the script executable
chmod +x scripts/check_lighthouse.sh

# Lighthouse will be auto-installed on first run
```

## Quick Start

Check an entire website:
```bash
./scripts/check_lighthouse.sh -u https://example.com
```

Check a single page:
```bash
./scripts/check_lighthouse.sh -u https://example.com/about
```

Check accessibility only:
```bash
./scripts/check_lighthouse.sh -u https://example.com -c a11y
```

## Usage

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

## Examples

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

## Output

Reports are saved to `./lighthouse-reports/` (or custom directory):

```
lighthouse-reports/
├── summary.html      # Dashboard with all results
├── pass/             # Pages scoring >= threshold
│   ├── page1.html
│   └── page1.score
└── fail/             # Pages scoring < threshold
    ├── page2.html
    └── page2.score
```

Open `summary.html` in a browser to view all reports with scores for each category.

## Categories

| Category | Short | What It Measures |
|----------|-------|------------------|
| performance | perf | Core Web Vitals, load times, rendering |
| accessibility | a11y | WCAG compliance, screen reader support |
| best-practices | bp | Security, modern APIs, console errors |
| seo | seo | Meta tags, crawlability, mobile-friendly |

## Score Interpretation

| Score | Rating |
|-------|--------|
| 90-100 | Good |
| 50-89 | Needs Improvement |
| 0-49 | Poor |

## Requirements

- Node.js 14+
- npm
- Python 3 (for score parsing)

## License

MIT
