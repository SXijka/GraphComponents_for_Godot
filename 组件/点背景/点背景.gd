@tool
## 平铺排布的点背景，图案并非只有点状，还有叉状，十字，一字。
class_name 点背景
extends NinePatchRect


@export_range(32,248,1) var 间距: int = 64: ## 点之间的间距，单位为像素。如果希望调整点的大小，可以通过调整节点scale来实现。
	set = _设置

@export_enum("点","叉","十","一") var 图案: String = "点": ## 平铺的图案，可设置为四种："点","叉","十","一"。
	set = _设置

@export var 点颜色: Color = Color.GRAY: ## 点的颜色。
	set = _调整点颜色

@export var 点完整: bool = true: ## 是否修正平铺，显示等距的完整点。可能会导致点图像的比例失调。
	set = _配置点完整

const _点 = Vector2(384,384)
const _叉 = Vector2(128,384)
const _十 = Vector2(384,128)
const _一 = Vector2(128,128)


func _ready() -> void:
	_配置点完整(点完整)
	_设置(图案)
	_设置(间距)
	_调整点颜色(点颜色)

func _配置点完整(是_完整的: bool):
	点完整 = 是_完整的
	if 点完整:
		axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
		axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	else:
		axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
		axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE


func _设置(值: Variant):
	if typeof(值) == TYPE_INT:
		间距 = 值
	else:
		图案 = 值

	var 间距_ := Vector2(间距,间距)
	if 间距 < 32:
		间距_ = Vector2(32,32)
	elif 间距 > 248:
		间距_ = Vector2(248,248)

	match 图案:
		"点":
			(texture as AtlasTexture).region = Rect2(_点 - 间距_/2, 间距_)
		"叉":
			(texture as AtlasTexture).region = Rect2(_叉 - 间距_/2, 间距_)
		"十":
			(texture as AtlasTexture).region = Rect2(_十 - 间距_/2, 间距_)
		"一":
			(texture as AtlasTexture).region = Rect2(_一 - 间距_/2, 间距_)


func _调整点颜色(颜色: Color):
	点颜色 = 颜色
	self_modulate = 颜色

