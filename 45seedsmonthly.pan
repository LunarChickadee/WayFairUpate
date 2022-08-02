global raya
local seedsselected
select OrderNo = int(OrderNo)
seedsselected=info("selected")
selectwithin Status contains "com"

raya=""

arrayselectedbuild raya,¶,"", "Seeds"+¬+str(OrderNo)+¬+Taxable+¬+TaxState+¬+Cit+¬+pattern(Z,"#####")+¬+¬+str(TaxRate)+¬+str(StateRate)+¬+
str(CountyRate)+¬+str(CityRate)+¬+str(SpecialRate)+¬+str(«$Shipping»)+¬+str(AdjTotal)+¬+str(TaxedAmount)+¬+str(SalesTax)+¬+datepattern(FillDate,"Month YYYY")+¬+¬+
str(StateTax)+¬+str(CountyTax)+¬+str(CityTax)+¬+str(SpecialTax)+¬+str(OrderTotal)

openfile "WayfairSalesTax"
openfile "+@raya"
