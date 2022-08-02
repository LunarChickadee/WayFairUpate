//*********Gets list of months in Tally currently
global realDate,dateArray
dateArray=""
select DateFilled≠""
arrayselectedbuild dateArray, ¶,"",date(DateFilled[1," "]+" 1, "+DateFilled["- ",-1])
dateArray=arraydeduplicate(dateArray,¶)
arraysort dateArray,dateArray,¶
dateArray=arrayreverse(dateArray,¶)

arrayfilter dateArray,dateArray,¶,datepattern(val(array(dateArray,seq(),¶)),"mm/yy")


//**************************************

superchoicedialog dateArray, fakechoice, 
{caption="these are all the months currently imported from Tallies. If the month you need to do taxes on isn't here: Click Import Tallies.
You can scroll to see more dates." captionheight="3" buttons=ImportTallies:200;cancel}
if info("dialogtrigger")="ImportTallies"
call ImportTallies
endif
