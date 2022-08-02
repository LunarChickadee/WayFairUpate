___ PROCEDURE .Initialize ______________________________________________________
global zyear, vTaxStates,zpreviousyear
EXPRESSIONSTACKSIZE 125000000

global winList2
winList2=info("windows")


///*****************************!!!!!!!!!!!!!!!!!!!
///*******Change These to the correct years!!!!!
//zyear=this FY and zprevious = last fiscal year

zyear="45"
zpreviousyear="44"


//Please close this window when you are done! 
//and then run "instructions" again
///*********************
//*****************************!!!!!!!!!!!!!!!!!!!!!!



vTaxStates="CT,FL,GA,IA,IL,IN,KS,KY,MA,MD,ME,MI,MN,NC,NJ,NM,NY,OH,PA,RI,TN,UT,VA,VT,WA,WI,WV,WY"

Call "Instructions"

;Added: IA is it not here on purpose? 
;seems like it
___ ENDPROCEDURE .Initialize ___________________________________________________

___ PROCEDURE ImportTallies ____________________________________________________
global vTreesWindow //declared to fix a window issue with trees

bigmessage "The next Window will list all the files you currently have in the WayFairTax folder."

//**********Displays files with this and last fiscal year in the name

global thisFolder,allFiles,theTallies,fakechoice1, loadedTallies
local loopcount

loadedTallies=""

