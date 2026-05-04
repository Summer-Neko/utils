import pandas as pd
import json
from collections import defaultdict

df = pd.read_excel("gacha_logs_zh.xlsx", sheet_name="总数据")

uid_col = next((col for col in df.columns if col.lower() == 'uid'), None)
if not uid_col:
    raise ValueError("Excel 中未找到 UID 列")

KEY_MAP = {
    "角色活动唤取": "1",
    "武器活动唤取": "2",
    "角色常驻唤取": "3",
    "武器常驻唤取": "4",
    "新手唤取": "5",
    "新手自选唤取": "6",
    "感恩定向唤取": "7",
}

uid_groups = defaultdict(list)
for _, row in df.iterrows():
    uid = str(int(row[uid_col]))
    pool = row["卡池类型"]
    if pool not in KEY_MAP:
        continue
    key = KEY_MAP[pool]
    time_val = row["时间戳"]
    time_str = time_val.strftime("%Y-%m-%d %H:%M:%S") if hasattr(time_val, 'strftime') else str(time_val)
    record = {
        "cardPoolType": pool,
        "resourceId": row["物品ID"],
        "qualityLevel": row["品质"],
        "resourceType": row["类型"],
        "name": row["名称"],
        "count": row["数量"],
        "time": time_str
    }
    uid_groups[uid].append((key, record))

for uid, entries in uid_groups.items():
    result = {str(i): [] for i in range(1, 8)}
    result["uid"] = uid
    for key, record in entries:
        result[key].append(record)

    output_filename = f"gacha_record_{uid}.json"
    with open(output_filename, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print(f"已生成: {output_filename}")
