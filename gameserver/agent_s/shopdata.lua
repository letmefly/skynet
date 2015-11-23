local shopdata = {data = {}}

function shopdata:plus_money(money_num)
	self.data["money"] = self.data["money"] + money_num
end

return shopdata
