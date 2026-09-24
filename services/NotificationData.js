.pragma library

function sourceKey(notification) {
    const desktopEntry = (notification.desktopEntry || "").trim().replace(/\.desktop$/i, "");
    return desktopEntry ? "desktop:" + desktopEntry.toLowerCase()
                        : "app:" + (notification.appName || "Notification").trim().toLowerCase();
}

// Records are newest first. The first occurrence also orders each source.
function group(records) {
    const groups = [];
    const bySource = Object.create(null);
    for (const record of records) {
        let source = bySource[record.sourceKey];
        if (!source) {
            source = { sourceKey: record.sourceKey, records: [] };
            bySource[record.sourceKey] = source;
            groups.push(source);
        }
        source.records.push(record);
    }
    return groups;
}

// Reserve the footer only when the complete list does not fit.
function fitGroups(heights, counts, maximumHeight, spacing, footerHeight) {
    const totalHeight = heights.reduce((sum, height) => sum + height, 0)
        + Math.max(0, heights.length - 1) * spacing;
    if (totalHeight <= maximumHeight)
        return { visibleCount: heights.length, hiddenCount: 0 };

    const available = Math.max(0, maximumHeight - footerHeight);
    let used = 0;
    let visibleCount = 0;
    for (let index = 0; index < heights.length; index++) {
        const next = used + (index > 0 ? spacing : 0) + heights[index];
        // A single tall group remains scrollable, even on a small display.
        if (next > available && index > 0)
            break;
        used = next;
        visibleCount++;
    }
    return {
        visibleCount: visibleCount,
        hiddenCount: counts.slice(visibleCount).reduce((sum, count) => sum + count, 0)
    };
}
