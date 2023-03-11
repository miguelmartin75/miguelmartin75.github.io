---
tags: index
---

# Posts
```dataview
TABLE
state as "State",
priority as "Pri",
tags as "Tags"
WHERE contains(tags, "post")
```

# Surveys
```dataview
TABLE
state as "State",
priority as "Pri",
tags as "Tags"
WHERE contains(tags, "survey") AND !contains(tags, "paper")
```

# Papers
```dataview
TABLE
state as "State",
priority as "Pri",
tags as "Tags"
WHERE contains(tags, "paper")
```

# All
```dataview
TABLE
state as "State",
priority as "Pri",
tags as "Tags"
```