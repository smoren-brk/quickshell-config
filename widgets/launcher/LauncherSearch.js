.pragma library

function normalize(value) {
    return String(value || "").toLocaleLowerCase().trim();
}

function nameScore(name, query) {
    if (name === query)
        return 1000;
    if (name.startsWith(query))
        return 800;
    const position = name.indexOf(query);
    if (position >= 0)
        return 600 - Math.min(position, 100);

    let cursor = 0;
    let previous = -1;
    let gaps = 0;
    for (let i = 0; i < query.length; ++i) {
        const next = name.indexOf(query[i], cursor);
        if (next < 0)
            return -1;
        gaps += previous < 0 ? next : next - previous - 1;
        previous = next;
        cursor = next + 1;
    }
    return 200 - Math.min(gaps, 100);
}

function applications(entries, query) {
    const needle = normalize(query);
    const tokens = needle.split(/\s+/).filter(Boolean);
    return Array.from(entries).filter(entry => !entry.noDisplay).map(entry => {
        const name = normalize(entry.name);
        const metadata = normalize([entry.genericName, entry.comment, entry.id,
            ...Array.from(entry.keywords || [])].join(" "));
        let score = needle ? nameScore(name, needle) : 0;
        if (tokens.length && tokens.every(token => name.includes(token) || metadata.includes(token)))
            score = Math.max(score, 350);
        return {
            id: "app:" + entry.id,
            kind: "app",
            name: entry.name,
            description: entry.genericName || entry.comment || "Application",
            icon: entry.icon,
            application: entry,
            score: score
        };
    }).filter(result => result.score >= 0).sort((first, second) =>
        second.score - first.score || first.name.localeCompare(second.name));
}

// Split quoted arguments without evaluating shell syntax or expanding variables.
function argumentsFor(text) {
    const words = [];
    let word = "";
    let quote = "";
    let started = false;
    for (let i = 0; i < text.length; ++i) {
        const character = text[i];
        if (character === "\\" && quote !== "'") {
            if (++i === text.length)
                return null;
            if (quote === '"' && !['"', "\\", "$", "`", "\n"].includes(text[i]))
                word += "\\";
            if (text[i] !== "\n")
                word += text[i];
            started = true;
        } else if (quote) {
            if (character === quote)
                quote = "";
            else
                word += character;
        } else if (character === "'" || character === '"') {
            quote = character;
            started = true;
        } else if (/\s/.test(character)) {
            if (started) {
                words.push(word);
                word = "";
                started = false;
            }
        } else {
            word += character;
            started = true;
        }
    }
    if (quote)
        return null;
    if (started)
        words.push(word);
    return words;
}

function executables(entries, query) {
    const words = argumentsFor(query);
    if (!words)
        return [];
    const needle = normalize(words[0]);
    return entries.map(entry => {
        const score = needle ? nameScore(normalize(entry.name), needle) : 0;
        return {
            id: "executable:" + entry.path,
            kind: "executable",
            name: words.length > 1 ? query : entry.name,
            description: "Executable · " + entry.path,
            command: [entry.path, ...words.slice(1)],
            score: words.length > 1 && entry.name !== words[0] ? -1 : score
        };
    }).filter(result => result.score >= 0).sort((first, second) =>
        second.score - first.score || first.name.localeCompare(second.name));
}
