# Hướng dẫn biến `armmercury` thành Tháp phòng không Nuke bay thẳng

Theo yêu cầu của bạn, chúng ta sẽ làm cho `armmercury` bắn ra tên lửa hạt nhân (nuke), nhưng **chỉ bắn các mục tiêu trên không (VTOL)** và tên lửa **phải bay thẳng**, không bay ngoằn ngoèo bám đuổi mục tiêu.

## Cách tiếp cận

Do `armmercury` vốn đã được thiết lập để chỉ bắn mục tiêu trên không (thuộc tính `onlytargetcategory = "VTOL"` trong bảng `weapons` và `canattackground = false` trong `weapondefs`), ta không cần gỡ bỏ các hạn chế này.

Thay vào đó, ta sẽ sử dụng một script mutator (tweakdef) để thay đổi trực tiếp vũ khí `arm_advsam` của nó khi nạp game. Script này sẽ thực hiện 2 việc chính:
1. **Làm đạn bay thẳng:** Tắt hoàn toàn khả năng ngoặt (`tracks = false`, `turnrate = 0`). Vũ khí sẽ bắn ra hướng mục tiêu ở thời điểm khai hỏa và bay thẳng tuột.
2. **Cài đặt sát thương Nuke:** Gắn bán kính nổ khổng lồ (`areaofeffect = 1280`), đổi hiệu ứng nổ thành `custom:newnuke`, và đặt sát thương cực cao cho `vtol` (máy bay) lên mức `9500`.

_Lưu ý: Vì đạn bay thẳng và không đuổi, nó rất dễ trượt nếu máy bay di chuyển ngang. Tuy nhiên, nhờ bán kính nổ Nuke cực lớn (1280), chỉ cần đạn nổ ở gần là máy bay sẽ bị tiêu diệt._

## Code Mutator

Tôi đã tạo sẵn một file tên là `armmercury_aa_nuke.lua`. Đây là script dùng để cài làm mod (tweakdef). Nội dung script như sau:

```lua
-- Author: Jules
-- Name: ArmMercury AA Straight Nuke

if WeaponDefs and WeaponDefs["arm_advsam"] then
	-- Tắt khả năng bám đuổi để đạn bay thẳng
	WeaponDefs["arm_advsam"].tracks = false
	WeaponDefs["arm_advsam"].turnrate = 0
	WeaponDefs["arm_advsam"].trajectoryheight = 0

	-- Tăng thời gian bay để đạn bay được xa hơn (vì không đuổi)
	WeaponDefs["arm_advsam"].flighttime = 10

	-- Thiết lập hiệu ứng và thông số Nuke
	WeaponDefs["arm_advsam"].areaofeffect = 1280
	WeaponDefs["arm_advsam"].craterareaofeffect = 1280
	WeaponDefs["arm_advsam"].explosiongenerator = "custom:newnuke"
	WeaponDefs["arm_advsam"].soundhit = "nukearm"
	WeaponDefs["arm_advsam"].soundstart = "nukelaunch"

	-- Đặt biến custom param là nuke
	WeaponDefs["arm_advsam"].customparams = WeaponDefs["arm_advsam"].customparams or {}
	WeaponDefs["arm_advsam"].customparams.nuclear = 1

	-- Thiết lập sát thương cực mạnh đối phó với cả không quân
	WeaponDefs["arm_advsam"].damage = WeaponDefs["arm_advsam"].damage or {}
	WeaponDefs["arm_advsam"].damage.default = 9500
	WeaponDefs["arm_advsam"].damage.vtol = 9500
end
```

## Cách sử dụng

* Đặt đoạn mã trên vào hệ thống tải mutator/tweakdef của bạn (thường sẽ được chạy tự động trong `gamedata/alldefs_post.lua` thông qua hàm `loadstring`, hoặc load riêng như một mod).
* Nó sẽ ghi đè các thông số của vũ khí `arm_advsam` trên toàn hệ thống. Kể từ lúc đó, `armmercury` sẽ hoạt động như một tháp bắn Nuke thẳng phòng không.