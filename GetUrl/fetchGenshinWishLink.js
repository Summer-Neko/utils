module.exports = {
    // 更新缓存文件版本
    getCacheVersion: () => "2.31.0.0",

    // 从日志文件中提取游戏路径
    extractGameDir: (logContent) => {
        const match = logContent.match(/([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))/);
        return match ? match[1] : null;
    },

    // 从缓存文件中提取祈愿记录链接
    extractGachaLogUrl: (cachePath) => {
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

    simplifyUrl: (rawUrl) => {
        const url = require("url");
        const parsed = url.parse(rawUrl, true);
        const allowedKeys = ["authkey", "authkey_ver", "sign_type", "game_biz", "lang"];
        const filteredQuery = Object.keys(parsed.query)
            .filter((key) => allowedKeys.includes(key))
            .reduce((obj, key) => {
                obj[key] = parsed.query[key];
                return obj;
            }, {});
        return `${parsed.protocol}//${parsed.host}${parsed.pathname}?${new url.URLSearchParams(filteredQuery)}`;
    },
};
