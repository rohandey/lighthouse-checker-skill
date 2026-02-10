# WCAG Quick Reference

Quick reference for Web Content Accessibility Guidelines (WCAG) 2.1 compliance levels.

## Conformance Levels

| Level | Description |
|-------|-------------|
| **A** | Minimum accessibility (must fix) |
| **AA** | Acceptable accessibility (recommended target) |
| **AAA** | Enhanced accessibility (ideal) |

## Most Common Issues

### Level A (Critical)

| Issue | WCAG | Fix |
|-------|------|-----|
| Missing alt text | 1.1.1 | Add `alt` attribute to all `<img>` elements |
| Missing form labels | 1.3.1 | Associate `<label>` with form inputs |
| Keyboard inaccessible | 2.1.1 | Ensure all interactive elements are keyboard accessible |
| Missing page title | 2.4.2 | Add descriptive `<title>` element |
| Empty links | 2.4.4 | Add text content or aria-label to links |
| Missing language | 3.1.1 | Add `lang` attribute to `<html>` element |

### Level AA (Important)

| Issue | WCAG | Fix |
|-------|------|-----|
| Low color contrast | 1.4.3 | Ensure 4.5:1 ratio for text, 3:1 for large text |
| Text resize issues | 1.4.4 | Support 200% zoom without loss of content |
| Focus not visible | 2.4.7 | Ensure keyboard focus indicator is visible |
| Inconsistent navigation | 3.2.3 | Keep navigation consistent across pages |
| Missing error identification | 3.3.1 | Clearly identify and describe input errors |

### Level AAA (Enhanced)

| Issue | WCAG | Fix |
|-------|------|-----|
| Enhanced contrast | 1.4.6 | 7:1 ratio for text, 4.5:1 for large text |
| No timing | 2.2.3 | Remove all time limits |
| Sign language | 1.2.6 | Provide sign language for video content |

## ARIA Best Practices

```html
<!-- Landmarks -->
<header role="banner">
<nav role="navigation">
<main role="main">
<footer role="contentinfo">

<!-- Live regions for dynamic content -->
<div aria-live="polite">Status updates here</div>
<div aria-live="assertive">Critical alerts here</div>

<!-- Buttons without native semantics -->
<div role="button" tabindex="0" aria-pressed="false">Toggle</div>

<!-- Custom controls -->
<div role="slider" aria-valuemin="0" aria-valuemax="100" aria-valuenow="50">
```

## Color Contrast Ratios

| Text Type | AA Minimum | AAA Minimum |
|-----------|------------|-------------|
| Normal text (<18px) | 4.5:1 | 7:1 |
| Large text (>=18px or >=14px bold) | 3:1 | 4.5:1 |
| UI components | 3:1 | 3:1 |

## Testing Checklist

- [ ] All images have alt text
- [ ] All form inputs have labels
- [ ] Color contrast meets AA standards
- [ ] Page is fully keyboard navigable
- [ ] Focus order is logical
- [ ] Focus indicator is visible
- [ ] Page has proper heading hierarchy (h1 > h2 > h3)
- [ ] Links have descriptive text
- [ ] ARIA attributes are valid
- [ ] No keyboard traps exist
- [ ] Error messages are clear and helpful

## Tools Referenced

### axe-core
- Industry standard accessibility engine
- Checks WCAG 2.0/2.1 Level A and AA
- Zero false positives design philosophy

### Lighthouse
- Google's auditing tool
- Checks accessibility, performance, SEO, PWA
- Integrated in Chrome DevTools

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [axe-core Rules](https://dequeuniversity.com/rules/axe/)
- [Lighthouse Accessibility Audits](https://web.dev/lighthouse-accessibility/)