////*****Gets List of Pan Files in this folder that have 44 or 45 and either walkin or tally
thisFolder=folder("")
allFiles=listfiles(thisFolder,"????KASX")
theTallies=""
loopcount=1
loop
if (array(allFiles,loopcount,¶) contains "45" or array(allFiles,loopcount,¶) contains "44") 
and (array(allFiles,loopcount,¶) contains "walk" or array(allFiles,loopcount,¶) contains "tall")
and (array(allFiles,loopcount,¶) notcontains "recon")
theTallies=theTallies+¶+array(allFiles,loopcount,¶)
endif
increment loopcount
until loopcount>arraysize(allFiles,¶)
arraystrip theTallies,¶
superchoicedialog theTallies, fakechoice1,
    {caption="if you are missing a tally from here, please hit stop, add it to the WayFairTax folder, and run the Instructions macro again.
    When you are done, run the ImportTallies macro again" captionheight="2" buttons=continue;STOP}
if info("dialogtrigger")="STOP"
stop
endif
////***********

///*****clears previous data
;deleteall
;nop

if theTallies contains zyear+"ogstally"
loadedTallies=zyear+"ogstally"+¶+loadedTallies
;****Pulls ogs tally info******
openfile zyear+"ogstally" 
    call ogsmonthly 
    window zyear+"ogstally" 
    save 
    closewindow
endif

debug
if theTallies contains zyear+"seedstally"
;****Pulls seeds tally info******
openfile zyear+"seedstally"
gosheet
call seedsmonthly
window zyear+"seedstally"
save 
closewindow
endif
yesno "For FY "+zyear+", Do you have Seeds Winter?"
if clipboard()="Yes"
;****Pulls this years seeds winter tally info****** 
    openfile zyear+"seedstally-winter" 
    gosheet
    call seedsmonthly
    window zyear+"seedstally-winter"
    save 
    closewindow
endif

yesno "For FY "+zyear+", Do you have Seeds Summer?"
if clipboard()="Yes"
;****Pulls this years seeds summer tally info****** 
    openfile zyear+"seedstally-summer" 
    gosheet
    call seedsmonthly
    window zyear+"seedstally-summer"
    save 
    closewindow
endif

noyes "do you want to import last years tallies for annual taxes? or are you reporting June Taxes?"
If clipboard() contains "yes"
    //*****Sometimes the seedstally-winteralready has this data uncomment this if not
    
    openfile zpreviousyear+"seedstally"
    gosheet
    window zpreviousyear+"seedstally"
    call seedsmonthly
    window zpreviousyear+"seedstally"
    save 
    closewindow
    
    
    openfile zpreviousyear+"ogstally"
    gosheet
    window zpreviousyear+"ogstally"
    call ogsmonthly
    window zpreviousyear+"ogstally"
    save 
    closewindow

    openfile zpreviousyear+"treestally"
    gosheet
    window zpreviousyear+"treestally"
    call "Tree Monthlies"
    window zpreviousyear+"treestally"
    save 
    closewindow

    openfile zpreviousyear+"Walk-In Sales archive"
    gosheet
    call walkinmonthly
    window zpreviousyear+"Walk-In Sales archive"
    save 
    closewindow

    openfile "Walkin Register"+zpreviousyear
    gosheet
    call WalkinMonthly
    window "Walkin Register"+zpreviousyear
    save 
    closewindow
/*
    openfile zpreviousyear+"seedstally-winter" 
    gosheet
    call seedsmonthly
    window zpreviousyear+"seedstally-winter"
    save 
    closewindow
*/
endif

;****Pulls Trees tally info******

yesno "For FY "+zyear+", Do you want to append Trees Tally orders?"
if clipboard() contains "Yes"
    openfile zyear+"treestally"
        vTreesWindow = info("windowname")  //you can change this varible name and add this with....
        call «Tree Monthlies»
        window vTreesWindow //...this to make sure its always bringing up the correct window to close
        //window zyear+"treestally"
        save 
        closewindow
endif

call ImportCounty 


;****Pulls seeds Walkin info******
openfile zyear+"Walk-In Sales archive"
    call walkinmonthly
    window zyear+"Walk-In Sales archive"
    save 
    closewindow

;****Pulls ogs Walkin info******

openfile "Walkin Register"+zyear
    call WalkinMonthly
    window "Walkin Register"+zyear
    save 
    closewindow

;****Pulls trees Walkin info******
//add when given a walkin from trees

call CalculateTaxField

select Branch≠""
removeunselected

select DateFilled≠""
removeunselected

message "All Done Loading!"
___ ENDPROCEDURE ImportTallies _________________________________________________

___ PROCEDURE fillrates ________________________________________________________
field TaxState
select TaxState=""
if info("selected")<info("records")
formulafill lookup("45seedstally", "OrderNo", «OrderNo», "TaxState","",0)
endif
select ShiptoCity=""
if info("selected")<info("records")
formulafill  lookup("45seedstally","OrderNo",«OrderNo»,"Cit","",0)
endif
select ShiptoZip
if info("selected")<info("records")
formulafill  lookup("45seedstally","OrderNo",«OrderNo»,"Z",0,0)
endif
field County
formulafill lookup("USTownsbyCounty","FirstZip",«ShiptoZip»,"County","",0)
select County=""
if info("selected")>0
formulafill table("USTownsbyCounty","Zip Range",pattern(«ShiptoZip»,"#####"),"County","",0)
endif
;stop
select TaxRate=0
if info("selected")<info("records")
field TaxRate
formulafill lookup("45seedstally", "OrderNo", «OrderNo», "TaxRate",0,0)
field StateRate
formulafill lookup("45seedstally", "OrderNo", «OrderNo», "StateRate",0,0)
field CountyRate
formulafill lookup("45seedstally", "OrderNo", «OrderNo», "CountyRate",0,0)
field CityRate
formulafill lookup("45seedstally", "OrderNo", «OrderNo», "CityRate",0,0)
field SpecialRate
formulafill lookup("45seedstally", "OrderNo", «OrderNo», "SpecialRate",0,0)
endif
selectall
stop
select arraycontains("VT,MD,RI",TaxState, ",")
field TaxStatus 
formulafill ?(val(Item[1,"-"][1,-2])<4800, "N","Y")
selectall
save




___ ENDPROCEDURE fillrates _____________________________________________________

___ PROCEDURE filltax __________________________________________________________
;field ItemTotal
;formulafill Fill*Price*(1-Discount)
;field TaxableTotal
;formulafill ?(Taxable="N",0,?(TaxStatus="N",0,ItemTotal))
field Tax
formulafill ?(Taxable ≠"N", ?(arraycontains("MD,IA",TaxState,","),TaxableTotal*TaxRate,(TaxableTotal+Shipping)*TaxRate),0)
field StateTax
formulafill ?(Taxable ≠"N", ?(arraycontains("MD,IA",TaxState,","),TaxableTotal*StateRate,(TaxableTotal+Shipping)*StateRate),0)
field CountyTax
formulafill ?(Taxable ≠"N", ?(arraycontains("MD,IA",TaxState,","),TaxableTotal*CountyRate,(TaxableTotal+Shipping)*CountyRate),0)
field CityTax
formulafill ?(Taxable ≠"N", ?(arraycontains("MD,IA",TaxState,","),TaxableTotal*CityRate,(TaxableTotal+Shipping)*CityRate),0)
field SpecialTax
formulafill ?(Taxable ≠"N", ?(arraycontains("MD,IA",TaxState,","),TaxableTotal*SpecialRate,(TaxableTotal+Shipping)*SpecialRate),0)

stop
field TaxState

GroupUp
field County
GroupUp
Field ShiptoCity
GroupUp
field OrderNo
Propagate
Field County
Propagate
Field TaxState
Propagate
Field TaxRate
Propagate
Field StateRate
Propagate
Field CountyRate
Propagate
Field CityRate
Propagate
Field SpecialRate
Propagate
Field Tax
Total
Field ItemTotal 
Total
Field TaxableTotal
Total
Field StateTax
Total
Field CountyTax
Total
Field CityTax
Total
Field SpecialTax
Total
Field ItemShipping
Total


___ ENDPROCEDURE filltax _______________________________________________________

___ PROCEDURE ImportCounty _____________________________________________________

local vwindow, vwindow2
vwindow= "USTowns&Counties&Zip"
vwindow2="WayfairSalesTax"
openfile vwindow
window vwindow2
selectall

field County
formulafill lookup("USTowns&Counties&Zip","ZipCode",ShiptoZip,"County","""""",0)
    select TaxState="VT"
        if info("selected")≠info("records")
            window "USTowns&Counties&Zip"
            select St="VT"
            window vwindow2
            field ShiptoCity
            formulafill ?(lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0)="",ShiptoCity,lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0))
        else
            endif

    select TaxState="WV"
        if info("selected")≠info("records")
            window "USTowns&Counties&Zip"
            select St="WV"
            window vwindow2
            field ShiptoCity
            formulafill ?(lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0)="",ShiptoCity,lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0))
        else
            endif
    select TaxState="MN"
        if info("selected")≠info("records")
            window "USTowns&Counties&Zip"
            select St="MN"
            window vwindow2
            field ShiptoCity
            formulafill ?(lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0)="",ShiptoCity,lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0))
        else
            endif

        select TaxState="WA"
        if info("selected")≠info("records")
            window "USTowns&Counties&Zip"
            select St="WA"
            window vwindow2
            field ShiptoCity
            formulafill ?(lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0)="",ShiptoCity,lookupselected("USTowns&Counties&Zip","ZipCode",«ShiptoZip»,"City","",0))
        else
            endif



