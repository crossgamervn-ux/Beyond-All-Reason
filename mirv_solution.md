Chào bạn,

Vấn đề bạn đang gặp phải với việc sử dụng `speceffect = "split"` cho tên lửa hạt nhân (Nuke) xuất phát từ cách mà Spring Engine xử lý cơ chế "split" (tách đạn giữa không trung).

**Nguyên nhân:**
Trong engine (cụ thể ở file `luarules/gadgets/unit_custom_weapons_behaviours.lua`), điều kiện để kích hoạt hiệu ứng "split" là:
```lua
local function isProjectileFalling(projectileID)
	local _, velocityY = spGetProjectileVelocity(projectileID)
	return velocityY < 0
end
```
Tức là ngay khi vận tốc rơi (theo trục Y) của viên đạn nhỏ hơn 0 (đạn bắt đầu đi xuống), nó sẽ bị xóa bỏ và lập tức sinh ra các viên đạn con.
Đối với vũ khí loại `StarburstLauncher` (như Nuke), đường đạn của nó sẽ bay vút lên cao, sau đó chuyển hướng và bắt đầu rơi xuống từ rất sớm (gần như ở ngay trên đầu silo phóng). Do đó, hàm kiểm tra `velocityY < 0` sẽ kích hoạt ngay lập tức, làm cho Nuke vỡ ra thành đạn con ở vị trí rất gần, thay vì bay đến mục tiêu rồi mới nổ.

**Cách khắc phục:**
Thay vì dùng `speceffect = "split"`, chúng ta sẽ sử dụng cơ chế **Cluster Munitions** (`cluster_def` và `cluster_number`) đã được hỗ trợ sẵn trong game (file `unit_custom_weapons_cluster.lua`). Cơ chế cluster này sẽ đảm bảo viên đạn mẹ bay đến tận nơi mục tiêu (hoặc khi hết thời gian bay) rồi mới nổ và phân tán thành các viên đạn con.

Bên cạnh đó, vì đạn con sinh ra từ cluster cần tuân thủ cấu trúc của một `Cannon`, ta nên đặt `weapontype = "Cannon"` cho đạn con.

Dưới đây là mã Lua đã được sửa lại:

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

        -- Cluster gadget ưu tiên vũ khí dạng Cannon
        childNuke.weapontype = "Cannon"

        -- Có thể cần cung cấp tầm bắn/tốc độ cho đạn con (Cluster tự động dùng range hoặc weaponvelocity để phân tán)
        childNuke.range = 300

        -- Chia sát thương làm 6
        if childNuke.damage then
            for k, v in pairs(childNuke.damage) do
                childNuke.damage[k] = math.floor(v / 6)
            end
        end

        -- Đưa đạn con vào danh sách weapondefs của Unit
        wdefs[childName] = childNuke

        -- LƯU Ý QUAN TRỌNG: Engine sẽ tự nối tên unit vào trước tên vũ khí.
        -- Ta phải khai báo cluster_def có chứa tiền tố này để gadget cluster tìm đúng đạn!
        local compiledChildName = unitName .. "_" .. childName

        -- 2. Sửa thông số đạn mẹ sử dụng Cluster thay vì Split
        motherNuke.customparams = motherNuke.customparams or {}
        motherNuke.customparams.speceffect = nil -- Xóa split
        motherNuke.customparams.cluster_def = compiledChildName
        motherNuke.customparams.cluster_number = 6
    end
end

-- Kích hoạt MIRV cho Silo nuke
addMIRVToSilo("corsilo", "crblmssl")
addMIRVToSilo("armsilo", "nuclear_missile")
```
