// Extract times from the https://qlocktwo.com/eu/timecheck webapp
// which is available on web.archive.org
const fs = require('fs');
const vm = require('vm');

// Mock DOM classes
class ClassList {
    constructor() { this.classes = new Set(); }
    add(c) { this.classes.add(c); }
    remove(c) { this.classes.delete(c); }
    contains(c) { return this.classes.has(c); }
    toString() { return Array.from(this.classes).join(' '); }
}

class Element {
    constructor(tagName) {
        this.tagName = tagName;
        this.children = [];
        this.classList = new ClassList();
        this.style = {};
        this._innerHTML = "";
        this.textContent = "";
        this.attributes = {};
    }
    set innerHTML(html) {
        this._innerHTML = html;
        this.children = [];
        // Minimal parser for QLockTwo initialization
        if (html.includes('qlocktwo__letters')) {
            // <span class="qlocktwo__dots dots--0">●</span>...
            // <div class="qlocktwo__letters"></div>
            // We manually create structure
            for (let i = 0; i < 4; i++) {
                const dot = new Element('span');
                dot.classList.add('qlocktwo__dots');
                dot.classList.add(`dots--${i}`);
                dot.innerHTML = '●';
                this.appendChild(dot);
            }
            const letters = new Element('div');
            letters.classList.add('qlocktwo__letters');
            this.appendChild(letters);
        } else {
            // For simple text content in spans
            // We don't parse it into children, just keep the string
        }
    }
    get innerHTML() { return this._innerHTML; }
    appendChild(child) {
        this.children.push(child);
        return child;
    }
    getElementsByClassName(className) {
        let results = [];
        if (this.classList.contains(className)) results.push(this);
        for (let child of this.children) {
            results = results.concat(child.getElementsByClassName(className));
        }
        return results;
    }
    querySelector() { return null; }
    querySelectorAll() { return []; }
    setAttribute(k, v) { this.attributes[k] = v; }
    addEventListener() { }
    get firstChild() { return this.children[0]; }
    insertBefore(node, ref) {
        // Simple append for mock
        this.children.push(node);
    }
}

// Mock Global Document
const doc = {
    createElement: (tag) => new Element(tag),
    createDocumentFragment: () => new Element('fragment'),
    getElementsByClassName: () => [],
    body: new Element('body'),
};

// Setup Global Environment
global.document = doc;
global.window = {
    location: { href: '' },
    document: doc
};
global.self = global.window;
global.navigator = { userAgent: 'Node' };
// No-op timers
global.setTimeout = (fn, delay) => { return 1; };
global.clearTimeout = () => { };

// Read check-new.js
const filePath = 'check-new.js';
if (!fs.existsSync(filePath)) {
    console.error(`File not found: ${filePath}`);
    process.exit(1);
}

let code = fs.readFileSync(filePath, 'utf8');

// Strip Wayback Machine header if present
const startFn = code.indexOf('!function');
if (startFn !== -1) {
    code = code.substring(startFn);
}

// Trim trailing Wombat wrapper '}'
// The webpack bundle ends with ']);'
const endMarker = ']);';
const endIdx = code.lastIndexOf(endMarker);
if (endIdx !== -1) {
    code = code.substring(0, endIdx + endMarker.length);
}

// Patch the entry point execution
// The bundle ends with t(t.s = 16)
const bootstrapRef = 't(t.s = 16)';
if (code.indexOf(bootstrapRef) === -1) {
    console.error(`Could not find bootstrap pattern '${bootstrapRef}' in check-new.js`);
    process.exit(1);
}

// We define a global variable to capture the class (Entry module 0 default export)
code = code.replace(bootstrapRef, '(global.QLockTwo = t(0).default)');

// Execute logic
try {
    const script = new vm.Script(code);
    const context = vm.createContext(global);
    script.runInContext(context);
} catch (e) {
    console.error("Error executing check-new.js logic:", e);
    process.exit(1);
}

if (!global.QLockTwo) {
    console.error("Failed to extract QLockTwo class from check-new.js");
    process.exit(1);
}

const QLockTwo = global.QLockTwo;
const languages = QLockTwo.languages;

// Process Args
let langFilter = null;
const langIndex = process.argv.indexOf('--lang');
if (langIndex !== -1 && process.argv[langIndex + 1]) {
    langFilter = process.argv[langIndex + 1].toUpperCase();
}

const allLangs = Object.keys(languages).sort();
const langsToProcess = langFilter ? [langFilter] : allLangs;

const container = new Element('div');

for (const lang of langsToProcess) {
    if (!languages[lang]) {
        console.error(`Language ${lang} not found.`);
        continue;
    }

    // Skip languages marked as 's' (System/Special?) or missing matrix/rules
    if (languages[lang].s || !languages[lang].a || !languages[lang].r) {
        console.warn(`Skipping Language ${lang} (Incompatible configuration)`);
        continue;
    }

    console.log(`\n### Language: ${lang}`);

    let clock;
    try {
        clock = new QLockTwo(container, { language: languages[lang] });
    } catch (e) {
        console.error(`Error instantiating clock for ${lang}:`, e);
        continue;
    }

    for (let h = 0; h < 24; h++) {
        for (let m = 0; m < 60; m += 5) {
            clock.showTime(h, m);

            const grid = clock.O;
            if (!grid) continue;

            let sentence = [];

            for (let r = 0; r < grid.length; r++) {
                if (!grid[r]) continue;
                let currentWord = "";

                for (let c = 0; c < grid[r].length; c++) {
                    const span = grid[r][c];
                    // 'light' class indicates the letter is lit
                    const isLit = span && span.classList.contains('light');

                    if (isLit) {
                        currentWord += span.innerHTML;
                    } else {
                        if (currentWord) {
                            sentence.push(currentWord);
                            currentWord = "";
                        }
                    }
                }
                if (currentWord) sentence.push(currentWord);
            }

            console.log(`${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')} -> ${sentence.join(' ')}`);
        }
    }
}
