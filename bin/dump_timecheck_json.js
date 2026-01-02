const fs = require('fs');
const vm = require('vm');

// Mock DOM classes (Minimal needed for check-new.js execution)
class Element {
    constructor(tagName) {
        this.tagName = tagName;
        this.children = [];
        this.attributes = {};
        this.style = {};
    }
    appendChild(c) { this.children.push(c); return c; }
    getElementsByClassName() { return []; }
    setAttribute(k, v) { this.attributes[k] = v; }
    addEventListener() { }
}
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
global.setTimeout = () => { };
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
const endMarker = ']);';
const endIdx = code.lastIndexOf(endMarker);
if (endIdx !== -1) {
    code = code.substring(0, endIdx + endMarker.length);
}

// Patch the entry point execution
const bootstrapRef = 't(t.s = 16)';
if (code.indexOf(bootstrapRef) === -1) {
    console.error(`Could not find bootstrap pattern '${bootstrapRef}' in check-new.js`);
    process.exit(1);
}
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

if (!global.QLockTwo || !global.QLockTwo.languages) {
    console.error("Failed to extract QLockTwo.languages from check-new.js");
    process.exit(1);
}

// Dump languages to stdout
const json = JSON.stringify(global.QLockTwo.languages, null, 2);
const formatted = json.replace(/\[\s+((?:(?:"[^"]+"|\d+|null|true|false)(?:\s*,\s*(?:"[^"]+"|\d+|null|true|false))*))\s+\]/g, (match, content) => {
    return '[' + content.replace(/\s*\n\s*/g, ' ') + ']';
});
console.log(formatted);
