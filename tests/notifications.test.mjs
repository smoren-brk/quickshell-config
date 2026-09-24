import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

// Run the same QML JavaScript helpers without requiring a desktop session.
const source = readFileSync(new URL('../services/NotificationData.js', import.meta.url), 'utf8');
const helpers = vm.createContext({});
vm.runInContext(source.replace(/^\.pragma library\s*/, ''), helpers);
const plain = value => JSON.parse(JSON.stringify(value));

test('source identity uses desktop entry, then normalized app name', () => {
    assert.equal(helpers.sourceKey({ desktopEntry: 'org.example.Chat.desktop', appName: 'Room 1' }), 'desktop:org.example.chat');
    assert.equal(helpers.sourceKey({ desktopEntry: 'org.example.Chat', appName: 'Room 2' }), 'desktop:org.example.chat');
    assert.equal(helpers.sourceKey({ appName: ' Mail ' }), 'app:mail');
    assert.equal(helpers.sourceKey({}), 'app:notification');
});

test('latest notification leads its source and latest source leads the list', () => {
    const records = [
        { notificationId: 4, sourceKey: 'mail' },
        { notificationId: 3, sourceKey: 'chat' },
        { notificationId: 2, sourceKey: 'mail' },
        { notificationId: 1, sourceKey: 'chat' },
    ];
    const groups = helpers.group(records);
    assert.deepEqual(plain(groups.map(group => group.records.map(record => record.notificationId))), [[4, 2], [3, 1]]);
    assert.equal(records.length, 4);
});

test('exact fit needs no overflow footer', () => {
    assert.deepEqual(plain(helpers.fitGroups([100, 100, 100], [1, 1, 1], 328, 14, 40)), {
        visibleCount: 3, hiddenCount: 0,
    });
});

test('overflow reserves footer space and counts notifications inside hidden groups', () => {
    assert.deepEqual(plain(helpers.fitGroups([100, 100, 100], [2, 4, 5], 240, 14, 40)), {
        visibleCount: 1, hiddenCount: 9,
    });
});

test('variable card heights fit independently on different screen sizes', () => {
    const heights = [140, 180, 110, 200, 120];
    const counts = [3, 1, 2, 4, 1];
    assert.deepEqual(plain(helpers.fitGroups(heights, counts, Math.floor(1080 * 0.6) - 86, 14, 40)), {
        visibleCount: 3, hiddenCount: 5,
    });
    assert.deepEqual(plain(helpers.fitGroups(heights, counts, Math.floor(1440 * 0.6) - 86, 14, 40)), {
        visibleCount: 4, hiddenCount: 1,
    });
});

test('one oversized expanded group stays accessible by scrolling', () => {
    assert.deepEqual(plain(helpers.fitGroups([900, 100], [20, 3], 500, 14, 40)), {
        visibleCount: 1, hiddenCount: 3,
    });
    assert.deepEqual(plain(helpers.fitGroups([900], [20], 500, 14, 40)), {
        visibleCount: 1, hiddenCount: 0,
    });
});

test('empty lists have no overflow', () => {
    assert.deepEqual(plain(helpers.fitGroups([], [], 500, 14, 40)), {
        visibleCount: 0, hiddenCount: 0,
    });
});