selectall


___ ENDPROCEDURE ImportCounty __________________________________________________

___ PROCEDURE CalculateTaxField ________________________________________________
local vStateShip

vStateShip="AR,CO,CT,DC,FL,GA,HI,IL,IN,KS,KY,MD,MI,MN,MS,NE,NJ,NM,NY,NC,ND,OH,PA,RI,SC,SD,TN,TX,VT,WA,WV,WI"

openfile "ZipCodeList"

window "WayfairSalesTax"


//**********Loads tax rates from ZipCodeList*******
selectall

field TaxRate
formulafill lookup("ZipCodeList","ZipCode",«ShiptoZip»,"TaxRate",0,0)

field StateRate
formulafill lookup("ZipCodeList","ZipCode",«ShiptoZip»,"StateRate",0,0)

field CountyRate
formulafill lookup("ZipCodeList","ZipCode",«ShiptoZip»,"CountyRate",0,0)

field CityRate
formulafill lookup("ZipCodeList","ZipCode",«ShiptoZip»,"CityRate",0,0)

field SpecialRate
formulafill lookup("ZipCodeList","ZipCode",«ShiptoZip»,"SpecialRate",0,0)


//******Does the Math for the various Taxes********
field Tax

formulafill TaxableTotal*TaxRate

field StateTax
formulafill TaxableTotal*StateRate
field CountyTax
formulafill TaxableTotal*CountyRate


field CityTax
formulafill TaxableTotal*CityRate


field SpecialTax
formulafill TaxableTotal*SpecialRate

field ItemPlusShipping
formulafill ?(vStateShip contains TaxState, ItemTotal+Shipping,0)

window "ZipCodeList"
closefile
___ ENDPROCEDURE CalculateTaxField _____________________________________________

___ PROCEDURE taxexempt ________________________________________________________
select arraycontains("VT,MD,RI",TaxState, ",")
field TaxStatus 
formulafill ?(val(Item[1,"-"][1,-2])<4800, "N","Y")
selectall
save
___ ENDPROCEDURE taxexempt _____________________________________________________

