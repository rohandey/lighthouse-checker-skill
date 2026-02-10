---
name: Lighthouse Checker Skill
description: Run Google Lighthouse audits on websites to check performance, accessibility, best practices, and SEO. Use when users ask to audit websites, check page speed, test accessibility, analyze Core Web Vitals, or generate Lighthouse reports.
triggers:
  - check page speed
  - run lighthouse audit
  - audit website performance
  - check accessibility
  - test website performance
  - analyze site speed
  - check SEO score
  - run performance test
  - check core web vitals
  - audit this site
  - check best practices
  - generate lighthouse report
  - website audit
  - page speed test
  - a11y check
  - wcag compliance check
---

# Lighthouse Website Auditor

Comprehensive website auditing tool using Google Lighthouse. Audits pages for Performance, Accessibility, Best Practices, and SEO.

## Quick Reference

### Check Entire Website (Crawls Sitemap)
```bash
./scripts/check_lighthouse.sh -u https://example.com
```

### Check Single Page
```bash
./scripts/check_lighthouse.sh -u https://example.com/about
```

### Check Specific Categories
```bash
# Accessibility only
./scripts/check_lighthouse.sh -u https://example.com -c a11y

# Performance only
./scripts/check_lighthouse.sh -u https://example.com -c perf

# SEO only
./scripts/check_lighthouse.sh -u https://example.com -c seo

# Best practices only
./scripts/check_lighthouse.sh -u https://example.com -c bp

# Multiple categories
./scripts/check_lighthouse.sh -u https://example.com -c perf,a11y
```

## Full Syntax

```bash
./scripts/check_lighthouse.sh -u <url> [-c <categories>] [-o <output_dir>] [-m <max_urls>] [-p <pass_threshold>]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-u` | URL to audit (required) | - |
| `-c` | Categories: `perf`, `a11y`, `bp`, `seo` (comma-separated) | all |
| `-o` | Output directory for reports | `./lighthouse-reports` |
| `-m` | Max URLs to check from sitemap | 50 |
| `-p` | Pass threshold score (0-100) | 90 |

### Category Shortcuts

| Full Name | Shorthand | What It Measures |
|-----------|-----------|------------------|
| performance | perf | Core Web Vitals, load times, rendering |
| accessibility | a11y | WCAG compliance, screen reader support |
| best-practices | bp | Security, modern APIs, console errors |
| seo | seo | Meta tags, crawlability, mobile-friendliness |

## Examples

```bash
# Full site audit with all categories
./scripts/check_lighthouse.sh -u https://mysite.com

# Single page, accessibility focus
./scripts/check_lighthouse.sh -u https://mysite.com/contact -c a11y

# Site audit with 80% threshold, max 20 pages
./scripts/check_lighthouse.sh -u https://mysite.com -m 20 -p 80

# Performance and SEO only
./scripts/check_lighthouse.sh -u https://mysite.com -c perf,seo

# Custom output directory
./scripts/check_lighthouse.sh -u https://mysite.com -o ./my-reports
```

## Output Structure

Each run creates a timestamped folder:

```
lighthouse-reports-2024-01-15_14-30-22/
├── summary.html      # Interactive dashboard
├── pass/             # Pages scoring >= threshold
│   ├── page1.html
│   └── page1.score
└── fail/             # Pages scoring < threshold
    ├── page2.html
    └── page2.score
```

## Score Interpretation

| Score | Rating | Color |
|-------|--------|-------|
| 90-100 | Good | Green |
| 50-89 | Needs Improvement | Orange |
| 0-49 | Poor | Red |

## Workflow

1. Run the checker on target URL
2. Open `summary.html` in browser to view dashboard
3. Review failed pages first (organized by score)
4. Click individual reports for detailed recommendations
5. Fix issues and re-run to verify improvements

## Manual Lighthouse Commands

For quick single-page checks without the wrapper:

```bash
# Full audit to HTML
lighthouse https://example.com --output=html --output-path=report.html

# Performance only
lighthouse https://example.com --only-categories=performance --output=html

# Accessibility only
lighthouse https://example.com --only-categories=accessibility --output=html

# JSON output for programmatic use
lighthouse https://example.com --output=json --output-path=report.json
```

## Requirements

- Node.js 14+
- npm (Lighthouse auto-installed on first run)
- Python 3 (for score parsing)
- Chrome/Chromium browser

## Resources

- `scripts/check_lighthouse.sh` - Main script
- `references/wcag-quick-ref.md` - WCAG accessibility guidelines
