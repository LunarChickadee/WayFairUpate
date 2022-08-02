local fakechoice, winList, initWin, wayFairWin
winList=""
initWin=""
wayFairWin="WayfairSalesTax"
Message "To use this file, you must run the ImportTallies macro. The Following Prompts will help you do so"
yesno "Is the current fiscal year "+zyear+". And the last fiscal year "+zpreviousyear+"?"
if clipboard()="No"
message "please change zyear and zpreviousyear in the macro that will now open"
goprocedure ".Initialize"
winList=info("windows")
arrayfilter winList, initWin, ¶, ?(import() contains "Init", import(),"")
initWin=arraystrip(initWin,¶)
window initWin
//needs to keep open the data sheet
stop
endif
