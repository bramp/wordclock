const fs = require('fs');

const fileA = 'scriptable.json';
const fileB = 'check_new.json';

if (!fs.existsSync(fileA) || !fs.existsSync(fileB)) {
    console.error("Missing JSON files. Run dump scripts first.");
    process.exit(1);
}

const jsonA = JSON.parse(fs.readFileSync(fileA, 'utf8'));
const jsonB = JSON.parse(fs.readFileSync(fileB, 'utf8'));

const keysA = new Set(Object.keys(jsonA));
const keysB = new Set(Object.keys(jsonB));

const common = [...keysA].filter(k => keysB.has(k)).sort();
const onlyA = [...keysA].filter(k => !keysB.has(k)).sort();
const onlyB = [...keysB].filter(k => !keysA.has(k)).sort();

console.log(`Languages in Scriptable only: ${onlyA.join(', ')}`);
console.log(`Languages in CheckNew only: ${onlyB.join(', ')}`);
console.log(`Common languages: ${common.length}`);

function deepEqual(obj1, obj2) {
    if (obj1 === obj2) return true;
    if (typeof obj1 !== typeof obj2) return false;
    if (obj1 === null || obj2 === null) return false;
    if (typeof obj1 !== 'object') return false;

    if (Array.isArray(obj1)) {
        if (!Array.isArray(obj2)) return false;
        if (obj1.length !== obj2.length) return false;
        for (let i = 0; i < obj1.length; i++) {
            if (!deepEqual(obj1[i], obj2[i])) return false;
        }
        return true;
    }

    const keys1 = Object.keys(obj1).sort();
    const keys2 = Object.keys(obj2).sort();

    if (keys1.length !== keys2.length) return false;
    for (let k of keys1) {
        if (!keys2.includes(k)) return false;
        if (!deepEqual(obj1[k], obj2[k])) return false;
    }
    return true;
}

const identical = [];
const different = [];

for (const lang of common) {
    // Filter out 's' property which check-new has but scriptable likely doesn't
    // Also Scriptable might have extra props?
    // We compare a, b, r.

    const cleanA = { a: jsonA[lang].a, b: jsonA[lang].b, r: jsonA[lang].r };
    const cleanB = { a: jsonB[lang].a, b: jsonB[lang].b, r: jsonB[lang].r };

    if (deepEqual(cleanA, cleanB)) {
        identical.push(lang);
    } else {
        different.push(lang);
    }
}

console.log(`Identical Languages (${identical.length}): ${identical.join(', ')}`);
console.log(`Different Languages (${different.length}): ${different.join(', ')}`);

if (different.length > 0) {
    console.log("\nDetails for Different Languages:");
    for (const lang of different) {
        console.log(`\n### ${lang}`);
        // Simple heuristic diff
        const dataA = jsonA[lang];
        const dataB = jsonB[lang];

        // Grid
        const gridA = JSON.stringify(dataA.a);
        const gridB = JSON.stringify(dataB.a);
        if (gridA !== gridB) console.log("- Grid (a) differs");

        // Limit
        if (dataA.b !== dataB.b) console.log(`- Limit (b) differs: ${dataA.b} vs ${dataB.b}`);

        // Rules
        const rulesA = JSON.stringify(dataA.r);
        const rulesB = JSON.stringify(dataB.r);
        if (rulesA !== rulesB) {
            console.log("- Rules (r) differ");
            // Check sub-rules
            ['i', 'c', 'd', 'e'].forEach(k => {
                if (JSON.stringify(dataA.r[k]) !== JSON.stringify(dataB.r[k])) {
                    console.log(`  - ${k} map differs`);
                }
            });
        }
    }
}
