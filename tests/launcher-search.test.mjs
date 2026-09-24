import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const source = readFileSync(new URL('../widgets/launcher/LauncherSearch.js', import.meta.url), 'utf8');
const search = vm.createContext({ URL });
vm.runInContext(source.replace(/^\.pragma library\s*/, ''), search);

test('plain queries offer Google without taking priority over local matches', () => {
    const result = search.web(' firefox ');
    assert.equal(result.kind, 'web');
    assert.equal(result.url, 'https://www.google.com/search?q=firefox');
    assert.equal(result.exclusive, false);
});

test('all qutebrowser prefixes preserve their configured destinations', () => {
    const cases = [
        ['yt live jazz', 'https://www.youtube.com/results?search_query=live%20jazz'],
        ['re nixos', 'https://www.reddit.com/r/nixos'],
        ['mn firefox', 'https://mynixos.com/search?q=firefox'],
        ['13 ubuntu linux', 'https://1337x.to/search/ubuntu%20linux/1/'],
    ];
    for (const [query, url] of cases) {
        const result = search.web(query);
        assert.equal(result.url, url);
        assert.equal(result.exclusive, true);
    }
    assert.equal(search.web('re nixos').name, 'Open r/nixos');
});

test('prefixes require a separate query and tolerate whitespace and capitalization', () => {
    assert.equal(search.web('  YT \t jazz  ').url, 'https://www.youtube.com/results?search_query=jazz');
    for (const query of ['yt', 'mn', 're', '13', 'ytmusic', 'unknown query', '__proto__ query']) {
        assert.equal(search.web(query).engine, 'Google');
        assert.equal(search.web(query).exclusive, false);
    }
});

test('search terms are encoded as data, including Unicode and URL delimiters', () => {
    const terms = 'café & tea #1 / 50%? $(echo test)';
    const url = new URL(search.web(terms).url);
    assert.equal(url.searchParams.get('q'), terms);
    assert.equal(Array.from(url.searchParams.keys()).length, 1);
    assert.equal(url.hash, '');
    assert.equal(search.web('re a/b?c#d').url, 'https://www.reddit.com/r/a%2Fb%3Fc%23d');
});

test('HTTP URLs and bare domains open directly', () => {
    const cases = [
        ['https://example.org/a?q=x%20y#section', 'https://example.org/a?q=x%20y#section'],
        ['http://example.org:8080/path', 'http://example.org:8080/path'],
        ['example.org/path?q=test', 'https://example.org/path?q=test'],
        ['www.example.org', 'https://www.example.org'],
        ['localhost:3000/app', 'http://localhost:3000/app'],
        ['192.168.1.1', 'http://192.168.1.1'],
        ['[::1]:8080', 'http://[::1]:8080'],
        ['münich.de', 'https://münich.de'],
    ];
    for (const [query, url] of cases) {
        const result = search.web(query);
        assert.equal(result.kind, 'url', query);
        assert.equal(result.url, url, query);
        assert.equal(result.exclusive, true, query);
    }
});

test('prefix search takes precedence over URL detection inside the query', () => {
    const result = search.web('mn example.org');
    assert.equal(result.kind, 'web');
    assert.equal(result.url, 'https://mynixos.com/search?q=example.org');
});

test('email, invalid URLs, and other URI schemes remain search text', () => {
    for (const query of ['user@example.org', 'javascript:alert(1)', 'file:///tmp/example',
        'mailto:user@example.org', 'https://', 'https://example.org/a b', 'example.org:99999',
        'hello world', 'example..org']) {
        assert.equal(search.web(query).kind, 'web', query);
    }
});

test('empty input and executable mode never offer web activation', () => {
    for (const query of ['', '   ', '>', '> firefox', '> echo https://example.org'])
        assert.equal(search.web(query), null, query);
});

test('local matching and quoted command arguments retain their behavior', () => {
    const apps = [{ name: 'Firefox', id: 'firefox.desktop', keywords: ['browser'], noDisplay: false }];
    assert.equal(search.applications(apps, 'firefox')[0].kind, 'app');
    const commands = search.executables([{ name: 'printf', path: '/bin/printf' }], 'printf "hello world"');
    assert.deepEqual(Array.from(commands[0].command), ['/bin/printf', 'hello world']);
});
