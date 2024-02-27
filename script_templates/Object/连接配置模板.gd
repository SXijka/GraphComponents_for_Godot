extends 连接配置

# 判断是否进行连接的代码，返回值将决定连接是否成功。
func 连接判断(_发送者: 接口)-> bool:
	if _发送者.接口模式 != "发送模式":
		return false
		
	return true


func 在连接成功时执行():
	pass


func 连接时不断执行(_delta: float):
	pass


func 断开时执行一次():
	pass
