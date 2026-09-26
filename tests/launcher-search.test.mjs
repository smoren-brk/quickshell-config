import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const source = readFileSync(new URL('../widgets/launcher/LauncherSearch.js', import.meta.url), 'utf8');
const search = vm.createContext({});
vm.runInContext(source.replace(/^\.pragma library\s*/, ''), search);

test('local matching and quoted command arguments retain their behavior', () => {
    const apps = [{ name: 'Firefox', id: 'firefox.desktop', keywords: ['browser'], noDisplay: false }];
    assert.equal(search.applications(apps, 'firefox')[0].kind, 'app');
    const commands = search.executables([{ name: 'printf', path: '/bin/printf' }], 'printf "hello world"');
    assert.deepEqual(Array.from(commands[0].command), ['/bin/printf', 'hello world']);
});
