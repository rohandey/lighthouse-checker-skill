---
name: lighthouse-checker
description: This skill should be used when checking websites for page speed, performance, accessibility, best practices, and SEO. It applies when users ask to audit a website's performance, check Lighthouse scores, run page speed tests, or analyze site quality. Triggers on requests like "check page speed", "run Lighthouse audit", "check accessibility", "audit this site", or "test website performance".
---

# Lighthouse Page Speed Checker

## Overview

This skill enables comprehensive website auditing using Google Lighthouse. It crawls websites via sitemap discovery and generates detailed HTML reports for all four Lighthouse categories:

- **Performance** - Page load speed, rendering, and interactivity
- **Accessibility** - WCAG compliance and usability for all users
- **Best Practices** - Security, modern web standards, and code quality
- **SEO** - Search engine optimization and discoverability

## Prerequisites

Ensure Node.js and npm are installed. The skill's script will auto-install Lighthouse if missing.

## Quick Start

**Check an entire website** (crawls sitemap.xml):
```bash
./scripts/check_lighthouse.sh -u https://example.com
```

**Check a single page**:
```bash
./scripts/check_lighthouse.sh -u https://example.com/about
```

The script automatically detects:
- **Domain URL** (e.g., `https://example.com`) → Crawls sitemap.xml for all pages
- **Specific URL** (e.g., `https://example.com/about`) → Checks only that page

## Usage Options

```bash
./scripts/check_lighthouse.sh -u <url> [-c <categories>] [-o <output_dir>] [-m <max_urls>] [-p <pass_threshold>]

Options:
  -u    URL to check (required)
        - Domain → crawls sitemap.xml
        - Specific page → checks only that URL
  -c    Categories to check (comma-separated, default: all)
        - performance (or perf)
        - accessibility (or a11y)
        - best-practices (or bp)
        - seo
  -o    Output directory for reports (default: ./lighthouse-reports)
  -m    Maximum URLs to check from sitemap (default: 50)
  -p    Pass threshold score 0-100 (default: 90)
```

### Examples

Check entire site (all categories):
```bash
./scripts/check_lighthouse.sh -u https://mysite.com
```

Check a single page:
```bash
./scripts/check_lighthouse.sh -u https://mysite.com/contact
```

**Check accessibility only**:
```bash
./scripts/check_lighthouse.sh -u https://mysite.com -c accessibility
# or shorthand:
./scripts/check_lighthouse.sh -u https://mysite.com -c a11y
```

**Check performance only**:
```bash
./scripts/check_lighthouse.sh -u https://mysite.com -c perf
```

**Check SEO only**:
```bash
./scripts/check_lighthouse.sh -u https://mysite.com -c seo
```

**Check multiple categories**:
```bash
./scripts/check_lighthouse.sh -u https://mysite.com -c perf,seo
./scripts/check_lighthouse.sh -u https://mysite.com -c a11y,bp
```

Crawl site with limit of 10 pages and 80% pass threshold:
```bash
./scripts/check_lighthouse.sh -u https://mysite.com -m 10 -p 80
```

## Understanding Reports

The summary shows scores for each category:

| Category | What It Measures |
|----------|------------------|
| **Perf** | Core Web Vitals, load times, rendering performance |
| **A11y** | Accessibility issues, WCAG compliance |
| **BP** | Security, modern APIs, console errors |
| **SEO** | Meta tags, crawlability, mobile-friendliness |

### Pass/Fail Criteria

Pages are organized into pass/fail folders based on their **average score** across all categories:
- **Pass**: Average score >= threshold (default 90)
- **Fail**: Average score < threshold

## Manual Checking

For quick single-page checks:

```bash
# Full Lighthouse audit
lighthouse https://example.com --output=html --output-path=report.html

# Performance only
lighthouse https://example.com --only-categories=performance --output=html

# Accessibility only
lighthouse https://example.com --only-categories=accessibility --output=html
```

## Workflow for Full Site Audit

1. **Run the checker**: Execute the script on the target URL
2. **Review summary**: Open `summary.html` in browser
3. **Analyze scores**: Look for patterns in low-scoring categories
4. **Prioritize fixes**: Focus on lowest scores first
5. **Re-test**: Run again after fixes to verify improvement

## Score Interpretation

| Score Range | Rating |
|-------------|--------|
| 90-100 | Good (green) |
| 50-89 | Needs Improvement (orange) |
| 0-49 | Poor (red) |

## Resources

- `scripts/check_lighthouse.sh` - Main Lighthouse checking script
- `references/wcag-quick-ref.md` - WCAG guidelines quick reference
