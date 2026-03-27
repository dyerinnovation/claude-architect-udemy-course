# Built-in Tools: Which One to Use

Quick reference for the 5 file operation tools in Claude Code.

---

## Tool Selection Decision Tree

```
What do you need?
    │
    ├─ Find files by NAME/PATTERN? → GLOB
    │   (e.g., all .test.ts files)
    │
    ├─ Search file CONTENTS? → GREP
    │   (e.g., "function authenticate")
    │
    ├─ Read a SPECIFIC file I know about? → READ
    │   (e.g., config.json in /src/config/)
    │
    ├─ Create NEW file OR replace entirely? → WRITE
    │   (e.g., new JSON config, full rewrite)
    │
    └─ Make TARGETED edits to existing file? → EDIT
        (e.g., change one function, add import)
```

---

## The Tools

### 1. GLOB — Find files by name/path pattern

**When to use:**
- Finding files that match a pattern
- Discovering file structure
- Locating all test files, config files, etc.

**Examples:**
```
Pattern: "*.test.ts"
Result: [test1.ts, test2.ts, components/button.test.ts]

Pattern: "src/**/*.tsx"
Result: [src/App.tsx, src/components/Header.tsx, ...]

Pattern: "*.json"
Result: [package.json, config.json, tsconfig.json]
```

**Syntax:**
```bash
*.test.ts          # All test files in current dir
src/**/*.tsx       # Recursive: all .tsx under src/
src/auth/*         # Files directly in src/auth/
src/auth/**        # Files in auth and subdirectories
```

**Important:** Glob is for NAMES/PATHS, not content.

---

### 2. GREP — Search file CONTENTS

**When to use:**
- Finding where a function/variable is defined
- Searching for a string across files
- Finding error messages, imports, etc.

**Examples:**
```
Pattern: "function authenticate"
Result: [auth/login.ts:line 42, auth/oauth.ts:line 15]

Pattern: "import.*MCP"
Result: [agents/mcp-client.ts:line 3, tools/index.ts:line 1]

Pattern: "ERROR_CODE_403"
Result: [errors.ts:line 89, middleware.ts:line 156]
```

**Features:**
- Regex support: `function\s+\w+` (regex for "function NAME")
- Filter by file type: `type: "ts"` (search only TypeScript)
- Filter by glob: `glob: "**/*.test.ts"` (search only tests)
- Case-insensitive: `-i: true`

**Important:** Grep searches CONTENTS, not filenames.

---

### 3. READ — Load a specific file

**When to use:**
- Reading a file you already know the path to
- Loading config files, understanding structure
- Reviewing code you're about to modify

**Examples:**
```
Path: /src/config/auth.json
Result: Full file contents loaded

Path: /src/components/Button.tsx
Result: Full source code visible

Path: /package.json
Result: Full package.json contents
```

**Advanced:**
- Read specific line range: `offset: 100, limit: 50` (lines 100-150)
- For large files: specify exact range to avoid slow loads

**Important:** Use READ when you know the exact path.

---

### 4. WRITE — Create new or fully replace

**When to use:**
- Creating entirely new files
- Complete rewrite of existing file
- No partial/targeted changes needed

**Examples:**
```
File: /src/utils/new-helper.ts
Content: [complete file code]
Result: File created or completely replaced

File: /config/app.json
Content: [complete JSON]
Result: Entirely new config
```

**Important:**
- READ first if file exists (unless you're replacing)
- Use EDIT for modifications to existing files
- WRITE is all-or-nothing

---

### 5. EDIT — Targeted modifications to existing files

**When to use:**
- Changing one function in a 500-line file
- Adding an import at the top
- Fixing a bug in existing code
- Modifying a specific section

**Examples:**
```
Old string: "function authenticate() { ... }"
New string: "async function authenticate() { ... }"
Result: Only that function changed, rest untouched

Old string: "import { foo } from './lib'"
New string: "import { foo, bar } from './lib'"
Result: Only that line modified
```

**Advanced:**
- `replace_all: true` for replacing all occurrences
- Must provide UNIQUE old_string (no duplicates)
- If not unique: use Read + Write instead

**Important:**
- Old string must be EXACT (including whitespace)
- Unique match required
- Use Read first to get exact text

---

## Common Workflows

### Workflow 1: Add a feature to existing code
```
1. GLOB: find files matching "components/*.tsx"
2. READ: load the component file
3. EDIT: add new function/export
```

### Workflow 2: Fix a bug across the codebase
```
1. GREP: find all occurrences of bug pattern
2. READ: load each affected file
3. EDIT: fix in each file
```

### Workflow 3: Create new module
```
1. WRITE: create new file with complete code
2. GLOB: find where to import it
3. EDIT: add import statement
```

### Workflow 4: Refactor file structure
```
1. GLOB: find all files to move
2. READ: understand dependencies
3. WRITE: create new structure
4. GREP: find imports to update
5. EDIT: update all imports
```

---

## Tool Comparison Table

| Task | Glob | Grep | Read | Write | Edit |
|------|------|------|------|-------|------|
| Find files by name | ✓ | - | - | - | - |
| Search content | - | ✓ | - | - | - |
| Read file | - | - | ✓ | - | - |
| Create file | - | - | - | ✓ | - |
| Modify file | - | - | - | - | ✓ |
| Partial edit | - | - | - | - | ✓ |
| Full replace | - | - | - | ✓ | ✗ |
| Must know path | - | - | ✓ | ✓ | ✓ |
| Pattern matching | ✓ | ✓ | - | - | - |

---

## EDIT Gotchas

### ❌ Non-unique old_string
```
File has multiple functions:
function foo() { return 1; }
function bar() { return 1; }

EDIT with old_string: "return 1;"
→ FAILS (appears twice, ambiguous)

Solution:
EDIT with larger context:
old_string: "function foo() { return 1; }"
```

### ❌ Whitespace mismatch
```
File: "  const x = 5"  (2 spaces)
EDIT: "const x = 5"     (0 spaces)
→ FAILS (whitespace doesn't match)

Solution:
EDIT with exact whitespace
```

### ✓ Fallback: Read + Write
If EDIT fails due to non-unique string:
```
1. READ the file
2. WRITE the entire file with modifications
```

---

## Performance Tips

1. **Use GLOB first** to find candidates before READ
2. **Use GREP to find** before READ to know what you need
3. **Read large files in chunks** with `offset` and `limit`
4. **Edit is faster than Write** for small changes
5. **Combine tools**: GLOB → READ → EDIT (not GLOB → WRITE)

---

## Key Insight

**Choose the right tool for the job:**

- **Finding files?** GLOB
- **Finding content?** GREP
- **Reading known file?** READ
- **Whole file ops?** WRITE
- **Surgical changes?** EDIT
