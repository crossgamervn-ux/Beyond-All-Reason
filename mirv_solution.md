Chào bạn,

Nếu bạn muốn hiệu ứng các đầu đạn con **văng ra thật xa** và nổ trải đều khắp căn cứ (chứ không bị chụm lại một chỗ), bạn cần điều chỉnh độ tản mát (scatter) của đạn con.

**Nguyên lý tản mát của đạn Cluster:**
Trong hệ thống của game, tốc độ và độ văng xa của các đạn con được tính toán trực tiếp dựa trên thuộc tính **`range`** (tầm bắn) của chính viên đạn con đó.
- Nếu `range` thấp (ví dụ 300), đạn con sẽ rớt lẹt đẹt ngay tại chỗ đạn mẹ nổ.
- Nếu bạn tăng `range` lên thật cao (ví dụ `1200` hoặc `1500`), lực văng sẽ cực mạnh, đẩy các đầu đạn tủa ra khắp một vùng rộng lớn tạo ra hiệu ứng rải thảm cực kỳ đẹp mắt và tàn phá!

Dưới đây là mã Lua đã được cập nhật, tập trung vào việc đẩy mạnh độ văng của MIRV:

```lua
-- Mod tác giả: [Tên của bạn]
-- Tên mod: Nuke MIRV Cluster Modifier

local function addMIRVToSilo(unitName, weaponName)
    if UnitDefs[unitName] and UnitDefs[unitName].weapondefs and UnitDefs[unitName].weapondefs[weaponName] then
        local wdefs = UnitDefs[unitName].weapondefs
        local motherNuke = wdefs[weaponName]

        -- 1. Sao chép thông số (manual copy)
        local childNuke = {}
        for k, v in pairs(motherNuke) do
            if type(v) == "table" then
                childNuke[k] = {}
                for k2, v2 in pairs(v) do childNuke[k][k2] = v2 end
            else
                childNuke[k] = v
            end
        end

        -- Khai báo tên đạn con
        local childName = weaponName .. "_mirv_child"
        childNuke.name = (childNuke.name or "Nuke") .. " (MIRV Child)"

        -- Xóa cluster_def hoặc speceffect ở đạn con để tránh lặp vô hạn
        if childNuke.customparams then
            childNuke.customparams.speceffect = nil
            childNuke.customparams.cluster_def = nil
        end

        -- Cluster gadget ưu tiên vũ khí dạng Cannon để tính đường đạn parabol
        childNuke.weapontype = "Cannon"

        -- TẠO ĐỘ VĂNG XA: Tăng `range` lên thật cao để đầu đạn tản ra diện rộng.
        -- Bạn có thể chỉnh con số 1500 này to hơn hoặc nhỏ hơn tùy ý muốn!
        childNuke.range = 1500

        -- Chia sát thương làm 6
        if childNuke.damage then
            for k, v in pairs(childNuke.damage) do
                childNuke.damage[k] = math.floor(v / 6)
            end
        end

        -- Đưa đạn con vào danh sách weapondefs của Unit
        wdefs[childName] = childNuke

        -- 2. Sửa thông số đạn mẹ sử dụng Cluster thay vì Split
        motherNuke.customparams = motherNuke.customparams or {}
        motherNuke.customparams.speceffect = nil -- Xóa split

        -- LƯU Ý: Tuyệt đối KHÔNG nối `unitName .. "_"` vào đây, vì engine
        -- trong `alldefs_post.lua` sẽ TỰ ĐỘNG làm việc đó.
        motherNuke.customparams.cluster_def = childName
        motherNuke.customparams.cluster_number = 6
    end
end

-- Kích hoạt MIRV cho Silo nuke
addMIRVToSilo("corsilo", "crblmssl")
addMIRVToSilo("armsilo", "nuclear_missile")
```
