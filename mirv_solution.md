Chào bạn,

Nếu bạn muốn đạn Nuke tách làm nhiều mảnh **ngay giữa không trung** (không chạm đất) ở ngay phía trên mục tiêu, đây là một thách thức khá lớn vì giới hạn vật lý của engine game.

**Vấn đề của Nuke (StarburstLauncher):**
- Đạn Nuke sử dụng loại vũ khí `StarburstLauncher`. Đặc trưng của loại đạn này là bay thẳng đứng lên trời từ hầm chứa (Silo), sau đó bẻ lái và phóng tới mục tiêu.
- Cơ chế tách đạn trên không `speceffect = "split"` chỉ kích hoạt khi đạn bắt đầu rơi (vận tốc Y < 0). Với Nuke, đạn bắt đầu "rơi" ngay sau khi đạt đỉnh quỹ đạo ở sát nhà bạn, do đó nó luôn bị tách sớm.
- Bạn **không thể** đổi đạn mẹ thành `Cannon` (để bay vòng cung parabol) vì hầm chứa (Silo) được thiết kế code animation chỉ để bắn `StarburstLauncher`. Nếu đổi thành Cannon, hầm Silo sẽ bị lỗi và không thể bắn được.

**Kết luận:**
Trong hệ thống Spring Engine hiện tại, **không có thông số mặc định nào** hỗ trợ đạn `StarburstLauncher` tự động phát nổ giữa không trung (Airburst) ngay trên đầu mục tiêu ở các khoảng cách ngẫu nhiên.
- `flighttime` cố định sẽ khiến đạn nổ sớm ở mục tiêu xa, hoặc chạm đất ở mục tiêu gần.
- Cơ chế `cluster` là giải pháp an toàn và hoàn hảo nhất cho Nuke. Nó bắt buộc đạn phải đâm xuống đất (hoặc đập vào khiên năng lượng) rồi mới văng đạn con ra rải thảm. Nhưng bù lại, nó luôn luôn nổ chính xác ở mọi khoảng cách.

Dưới đây là đoạn code **hoàn thiện và đẹp nhất** để nuke tản ra diện rộng khi đâm trúng mục tiêu (sử dụng Cluster với lực văng xa mạnh `range = 1500`):

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

        -- Đạn con văng ra dưới dạng Cannon để tạo parabol đẹp mắt
        childNuke.weapontype = "Cannon"

        -- Lực văng siêu mạnh để đầu đạn tản ra diện rộng
        childNuke.range = 1500

        -- Chia sát thương làm 6
        if childNuke.damage then
            for k, v in pairs(childNuke.damage) do
                childNuke.damage[k] = math.floor(v / 6)
            end
        end

        -- Đưa đạn con vào danh sách weapondefs của Unit
        wdefs[childName] = childNuke

        -- 2. Đạn mẹ sử dụng Cluster
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