___ PROCEDURE shipping _________________________________________________________
field OrderNo
Groupup
Field ItemTotal
Total
Field Shipping
Propagate
Field ItemShipping
formulafill ItemTotal*(divzero(lookup(info("databasename"),"OrderNo",«OrderNo»,"Shipping",0,1),lookup(info("databasename"),"OrderNo",«OrderNo»,"ItemTotal",0,1)))
removeallsummaries
___ ENDPROCEDURE shipping ______________________________________________________

___ PROCEDURE CheckNexusRules __________________________________________________
field TaxState
groupup
field ItemPlusShipping
total
field ShiptoZip
count
lastrecord
deleterecord
selectsummaries
___ ENDPROCEDURE CheckNexusRules _______________________________________________

___ PROCEDURE Test1 ____________________________________________________________
message date(DateFilled[1," "]+" 1, "+DateFilled["- ",-1])
___ ENDPROCEDURE Test1 _________________________________________________________

___ PROCEDURE deletescrap ______________________________________________________

___ ENDPROCEDURE deletescrap ___________________________________________________

___ PROCEDURE Instructions _____________________________________________________
local fakechoice, winList, initWin, wayFairWin
winList=""
initWin=""
wayFairWin="WayfairSalesTax"
Message "To use this file, you must run the ImportTallies macro. The Following Prompts will help you do so"
yesno "Is the current fiscal year "+zyear+". And the last fiscal year "+zpreviousyear+"?"

if clipboard()="No"
message "please change zyear and zpreviousyear in the macro that will now open"
openprocedure ".Initialize"
winList=info("windows")
arrayfilter winList, initWin, ¶, ?(import() contains "Init", import(),"")
initWin=arraystrip(initWin,¶)
endif



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


___ ENDPROCEDURE Instructions __________________________________________________

___ PROCEDURE (CommonFunctions) ________________________________________________

___ ENDPROCEDURE (CommonFunctions) _____________________________________________

___ PROCEDURE ExportMacros _____________________________________________________
local Dictionary1, ProcedureList
//this saves your procedures into a variable
exportallprocedures "", Dictionary1
clipboard()=Dictionary1

message "Macros are saved to your clipboard!"
___ ENDPROCEDURE ExportMacros __________________________________________________

___ PROCEDURE ImportMacros _____________________________________________________
local Dictionary1,Dictionary2, ProcedureList
Dictionary1=""
Dictionary1=clipboard()
yesno "Press yes to import all macros from clipboard"
if clipboard()="No"
stop
endif
//step one
importdictprocedures Dictionary1, Dictionary2
//changes the easy to read macros into a panorama readable file

 
//step 2
//this lets you load your changes back in from an editor and put them in
//copy your changed full procedure list back to your clipboard
//now comment out from step one to step 2
//run the procedure one step at a time to load the new list on your clipboard back in
//Dictionary2=clipboard()
loadallprocedures Dictionary2,ProcedureList
message ProcedureList //messages which procedures got changed

___ ENDPROCEDURE ImportMacros __________________________________________________

___ PROCEDURE Symbol Reference _________________________________________________
bigmessage "Option+7= ¶  [in some functions use chr(13)
Option+= ≠ [not equal to]
Option+\= « || Option+Shift+\= » [chevron]
Option+L= ¬ [tab]
Option+Z= Ω [lineitem or Omega]
Option+V= √ [checkmark]
Option+M= µ [nano]
Option+<or>= ≤or≥ [than or equal to]"


___ ENDPROCEDURE Symbol Reference ______________________________________________

___ PROCEDURE GetDBInfo ________________________________________________________
local DBChoice, vAnswer1, vClipHold

Message "This Procedure will give you the names of Fields, procedures, etc in the Database"
//The spaces are to make it look nicer on the text box
DBChoice="fields
forms
procedures
permanent
folder
level
autosave
fileglobals
filevariables
fieldtypes
records
selected
changes"
superchoicedialog DBChoice,vAnswer1,“caption="What Info Would You Like?"
captionheight=1”


vClipHold=dbinfo(vAnswer1,"")
bigmessage "Your clipboard now has the name(s) of "+str(vAnswer1)+"(s)"+¶+
"Preview: "+¶+str(vClipHold)
Clipboard()=vClipHold

___ ENDPROCEDURE GetDBInfo _____________________________________________________
