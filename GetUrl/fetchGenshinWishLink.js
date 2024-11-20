module.exports = {
    getCacheVersion: () => "2.31.0.0", // 动态更新版本
    extractGachaLogUrl: function (cachePath) {
        const fs = require("fs");
        const url = require("url");

        if (!fs.existsSync(cachePath)) return null;
        const cacheData = fs.readFileSync(cachePath, "latin1");
        const entries = cacheData.split("1/0/");
        for (let i = entries.length - 1; i >= 0; i--) {
            const entry = entries[i];
            if (entry.includes("http") && entry.includes("getGachaLog")) {
                const rawUrl = entry.split("\0")[0];
                return simplifyUrl(rawUrl);
            }
        }
        return null;
    },
    simplifyUrl: function (rawUrl) {
        const parsed = url.parse(rawUrl, true);
        const allowedKeys = ["authkey", "authkey_ver", "sign_type", "game_biz", "lang"];
        const filteredQuery = Object.keys(parsed.query)
            .filter((key) => allowedKeys.includes(key))
            .reduce((obj, key) => {
                obj[key] = parsed.query[key];
                return obj;
            }, {});
        return `${parsed.protocol}//${parsed.host}${parsed.pathname}?${new url.URLSearchParams(
            filteredQuery
        )}`;
    },
};
