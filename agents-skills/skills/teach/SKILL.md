---
name: teach
description: Teach the user a skill or concept through structured lessons in a workspace. Use when user wants to learn something, says "teach me", or wants guided learning on a topic.
---

# Teach

Teach through lessons tied to a mission. The user learns by doing, not just reading.

## Workspace Structure

```
learning/
├── MISSION.md              # Why they're learning this
├── NOTES.md                # Preferences, scratchpad
├── RESOURCES.md            # High-quality sources
├── lessons/
│   └── 0001-topic.html     # Sequential lessons (HTML for interactivity)
├── reference/
│   └── cheat-sheet.html    # Quick reference (printable)
└── records/
    └── 0001-insight.md     # What they learned (for spaced repetition)
```

## Process

1. **Find the mission** - ask "why do you want to learn this?"
   - Without mission, lessons feel abstract
   - Update mission if it changes

2. **Find resources** - search for high-quality sources
   - Don't trust parametric knowledge
   - Cite sources in lessons

3. **Teach in zone** - find their level from records
   - Too easy → boredom
   - Too hard → frustration
   - Just right → flow

4. **Create lesson** - one tight concept, one tangible win
   - Short (stay in working memory)
   - Tied to mission
   - Includes practice/feedback
   - Links to resources

5. **Record learning** - capture insights in records
   - What they learned
   - What to review later
   - What changed

## Lesson Format (HTML)

Create self-contained HTML files. Why HTML:
- Better typography = better retention
- Interactive quizzes (JS feedback)
- Code highlighting
- Print-friendly
- Visual elements

### Lesson Template

```html
<!DOCTYPE html>
<html>
<head>
  <title>Lesson N: Topic</title>
  <style>
    body { font-family: system-ui; max-width: 700px; margin: 2rem auto; line-height: 1.6; }
    .goal { background: #e8f5e9; padding: 1rem; border-radius: 8px; }
    .quiz { background: #f5f5f5; padding: 1rem; border-radius: 8px; margin: 1rem 0; }
    .quiz button { margin: 0.5rem 0; padding: 0.5rem 1rem; }
    .feedback { display: none; padding: 0.5rem; margin-top: 0.5rem; border-radius: 4px; }
    .correct { background: #c8e6c9; }
    .wrong { background: #ffcdd2; }
    code { background: #f5f5f5; padding: 2px 6px; border-radius: 4px; }
    pre { background: #263238; color: #aed581; padding: 1rem; border-radius: 8px; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>Lesson N: Topic</h1>
  
  <div class="goal">
    <strong>Goal:</strong> After this, you'll be able to [one thing].
  </div>
  
  <h2>Why This Matters</h2>
  <p>[Tie to mission]</p>
  
  <h2>The Concept</h2>
  <p>[Teach it. Keep tight.]</p>
  
  <h2>Try It</h2>
  <div class="quiz">
    <p><strong>Q:</strong> [question]</p>
    <button onclick="check(this, true)">A) [answer]</button>
    <button onclick="check(this, false)">B) [wrong]</button>
    <button onclick="check(this, false)">C) [wrong]</button>
    <div class="feedback"></div>
  </div>
  
  <h2>Resources</h2>
  <ul>
    <li><a href="url">Source</a> - why it's good</li>
  </ul>
  
  <h2>Next Lesson</h2>
  <p>→ <a href="0002-next.html">Next Topic</a></p>
  
  <script>
    function check(btn, correct) {
      const fb = btn.parentElement.querySelector('.feedback');
      fb.style.display = 'block';
      fb.className = 'feedback ' + (correct ? 'correct' : 'wrong');
      fb.textContent = correct ? '✓ Correct!' : '✗ Try again.';
    }
  </script>
</body>
</html>
```

## Teaching Principles

**Knowledge** = acquisition (reading, watching)
- First, gather from trusted sources
- Cite everything

**Skills** = durability (practice, retrieval)
- Teach through interactive exercises
- Feedback loop must be tight
- Difficulty is the tool, not the enemy

**Wisdom** = real-world testing
- Point to communities when relevant
- Reddit, forums, local groups

## Fluency vs Storage

| Type | What | Risk |
|------|------|------|
| Fluency | In-the-moment recall | Illusory mastery |
| Storage | Long-term retention | Real goal |

Build storage through:
- Retrieval practice (recall from memory)
- Spacing (distribute over time)
- Interleaving (mix related topics)

## Reference Materials

While teaching, build reference docs:
- Cheat sheets
- Glossaries
- Code snippets
- Flowcharts

Lessons are rarely revisited. Reference docs are.

## Checklist

- [ ] Mission defined and understood
- [ ] Resources gathered from trusted sources
- [ ] Lesson tied to mission
- [ ] One concept per lesson
- [ ] Practice with interactive feedback (not just text)
- [ ] Sources cited
- [ ] Record created after lesson
- [ ] Opens in browser (run `open filename.html`)
