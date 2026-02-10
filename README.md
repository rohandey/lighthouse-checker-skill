# Lighthouse Checker

A CLI tool and AI skill for running Google Lighthouse audits across websites. Automatically discovers pages via sitemap.xml and generates organized HTML reports with pass/fail classification.

## Features

- **Sitemap crawling** - Automatically discovers pages from sitemap.xml
- **Single page mode** - Check specific URLs directly
- **Category filtering** - Run only Performance, Accessibility, Best Practices, or SEO
- **Pass/Fail organization** - Reports sorted by score threshold
- **Interactive HTML dashboard** - Summary with links to all reports
- **AI Skill integration** - Works with Claude Code and other LLMs

---

## Installation

### Prerequisites

- **Node.js 14+** and npm
- **Python 3** (for score parsing)
- **Chrome/Chromium** browser

### Option 1: Install as Claude Code Skill

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/lighthouse-checker.git

# Add to Claude Code as a skill
claude mcp add-skill /path/to/lighthouse-checker

# Or add the skill directory to your project
cp -r lighthouse-checker /your/project/.claude/skills/
```

The skill will be automatically detected when you use trigger phrases like "check page speed" or "run lighthouse audit".

### Option 2: Install Globally (Symlink)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/lighthouse-checker.git
cd lighthouse-checker

# Make executable
chmod +x scripts/check_lighthouse.sh

# Symlink to PATH (optional)
ln -s $(pwd)/scripts/check_lighthouse.sh /usr/local/bin/lighthouse-checker
```

### Option 3: Direct Usage

```bash
# Clone and run directly
git clone https://github.com/YOUR_USERNAME/lighthouse-checker.git
cd lighthouse-checker
chmod +x scripts/check_lighthouse.sh

# Lighthouse will auto-install on first run
./scripts/check_lighthouse.sh -u https://example.com
```

---

## Usage

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

### Examples

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

## AI Skill Integration

### For Claude Code

The `SKILL.md` file defines this tool as a skill. When installed, Claude Code will automatically invoke it for relevant requests.

**Trigger phrases:**
- "Check page speed for https://example.com"
- "Run a lighthouse audit on my website"
- "Check accessibility of this page"
- "Test website performance"
- "Audit this site for SEO"

### For Other LLMs

Include the `SKILL.md` content in your system prompt or tool definitions. The skill provides:

1. **Tool definition** with triggers and description
2. **Command syntax** for all operations
3. **Examples** for common use cases

---

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
